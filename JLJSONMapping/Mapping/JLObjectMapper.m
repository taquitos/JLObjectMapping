//
//  JLObjectMapper.m
//  JLJSONMapping
//
//  Convenience class, you can control the serializer/deserializer individually if you'd like.
//  Uses default options for the init
//
//  Created by Joshua Liebowitz on 5/19/13.
//  Copyright (c) 2013 Joshua Liebowitz. All rights reserved.
//

#import "JLObjectDeserializer.h"
#import "JLObjectMapper.h"
#import "JLObjectSerializer.h"

@interface JLObjectMapper()

@property(nonatomic) JLObjectSerializer *serializer;
@property(nonatomic) JLObjectDeserializer *deserializer;

@end

@implementation JLObjectMapper

- (id)init
{
    self = [super init];
    if (self) {
        _serializer = [[JLObjectSerializer alloc] init];
        _deserializer = [[JLObjectDeserializer alloc] init];
    }
    return self;
}

- (NSString *)JSONStringWithObject:(NSObject *)object
{
    return [self.serializer JSONStringWithObject:object];
}

- (id)JSONObjectWithObject:(NSObject *)object
{
    return [self.serializer JSONObjectWithObject:object];
}

- (id)objectWithJSONObject:(id)obj targetClass:(Class)class error:(NSError * __autoreleasing *)error
{
    return [self.deserializer objectWithJSONObject:obj targetClass:class error:error];
}

- (id)objectWithString:(NSString *)objectString targetClass:(Class)class error:(NSError * __autoreleasing *)error
{
    return [self.deserializer objectWithString:objectString targetClass:class error:error];
}

@end
