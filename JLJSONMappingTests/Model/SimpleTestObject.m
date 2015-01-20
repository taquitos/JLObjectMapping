//
//  SimpleTestObject.m
//  JLJSONMapping
//
//  Created by Joshua Liebowitz on 6/8/13.
//  Copyright (c) 2013 Joshua Liebowitz. All rights reserved.
//

#import "SimpleTestObject.h"

@implementation SimpleTestObject

+ (SimpleTestObject *)newSimpleTestObjectMaxValues
{
    SimpleTestObject *testObject = [[SimpleTestObject alloc] init];
    testObject.boolean = YES;
    testObject.cgfloat = CGFLOAT_MAX-1.0;
    testObject.date = [NSDate dateWithTimeIntervalSince1970:1234567890.012];
    testObject.integer = NSIntegerMax-1;
    testObject.number = [[NSNumber alloc] initWithLongLong:LONG_LONG_MAX-1];
    testObject.pBoolean = true;
    testObject.pChar = '*';
    testObject.pDouble = DBL_MAX-1;
    testObject.pFloat = FLT_MAX-1;
    testObject.pInt16 = INT16_MAX-1;
    testObject.pInt32 = INT32_MAX-1;
    testObject.pInt64 = INT64_MAX-1;
    testObject.pInt = INT_MAX-1;
    testObject.pLong = LONG_MAX-1;
    testObject.pLongLong = LONG_LONG_MAX-1;
    testObject.pShort = SHRT_MAX-1;
    testObject.pUnsignedChar = 254;
    testObject.pUnsignedInt = UINT_MAX-1;
    testObject.pUnsignedLong = ULONG_MAX - 1;
    testObject.pUnsignedLongLong = ULONG_LONG_MAX-1;
    testObject.pUnsignedShort = USHRT_MAX-1;
    testObject.string = @"hey there, I'm a test string, here have some unicode: Ω≈ç√∫˜µœ∑´®†¥¨ˆøπ“‘æ…¬˚∆˙©ƒ∂ßåΩ≈ç√∫˜µ≤≥÷™£¢∞§¶•ªº";
    testObject.uInteger = UINT_MAX-1;
    return testObject;
}

+ (SimpleTestObject *)newSimpleTestObjectSafeValues
{
    SimpleTestObject *testObject = [[SimpleTestObject alloc] init];
    testObject.boolean = YES;
    testObject.cgfloat = 22.1;
    testObject.date = [NSDate dateWithTimeIntervalSince1970:1234567890.012];
    testObject.integer = 32123;
    testObject.number = [[NSNumber alloc] initWithLongLong:432];
    testObject.pBoolean = true;
    testObject.pChar = '*';
    testObject.pDouble = 2123.23;
    testObject.pFloat = 2.3;
    testObject.pInt16 = 16;
    testObject.pInt32 = 32;
    testObject.pInt64 = 64;
    testObject.pInt = 321;
    testObject.pLong = 5432;
    testObject.pLongLong = 5432;
    testObject.pShort = 2;
    testObject.pUnsignedChar = 254;
    testObject.pUnsignedInt = 2223;
    testObject.pUnsignedLong = 64545;
    testObject.pUnsignedLongLong = 5443451;
    testObject.pUnsignedShort = 6;
    testObject.string = @"hey there, I'm a test string, here have some unicode: Ω≈ç√∫˜µœ∑´®†¥¨ˆøπ“‘æ…¬˚∆˙©ƒ∂ßåΩ≈ç√∫˜µ≤≥÷™£¢∞§¶•ªº";
    testObject.uInteger = 9238;
    return testObject;
}

- (NSUInteger)hash
{
    NSUInteger objectsHash = self.number ? [self.number hash] : 0;
    objectsHash ^= self.date ? [self.date hash] : 0;
    objectsHash ^= self.string ? [self.string hash] : 0;
    NSMutableString *primativeString = [[NSMutableString alloc]init];

    [primativeString appendString:[NSString stringWithFormat:@"%c", self.pBoolean]];
    [primativeString appendString:[NSString stringWithFormat:@"%c", self.pChar]];
    [primativeString appendString:[NSString stringWithFormat:@"%c", self.boolean]];
    [primativeString appendString:[NSString stringWithFormat:@"%f", self.pDouble]];
    [primativeString appendString:[NSString stringWithFormat:@"%f", self.pFloat]];
    [primativeString appendString:[NSString stringWithFormat:@"%i", self.pInt]];
    [primativeString appendString:[NSString stringWithFormat:@"%ld", self.pLong]];
    [primativeString appendString:[NSString stringWithFormat:@"%lld", self.pLongLong]];
    [primativeString appendString:[NSString stringWithFormat:@"%c", self.pShort]];
    [primativeString appendString:[NSString stringWithFormat:@"%c", self.pUnsignedChar]];
    [primativeString appendString:[NSString stringWithFormat:@"%c", self.pUnsignedInt]];
    [primativeString appendString:[NSString stringWithFormat:@"%lu", self.pUnsignedLong]];
    [primativeString appendString:[NSString stringWithFormat:@"%llu", self.pUnsignedLongLong]];
    [primativeString appendString:[NSString stringWithFormat:@"%i", self.pUnsignedShort]];
    [primativeString appendString:[NSString stringWithFormat:@"%hi", self.pInt16]];
    [primativeString appendString:[NSString stringWithFormat:@"%i", self.pInt32]];
    [primativeString appendString:[NSString stringWithFormat:@"%lld", self.pInt64]];
    [primativeString appendString:[NSString stringWithFormat:@"%f", self.cgfloat]];
    [primativeString appendString:[NSString stringWithFormat:@"%li", (long)self.integer]];
    [primativeString appendString:[NSString stringWithFormat:@"%li", (unsigned long)self.uInteger]];
    NSUInteger primativesHash = [primativeString hash];
    return primativesHash ^ objectsHash;
}

- (BOOL)isEqual:(id)obj
{
    if ([obj class] != [self class]) {
        return NO;
    }
    SimpleTestObject *object = (SimpleTestObject *)obj;
    BOOL theyEqual = YES;
    
    //Objects
    if (theyEqual && (self.number != object.number && ![(id)self.number isEqual:object.number])) {
        theyEqual = NO;
    }
    
    if (theyEqual && (self.date != object.date && ![(id)self.date isEqual:object.date])) {
        theyEqual = NO;
    }
    
    if (theyEqual && (self.string != object.string && ![self.string isEqualToString:object.string])) {
        theyEqual = NO;
    }
    
    //primatives    
    if (theyEqual && (self.pBoolean != object.pBoolean)) {
        theyEqual = NO;
    }
    
    if (theyEqual && (self.pChar != object.pChar)) {
        theyEqual = NO;
    }
    
    if (theyEqual && (self.boolean != object.boolean)) {
        theyEqual = NO;
    }
    
    if (theyEqual && (self.pDouble != object.pDouble)) {
        theyEqual = NO;
    }
    
    if (theyEqual && (self.pFloat != object.pFloat)) {
        theyEqual = NO;
    }
    
    if (theyEqual && (self.pInt != object.pInt)) {
        theyEqual = NO;
    }
    
    if (theyEqual && (self.pLong != object.pLong)) {
        theyEqual = NO;
    }
    
    if (theyEqual && (self.pLongLong != object.pLongLong)) {
        theyEqual = NO;
    }
    
    if (theyEqual && (self.pShort != object.pShort)) {
        theyEqual = NO;
    }
    
    if (theyEqual && (self.pUnsignedChar != object.pUnsignedChar)) {
        theyEqual = NO;
    }

    if (theyEqual && (self.pUnsignedInt != object.pUnsignedInt)) {
        theyEqual = NO;
    }
    
    if (theyEqual && (self.pUnsignedLong != object.pUnsignedLong)) {
        theyEqual = NO;
    }
    
    if (theyEqual && (self.pUnsignedLongLong != object.pUnsignedLongLong)) {
        theyEqual = NO;
    }
    
    if (theyEqual && (self.pUnsignedShort != object.pUnsignedShort)) {
        theyEqual = NO;
    }
    
    if (theyEqual && (self.pInt16 != object.pInt16)) {
        theyEqual = NO;
    }
    
    if (theyEqual && (self.pInt32 != object.pInt32)) {
        theyEqual = NO;
    }
    
    if (theyEqual && (self.pInt64 != object.pInt64)) {
        theyEqual = NO;
    }
    
    if (theyEqual && (self.cgfloat != object.cgfloat)) {
        theyEqual = NO;
    }
    
    if (theyEqual && (self.integer != object.integer)) {
        theyEqual = NO;
    }

    if (theyEqual && (self.uInteger != object.uInteger)) {
        theyEqual = NO;
    }
    
    return theyEqual;
}

+ (NSDateFormatter *)jl_dateFormatterForPropertyNamed:(NSString *)propertyName;
{
    //default date formatter
    static NSDateFormatter *df = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        df = [[NSDateFormatter alloc] init];
        df.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSS Z";
        NSLocale *locale = [NSLocale currentLocale];
        NSTimeZone *tz = [NSTimeZone timeZoneWithName:@"America/Los_Angeles"];
        df.timeZone = tz;
        df.locale = locale;
    });
    return df;
}

@end
