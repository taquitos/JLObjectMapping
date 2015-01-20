//
//  ObjectAmbiguousType.m
//  JLJSONMapping
//
//  Created by Joshua Liebowitz on 7/27/13.
//  Copyright (c) 2013 Joshua Liebowitz. All rights reserved.
//

#import "ObjectAmbiguousType.h"

@implementation ObjectAmbiguousType

+ (NSDateFormatter *)jl_dateFormatterForPropertyNamed:(NSString *)propertyName
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
