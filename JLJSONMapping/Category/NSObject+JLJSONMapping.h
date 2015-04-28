//
//  NSObject+JLJSONMapping.h
//  JLJSONMapping
//
//  Created by Joshua Liebowitz on 5/19/13.
//  Copyright (c) 2013 Joshua Liebowitz. All rights reserved.
//

#import <Foundation/Foundation.h>

void linkObjectCategory();

@interface NSObject (FABJLJSONMapping)

/* 
 Return a new dictionary containing the name and clases of collection-type properties
 
 This allows you to set dictionaries with property names and class types that the properties should transcode to. An example would be if you have an NSArray named "people". A single person might be a JLPerson object. So you'd return this: @{@"people":[JLPerson class]}
 
 @return Returns a dictionary containing keys that represent property names of collection-types, and values which represent their Class.
 */
+ (NSDictionary *)jl_propertyTypeMap;

/* 
 Custom property name mapping, return a new dictionary containing the property names mapped to json fields
 
 This allows you to set dictionaries with property names and JSON field names that the properties map to to. An example would be if you have a property named "firstname" but the JSON representation was "first", you'd return this: @{@"firstname":@"first"}
 
 @return Returns a dictionary containing keys that represent property names, and values which represent their JSON mapping.
 */
+ (NSDictionary *)jl_propertyNameMap;

/*
 Properties to exclude from serialization. Return a new array containing the property names you want to ignore during serialization
 
 @return Returns an array containing keys that represent property names
*/
+ (NSArray *)jl_excludedFromSerialization;

/* 
 Return a date formatter specific to any given property
 This allows you to return a custom date formatter for any given property on the object.
 Default locale: @"en_US_POSIX", default format string: @"MM-dd-yyyy 'T'HH:mm:ss.SSS Z"
 When overriding, it's important to use a dispatch_once call to create your date formatter, they are very expensive
 and this method is likely to be called many times.
 
 @param propertyName Name of the property that is a NSDate and needs a custom format
 @return Returns a date formatter for your property named 'propertyName'
 */
+ (NSDateFormatter *)jl_dateFormatterForPropertyNamed:(NSString*)propertyName;

/*
 Callbacks
*/
- (void)jl_didDeserialize:(NSDictionary *)jsonDictionary;
- (void)jl_willSerialize;

@end
