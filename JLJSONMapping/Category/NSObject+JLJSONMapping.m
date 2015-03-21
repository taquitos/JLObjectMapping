//
//  NSObject+JLJSONMapping.m
//  JLJSONMapping
//
//  Created by Joshua Liebowitz on 5/19/13.
//  Copyright (c) 2013 Joshua Liebowitz. All rights reserved.
//

#import "NSObject+JLJSONMapping.h"

@implementation NSObject (JLJSONMapping)

+ (NSDateFormatter *)jl_dateFormatterForPropertyNamed:(NSString*)propertyName
{
    //NOTE: ignoring propertyName
    static dispatch_once_t once;
    static NSDateFormatter *dateFormatter;
    dispatch_once(&once, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
        NSLocale *enUSPOSIXLocale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
        NSTimeZone *timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
        [dateFormatter setLocale:enUSPOSIXLocale];
        [dateFormatter setTimeZone:timeZone];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS"]; //any more than .SSS and the date formatter turns it into 0's
    });
    return dateFormatter;
}

+ (NSDictionary *)jl_propertyNameMap
{
    return @{};
}

+ (NSDictionary *)jl_propertyTypeMap
{
    return @{};
}

+ (NSArray *)jl_excludedFromSerialization
{
    return @[];
}

- (void)jl_didDeserialize:(NSDictionary *)jsonDictionary
{

}

- (void)jl_willSerialize
{

}

@end
