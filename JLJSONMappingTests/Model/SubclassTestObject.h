//
//  SubclassTestObject.h
//  JLJSONMapping
//
//  Created by Joshua Liebowitz on 1/18/15.
//  Copyright (c) 2015 Joshua Liebowitz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SimpleTestObject.h"

@interface SubclassTestObject : SimpleTestObject

@property (nonatomic, copy) NSString *aString;
@property (nonatomic) NSNumber *aNumber;

@end
