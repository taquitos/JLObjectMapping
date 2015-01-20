//
//  SenTestCase+Util.m
//  JLJSONMapping
//
//  Created by Joshua Liebowitz on 1/13/15.
//  Copyright (c) 2015 Joshua Liebowitz. All rights reserved.
//

#import "XCTestCase+Util.h"

@implementation XCTestCase (Util)

+ (BOOL)is64Bit
{
#if __LP64__ || (TARGET_OS_EMBEDDED && !TARGET_OS_IPHONE) || NS_BUILD_32_LIKE_64
    return YES;
#else
    return NO;
#endif
}

@end
