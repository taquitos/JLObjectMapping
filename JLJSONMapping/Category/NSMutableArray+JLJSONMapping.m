//
//  NSMutableArray+JLJSONMapping.m
//  JLJSONMapping
//
//  Created by Joshua Liebowitz on 1/19/15.
//  Copyright (c) 2015 Joshua Liebowitz. All rights reserved.
//

#import "NSMutableArray+JLJSONMapping.h"

@implementation NSMutableArray (JLJSONMapping)

+ (NSMutableArray *)jl_newSparseArray:(NSUInteger)size
{
    NSMutableArray *newArray = [[NSMutableArray alloc] initWithCapacity:size];
    for (NSUInteger index = 0; index < size; index++) {
        [newArray addObject:[NSNull null]];
    }
    return newArray;
}

@end
