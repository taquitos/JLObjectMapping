JLObjectMapping
===============

Simple concurrent JSON to object and object to JSON mapper inspired by Jackson JSON Processor for Java. Use an object, no subclassing, no defining what properties to transcode unless you need to map them to different names.

To start using, check out this project and add all the source files found in JLJSONMapping subfolder to your project (not including the unit tests).

You're done.

To use, it's as simple as:
```objc
//class example
@interface SimpleTestMappingObject : NSObject
@property (nonatomic) NSInteger someInt;
@property (nonatomic) NSDictionary *someDict;
@property (nonatomic) NSDictionary *dictionaryOfSimpleObjects;
@property (nonatomic) SimpleTestMappingObject *someChildObject;
@end

@implementation
//tells the mapper we're expecting SimpleTestMappingObject as values in our NSDictionary property: dictionaryOfSimpleObjects
+ (NSDictionary *)jl_propertyTypeMap {
    return @{@"dictionaryOfSimpleObjects" : [SimpleTestMappingObject class]};
}
@end

//Code for mapping raw json

JLObjectMapper *mapper = [[JLObjectMapper alloc] init];
  NSString *objectJSON = @"{\"someInt\":12345, \"someDict\":
  {\"turtles\":\"yes\"}, \"someChildObject\" : {\"someInt\":9876, 
  \"someDict\":{\"someKey\":\"someVal\"}, 
  \"dictionaryOfSimpleObjects\" : {@\"objKey\":{\"someInt\":321, \"someDict\":
  {\"aKey\":\"aVal\"}}}}}"; //this last one shows an object of type SimpleTestMappingObject inserted into a map with key "objKey"
  NSError *error;
  SimpleTestMappingObject *objectFromString = [mapper objectWithString:objectJSON targetClass:[SimpleTestMappingObject class] error:&error];
```
It is configurable offering the following options:
```objc
JLDeserializerOptionIgnoreMissingProperties = 1 << 0,   //Ignore it when your json has more properties than your model, otherwise it will error
JLDeserializerOptionErrorOnAmbiguousType = 1 << 1,      //Errors when property containing a collection doesn't implement jl_propertyTypeMap
JLDeserializerOptionReportMissingProperties = 1 << 2,   //Log when JSON has more properties than your model
JLDeserializerOptionReportNilProperties = 1 << 3,       //Log when JSON is missing a property that exists in your model
JLDeserializerOptionReportTimers = 1 << 4,              //Public api has timers that will report how long they took on per invocation
JLDeserializerOptionVerboseOutput = 1 << 5,             //Spew status and details about deserialization, great for debugging.

JLSerializerOptionVerboseOutput = 1 << 0,           //Spew status and details about deserialization, great for debugging.
JLSerializerOptionReportTimers = 1 << 1,            //Public api has timers that will report how long they took on per invocation
JLSerializerOptionUseNSJSONSerializer = 1 << 2,     //instead of using custom serializer (faster) use NSJSONSerializer (safe for html content and other things NSJSONSerialization would escape for you inside json)
```

There are many more examples of how to use the various features in the unit tests included with the project.

**To assist with serialization/deserialization, there are several methods in NSObject+JLJSONMapping.h you should know about:**

**\+ (NSDictionary *)jl_propertyTypeMap;**
Implement this method in your model object if your objects have properties that are arrays or dictionaries. This is because you'll need to tell the deserializer what class you expect the objects to be when it's done. An example would be if you have an NSArray named "people". A single person might be a JLPerson object. So you'd return: @{@"people":[JLPerson class]} from this method.

**\+ (NSDictionary *)jl_propertyNameMap;**
Implement this method if your JSON objects have properties that map to different names on your model object. An example would be if you have a property on your model named "firstname" but the JSON representation was "first", you'd return: @{@"firstname":@"first"} from this method.

**\+ (NSArray *)jl_excludedFromSerialization;**
Implement this method in your model object if your objects have properties that you don't want to be included in your JSON representation when serialized. For each property you don't want serialized, add it's name to an array. An example would be if you have a property named **password** and you didn't want it to be serialized, you return **@["password"]** from this method.

**\+ (NSDateFormatter *)jl_dateFormatterForPropertyNamed:(NSString *)propertyName;**
Implement this method if you pass dates around. Right now only passing dates as a string is supported (not as a Long, yet). Return a dateformatter object you that matches the date string you are expecting for the given property.
An example would be if you have a property named "endDate", you would implement something like this:

 (NSDateFormatter *)jl_dateFormatterForPropertyNamed:(NSString *)propertyName{
    static NSDictionary *formatters;
    dispatch_once...{
      NSDateFormatter *dateFormatterForEndDate = ...
      NSDateFormatter *dateFormattedForStartDate = ...
      formatters = @{@"endDate":dateFormatterForEndDate,
             @"startDate": dateFormattedForStartDate};
             }
    return [formatters objectForKey:propertyName];
</code>  
}

**Serialization and Deserialization callbacks**
JLObjectMapping currently supports two callbacks:

**\-(void)jl_didDeserialize:(NSDictionary *)jsonDictionary;** Called after a JSON object or JSONString was deserialized into an object. The receiving object is the new object created. 
This allows you to massage your data further, if needed.

**\-(void)jl_willSerialize;** Called before serialization on the object you are about to serialize. This allows you to massage your data or do validation before serialization.
