//
//  JLObjectDeserializer.h
//  JLJSONMapping
//
//  Created by Joshua Liebowitz on 7/20/13.
//  Copyright (c) 2013 Joshua Liebowitz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FABJLObjectMapper.h"
#import "FABJLTranscodingBase.h"

typedef NS_OPTIONS(NSInteger, FABJLDeserializerOptions) {
    FABJLDeserializerOptionIgnoreMissingProperties = 1 << 0,   //Ignore it when your json has more properties than your model, otherwise it will error
    FABJLDeserializerOptionErrorOnAmbiguousType = 1 << 1,      //Errors when property containing a collection doesn't implement jl_propertyTypeMap
    FABJLDeserializerOptionReportMissingProperties = 1 << 2,   //Log when JSON has more properties than your model
    FABJLDeserializerOptionReportNilProperties = 1 << 3,       //Log when JSON is missing a property that exists in your model
    FABJLDeserializerOptionReportTimers = 1 << 4,              //Public api has timers that will report how long they took on per invocation
    FABJLDeserializerOptionVerboseOutput = 1 << 5,             //Spew status and details about deserialization, great for debugging.
    FABJLDeserializerOptionDefaultOptionMask = FABJLDeserializerOptionIgnoreMissingProperties
};

@interface FABJLObjectDeserializer : FABJLTranscodingBase

@property (nonatomic, readonly) NSError *lastError;

- (id)initWithDeserializerOptions:(FABJLDeserializerOptions)options NS_DESIGNATED_INITIALIZER;
- (id)objectWithJSONObject:(id)obj targetClass:(Class)class error:(NSError * __autoreleasing *)error;
- (id)objectWithString:(NSString *)objectString targetClass:(Class)class error:(NSError * __autoreleasing *)error;
- (id)objectWithData:(NSData *)objectData targetClass:(Class)class error:(NSError * __autoreleasing *)error;

@end
