//
//  SimpleExcludedPropertyTestObject.h
//  JLJSONMapping
//
//  Created by Joshua Liebowitz on 1/14/15.
//  Copyright (c) 2015 Joshua Liebowitz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AnotherSimpleTestObject.h"

@interface SimpleExcludedPropertyTestObject : AnotherSimpleTestObject

@property (nonatomic, copy) NSString *something;
@property (nonatomic, copy) NSString *somethingToExclude;

@end
