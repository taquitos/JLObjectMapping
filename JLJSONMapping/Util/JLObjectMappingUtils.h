//
//  JLObjectMappingUtils.h
//  JLJSONMapping
//
//  Created by Joshua Liebowitz on 7/22/13.
//  Copyright (c) 2013 Joshua Liebowitz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JLObjectMappingUtils : NSObject

+ (Class)classFromPropertyProperties:(NSString *)propertiesString;
+ (BOOL)isBasicType:(id)obj;
+ (BOOL)isValueType:(NSString *)propertyProperties;
+ (NSString *)stringForBasicType:(NSObject *)object;

@end
