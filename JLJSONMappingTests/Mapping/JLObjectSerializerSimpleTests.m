//
//  JLObjectSerializerSimpleTests.m
//  JLJSONMapping
//
//  Created by Joshua Liebowitz on 6/8/13.
//  Copyright (c) 2013 Joshua Liebowitz. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "EnumerationContainingTestObject.h"
#import "JLObjectDeserializer.h"
#import "JLObjectSerializer.h"
#import "MappedCollectionTypeTestObject.h"
#import "SimpleExcludedPropertyTestObject.h"
#import "SimpleTestObject.h"
#import "XCTestCase+Util.h"

static NSString * const simpleTestObjectString64Bit = @"{\"pUnsignedChar\":254,\"pFloat\":3.402823e+38,\"pLong\":9223372036854775806,\"pInt16\":32766,\"pInt64\":9223372036854775806,\"pChar\":42,\"pShort\":32766,\"number\":9223372036854775806,\"pUnsignedShort\":65534,\"date\":\"2009-02-13T15:31:30.012 -0800\",\"cgfloat\":1.797693134862316e+308,\"pInt32\":2147483646,\"pLongLong\":9223372036854775806,\"pDouble\":1.797693134862316e+308,\"pUnsignedLong\":18446744073709551614,\"boolean\":1,\"pUnsignedLongLong\":18446744073709551614,\"uInteger\":4294967294,\"pUnsignedInt\":4294967294,\"pInt\":2147483646,\"pBoolean\":1,\"integer\":9223372036854775806,\"string\":\"hey there, I'm a test string, here have some unicode: Ω≈ç√∫˜µœ∑´®†¥¨ˆøπ“‘æ…¬˚∆˙©ƒ∂ßåΩ≈ç√∫˜µ≤≥÷™£¢∞§¶•ªº\"}";

static NSString * const simpleTestObjectString32Bit = @"{\"pBoolean\":1,\"boolean\":1,\"pLongLong\":9223372036854775806,\"string\":\"hey there, I'm a test string, here have some unicode: Ω≈ç√∫˜µœ∑´®†¥¨ˆøπ“‘æ…¬˚∆˙©ƒ∂ßåΩ≈ç√∫˜µ≤≥÷™£¢∞§¶•ªº\",\"pInt64\":9223372036854775806,\"cgfloat\":3.402823e+38,\"pInt16\":32766,\"pUnsignedChar\":254,\"date\":\"2009-02-13T15:31:30.012 -0800\",\"pLong\":2147483646,\"uInteger\":4294967294,\"pUnsignedLong\":4294967294,\"number\":9223372036854775806,\"pUnsignedShort\":65534,\"integer\":2147483646,\"pUnsignedInt\":4294967294,\"pDouble\":1.797693134862316e+308,\"pChar\":42,\"pInt\":2147483646,\"pInt32\":2147483646,\"pFloat\":3.402823e+38,\"pShort\":32766,\"pUnsignedLongLong\":18446744073709551614}";

@interface JLObjectSerializerSimpleTests : XCTestCase

@property (nonatomic) JLObjectSerializer *serializer;
@property (nonatomic) JLObjectDeserializer *deserializer;

@end

@implementation JLObjectSerializerSimpleTests
@synthesize serializer, deserializer;

- (void)setUp
{
    serializer = [[JLObjectSerializer alloc] init];
    deserializer = [[JLObjectDeserializer alloc] init];
    [super setUp];
}

- (void)testPropertyNameMapping
{
    MappedCollectionTypeTestObject *simpleObject = [[MappedCollectionTypeTestObject alloc] init];
    simpleObject.integer = 12345;//
    simpleObject.dictionary = @{@"turtles":@"nope"};//
    MappedCollectionTypeTestObject *simpleDictionaryObject = [[MappedCollectionTypeTestObject alloc] init];
    simpleDictionaryObject.integer = 101;//
    simpleDictionaryObject.dictionary = @{@"turtles":@"yup"};//
    
    NSDictionary *testDictionary = @{@"oneObject":simpleDictionaryObject};
    simpleObject.dictionaryOfSimpleObjects = testDictionary;
    
    MappedCollectionTypeTestObject *arrayObject = [[MappedCollectionTypeTestObject alloc] init];
    arrayObject.integer = 202;
    arrayObject.dictionary = @{@"turtles":@"huh?"};
    simpleObject.arrayOfTestObjects = @[arrayObject];
    
    NSString *json =@"{\"myDictionary\":{\"turtles\":\"nope\"},\"someOtherNameOfInteger\":12345,\"dictionaryOfSimpleTestMappingObjects\":{\"oneObject\":{\"someOtherNameOfInteger\":101,\"myDictionary\":{\"turtles\":\"yup\"}}},\"array\":[{\"someOtherNameOfInteger\":202,\"myDictionary\":{\"turtles\":\"huh?\"}}]}";;
    MappedCollectionTypeTestObject *transcodedObject = [deserializer objectWithString:json targetClass:[MappedCollectionTypeTestObject class] error:NULL];
    
    //test that simple properties can be transcoded
    XCTAssertEqual(simpleObject.integer, transcodedObject.integer, @"simple properties couldn't be transcoded");
    
    //test that dictionaries with simple values can be transcoded
    XCTAssertEqualObjects([simpleObject.dictionary objectForKey:@"turtles"], [transcodedObject.dictionary objectForKey:@"turtles"], @"dictionaries with simple values couldn't be transcoded");
    
    //test that dictionaries containing objects can be transcoded
    XCTAssertEqual([[simpleObject.dictionaryOfSimpleObjects objectForKey:@"oneObject"] integer], [[transcodedObject.dictionaryOfSimpleObjects objectForKey:@"oneObject"] integer], @"dictionaries containing objects couldn't be transcoded");
    
    XCTAssertEqualObjects([[[simpleObject.dictionaryOfSimpleObjects objectForKey:@"oneObject"] dictionary] objectForKey:@"turtles"], [[[transcodedObject.dictionaryOfSimpleObjects objectForKey:@"oneObject"] dictionary] objectForKey:@"turtles"], @"dictionaries with complicated objects as values that contain other dictionaries couldn't be transcoded");
    
    //test that arrays of objects can be transcoded with the property name map
    XCTAssertEqual([[simpleObject.arrayOfTestObjects objectAtIndex:0] integer], [[transcodedObject.arrayOfTestObjects objectAtIndex:0] integer], @"objects with arrays with complicated objects as values couldn't be transcoded");
    
    XCTAssertEqualObjects([[[simpleObject.arrayOfTestObjects objectAtIndex:0] dictionary] objectForKey:@"turtles"], [[[transcodedObject.arrayOfTestObjects objectAtIndex:0] dictionary] objectForKey:@"turtles"], @"objects with arrays with complicated objects in them that also contains dictionaries whose values couldn't be transcoded");
}

- (void)testFullObjectTranscodeNSJSONSerializer
{
    if ([XCTestCase is64Bit]) {
        [self sixtyFourBitFullObjectTranscodeNSJSONSerializer];
    } else {
        [self thirtyTwoBitFullObjectTranscodeNSJSONSerializer];
    }
}

- (void)sixtyFourBitFullObjectTranscodeNSJSONSerializer
{
    SimpleTestObject *newObject = [SimpleTestObject newSimpleTestObjectMaxValues];
    serializer = [[JLObjectSerializer alloc] initWithSerializerOptions:JLSerializerOptionDefaultOptionsMask | JLSerializerOptionUseNSJSONSerializer];
    NSString *objectData = [serializer JSONStringWithObject:newObject];
    NSString *expectedData = @"{\"pUnsignedChar\":254,\"pFloat\":3.402823e+38,\"pLong\":9223372036854775806,\"pInt16\":32766,\"pInt64\":9223372036854775806,\"pChar\":42,\"pShort\":32766,\"number\":9223372036854775806,\"pUnsignedShort\":65534,\"date\":\"2009-02-13T15:31:30.012 -0800\",\"cgfloat\":1.797693134862316e+308,\"pInt32\":2147483646,\"pLongLong\":9223372036854775806,\"pDouble\":1.797693134862316e+308,\"pUnsignedLong\":18446744073709551614,\"boolean\":true,\"pUnsignedLongLong\":18446744073709551614,\"uInteger\":4294967294,\"pUnsignedInt\":4294967294,\"pInt\":2147483646,\"pBoolean\":true,\"integer\":9223372036854775806,\"string\":\"hey there, I'm a test string, here have some unicode: Ω≈ç√∫˜µœ∑´®†¥¨ˆøπ“‘æ…¬˚∆˙©ƒ∂ßåΩ≈ç√∫˜µ≤≥÷™£¢∞§¶•ªº\"}";
    XCTAssertTrue([objectData isEqualToString:expectedData], @"Simple object default values weren't set properly in the resulting JSON");
}

- (void)thirtyTwoBitFullObjectTranscodeNSJSONSerializer
{
    SimpleTestObject *newObject = [SimpleTestObject newSimpleTestObjectMaxValues];
    serializer = [[JLObjectSerializer alloc] initWithSerializerOptions:JLSerializerOptionDefaultOptionsMask | JLSerializerOptionUseNSJSONSerializer];
    NSString *objectData = [serializer JSONStringWithObject:newObject];
    NSString *expectedData = @"{\"pBoolean\":true,\"boolean\":1,\"pLongLong\":9223372036854775806,\"string\":\"hey there, I'm a test string, here have some unicode: Ω≈ç√∫˜µœ∑´®†¥¨ˆøπ“‘æ…¬˚∆˙©ƒ∂ßåΩ≈ç√∫˜µ≤≥÷™£¢∞§¶•ªº\",\"pInt64\":9223372036854775806,\"cgfloat\":3.402823e+38,\"pInt16\":32766,\"pUnsignedChar\":254,\"date\":\"2009-02-13T15:31:30.012 -0800\",\"pLong\":2147483646,\"uInteger\":4294967294,\"pUnsignedLong\":4294967294,\"number\":9223372036854775806,\"pUnsignedShort\":65534,\"integer\":2147483646,\"pUnsignedInt\":4294967294,\"pDouble\":1.797693134862316e+308,\"pChar\":42,\"pInt\":2147483646,\"pInt32\":2147483646,\"pFloat\":3.402823e+38,\"pShort\":32766,\"pUnsignedLongLong\":18446744073709551614}";
    XCTAssertTrue([objectData isEqualToString:expectedData], @"Simple object default values weren't set properly in the resulting JSON");
}

- (void)testFullObjectTranscodeCustomSerializer
{
    if ([XCTestCase is64Bit]) {
        [self sixtyFourBitFullObjectTranscodeCustomSerializer];
    } else {
        [self thirtyTwoBitFullObjectTranscodeCustomSerializer];
    }
}

- (void)thirtyTwoBitFullObjectTranscodeCustomSerializer
{
    SimpleTestObject *newObject = [SimpleTestObject newSimpleTestObjectMaxValues];
    NSString *objectData = [serializer JSONStringWithObject:newObject];
    NSString *expected = @"{\"pBoolean\":1,\"boolean\":1,\"pLongLong\":9223372036854775806,\"string\":\"hey there, I'm a test string, here have some unicode: Ω≈ç√∫˜µœ∑´®†¥¨ˆøπ“‘æ…¬˚∆˙©ƒ∂ßåΩ≈ç√∫˜µ≤≥÷™£¢∞§¶•ªº\",\"pInt64\":9223372036854775806,\"cgfloat\":3.402823e+38,\"pInt16\":32766,\"pUnsignedChar\":254,\"date\":\"2009-02-13T15:31:30.012 -0800\",\"pLong\":2147483646,\"uInteger\":4294967294,\"pUnsignedLong\":4294967294,\"number\":9223372036854775806,\"pUnsignedShort\":65534,\"integer\":2147483646,\"pUnsignedInt\":4294967294,\"pDouble\":1.797693134862316e+308,\"pChar\":42,\"pInt\":2147483646,\"pInt32\":2147483646,\"pFloat\":3.402823e+38,\"pShort\":32766,\"pUnsignedLongLong\":18446744073709551614}";
    XCTAssertTrue([objectData isEqualToString:expected], @"Simple object default values weren't set properly in the resulting JSON");
}

- (void)sixtyFourBitFullObjectTranscodeCustomSerializer
{
    SimpleTestObject *newObject = [SimpleTestObject newSimpleTestObjectMaxValues];
    NSString *objectData = [serializer JSONStringWithObject:newObject];
    NSString *expected = @"{\"pUnsignedChar\":254,\"pFloat\":3.402823e+38,\"pLong\":9223372036854775806,\"pInt16\":32766,\"pInt64\":9223372036854775806,\"pChar\":42,\"pShort\":32766,\"number\":9223372036854775806,\"pUnsignedShort\":65534,\"date\":\"2009-02-13T15:31:30.012 -0800\",\"cgfloat\":1.797693134862316e+308,\"pInt32\":2147483646,\"pLongLong\":9223372036854775806,\"pDouble\":1.797693134862316e+308,\"pUnsignedLong\":18446744073709551614,\"boolean\":1,\"pUnsignedLongLong\":18446744073709551614,\"uInteger\":4294967294,\"pUnsignedInt\":4294967294,\"pInt\":2147483646,\"pBoolean\":1,\"integer\":9223372036854775806,\"string\":\"hey there, I'm a test string, here have some unicode: Ω≈ç√∫˜µœ∑´®†¥¨ˆøπ“‘æ…¬˚∆˙©ƒ∂ßåΩ≈ç√∫˜µ≤≥÷™£¢∞§¶•ªº\"}";
    XCTAssertTrue([objectData isEqualToString:expected], @"Simple object default values weren't set properly in the resulting JSON");
}

//Sanity test
- (void)testSimpleObjectsEqual
{
    if ([XCTestCase is64Bit]) {
        [self simpleObjectEqual64Bit];
    } else {
        [self simpleObjectEqual32Bit];
    }
}

- (void)simpleObjectEqual32Bit
{
    SimpleTestObject *newObject1 = [SimpleTestObject newSimpleTestObjectMaxValues];
    SimpleTestObject *newObject2 = [SimpleTestObject newSimpleTestObjectMaxValues];
    NSString *objectString = [serializer JSONStringWithObject:newObject1];
    XCTAssertEqualObjects(newObject1, newObject2, @"Both simple objects should be equal, nothing was done other than creating a new one");
    XCTAssertEqualObjects(objectString, simpleTestObjectString32Bit, @"String representation should match original object2");
}

- (void)simpleObjectEqual64Bit
{
    SimpleTestObject *newObject1 = [SimpleTestObject newSimpleTestObjectMaxValues];
    SimpleTestObject *newObject2 = [SimpleTestObject newSimpleTestObjectMaxValues];
    NSString *objectString = [serializer JSONStringWithObject:newObject1];
    XCTAssertEqualObjects(newObject1, newObject2, @"Both simple objects should be equal, nothing was done other than creating a new one");
    XCTAssertEqualObjects(objectString, simpleTestObjectString64Bit, @"String representation should match original object2");
}

- (void)testEnumerationSerialization
{
    EnumerationContainingTestObject *object = [[EnumerationContainingTestObject alloc] init];
    object.enumValue = MyEnumSecondValue;
    NSString *serializedJSON = [serializer JSONStringWithObject:object];
    NSString *expectedJson = @"{\"optionValue\":0,\"enumValue\":2}";
    XCTAssertEqualObjects(expectedJson, serializedJSON, @"Object with an enum property should have been serialized correctly");
}

- (void)testOptionSerialization
{
    EnumerationContainingTestObject *object = [[EnumerationContainingTestObject alloc] init];
    object.optionValue = MyOptionAValue | MyOptionSecondValue;
    NSString *serializedJSON = [serializer JSONStringWithObject:object];
    NSString *expectedJson = @"{\"optionValue\":3,\"enumValue\":0}";
    XCTAssertEqualObjects(expectedJson, serializedJSON, @"Object with an option property should have been serialized correctly");
}

#pragma mark - Property Exclusion

- (void)testExcludedProperty
{
    SimpleExcludedPropertyTestObject *object = [[SimpleExcludedPropertyTestObject alloc] init];
    object.something = @"something property";
    object.somethingToExclude = @"something to exclude property";
    NSString *json = [serializer JSONStringWithObject:object];
    XCTAssertEqualObjects(json, @"{\"something\":\"something property\"}", @"Property should be excluded");
    SimpleExcludedPropertyTestObject *deserialized = [deserializer objectWithString:json targetClass:[SimpleExcludedPropertyTestObject class] error:NULL];
    XCTAssertNil(deserialized.somethingToExclude, @"This property should be empty");
    XCTAssertEqualObjects(@"something to exclude property", object.somethingToExclude, @"The original object should still have it's data");
}

@end
