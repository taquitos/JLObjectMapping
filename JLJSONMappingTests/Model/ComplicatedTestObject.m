//
//  ComplicatedTestObject.m
//  JLJSONMapping
//
//  Created by Joshua Liebowitz on 6/8/13.
//  Copyright (c) 2013 Joshua Liebowitz. All rights reserved.
//

#import "ComplicatedTestObject.h"
#import "NSObject+JLJSONMapping.h"
#import "SimpleTestObject.h"

@implementation ComplicatedTestObject

+ (ComplicatedTestObject *)newComplicatedTestObject
{
    ComplicatedTestObject *object = [[ComplicatedTestObject alloc] init];
    object.simpleTestObject = [SimpleTestObject newSimpleTestObjectSafeValues];
    
    object.arrayOfSimpleTestObjects = @[[object simpleObjectWithIntegerValue:0],
                                        [object simpleObjectWithIntegerValue:1],
                                        [object simpleObjectWithIntegerValue:2],
                                        [object simpleObjectWithIntegerValue:3],
                                        [object simpleObjectWithIntegerValue:4],
                                        [object simpleObjectWithIntegerValue:5]];
    
    object.setOfSimpleTestObjects = [NSSet setWithArray: @[[object simpleObjectWithIntegerValue:10],
                                                           [object simpleObjectWithIntegerValue:11],
                                                           [object simpleObjectWithIntegerValue:12],
                                                           [object simpleObjectWithIntegerValue:13],
                                                           [object simpleObjectWithIntegerValue:14],
                                                           [object simpleObjectWithIntegerValue:15]
                                       ]];
    
    object.dictionaryOfSimpleTestObjects = @{ @"0": [object simpleObjectWithIntegerValue:0],
                                              @"1": [object simpleObjectWithIntegerValue:1],
                                              @"2": [object simpleObjectWithIntegerValue:2],
                                              @"3": [object simpleObjectWithIntegerValue:3],
                                              @"4": [object simpleObjectWithIntegerValue:4],
                                              @"5": [object simpleObjectWithIntegerValue:5]};
    return object;
}

- (SimpleTestObject *)simpleObjectWithIntegerValue:(NSInteger)value
{
    SimpleTestObject *simpleObject = [SimpleTestObject newSimpleTestObjectSafeValues];
    simpleObject.integer =value;
    return simpleObject;
}

+ (NSDictionary *)jl_propertyTypeMap
{
    return @{@"arrayOfSimpleTestObjects": [SimpleTestObject class], @"setOfSimpleTestObjects": [SimpleTestObject class], @"dictionaryOfSimpleTestObjects": [SimpleTestObject class]};
}

- (BOOL)isEqual:(id)someObject
{
    if ([someObject isKindOfClass:[self class]]) {
        ComplicatedTestObject *object = (ComplicatedTestObject *)someObject;
        if ([object.arrayOfSimpleTestObjects count] != [self.arrayOfSimpleTestObjects count]) {
            return NO;
        } else {
            for (int i = 0; [object.arrayOfSimpleTestObjects count] < [object.arrayOfSimpleTestObjects count]; i++) {
                if (![[object.arrayOfSimpleTestObjects objectAtIndex:i] isEqual:[self.arrayOfSimpleTestObjects objectAtIndex:i]]) {
                    return NO;
                }
            }
        }
        
        if ([object.setOfSimpleTestObjects count] != [self.setOfSimpleTestObjects count]) {
            return NO;
        } else {
            __block BOOL same = YES;
            [object.setOfSimpleTestObjects enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
                if (![self.setOfSimpleTestObjects containsObject:obj]) {
                    same = NO;
                    *stop = YES;
                }
            }];
            if (!same) {
                return NO;
            }
        }
        
        if ([object.dictionaryOfSimpleTestObjects count] != [self.dictionaryOfSimpleTestObjects count]) {
            return NO;
        } else {
            __block BOOL same = YES;
            [object.dictionaryOfSimpleTestObjects enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                SimpleTestObject *simpleObject = [object.dictionaryOfSimpleTestObjects valueForKey:key];
                SimpleTestObject *simpleObject2 = [self.dictionaryOfSimpleTestObjects objectForKey:key];
                if (![simpleObject isEqual:simpleObject2]) {
                    same = NO;
                }
            }];
            if (!same) {
                return NO;
            }
        }
        return YES;
    }
    return NO;
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
