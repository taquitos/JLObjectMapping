//
//  JLObjectMappingUtils.m
//  JLJSONMapping
//
//  Created by Joshua Liebowitz on 7/22/13.
//  Copyright (c) 2013 Joshua Liebowitz. All rights reserved.
//

#import "JLObjectMappingUtils.h"

@implementation JLObjectMappingUtils

+ (BOOL)isBasicType:(id)obj
{
    if ([obj isKindOfClass:[NSString class]]) {
        return YES;
    }else if ([obj isKindOfClass:[NSNumber class]]) {
        return YES;
    }else if ([obj isKindOfClass:[NSNull class]]) {
        return YES;
    } else {
        return NO;
    }
}

+ (Class)classFromPropertyProperties:(NSString *)propertiesString
{
    NSArray *attributes = [propertiesString componentsSeparatedByString:@","];
    NSString *typeItem = [attributes objectAtIndex:0];
    if ([typeItem hasPrefix:@"T@"]) { //is class
        NSRange range = [typeItem rangeOfString:@"T@\""];
        if (range.location != NSNotFound) {
            NSInteger startIndex = range.location + range.length;
            NSRange typeRange = NSMakeRange(startIndex, ([typeItem length] - 1) - startIndex);
            NSString *className = [typeItem substringWithRange:typeRange];
            Class classOfProperty = NSClassFromString(className);
            if (!classOfProperty) {
                NSLog(@"Class: %@ not loaded in runtime. To fix this, you can load it by referencing the class somewhere before using the mapper (calling [%@ class]), or you can add -ObjC to your linker flags", className, className);
            }
            return classOfProperty;
        }
    }
    return nil;
}

/*
 Returns whether or not the given properties for the Class property is a Value (vs primative)
 */
+ (BOOL)isValueType:(NSString *)propertyProperties
{
    NSArray *attributes = [propertyProperties componentsSeparatedByString:@","];
    NSString *propertyType = [attributes objectAtIndex:1];
    if (![propertyType isEqualToString:@"&"]) {
        return YES;
    }
    return NO;
}

//returns the string representation of a basic object
+ (NSString *)stringForBasicType:(NSObject *)object
{
    if ([object isKindOfClass:[NSString class]]) {
        //faster than //[NSString stringWithFormat:@"\"%@\"", object];
        size_t size = strlen([((NSString *)object) UTF8String]) + 2;
        char *buffer = (char *)malloc(size);
        sprintf(buffer, "\"%s\"", [(NSString *)object UTF8String]);
        NSString *s = [NSString stringWithCString:buffer encoding:NSUTF8StringEncoding];
        free(buffer);
        return s;
    }else if ([object isKindOfClass:[NSNumber class]]) {
        return [(NSNumber *)object stringValue];
    } else {
        return @"null";
    }
}

@end
