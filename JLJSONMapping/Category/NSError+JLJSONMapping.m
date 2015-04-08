//
//  NSError+JLJSONMapping.m
//  JLJSONMapping
//
//  Created by Joshua Liebowitz on 1/16/15.
//  Copyright (c) 2015 Joshua Liebowitz. All rights reserved.
//

#import "NSError+JLJSONMapping.h"

NSString * const kObjectMappingDomain = @"com.mydoghatestechnology.objectmapping";
NSString * const kObjectMappingDescriptionKey = @"JLObjectMappingDescriptionKey";
NSString * const kObjectMappingFailureReasonKey = @"JLObjectMappingDetailedFailureReasonKey";

@implementation NSError (JLJSONMapping)

void linkErrorCategory(){}

+ (NSError *)errorWithReason:(JLDeserializationError)reason reasonText:(NSString *)reasonText description:(NSString *)description
{
    NSMutableDictionary *infoDict = [[NSMutableDictionary alloc] init];
    if (reasonText) {
        [infoDict setObject:reasonText forKey:kObjectMappingFailureReasonKey];
    }
    if (description) {
        [infoDict setObject:description forKey:kObjectMappingDescriptionKey];
    }
    return [NSError errorWithDomain:kObjectMappingDomain code:reason userInfo:([infoDict count] > 0) ? infoDict : nil];
}

@end
