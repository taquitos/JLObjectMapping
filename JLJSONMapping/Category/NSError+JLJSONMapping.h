//
//  NSError+JLJSONMapping.h
//  JLJSONMapping
//
//  Created by Joshua Liebowitz on 1/16/15.
//  Copyright (c) 2015 Joshua Liebowitz. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT NSString * const kObjectMappingDomain;
FOUNDATION_EXPORT NSString * const kObjectMappingDescriptionKey;
FOUNDATION_EXPORT NSString * const kObjectMappingFailureReasonKey;

typedef NS_ENUM(NSInteger, JLDeserializationError) {
    JLDeserializationErrorInvalidJSON,              //Malformed JSON or other general NSJSONSerialization Error
    JLDeserializationErrorNoPropertiesInClass,      //Couldn't find any properties on Object
    JLDeserializationErrorPropertyTypeMapNeeded,    //Object has Array/Dict as property but missing definition of jl_propertyTypeMap
    JLDeserializationErrorMorePropertiesExpected    //JSON to Object mismatch, JSON has extra fields (not a show stopping error for deserializer)
};

@interface NSError (JLJSONMapping)

+ (NSError *)errorWithReason:(JLDeserializationError)reason reasonText:(NSString *)reasonText description:(NSString *)description;

@end
