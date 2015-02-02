//
//  JLObjectSerializer.m
//  JLJSONMapping
//
//  Created by Joshua Liebowitz on 5/19/13.
//  Copyright (c) 2013 Joshua Liebowitz. All rights reserved.
//

#import <objc/runtime.h>
#import "JLObjectMapper.h"
#import "JLObjectMappingUtils.h"
#import "JLObjectSerializer.h"
#import "JLTimer.h"
#import "NSMutableArray+JLJSONMapping.h"
#import "NSObject+JLJSONMapping.h"

@interface JLObjectSerializer()

@property (nonatomic) JLSerializerOptions optionMask;
@property (nonatomic) NSSet *serializableClasses;
@property (nonatomic) NSCache *classPropertiesNameMap;

@end

@implementation JLObjectSerializer

- (id)initWithSerializerOptions:(JLSerializerOptions)options
{
    self = [super init];
    if (self) {
        _optionMask = options;
        _classPropertiesNameMap = [[NSCache alloc] init];
    }
    return self;
}

- (id)init
{
    return [self initWithSerializerOptions:JLSerializerOptionDefaultOptionsMask];
}

#pragma mark - API
- (NSString *)JSONStringWithObject:(NSObject *)object
{
    JLTimer *timer = [self timerForMethodNamed:@"JSONStringWithObject:"];
    id jsonObject = [self JSONObjectWithObject:object];
    NSString *jsonString;
    if (self.optionMask & JLSerializerOptionUseNSJSONSerializer) {
        //you probably don't want this...
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonObject options:0 error:&error];
        if (error) {
            NSLog(@"There was an error serializing your object:%@\n%@", error.localizedDescription, jsonObject);
        }
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    } else {
        jsonString = [self _JSONStringFromJSONObject:jsonObject];
    }
    if (timer) {
        [timer recordTime:[NSString stringWithFormat:@"finished %@", NSStringFromClass([object class])]];
    }
    if ([self isVerbose]) {
        [self logVerbose:[NSString stringWithFormat:@"Transcoded: %@ (type:%@) to:%@",object, NSStringFromClass([object class]), jsonString]];
    }
    return jsonString;
}

- (NSData *)dataWithObject:(NSObject *)object
{
    id jsonObject = [self JSONObjectWithObject:object];
    NSError *serializationError;
    NSData *data = [NSJSONSerialization dataWithJSONObject:jsonObject options:0 error:&serializationError];
    if (serializationError && [self isVerbose]) {
        [self logVerbose:[NSString stringWithFormat:@"There was an error serializing your object:%@\nType:%@ Description:%@", serializationError.localizedDescription, [object class], object]];
    }
    return data;
}

- (id)JSONObjectWithObject:(NSObject *)object
{
    JLTimer *timer = [self timerForMethodNamed:@"JSONObjectWithObject:"];
    id returnObject;
    if ([object isKindOfClass:[NSDictionary class]]) {
        returnObject = [self _dictionaryFromObjectDictionary:(NSDictionary*)object];
    } else if ([object isKindOfClass:[NSArray class]]) {
        returnObject = [self _arrayFromObjectArray:(NSArray*)object];
    } else if ([object isKindOfClass:[NSSet class]]) {
        returnObject = [self _arrayFromObjectSet:(NSSet*)object];
    } else if ([object class] == [NSDate class]) {
        NSDateFormatter *dateFormatter = [[object class] jl_dateFormatterForPropertyNamed:nil];
        returnObject = [dateFormatter stringFromDate:(NSDate *)object];
    } else if ([JLObjectMappingUtils isBasicType:object]) {
        //we have a simple object that can be trancoded by NSJSONSerialization so just return it
        returnObject = object;
    } else {
        returnObject = [self _dictionaryFromObject:object];
    }
    if (timer) {
        [timer recordTime:[NSString stringWithFormat:@"finished %@", NSStringFromClass([object class])]];
    }
    if ([self isVerbose]) {
        [self logVerbose:[NSString stringWithFormat:@"Transcoded: %@ (type:%@) to:%@",object, NSStringFromClass([object class]), returnObject]];
    }
    return returnObject;
}

- (NSString *)JSONEscapedStringFromObject:(NSObject *)object
{
    id jsonObject = [self JSONObjectWithObject:object];
    NSError *jsonError;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonObject options:0 error:&jsonError];
    if (jsonError && [self isVerbose]) {
        [self logVerbose:[NSString stringWithFormat:@"There was an error serializing your object:%@\nType:%@ Description:%@", jsonError.localizedDescription, [object class], object]];
    }
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return jsonString;
}

#pragma mark -
- (NSString *)_JSONStringFromJSONObject:(NSObject *)jsonObject
{
    NSString *jsonString;
    if ([JLObjectMappingUtils isBasicType:jsonObject]) {
        jsonString = [JLObjectMappingUtils stringForBasicType:jsonObject];
    } else if ([jsonObject isKindOfClass:[NSDictionary class]]) {
        NSMutableString *objectString = [[NSMutableString alloc] initWithString:@"{"];
        [(NSDictionary *)jsonObject enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            [objectString appendString:[NSString stringWithFormat:@"\"%@\":%@,", key, [self _JSONStringFromJSONObject:obj]]];
        }];
        NSRange range = {[objectString length]-1,1};
        [objectString deleteCharactersInRange:range];
        [objectString appendString:@"}"];
        jsonString = objectString;
    } else if ([jsonObject isKindOfClass:[NSArray class]]) {
        NSMutableString *objectString = [[NSMutableString alloc] initWithString:@"["];
        [(NSArray *)jsonObject enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [objectString appendString:[NSString stringWithFormat:@"%@,",[self _JSONStringFromJSONObject:obj]]];
        }];
        NSRange range = {[objectString length]-1,1};
        [objectString deleteCharactersInRange:range];
        [objectString appendString:@"]"];
        jsonString = objectString;
    } else if ([jsonObject isKindOfClass:[NSSet class]]) {
        NSMutableString *objectString = [[NSMutableString alloc] initWithString:@"["];
        [(NSSet *)jsonObject enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
            [objectString appendString:[NSString stringWithFormat:@"%@,",[self _JSONStringFromJSONObject:obj]]];
        }];
        NSRange range = {[objectString length]-1,1};
        [objectString deleteCharactersInRange:range];
        [objectString appendString:@"]"];
        jsonString = objectString;
    }
    return jsonString;
}

- (NSArray *)_arrayFromObjectArray:(NSArray *)array
{
    NSMutableArray *jsonArray = [NSMutableArray jl_newSparseArray:[array count]];
    [array enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDictionary *object = [self JSONObjectWithObject:obj];
        @synchronized(jsonArray) {
            jsonArray[idx] = object;
        }
    }];
    return jsonArray;
}

- (NSArray *)_arrayFromObjectSet:(NSSet *)set
{
    NSMutableArray *jsonArray = [[NSMutableArray alloc] initWithCapacity:[set count]];
    [set enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id obj, BOOL *stop) {
        id jsonObject = [self JSONObjectWithObject:obj];
        @synchronized(jsonArray) {
            [jsonArray addObject:jsonObject];
        }
    }];
    return jsonArray;
}

- (NSDictionary *)_dictionaryFromObjectDictionary:(NSDictionary *)dictionary
{
    NSMutableDictionary *jsonDictionary = [[NSMutableDictionary alloc] init];
    [dictionary enumerateKeysAndObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id key, id obj, BOOL *stop) {
        id object = [self JSONObjectWithObject:obj];
        @synchronized(jsonDictionary) {
            [jsonDictionary setObject:object forKey:key];
        }
    }];
    return jsonDictionary;
}

- (NSSet *)_loadPropertyMapForClass:(Class)class
{
    NSMutableSet *collectedProperties = [[NSMutableSet alloc] init];
    if ([class superclass] != [NSObject class]) {
        NSSet *superProperties = [self _loadPropertyMapForClass:[class superclass]];
        if (superProperties && [superProperties count]>0) {
            [superProperties enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
                [collectedProperties addObject:obj];
            }];
        }
    }
    
    unsigned count;
    objc_property_t *properties = class_copyPropertyList(class, &count);
    for (unsigned i = 0; i < count; i++) {
        NSString *propertyNameKey = [NSString stringWithUTF8String:property_getName(properties[i])];
        [collectedProperties addObject:propertyNameKey];
    }
    free(properties);
    // Remove excluded properties
    [[class jl_excludedFromSerialization] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [collectedProperties removeObject:obj];
    }];
    return collectedProperties;
}

- (NSDictionary *)_dictionaryFromObject:(NSObject *)obj
{
    if (!obj) {
        return nil;
    }
    NSString *currentClassName = NSStringFromClass([obj class]);
    NSSet *propertySet = [self.classPropertiesNameMap objectForKey:currentClassName];
    if (!propertySet) {
        propertySet = [self _loadPropertyMapForClass:[obj class]];
        [self.classPropertiesNameMap setObject:propertySet forKey:currentClassName];
        if ([self isVerbose]) {
            [self logVerbose:[NSString stringWithFormat:@"loaded properties from class:%@\n", currentClassName]];
        }
    } else {
        if ([self isVerbose]) {
            [self logVerbose:[NSString stringWithFormat:@"using cached properties from class:%@\n", currentClassName]];
        }
    }
    [obj jl_willSerialize];
    NSMutableDictionary *newJSONDictionary = [NSMutableDictionary dictionary];
    NSDictionary *propertyNameMap = [[obj class] jl_propertyNameMap];
    if (propertySet) {
        [propertySet enumerateObjectsUsingBlock:^(id propertyKey, BOOL *stop) {
            id propertyJSONValue = [obj valueForKey:propertyKey];
            if ([self isVerbose]) {
                [self logVerbose: [NSString stringWithFormat:@"key:%@ class: %@ value: %@\n", propertyKey, [propertyJSONValue class], propertyJSONValue]];
            }
            if (propertyJSONValue != nil) {
                if ([propertyJSONValue isKindOfClass:[NSArray class]]) {
                    propertyJSONValue = [self _arrayFromObjectArray:(NSArray*)propertyJSONValue];
                } else if ([propertyJSONValue isKindOfClass:[NSDictionary class]]) {
                    propertyJSONValue = [self _dictionaryFromObjectDictionary:(NSDictionary*)propertyJSONValue];
                } else if ([propertyJSONValue isKindOfClass:[NSSet class]]) {
                    propertyJSONValue = [self _arrayFromObjectSet:(NSSet*)propertyJSONValue];
                } else if ([propertyJSONValue isKindOfClass:[NSDate class]]) {
                    NSDateFormatter *df = [[obj class] jl_dateFormatterForPropertyNamed:propertyKey];
                    propertyJSONValue = [df stringFromDate:(NSDate*)propertyJSONValue];
                } else if (![JLObjectMappingUtils isBasicType:propertyJSONValue]) {
                    propertyJSONValue = [self _dictionaryFromObject:propertyJSONValue];
                }
                if (propertyJSONValue) {
                    NSString *jsonFieldName = [propertyNameMap objectForKey:propertyKey];
                    if (jsonFieldName) {
                        //if we have a property name to JSON field mapping, use it
                        propertyKey = jsonFieldName;
                    }
                    [newJSONDictionary setObject:propertyJSONValue forKey:propertyKey];
                }
            } else {
                if ([self isVerbose]) {
                    [self logVerbose:[NSString stringWithFormat:@"nil value for property:%@ on class:%@\n", propertyKey, currentClassName]];
                }
            }
        }];
    }
    return [NSDictionary dictionaryWithDictionary:newJSONDictionary];
}

#pragma mark - Serialization options
- (BOOL)isVerbose
{
    return (self.optionMask & JLSerializerOptionVerboseOutput) != NO;
}

- (BOOL)isReportTimers
{
    return (self.optionMask & JLSerializerOptionReportTimers) != NO;
}

@end
