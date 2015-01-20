//
//  ArrayHoldingTestObject.h
//  JLJSONMapping
//
//  Created by Joshua Liebowitz on 1/18/15.
//  Copyright (c) 2015 Joshua Liebowitz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ArrayHoldingTestObject : NSObject

@property (nonatomic) NSArray *arrayOfSimpleTestObjects;

+ (instancetype)newArrayHoldingTestObject;

@end
