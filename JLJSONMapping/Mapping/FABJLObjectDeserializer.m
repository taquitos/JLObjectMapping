//
//  JLObjectDeserializer.m
//  JLJSONMapping
//
//  Created by Joshua Liebowitz on 7/20/13.
//  Copyright (c) 2013 Joshua Liebowitz. All rights reserved.
//

#import <objc/runtime.h>
#import "FABJLCategoryLoader.h"
#import "FABJLObjectDeserializer.h"
#import "FABJLObjectMappingUtils.h"
#import "FABJLTimer.h"
#import "NSError+JLJSONMapping.h"
#import "NSMutableArray+JLJSONMapping.h"
#import "NSObject+JLJSONMapping.h"

@interface FABJLObjectDeserializer ()

@property (nonatomic) FABJLDeserializerOptions optionMask;
@property (nonatomic, readwrite) NSError *lastError;
@property (nonatomic) NSCache *collectedPropertyCache;

@end

@implementation FABJLObjectDeserializer

- (id)initWithDeserializerOptions:(FABJLDeserializerOptions)options
{
    self = [super init];
    if (self) {
        _optionMask = options;
        _collectedPropertyCache = [[NSCache alloc] init];
        [FABJLCategoryLoader loadCategories];
    }
    return self;
}

- (id)init
{
    return [self initWithDeserializerOptions:FABJLDeserializerOptionDefaultOptionMask];
}

- (id)objectWithJSONObject:(id)obj targetClass:(Class)class error:(NSError * __autoreleasing *)error
{
    FABJLTimer *timer = [self timerForMethodNamed:@"objectWithJSONObject:targetClass:error:"];
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
    FABJLTimer *timer = [self timerForMethodNamed:@"objectWithString:targetClass:error"];
    self.lastError = nil;
    if (objectString == nil) {
        self.lastError = [NSError errorWithReason:FABJLDeserializationErrorInvalidJSON reasonText:@"JSON string is nil" description:nil];
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

- (id)objectWithData:(NSData *)objectData targetClass:(Class)class error:(NSError * __autoreleasing *)error
{
    FABJLTimer *timer = [self timerForMethodNamed:@"objectWithData:targetClass:error"];
    self.lastError = nil;
    if (objectData == nil) {
        self.lastError = [NSError errorWithReason:FABJLDeserializationErrorInvalidJSON reasonText:@"JSON data is nil" description:nil];
    }
    id object = (self.lastError == nil) ? [self _objectWithData:objectData targetClass:class] : nil;
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
    if (class == nil) {
        if ([self isVerbose]) {
            [self logVerbose:[NSString stringWithFormat:@"Got object: %@\n it's a Foundation object and we also got nil for the target class. Returning original object.", obj]];
        }
        return obj;
    }
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

- (id)_objectWithData:(NSData *)objectData targetClass:(Class)class
{
    NSError *error;
    //    disabled for https://github.com/taquitos/JLObjectMapping/issues/7 exceptions can cause memory leaks.
    //    id jsonObject;
    //    @try {
    //        jsonObject = [NSJSONSerialization JSONObjectWithData:[objectString dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
    //    } @catch (NSException *e) {
    //        NSString *exceptionData = [NSString stringWithFormat:@"name:%@, reason:%@", e.name, e.reason];
    //        self.lastError = [NSError errorWithReason:JLDeserializationErrorNSJSONException reasonText:@"NSJSONSerialization blew up" description:exceptionData];
    //        return nil;
    //    }
    id jsonObject = [NSJSONSerialization JSONObjectWithData:objectData options:0 error:&error];
    if (error) {
        self.lastError = [NSError errorWithReason:FABJLDeserializationErrorInvalidJSON reasonText:@"JSON string probably not properly formed well, or your number was too long (NSJSONSerialization doesn't support <type>_MAX values)" description:[NSString stringWithFormat:@"JSON String: %@", [[NSString alloc] initWithData:objectData encoding:NSUTF8StringEncoding]]];
        return nil;
    }
    return (class != nil) ? [self _objectWithJSONObject:jsonObject targetClass:class] : jsonObject;
}

- (id)_objectWithString:(NSString *)objectString targetClass:(Class)class
{
    NSData *data = [objectString dataUsingEncoding:NSUTF8StringEncoding];
    return [self _objectWithData:data targetClass:class];
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
        if (newObject) {
            @synchronized(objectArray) {
                objectArray[idx] = newObject;
            }
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
        self.lastError = [NSError errorWithReason:FABJLDeserializationErrorNoPropertiesInClass reasonText:@"Class has no properties, can't deserialize" description:[NSString stringWithFormat:@"Class %@ missing properties", class]];
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
        Class propertyType = [FABJLObjectMappingUtils classFromPropertyProperties:propertyProperties];
        if (!propertyType) {
            if ([FABJLObjectMappingUtils isValueType:propertyProperties]) {
                id propertyValue = [obj objectForKey:JSONpropertyNameKey];
                if (propertyValue && propertyValue != [NSNull null]) {
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
                if (object) {
                    @synchronized(newArray) {
                        newArray[idx] = object;
                    }
                }
            }];
        } else {
            if ((self.optionMask & FABJLDeserializerOptionErrorOnAmbiguousType) != NO) {
                self.lastError = [NSError errorWithReason:FABJLDeserializationErrorPropertyTypeMapNeeded reasonText:@"Ambiguous array of objects, missing propertyTypeMap for property" description:[NSString stringWithFormat:@"Property name:%@", objectPropertyName]];
                return;
            }
            [array enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id someObject, NSUInteger idx, BOOL *stop) {
                if (![FABJLObjectMappingUtils isBasicType:someObject]) {
                    if (self.optionMask & FABJLDeserializerOptionErrorOnAmbiguousType) {
                        self.lastError = [NSError errorWithReason:FABJLDeserializationErrorPropertyTypeMapNeeded reasonText:@"Ambiguous array of objects, missing propertyTypeMap for property" description:[NSString stringWithFormat:@"Property name:%@, parent object type:%@", objectPropertyName, [newObject class]]];
                        return;
                    }
                }
                if (someObject) {
                    @synchronized(newArray) {
                        newArray[idx] = someObject;
                    }
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
            if ((self.optionMask & FABJLDeserializerOptionErrorOnAmbiguousType) != NO) {
                self.lastError = [NSError errorWithReason:FABJLDeserializationErrorPropertyTypeMapNeeded reasonText:@"Ambiguous dictionary of objects, missing propertyTypeMap for property" description:[NSString stringWithFormat:@"Property name:%@", objectPropertyName]];
                return;
            }
            [dict enumerateKeysAndObjectsWithOptions:0 usingBlock:^(id key, id obj, BOOL *stop) {
                if ([FABJLObjectMappingUtils isBasicType:obj]) {
                    [newDictionary setObject:obj forKey:key];
                } else if (self.optionMask & FABJLDeserializerOptionErrorOnAmbiguousType) {
                    self.lastError = [NSError errorWithReason:FABJLDeserializationErrorPropertyTypeMapNeeded reasonText:@"Ambiguous dictionary of objects, missing propertyTypeMap for property" description:[NSString stringWithFormat:@"Property name:%@, parent object type:%@", objectPropertyName, [newObject class]]];
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
    if (propertyValue == [NSNull null] || propertyValue == nil) {
        return;
    }
    if ([propertyValue isKindOfClass:[NSArray class]]) {
        [self _transcodeArrayProperty:propertyValue objectPropertyName:objectPropertyName owningObject:newObject];
    } else if ([propertyValue isKindOfClass:[NSDictionary class]] && type) {
        [self _transcodeDictionaryProperty:propertyValue objectPropertyName:objectPropertyName dictionaryClass:type owningObject:newObject];
    } else if ([type isSubclassOfClass:[NSDate class]]) {
        NSDateFormatter *df = [[newObject class] jl_dateFormatterForPropertyNamed:objectPropertyName];
        [newObject setValue:[df dateFromString:propertyValue] forKey:objectPropertyName];
    } else if ([FABJLObjectMappingUtils isBasicType:propertyValue]) {
        [newObject setValue:propertyValue forKey:objectPropertyName];
    } else if (propertyValue) {
        [self _transcodeProperty:propertyValue objectPropertyName:objectPropertyName JSONpropertyName:JSONpropertyName propertyType:type owningObject:newObject];
    } else {
        if ((self.optionMask & FABJLDeserializerOptionReportNilProperties) != NO) {
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
    if ((self.optionMask & FABJLDeserializerOptionIgnoreMissingProperties) && !(self.optionMask & FABJLDeserializerOptionReportMissingProperties)) {
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
        if ((self.optionMask & FABJLDeserializerOptionReportMissingProperties) != NO) {
            NSLog(@"While deserializing, found JSON object representing a %@ contained extra field(s):%@\n full object graph:\n%@", class, extras, jsonObj);
        }
        if ((self.optionMask & FABJLDeserializerOptionIgnoreMissingProperties) == NO) {
            self.lastError = [NSError errorWithReason:FABJLDeserializationErrorMorePropertiesExpected reasonText:@"JSON to Object mismatch, JSON has extra fields" description:[NSString stringWithFormat:@"Class %@ missing properties: %@", class, extras]];
        }
    }
}

#pragma mark - Deserialization options
- (BOOL)isReportTimers
{
    return self.optionMask & FABJLDeserializerOptionReportTimers;
}

- (BOOL)isVerbose
{
    return self.optionMask & FABJLDeserializerOptionVerboseOutput;
}

@end
