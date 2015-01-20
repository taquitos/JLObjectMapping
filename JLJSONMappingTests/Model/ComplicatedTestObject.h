//
//  ComplicatedTestObject.h
//  JLJSONMapping
//
//  Created by Joshua Liebowitz on 6/8/13.
//  Copyright (c) 2013 Joshua Liebowitz. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SimpleTestObject;

@interface ComplicatedTestObject : NSObject

@property (nonatomic) SimpleTestObject *simpleTestObject;
@property (nonatomic) NSArray *arrayOfSimpleTestObjects;
@property (nonatomic) NSSet *setOfSimpleTestObjects;
@property (nonatomic) NSDictionary *dictionaryOfSimpleTestObjects;

+ (ComplicatedTestObject *)newComplicatedTestObject;

- (SimpleTestObject *)simpleObjectWithIntegerValue:(NSInteger)value;

@end
