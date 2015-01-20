//
//  JLObjectDeserializer.m
//  JLJSONMapping
//
//  Created by Joshua Liebowitz on 7/20/13.
//  Copyright (c) 2013 Joshua Liebowitz. All rights reserved.
//

#import <objc/runtime.h>
#import "JLObjectDeserializer.h"
#import "JLObjectMappingUtils.h"
#import "JLTimer.h"
#import "NSError+JLJSONMapping.h"
#import "NSMutableArray+JLJSONMapping.h"
#import "NSObject+JLJSONMapping.h"

@interface JLObjectDeserializer ()

@property (nonatomic) JLDeserializerOptions optionMask;
@property (nonatomic, readwrite) NSError *lastError;
@property (nonatomic) NSCache *collectedPropertyCache;

@end

@implementation JLObjectDeserializer

- (id)initWithDeserializerOptions:(JLDeserializerOptions)options
{
    self = [super init];
    if (self) {
        _optionMask = options;
        _collectedPropertyCache = [[NSCache alloc] init];
    }
    return self;
}

- (id)init
{
    return [self initWithDeserializerOptions:JLDeserializerOptionDefaultOptionMask];
}

- (id)objectWithJSONObject:(id)obj targetClass:(Class)class error:(NSError * __autoreleasing *)error
{
    JLTimer *timer = [self timerForMethodNamed:@"objectWithJSONObject:targetClass:error:"];
    self.lastError = nil;
    id object = [self _objectWithJSONObject:obj targetClass:class];
    if (error != NULL) {
        *error = _lastError;
    }
    if ([self isReportTimers]) {
        [timer recordTime:[NSString stringWithFormat:@"Finished deserializing a: %@", NSStringFromClass(class)]];
    }
    return object;
}

- (id)objectWithString:(NSString *)objectString targetClass:(Class)class error:(NSError * __autoreleasing *)error
{
    JLTimer *timer = [self timerForMethodNamed:@"objectWithString:targetClass:error"];
    self.lastError = nil;
    if (objectString == nil) {
        //short circuit if nil, just set error and bail
        self.lastError = [NSError errorWithReason:JLDeserializationErrorInvalidJSON reasonText:@"JSON string probably not properly formed" description:[NSString stringWithFormat:@"JSON String: %@", objectString]];
    }
    id object = (self.lastError == nil) ? [self _objectWithString:objectString targetClass:class] : nil;
    if (error != NULL) {
        *error = _lastError;
    }
    if ([self isReportTimers]) {
        [timer recordTime:[NSString stringWithFormat:@"Finished initial json parsing, on to setting properties for any %@", NSStringFromClass(class)]];
    }
    return object;
}

- (id)_objectWithJSONObject:(id)obj targetClass:(Class)class
{
    if ([obj isKindOfClass:[NSDictionary class]]) {
        return [self _newObjectFromJSONDictionary:obj targetClass:class];
    } else if ([obj isKindOfClass:[NSArray class]]) {
        return [self _newArrayObjectFromJSONArray:obj targetClass:class];
    } else {
        if ([self isVerbose]) {
            [self logVerbose:[NSString stringWithFormat:@"Got object of type %@. That's not an NSArray or NSDictionary. Your code is bad and you should fix it. Returning nil for now, in the future this might cause a crash.", NSStringFromClass(class)]];
        }
    }
    return nil;
}

- (id)_objectWithString:(NSString *)objectString targetClass:(Class)class
{
    NSError *error;
    id jsonObject;
    @try {
        jsonObject = [NSJSONSerialization JSONObjectWithData:[objectString dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
    } @catch (NSException *e) {
        NSString *exceptionData = [NSString stringWithFormat:@"name:%@, reason:%@", e.name, e.reason];
        self.lastError = [NSError errorWithReason:JLDeserializationErrorNSJSONException reasonText:@"NSJSONSerialization blew up" description:exceptionData];
        return nil;
    }
    if (error) {
        self.lastError = [NSError errorWithReason:JLDeserializationErrorInvalidJSON reasonText:@"JSON string probably not properly formed well, or your number was too long (NSJSONSerialization doesn't support <type>_MAX values)" description:[NSString stringWithFormat:@"JSON String: %@", objectString]];
        return nil;
    }
    return [self _objectWithJSONObject:jsonObject targetClass:class];
}

#pragma mark - JSON to Object utility methods, the guts of the transcoding
- (id)_newArrayObjectFromJSONArray:(NSArray *)obj targetClass:(Class)class
{
    if ([self isVerbose]) {
        [self logVerbose:[NSString stringWithFormat:@"Transcoding:%@ to an array containing object of type:%@", obj, NSStringFromClass(class)]];
    }
    NSMutableArray *objectArray = [NSMutableArray jl_newSparseArray:[obj count]];
    [obj enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id object, NSUInteger idx, BOOL *stop) {
        id newObject = [self _objectWithJSONObject:object targetClass:class];
        @synchronized(objectArray) {
            objectArray[idx] = newObject;
        }
    }];
    return objectArray;
}

//Collects the properties of the super classes then collects the current class', overwriting any duplicates with subclassed versions
- (NSMutableDictionary *)_collectPropertiesOfClass:(Class)class
{
    unsigned count;
    NSMutableDictionary *collectedProperties = [[NSMutableDictionary alloc] init];
    objc_property_t *properties = class_copyPropertyList(class, &count);
    if ([class superclass] != [NSObject class]) {
        if ([self isVerbose]) {
            [self logVerbose:[NSString stringWithFormat:@"Super class:%@",[class superclass]]];
        }
        NSMutableDictionary *superProperties = [self _collectPropertiesOfClass:[class superclass]];
        if ([superProperties count] > 0) {
            [superProperties enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                [collectedProperties setObject:obj forKey:key];
            }];
        }
    }
    for (int i = 0; i < count; i++) {
        const char *propertyProperties = property_getAttributes(properties[i]);
        NSString *propertiesString = [NSString stringWithUTF8String:propertyProperties];
        NSString *propertyNameKey = [NSString stringWithUTF8String:property_getName(properties[i])];
        [collectedProperties setObject:propertiesString forKey:propertyNameKey];
    }
    free(properties);
    return collectedProperties;
}

- (id)_newObjectFromJSONDictionary:(NSDictionary *)obj targetClass:(Class)class
{
    if ([self isVerbose]) {
        [self logVerbose:[NSString stringWithFormat:@"Transcoding:%@ to type:%@", obj, NSStringFromClass(class)]];
    }
    id newObject = [[class alloc] init];
    NSDictionary *collectedProperties = [self.collectedPropertyCache objectForKey:class];
    if (collectedProperties == nil) {
        @synchronized (class) {
            collectedProperties = [self.collectedPropertyCache objectForKey:class];
            if (!collectedProperties) {
                collectedProperties = [self _collectPropertiesOfClass:class];
                [self.collectedPropertyCache setObject:collectedProperties forKey:class];
            }
        }
    }
    if ([collectedProperties count] == 0 && obj) {
        //I shouldn't have gotten here, maybe passing in NSDate will do it?
        self.lastError = [NSError errorWithReason:JLDeserializationErrorNoPropertiesInClass reasonText:@"Class has no properties, can't deserialize" description:[NSString stringWithFormat:@"Class %@ missing properties", class]];
        return nil;
    }

    if ([collectedProperties count] > 0 && obj) {
        [self _reportExtraJSONFields:obj classProperties:collectedProperties targetClass:class];
    }
    NSDictionary *propertyNameMap = [class jl_propertyNameMap];
    [collectedProperties enumerateKeysAndObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id key, id value, BOOL *stop) {
        NSString *propertyProperties = value;
        NSString *JSONpropertyNameKey = [propertyNameMap objectForKey:key];
        NSString *objectPropertyName = key;
        //if we have no overrides, just assume JSON field names match property names
        if (!JSONpropertyNameKey) {
            JSONpropertyNameKey = key;
        }
        Class propertyType = [JLObjectMappingUtils classFromPropertyProperties:propertyProperties];
        if (!propertyType) {
            if ([JLObjectMappingUtils isValueType:propertyProperties]) {
                id propertyValue = [obj objectForKey:JSONpropertyNameKey];
                if (propertyValue) {
                    [newObject setValue:propertyValue forKey:objectPropertyName];
                }
            }
        } else {
            [self _transcodeProperty:obj objectPropertyName:objectPropertyName JSONpropertyName:JSONpropertyNameKey propertyType:propertyType owningObject:newObject];
        }
    }];
    [newObject jl_didDeserialize:obj];
    return newObject;
}

#pragma mark - Object transcoding methods
- (void)_transcodeArrayProperty:(NSArray *)array objectPropertyName:(NSString *)objectPropertyName owningObject:(id)newObject
{
    if ([array count] > 0) {
        NSDictionary *propertyMappings = [[newObject class] jl_propertyTypeMap];
        NSMutableArray *newArray = [NSMutableArray jl_newSparseArray:[array count]];
        [newObject setValue:newArray forKey:objectPropertyName];
        Class arrayObjectType = [propertyMappings objectForKey:objectPropertyName];
        if ([self isVerbose]) {
            [self logVerbose:[NSString stringWithFormat:@"Transcoding an array of type:%@ stored in property:%@ owned by:%@ which is of type type:%@", NSStringFromClass(arrayObjectType), objectPropertyName, newObject, NSStringFromClass([newObject class])]];
        }
        if (arrayObjectType) {
            [array enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id someObject, NSUInteger idx, BOOL *stop) {
                id object = [self _objectWithJSONObject:someObject targetClass:arrayObjectType];
                @synchronized(newArray) {
                    newArray[idx] = object;
                }
            }];
        } else {
            if ((self.optionMask & JLDeserializerOptionErrorOnAmbiguousType) != NO) {
                self.lastError = [NSError errorWithReason:JLDeserializationErrorPropertyTypeMapNeeded reasonText:@"Ambiguous array of objects, missing propertyTypeMap for property" description:[NSString stringWithFormat:@"Property name:%@", objectPropertyName]];
                return;
            }
            [array enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id someObject, NSUInteger idx, BOOL *stop) {
                if (![JLObjectMappingUtils isBasicType:someObject]) {
                    if (self.optionMask & JLDeserializerOptionErrorOnAmbiguousType) {
                        self.lastError = [NSError errorWithReason:JLDeserializationErrorPropertyTypeMapNeeded reasonText:@"Ambiguous array of objects, missing propertyTypeMap for property" description:[NSString stringWithFormat:@"Property name:%@, parent object type:%@", objectPropertyName, [newObject class]]];
                        return;
                    }
                }
                @synchronized(newArray) {
                    newArray[idx] = someObject;
                }
            }];
        }
    }
}

//Transcode a dictionary, either a JSON dictionary (appropriate for NSJSONSerialization) or a dictionary that contains model objects.
- (void)_transcodeDictionaryProperty:(NSDictionary *)dict objectPropertyName:(NSString *)objectPropertyName dictionaryClass:(Class)type owningObject:(id)newObject
{
    if ([self isVerbose]) {
        [self logVerbose:[NSString stringWithFormat:@"Transcoding a dictionary where the values are of type:%@ stored in property:%@ owned by:%@ which is of type type:%@", type, objectPropertyName, newObject, NSStringFromClass([newObject class])]];
    }
    if (![type isSubclassOfClass:[NSDictionary class]]) {
        id someObject = [self _objectWithJSONObject:dict targetClass:type];
        [newObject setValue:someObject forKey:objectPropertyName];
    } else if ([dict count] > 0) {
        NSDictionary *propertyMappings = [[newObject class] jl_propertyTypeMap];
        NSMutableDictionary *newDictionary = [[NSMutableDictionary alloc] initWithCapacity:[dict count]];
        [newObject setValue:newDictionary forKey:objectPropertyName];
        Class dictionaryObjectType = [propertyMappings objectForKey:objectPropertyName];
        if (!dictionaryObjectType) {
            //we've gone down the tree to the leaves and transcoded. Now just set objects.
            if ((self.optionMask & JLDeserializerOptionErrorOnAmbiguousType) != NO) {
                self.lastError = [NSError errorWithReason:JLDeserializationErrorPropertyTypeMapNeeded reasonText:@"Ambiguous dictionary of objects, missing propertyTypeMap for property" description:[NSString stringWithFormat:@"Property name:%@", objectPropertyName]];
                return;
            }
            dictionaryObjectType = type;
            [dict enumerateKeysAndObjectsWithOptions:0 usingBlock:^(id key, id obj, BOOL *stop) {
                if ([JLObjectMappingUtils isBasicType:obj]) {
                    [newDictionary setObject:obj forKey:key];
                } else if (self.optionMask & JLDeserializerOptionErrorOnAmbiguousType) {
                    self.lastError = [NSError errorWithReason:JLDeserializationErrorPropertyTypeMapNeeded reasonText:@"Ambiguous dictionary of objects, missing propertyTypeMap for property" description:[NSString stringWithFormat:@"Property name:%@, parent object type:%@", objectPropertyName, [newObject class]]];
                    *stop = YES;
                }
            }];
        } else {
            [dict enumerateKeysAndObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id key, id obj, BOOL *stop) {
                id object = [self _objectWithJSONObject:obj targetClass:dictionaryObjectType];
                [newDictionary setObject:object forKey:key];
            }];
        }
    }
}

/*
 Given a property name, the type it should be, and the parent who owns this property, it will transcode your jsonObject (array, or dictionary representation) into the expected property value
 */
- (void)_transcodeProperty:(id)jsonObject objectPropertyName:(NSString *)objectPropertyName JSONpropertyName:(NSString *)JSONpropertyName propertyType:(Class)type owningObject:(id)newObject
{
    id propertyValue = [jsonObject objectForKey:JSONpropertyName];
    if ([propertyValue isKindOfClass:[NSNull class]] || propertyValue == nil) {
        [newObject setValue:nil forKey:objectPropertyName];
        return;
    }
    
    if ([propertyValue isKindOfClass:[NSArray class]]) {
        [self _transcodeArrayProperty:propertyValue objectPropertyName:objectPropertyName owningObject:newObject];
    } else if ([propertyValue isKindOfClass:[NSDictionary class]] && type) {
        [self _transcodeDictionaryProperty:propertyValue objectPropertyName:objectPropertyName dictionaryClass:type owningObject:newObject];
    } else if ([type isSubclassOfClass:[NSDate class]]) {
        NSDateFormatter *df = [[newObject class] jl_dateFormatterForPropertyNamed:objectPropertyName];
        [newObject setValue:[df dateFromString:propertyValue] forKey:objectPropertyName];
    } else if ([JLObjectMappingUtils isBasicType:propertyValue]) {
        [newObject setValue:propertyValue forKey:objectPropertyName];
    } else if (propertyValue) {
        [self _transcodeProperty:propertyValue objectPropertyName:objectPropertyName JSONpropertyName:JSONpropertyName propertyType:type owningObject:newObject];
    } else {
        if ((self.optionMask & JLDeserializerOptionReportNilProperties) != NO) {
            NSLog(@"Expected value for property %@ of type %@ had no matching property %@ in the JSON", objectPropertyName, JSONpropertyName, type);
        }
    }
}

#pragma mark - Reporting/Logging/Other options

/*
 If your JSON has more fields in it than you were expecting, this will report the extras.
 */
- (void)_reportExtraJSONFields:(id)jsonObj classProperties:(NSDictionary *)collectedProperties targetClass:(Class)class
{
    if ((self.optionMask & JLDeserializerOptionIgnoreMissingProperties) && !(self.optionMask & JLDeserializerOptionReportMissingProperties)) {
        //short circuit out of here, usually production cases (ignoring missing properties and don't want to report anything)
        return;
    }
    NSDictionary *extraMappings = [class jl_propertyTypeMap];
    NSMutableSet *jsonProperties;
    if (![jsonObj isKindOfClass:[NSDictionary class]]) {
        if ([self isVerbose]) {
            [self logVerbose:@"jsonObj isn't a dictionary, can't report extra data from json"];
        }
        return;
    }
    jsonProperties = [[NSMutableSet alloc] init];
    [collectedProperties enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [jsonProperties addObject:key];
    }];
    NSMutableArray *extras = [[NSMutableArray alloc] init];
    //TODO: account for duplicates, as in, data that shows up for a given property as well as the same property but from the mapped property in extraMappings
    [(NSDictionary *)jsonObj enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if (![jsonProperties containsObject:key]) {
            if (![extraMappings objectForKey:key]) {
                [extras addObject:key];
            }
        }
    }];
    if ([extras count] > 0) {
        if ((self.optionMask & JLDeserializerOptionReportMissingProperties) != NO) {
            NSLog(@"JSON object representing a %@ contained extra field(s):%@\n full object graph:\n%@", class, extras, jsonObj);
        }
        if ((self.optionMask & JLDeserializerOptionIgnoreMissingProperties) == NO) {
            self.lastError = [NSError errorWithReason:JLDeserializationErrorMorePropertiesExpected reasonText:@"JSON to Object mismatch, JSON has extra fields" description:[NSString stringWithFormat:@"Class %@ missing properties: %@", class, extras]];
        }
    }
}

#pragma mark - Deserialization options
- (BOOL)isReportTimers
{
    return self.optionMask & JLDeserializerOptionReportTimers;
}

- (BOOL)isVerbose
{
    return self.optionMask & JLDeserializerOptionVerboseOutput;
}

@end
