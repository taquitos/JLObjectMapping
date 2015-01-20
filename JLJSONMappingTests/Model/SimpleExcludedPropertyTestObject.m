//
//  SimpleExcludedPropertyTestObject.m
//  JLJSONMapping
//
//  Created by Joshua Liebowitz on 1/14/15.
//  Copyright (c) 2015 Joshua Liebowitz. All rights reserved.
//

#import "SimpleExcludedPropertyTestObject.h"

@implementation SimpleExcludedPropertyTestObject

+ (NSArray *)jl_excludedFromSerialization
{
    return @[@"somethingToExclude", @"someInt"];//someInt is from super class
}

@end
