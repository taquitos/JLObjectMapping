//
//  EnumerationContainingTestObject.h
//  JLJSONMapping
//
//  Created by Joshua Liebowitz on 1/19/15.
//  Copyright (c) 2015 Joshua Liebowitz. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, MyEnum) {
    MyEnumAValue = 1,
    MyEnumSecondValue,
    MyEnumThirdValue
};

typedef NS_OPTIONS(NSUInteger, MyOption) {
    MyOptionAValue = 1 << 0,
    MyOptionSecondValue,
    MyOptionThirdValue
};

@interface EnumerationContainingTestObject : NSObject

@property (nonatomic) MyEnum enumValue;
@property (nonatomic) MyOption optionValue;

@end
