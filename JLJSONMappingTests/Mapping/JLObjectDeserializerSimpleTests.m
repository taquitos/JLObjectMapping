//
//  JLObjectDeserializerSimpleTests.m
//  JLJSONMapping
//
//  Created by Joshua Liebowitz on 7/20/13.
//  Copyright (c) 2013 Joshua Liebowitz. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AmbiguousCollectionTypeTestObject.h"
#import "AnotherSimpleTestObject.h"
#import "ArrayHoldingTestObject.h"
#import "EnumerationContainingTestObject.h"
#import "HTMLContainingTestObject.h"
#import "JLObjectDeserializer.h"
#import "JLObjectSerializer.h"
#import "MappedCollectionTypeTestObject.h"
#import "NSError+JLJSONMapping.h"
#import "SimpleTestObject.h"
#import "SubclassTestObject.h"

@interface JLObjectDeserializerSimpleTests : XCTestCase

@end

@implementation JLObjectDeserializerSimpleTests
{
    JLObjectDeserializer *deserializer;
    JLObjectSerializer *serializer;
}

- (void)setUp
{
    deserializer = [[JLObjectDeserializer alloc] init];
    serializer = [[JLObjectSerializer alloc] init];
    [super setUp];
}

- (void)testSimpleObjectDeserialize
{
    SimpleTestObject *newSimpleObject = [[SimpleTestObject alloc] init];
    newSimpleObject.uInteger = 0x54;
    NSString *objectJSON = [serializer JSONStringWithObject:newSimpleObject];
    SimpleTestObject *objectFromString = [deserializer objectWithString:objectJSON targetClass:[SimpleTestObject class] error:NULL];
    XCTAssertEqualObjects(objectFromString, newSimpleObject, @"Both objects should be the same");
}

- (void)testPropertyNameMapping
{
    //tests nested object, dictionary, and property
    NSString *objectJSON = @"{\"someOtherNameOfInteger\":12345, \"myDictionary\":{\"turtles\":\"yes\"}, \"someTestingObject\" : {\"someOtherNameOfInteger\":9876, \"myDictionary\":{\"turtles\":\"nope\"}, \"someTestingObject\" : {}}}";
    NSLog(@"%@", objectJSON);
    MappedCollectionTypeTestObject *objectFromString = [deserializer objectWithString:objectJSON targetClass:[MappedCollectionTypeTestObject class] error:NULL];
    XCTAssertEqual(objectFromString.integer, 12345, @"simple property should have transcoded");
    XCTAssertEqualObjects([objectFromString.dictionary objectForKey:@"turtles"], @"yes", @"dictionary property should have transcoded");
    XCTAssertEqual(objectFromString.testMappingObject.integer, 9876, @"nested object simple property should have transcoded");
    XCTAssertEqualObjects([objectFromString.testMappingObject.dictionary objectForKey:@"turtles"] , @"nope", @"nested object dictionary property should have transcoded");
}

- (void)testMoreComplicatedPropertyNameMappingString
{
    NSString *objectJSON = @"{\"someOtherNameOfInteger\":12345, \"myDictionary\":{\"turtles\":\"yes\"}, \"someTestingObject\" : {\"someOtherNameOfInteger\":9876, \"myDictionary\":{\"turtles\":\"nope\"}, \"someTestingObject\" : {}}, \"dictionaryOfSimpleTestMappingObjects\" :{\"oneObject\":{\"someOtherNameOfInteger\":101, \"myDictionary\":{\"turtles\":\"yup\"}, \"someTestingObject\" : {}}}, \"array\" : [{\"someOtherNameOfInteger\":202, \"myDictionary\":{\"turtles\":\"yar\"}, \"someTestingObject\" : {}}]}";
    MappedCollectionTypeTestObject *objectFromString = [deserializer objectWithString:objectJSON targetClass:[MappedCollectionTypeTestObject class] error:NULL];
    
    XCTAssertEqual(objectFromString.integer, 12345, @"simple property should have transcoded");
    XCTAssertEqualObjects([objectFromString.dictionary objectForKey:@"turtles"], @"yes", @"dictionary property should have transcoded");
    XCTAssertEqual(objectFromString.testMappingObject.integer, 9876, @"nested object simple property should have transcoded");
    XCTAssertEqualObjects([objectFromString.testMappingObject.dictionary objectForKey:@"turtles"] , @"nope", @"nested object dictionary property should have transcoded");
    
    //test objects that were packaged in a dictionary that went by a different name
    MappedCollectionTypeTestObject *objectFromDict = [objectFromString.dictionaryOfSimpleObjects objectForKey:@"oneObject"];
    XCTAssertEqual(objectFromDict.integer, 101, @"nested object in dict simple property should have transcoded");
    XCTAssertEqualObjects([objectFromDict.dictionary objectForKey:@"turtles"], @"yup", @"nested object in dictionary property should have transcoded");

    
    //test objects that were packaged in an array that went by a different name
    MappedCollectionTypeTestObject *objectFromArray = [objectFromString.arrayOfTestObjects objectAtIndex:0];
    
    XCTAssertEqual(objectFromArray.integer, 202, @"nested object in dict simple property should have transcoded");
    XCTAssertEqualObjects([objectFromArray.dictionary objectForKey:@"turtles"], @"yar", @"nested object in dictionary property should have transcoded");
}

- (void)testMoreComplicatedPropertyNameMappingNSData
{
    NSString *objectJSON = @"{\"someOtherNameOfInteger\":12345, \"myDictionary\":{\"turtles\":\"yes\"}, \"someTestingObject\" : {\"someOtherNameOfInteger\":9876, \"myDictionary\":{\"turtles\":\"nope\"}, \"someTestingObject\" : {}}, \"dictionaryOfSimpleTestMappingObjects\" :{\"oneObject\":{\"someOtherNameOfInteger\":101, \"myDictionary\":{\"turtles\":\"yup\"}, \"someTestingObject\" : {}}}, \"array\" : [{\"someOtherNameOfInteger\":202, \"myDictionary\":{\"turtles\":\"yar\"}, \"someTestingObject\" : {}}]}";
    MappedCollectionTypeTestObject *objectFromString = [deserializer objectWithData:[objectJSON dataUsingEncoding:NSUTF8StringEncoding] targetClass:[MappedCollectionTypeTestObject class] error:NULL];
    
    XCTAssertEqual(objectFromString.integer, 12345, @"simple property should have transcoded");
    XCTAssertEqualObjects([objectFromString.dictionary objectForKey:@"turtles"], @"yes", @"dictionary property should have transcoded");
    XCTAssertEqual(objectFromString.testMappingObject.integer, 9876, @"nested object simple property should have transcoded");
    XCTAssertEqualObjects([objectFromString.testMappingObject.dictionary objectForKey:@"turtles"] , @"nope", @"nested object dictionary property should have transcoded");
    
    //test objects that were packaged in a dictionary that went by a different name
    MappedCollectionTypeTestObject *objectFromDict = [objectFromString.dictionaryOfSimpleObjects objectForKey:@"oneObject"];
    XCTAssertEqual(objectFromDict.integer, 101, @"nested object in dict simple property should have transcoded");
    XCTAssertEqualObjects([objectFromDict.dictionary objectForKey:@"turtles"], @"yup", @"nested object in dictionary property should have transcoded");
    
    
    //test objects that were packaged in an array that went by a different name
    MappedCollectionTypeTestObject *objectFromArray = [objectFromString.arrayOfTestObjects objectAtIndex:0];
    
    XCTAssertEqual(objectFromArray.integer, 202, @"nested object in dict simple property should have transcoded");
    XCTAssertEqualObjects([objectFromArray.dictionary objectForKey:@"turtles"], @"yar", @"nested object in dictionary property should have transcoded");
}

- (void)testJLDeserializerIgnoreMissingProperties
{
    deserializer = [[JLObjectDeserializer alloc] initWithDeserializerOptions:JLDeserializerOptionReportMissingProperties];
    NSString *jsonWithExtraProperty = @"{\"turtle\":\"yes\"}";
    NSError *error;
    [deserializer objectWithString:jsonWithExtraProperty targetClass:[AnotherSimpleTestObject class] error:&error];
    XCTAssertEqual(error.code, JLDeserializationErrorMorePropertiesExpected);
}

- (void)testJLDeserializerIgnoreMissingPropertiesDontError
{
    deserializer = [[JLObjectDeserializer alloc] initWithDeserializerOptions:JLDeserializerOptionIgnoreMissingProperties];
    NSString *jsonWithExtraProperty = @"{\"turtle\":\"yes\"}";
    NSError *error;
    [deserializer objectWithString:jsonWithExtraProperty targetClass:[AnotherSimpleTestObject class] error:&error];
    XCTAssertNil(error, @"this should throw an exception because the JSON doesn't match the object's properties");
}

- (void)testDictionaryJLDeserializerErrorOnAmbiguousTypeDontError
{
    NSString *jsonWithExtraProperty = @"{\"someDictionary\":{\"someInt\":5}}";
    NSError *error;
    [deserializer objectWithString:jsonWithExtraProperty targetClass:[AmbiguousCollectionTypeTestObject class] error:&error];
    XCTAssertNil(error);
}

- (void)testDictionaryJLDeserializerErrorOnAmbiguousType
{
    deserializer = [[JLObjectDeserializer alloc] initWithDeserializerOptions:JLDeserializerOptionErrorOnAmbiguousType | JLDeserializerOptionVerboseOutput];
    NSString *jsonWithExtraProperty = @"{\"someDictionary\":{\"someInt\":5}}";
    NSError *error;
    [deserializer objectWithString:jsonWithExtraProperty targetClass:[AmbiguousCollectionTypeTestObject class] error:&error];
    XCTAssertEqual(error.code, JLDeserializationErrorPropertyTypeMapNeeded, @"not defining what the class of the someDictionary object is expecting should throw an exception");
}

- (void)testArrayJLDeserializerErrorOnAmbiguousTypeDontError
{
    NSString *jsonWithExtraProperty = @"{\"someArray\":[{\"someInt\":5}]}";
    NSError *error;
    [deserializer objectWithString:jsonWithExtraProperty targetClass:[AmbiguousCollectionTypeTestObject class] error:&error];
    XCTAssertNil(error, @"not defining what the class of the someDictionary object is expecting should throw an exception");
}

- (void)testArrayJLDeserializerErrorOnAmbiguousType
{
    deserializer = [[JLObjectDeserializer alloc] initWithDeserializerOptions:JLDeserializerOptionErrorOnAmbiguousType | JLDeserializerOptionVerboseOutput];
    NSString *jsonWithExtraProperty = @"{\"someArray\":[{\"someInt\":5}]}";
    NSError *error;
    [deserializer objectWithString:jsonWithExtraProperty targetClass:[AmbiguousCollectionTypeTestObject class] error:&error];
    XCTAssertEqual(error.code, JLDeserializationErrorPropertyTypeMapNeeded, @"not defining what the class of the someArray object is expecting should throw an exception");
}

- (void)testArrayJLDeserializerWithType
{
    deserializer = [[JLObjectDeserializer alloc] initWithDeserializerOptions:JLDeserializerOptionErrorOnAmbiguousType | JLDeserializerOptionVerboseOutput];
    ArrayHoldingTestObject *testObject = [ArrayHoldingTestObject newArrayHoldingTestObject];
    NSString *jsonString = [serializer JSONStringWithObject:testObject];
    
    NSError *error;
    ArrayHoldingTestObject *deserializedObject = [deserializer objectWithString:jsonString targetClass:[ArrayHoldingTestObject class] error:&error];
    XCTAssertEqual(3, [deserializedObject.arrayOfSimpleTestObjects count], @"there should be 3 objects in the deserialized array");
    [deserializedObject.arrayOfSimpleTestObjects enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        XCTAssertEqualObjects(obj, testObject.arrayOfSimpleTestObjects[idx], @"Objects should match, since they are the same");
    }];
}

- (void)testJsonEscapedFeatureStillApplies
{
    NSString *stringThatCrashes  = @"{\"html\":\"<div><a href=\"http://www.google.com.com\" target=\"_blank\" data-mce-href=\"http://www.google.com\">google.com</a></div><div> 1:21 PM 7/6/14 is this right.</div><div><ol><li>something something yeah ok</li><li>bullets are cool.</li><li>Yet another bullet.</li></ol></div>\"}";
    NSError *error;
    [deserializer objectWithString:stringThatCrashes targetClass:[HTMLContainingTestObject class] error:&error];
    XCTAssertEqual(error.code, JLDeserializationErrorInvalidJSON, @"This shouldn't have worked, either the fix is not needed, or something is whack");
}

- (void)testJsonEscapedFeatureStillNeededForJSONStringFromObject
{
    NSString *stringThatCrashes  = @"{\"html\":\"<div><a href=\"http://www.google.com.com\" target=\"_blank\" data-mce-href=\"http://www.google.com\">google.com</a></div><div> 1:21 PM 7/6/14 is this right.</div><div><ol><li>something something yeah ok</li><li>bullets are cool.</li><li>Yet another bullet.</li></ol></div>\"}";
    HTMLContainingTestObject *crasher = [[HTMLContainingTestObject alloc] init];
    crasher.html = stringThatCrashes;
    NSDictionary *data = [serializer JSONObjectWithObject:crasher];
    
    NSError *error;
    [deserializer objectWithJSONObject:data targetClass:[HTMLContainingTestObject class] error:&error];
    XCTAssertEqual(error.code, JLDeserializationErrorInvalidJSON, @"This shouldn't have worked, either the fix is not needed, or something is whack");
}

//
//- (void)testPassingObjectToDeserializerExpectingString
//{
//    NSString *stringThatCrashes  = @"{\"html\":\"Hi\"}";
//    HTMLContainingTestObject *crasher = [[HTMLContainingTestObject alloc] init];
//    crasher.html = stringThatCrashes;
//    NSDictionary *data = [serializer JSONObjectWithObject:crasher];
//    NSError *error;
//    [deserializer objectWithString:(NSString *)data targetClass:[HTMLContainingTestObject class] error:&error];
//    XCTAssertEqual(error.code, JLDeserializationErrorNSJSONException, @"This shouldn't have worked, we sent in an object to the string method");
//    XCTAssertEqualObjects(error.userInfo[kObjectMappingFailureReasonKey], @"NSJSONSerialization blew up", @"Should have gotten an error about NSJSON blowing up");
//    XCTAssertTrue([error.userInfo[kObjectMappingDescriptionKey] rangeOfString:NSInvalidArgumentException].location != NSNotFound);
//} disabled for https://github.com/taquitos/JLObjectMapping/issues/7


- (void)testPassingObjectToDeserializerExpectingString
{ //added for https://github.com/taquitos/JLObjectMapping/issues/7
    NSString *stringThatCrashes  = @"{\"html\":\"Hi\"}";
    HTMLContainingTestObject *crasher = [[HTMLContainingTestObject alloc] init];
    crasher.html = stringThatCrashes;
    NSDictionary *data = [serializer JSONObjectWithObject:crasher];
    NSError *error;
    XCTAssertThrows([deserializer objectWithString:(NSString *)data targetClass:[HTMLContainingTestObject class] error:&error], @"Should have gotten an error about NSJSON blowing up");
}


- (void)testJsonEscapedFeature
{
    NSString *stringThatCrashes  = @"{\"html\":\"<div><a href=\"http://www.google.com.com\" target=\"_blank\" data-mce-href=\"http://www.google.com\">google.com</a></div><div> 1:21 PM 7/6/14 is this right.</div><div><ol><li>something something yeah ok</li><li>bullets are cool.</li><li>Yet another bullet.</li></ol></div>\"}";
    HTMLContainingTestObject *crasher = [[HTMLContainingTestObject alloc] init];
    crasher.html = stringThatCrashes;
    NSString *data = [serializer JSONEscapedStringFromObject:crasher];
    HTMLContainingTestObject *newObject = [deserializer objectWithString:data targetClass:[HTMLContainingTestObject class] error:NULL];
    XCTAssertTrue([newObject.html isEqualToString:stringThatCrashes], @"The input and output strings should be exactly the same");
}

- (void)testMalformedJsonNoClosing
{
    NSError *error;
    [deserializer objectWithString:@"{\"turtles\"" targetClass:[SimpleTestObject class] error:&error];
    XCTAssertEqual(error.code, JLDeserializationErrorInvalidJSON, @"This shouldn't have worked, we should have gotten a parsing error");
}

- (void)testMalformedJsonNil
{
    NSError *error;
    [deserializer objectWithString:nil targetClass:[SimpleTestObject class] error:&error];
    XCTAssertEqual(error.code, JLDeserializationErrorInvalidJSON, @"This shouldn't have worked, we should have gotten a parsing error");
}

- (void)testMalformedJsonMissingPropertyValueWithSeperator
{
    NSError *error;
    [deserializer objectWithString:@"{\"turtles\":}" targetClass:[SimpleTestObject class] error:&error];
    XCTAssertEqual(error.code, JLDeserializationErrorInvalidJSON, @"This shouldn't have worked, we should have gotten a parsing error");
}

- (void)testMalformedJsonMissingPropertyValue
{
    NSError *error;
    [deserializer objectWithString:@"{\"turtles\"}" targetClass:[SimpleTestObject class] error:&error];
    XCTAssertEqual(error.code, JLDeserializationErrorInvalidJSON, @"This shouldn't have worked, we should have gotten a parsing error");
}

- (void)testSuperClassPropertiesGetsDeserialized
{
    SubclassTestObject *testObject = [[SubclassTestObject alloc] init];
    testObject.aNumber = @(42);
    testObject.aString = @"This is a string here";
    testObject.pChar = 'H';
    testObject.pShort = 10;
    NSString *json = [serializer JSONStringWithObject:testObject];
    NSError *error;
    SubclassTestObject *deserializedObject = [deserializer objectWithString:json targetClass:[SubclassTestObject class] error:&error];
    XCTAssertNil(error);
    XCTAssertEqual(deserializedObject.pShort, testObject.pShort, @"Property from superclass didn't get transcoded");
    XCTAssertEqual(deserializedObject.pChar, testObject.pChar, @"Property from superclass didn't get transcoded");
    XCTAssertEqualObjects(deserializedObject.aString, testObject.aString, @"Property from superclass didn't get transcoded");
    XCTAssertEqualObjects(deserializedObject.aNumber, testObject.aNumber, @"Property from superclass didn't get transcoded");
}

- (void)testEnumerationDeserialization
{
    NSString *jsonString = @"{\"enumValue\":2}";
    NSError *error;
    EnumerationContainingTestObject *deserializedObject = [deserializer objectWithString:jsonString targetClass:[EnumerationContainingTestObject class] error:&error];
    XCTAssertNil(error, @"We shouldn't have gotten an error deserializing this object");
    EnumerationContainingTestObject *expectedObject = [[EnumerationContainingTestObject alloc] init];
    expectedObject.enumValue = MyEnumSecondValue;
    XCTAssertEqualObjects(expectedObject, deserializedObject, @"Object with an enum property should have been transcoded here but wasn't");
}

- (void)testOptionDeserialization
{
    NSString *jsonString = @"{\"optionValue\":3}";
    NSError *error;
    EnumerationContainingTestObject *deserializedObject = [deserializer objectWithString:jsonString targetClass:[EnumerationContainingTestObject class] error:&error];
    XCTAssertNil(error, @"We shouldn't have gotten an error deserializing this object");
    EnumerationContainingTestObject *expectedObject = [[EnumerationContainingTestObject alloc] init];
    expectedObject.optionValue = MyOptionAValue | MyOptionSecondValue;
    XCTAssertEqualObjects(expectedObject, deserializedObject, @"Object with an option property should have been transcoded here but wasn't");
}

@end
