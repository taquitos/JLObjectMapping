//
//  JLObjectSerializer.h
//  JLJSONMapping
//
//  Created by Joshua Liebowitz on 5/19/13.
//  Copyright (c) 2013 Joshua Liebowitz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JLObjectMapper.h"
#import "JLTranscodingBase.h"

typedef NS_OPTIONS(NSInteger, JLSerializerOptions) {
    JLSerializerOptionVerboseOutput = 1 << 0,           //Spew status and details about deserialization, great for debugging.
    JLSerializerOptionReportTimers = 1 << 1,            //Public api has timers that will report how long they took on per invocation
    JLSerializerOptionUseNSJSONSerializer = 1 << 2,     //instead of using custom serializer (faster) use NSJSONSerializer (safe for html content and other things NSJSONSerialization would escape for you inside json)
    JLSerializerOptionDefaultOptionsMask = 0x0
};

@interface JLObjectSerializer : JLTranscodingBase

- (id)initWithSerializerOptions:(JLSerializerOptions)options NS_DESIGNATED_INITIALIZER;
- (id)JSONObjectWithObject:(NSObject *)object;
- (NSData *)dataWithObject:(NSObject *)object;
- (NSString *)JSONStringWithObject:(NSObject *)object;

/*
 Produces a string of JSON that has it's values escaped (like urls). It's just a convenience method for NSJSONSerialization
 */
- (NSString *)JSONEscapedStringFromObject:(NSObject *)object;

@end
