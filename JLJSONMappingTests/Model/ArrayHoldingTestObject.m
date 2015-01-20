//
//  ArrayHoldingTestObject.m
//  JLJSONMapping
//
//  Created by Joshua Liebowitz on 1/18/15.
//  Copyright (c) 2015 Joshua Liebowitz. All rights reserved.
//

#import "ArrayHoldingTestObject.h"
#import "NSObject+JLJSONMapping.h"
#import "SimpleTestObject.h"

@implementation ArrayHoldingTestObject

+ (instancetype)newArrayHoldingTestObject
{
    ArrayHoldingTestObject *object = [[ArrayHoldingTestObject alloc] init];
    SimpleTestObject *simpleObject = [[SimpleTestObject alloc] init];
    simpleObject.boolean = YES;
    simpleObject.date = [NSDate dateWithTimeIntervalSince1970:1234567890.012];
    simpleObject.pBoolean = true;
    simpleObject.pChar = '*';
    simpleObject.pInt16 = INT16_MAX-1;
    simpleObject.pShort = SHRT_MAX-1;
    simpleObject.pUnsignedChar = 254;
    simpleObject.pUnsignedShort = USHRT_MAX-1;
    simpleObject.string = @"hey there, I'm a test string, here have some unicode: Ω≈ç√∫˜µœ∑´®†¥¨ˆøπ“‘æ…¬˚∆˙©ƒ∂ßåΩ≈ç√∫˜µ≤≥÷™£¢∞§¶•ªº";
    object.arrayOfSimpleTestObjects = @[simpleObject, simpleObject, simpleObject];
    return object;
}

+ (NSDictionary *)jl_propertyTypeMap
{
    return @{@"arrayOfSimpleTestObjects": [SimpleTestObject class]};
}

@end
