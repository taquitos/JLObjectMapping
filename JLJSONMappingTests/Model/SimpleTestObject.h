//
//  SimpleTestObject.h
//  JLJSONMapping
//
//  Created by Joshua Liebowitz on 6/8/13.
//  Copyright (c) 2013 Joshua Liebowitz. All rights reserved.
//

#import <CoreGraphics/CoreGraphics.h>
#import <Foundation/Foundation.h>

@interface SimpleTestObject : NSObject
//get many 'primative' types in here.
// from https://developer.apple.com/library/mac/documentation/cocoa/Conceptual/KeyValueCoding/KeyValueCoding.pdf
//BOOL
//char
//double
//float
//int
//long
//long long
//short
//unsigned char
//unsigned int
//unsigned long
//unsigned long long
//unsigned short

@property (nonatomic) bool pBoolean;
@property (nonatomic) char pChar;
@property (nonatomic) BOOL boolean;
@property (nonatomic) double pDouble;
@property (nonatomic) float pFloat;
@property (nonatomic) int pInt;
@property (nonatomic) long pLong;
@property (nonatomic) long long pLongLong;
@property (nonatomic) short pShort;
@property (nonatomic) unsigned char pUnsignedChar;
@property (nonatomic) unsigned int pUnsignedInt;
@property (nonatomic) unsigned long pUnsignedLong;
@property (nonatomic) unsigned long long pUnsignedLongLong;
@property (nonatomic) unsigned short pUnsignedShort;

@property (nonatomic) int16_t pInt16;
@property (nonatomic) int32_t pInt32;
@property (nonatomic) int64_t pInt64;
@property (nonatomic) CGFloat cgfloat;
@property (nonatomic) NSInteger integer;
@property (nonatomic) NSUInteger uInteger;
@property (nonatomic) NSNumber *number;
@property (nonatomic) NSDate *date;
@property (nonatomic, copy) NSString *string;


//this is used after deserialization and will contain the serialzed version of this object
//don't set anything in it.
@property (nonatomic, copy) NSString *deserializedResult;

+ (SimpleTestObject *)newSimpleTestObjectMaxValues;
+ (SimpleTestObject *)newSimpleTestObjectSafeValues;

@end
