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

#import "FABJLObjectDeserializer.h"
#import "FABJLObjectMapper.h"
#import "FABJLObjectSerializer.h"

@interface FABJLObjectMapper()

@property(nonatomic) FABJLObjectSerializer *serializer;
@property(nonatomic) FABJLObjectDeserializer *deserializer;

@end

@implementation FABJLObjectMapper

- (id)init
{
    self = [super init];
    if (self) {
        _serializer = [[FABJLObjectSerializer alloc] init];
        _deserializer = [[FABJLObjectDeserializer alloc] init];
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

- (NSData *)dataWithObject:(NSObject *)object
{
    return [self.serializer dataWithObject:object];
}

- (id)objectWithJSONObject:(id)obj targetClass:(Class)class error:(NSError * __autoreleasing *)error
{
    return [self.deserializer objectWithJSONObject:obj targetClass:class error:error];
}

- (id)objectWithString:(NSString *)objectString targetClass:(Class)class error:(NSError * __autoreleasing *)error
{
    return [self.deserializer objectWithString:objectString targetClass:class error:error];
}

- (id)objectWithData:(NSData *)objectData targetClass:(Class)class error:(NSError * __autoreleasing *)error
{
    return [self.deserializer objectWithData:objectData targetClass:class error:error];
}

@end
