//
//  NSMutableArray+JLJSONMapping.h
//  JLJSONMapping
//
//  Created by Joshua Liebowitz on 1/19/15.
//  Copyright (c) 2015 Joshua Liebowitz. All rights reserved.
//

#import <Foundation/Foundation.h>

void linkMutableArrayCategory(void);

@interface NSMutableArray (JLJSONMapping)

+ (NSMutableArray *)jl_newSparseArray:(NSUInteger)size;

@end
