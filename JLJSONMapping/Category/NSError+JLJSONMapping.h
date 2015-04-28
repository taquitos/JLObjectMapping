//
//  NSError+JLJSONMapping.h
//  JLJSONMapping
//
//  Created by Joshua Liebowitz on 1/16/15.
//  Copyright (c) 2015 Joshua Liebowitz. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT NSString * const kFABObjectMappingDomain;
FOUNDATION_EXPORT NSString * const kFABObjectMappingDescriptionKey;
FOUNDATION_EXPORT NSString * const kFABObjectMappingFailureReasonKey;

typedef NS_ENUM(NSInteger, FABJLDeserializationError) {
    FABJLDeserializationErrorInvalidJSON,              //Malformed JSON or other general NSJSONSerialization Error
    FABJLDeserializationErrorNoPropertiesInClass,      //Couldn't find any properties on Object
    FABJLDeserializationErrorPropertyTypeMapNeeded,    //Object has Array/Dict as property but missing definition of jl_propertyTypeMap
    FABJLDeserializationErrorMorePropertiesExpected    //JSON to Object mismatch, JSON has extra fields (not a show stopping error for deserializer)
};

void linkFABErrorCategory();

@interface NSError (FABJLJSONMapping)

+ (NSError *)errorWithReason:(FABJLDeserializationError)reason reasonText:(NSString *)reasonText description:(NSString *)description;

@end
