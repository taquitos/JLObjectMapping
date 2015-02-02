//
//  JLObjectMapper.h
//  JLJSONMapping
//
//  Created by Joshua Liebowitz on 5/19/13.
//  Copyright (c) 2013 Joshua Liebowitz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JLObjectMapper : NSObject

/* 
 Return a new object of type 'class' using the data from 'objectString'
 
 This allows you to transcode a string containing JSON into an object of any given type.
 
 @param targetClass The class of the object you wish to instantiate, nil for this param will return a Foundation object.
 @param objectString The JSON string that represents the object you wish to instantiate
 @return Returns a new object of type 'class' based on the data from 'objectString' or 'nil' on failure
 */
- (id)objectWithString:(NSString *)objectString targetClass:(Class)class error:(NSError * __autoreleasing *)error;

/*
 Return a new object of type 'class' using the data from 'objectData'
 
 This allows you to transcode NSData containing JSON into an object of any given type.
 
 @param targetClass The class of the object you wish to instantiate, nil for this param will return a Foundation object.
 @param objectData The JSON NSData that represents the object you wish to instantiate
 @return Returns a new object of type 'class' based on the data from 'objectData' or 'nil' on failure
 */
- (id)objectWithData:(NSData *)objectData targetClass:(Class)class error:(NSError * __autoreleasing *)error;

/* 
 Return a new object of type 'class' using the data from the JSONObject 'obj'
 
 This allows you to transcode a JSONObject into an object of any given type.
 
 @param class The class of the object you wish to instantiate, nil for this param will return a Foundation object (essentially a no-op).
 @param obj The JSONObject that holds the data about the object you wish to instantiate. This is usually an NSDictionary or NSArray
 @return Returns a new object of type 'class' based on the data from 'obj' or 'nil' on failure
 */
- (id)objectWithJSONObject:(id)obj targetClass:(Class)class error:(NSError * __autoreleasing *)error;

/* 
 Return a string of JSON that represents the object passed in.
 
 This allows you to serialize an object into a JSON string.
 
 @param object The object you wish to serialize into JSON
 @return Returns a NSString that represents the object passed in or 'nil' on failure.
 */
- (NSString *)JSONStringWithObject:(NSObject *)object;

/* Return a JSON object that represents the normal model object passed in.
 
 This allows you to serialize an object into a JSON object string.
 
 @param object The object you wish to serialize into JSON
 @return Returns a JSON object that represents the object passed in or 'nil' on failure. 
 The JSON object can be either an NSDictionary, NSArray, or an NSString
 */
- (id)JSONObjectWithObject:(NSObject *)object;

/* Return NSData that represents the serialized model object passed in.

 This allows you to serialize an object into a NSData object.

 @param object The object you wish to serialize into JSON
 @return Returns a NSData object that represents the serilized object passed in or 'nil' on failure.
 */
- (NSData *)dataWithObject:(NSObject *)object;

@end
