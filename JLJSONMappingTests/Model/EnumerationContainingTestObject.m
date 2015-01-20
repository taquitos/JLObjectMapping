//
//  EnumerationContainingTestObject.m
//  JLJSONMapping
//
//  Created by Joshua Liebowitz on 1/19/15.
//  Copyright (c) 2015 Joshua Liebowitz. All rights reserved.
//

#import "EnumerationContainingTestObject.h"

@implementation EnumerationContainingTestObject

- (BOOL)isEqual:(id)object
{
    if ([self class] != [object class]) {
        return NO;
    }
    EnumerationContainingTestObject *incoming = object;
    if (self.enumValue != incoming.enumValue) {
        return NO;
    }
    if (self.optionValue != incoming.optionValue) {
        return NO;
    }
    return YES;
}

@end
