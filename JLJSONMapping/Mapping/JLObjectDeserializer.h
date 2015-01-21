//
//  JLObjectDeserializer.h
//  JLJSONMapping
//
//  Created by Joshua Liebowitz on 7/20/13.
//  Copyright (c) 2013 Joshua Liebowitz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JLObjectMapper.h"
#import "JLTranscodingBase.h"

typedef NS_OPTIONS(NSInteger, JLDeserializerOptions) {
    JLDeserializerOptionIgnoreMissingProperties = 1 << 0,   //Ignore it when your json has more properties than your model, otherwise it will error
    JLDeserializerOptionErrorOnAmbiguousType = 1 << 1,      //Errors when property containing a collection doesn't implement jl_propertyTypeMap
    JLDeserializerOptionReportMissingProperties = 1 << 2,   //Log when JSON has more properties than your model
    JLDeserializerOptionReportNilProperties = 1 << 3,       //Log when JSON is missing a property that exists in your model
    JLDeserializerOptionReportTimers = 1 << 4,              //Public api has timers that will report how long they took on per invocation
    JLDeserializerOptionVerboseOutput = 1 << 5,             //Spew status and details about deserialization, great for debugging.
    JLDeserializerOptionDefaultOptionMask = JLDeserializerOptionIgnoreMissingProperties
};

@interface JLObjectDeserializer : JLTranscodingBase

@property (nonatomic, readonly) NSError *lastError;

- (id)initWithDeserializerOptions:(JLDeserializerOptions)options NS_DESIGNATED_INITIALIZER;
- (id)objectWithJSONObject:(id)obj targetClass:(Class)class error:(NSError * __autoreleasing *)error;
- (id)objectWithString:(NSString *)objectString targetClass:(Class)class error:(NSError * __autoreleasing *)error;
- (id)objectWithData:(NSData *)objectData targetClass:(Class)class error:(NSError * __autoreleasing *)error;

@end
