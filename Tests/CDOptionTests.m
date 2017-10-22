// CDOptionTest.m
// cocoadialog
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.

#import <XCTest/XCTest.h>
#import "CDOption.h"
#import "NSNumber+CDNumber.h"

@interface CDOption (Test)
- (CDOption *(^)(void)) reset;
@end

@implementation CDOption (Test)
- (CDOption *(^)(void)) reset {
    return ^CDOption *(){
        return CDOption.create(self.valueType, self.name);
    };
}
@end

@interface CDOptionTests : XCTestCase

@property CDOption*     boolean;
@property CDOption*     number;
@property CDOption*     string;
@property CDOption*     stringOrNumber;
@property NSNull*       null;

@end

@implementation CDOptionTests

- (void) setUp {
    [super setUp];
    NSStringCDColor = NO;
    _boolean = CDOption.create(CDBoolean, @"boolean");
    _number = CDOption.create(CDNumber, @"number");
    _string = CDOption.create(CDString, @"string");
    _stringOrNumber = CDOption.create(CDStringOrNumber, @"stringOrNumber");
    _null = [NSNull null];
}

- (void) testAddNote {
    NSString *note = @"a note";
    XCTAssertTrue([_boolean.reset().addNote(note).notes indexOfObjectIdenticalTo:note] != NSNotFound);
    XCTAssertTrue([_number.reset().addNote(note).notes indexOfObjectIdenticalTo:note] != NSNotFound);
    XCTAssertTrue([_string.reset().addNote(note).notes indexOfObjectIdenticalTo:note] != NSNotFound);
    XCTAssertTrue([_stringOrNumber.reset().addNote(note).notes indexOfObjectIdenticalTo:note] != NSNotFound);
}

- (void) testAddWarning {
    NSString *warning = @"a warning";
    XCTAssertTrue([_boolean.reset().addWarning(warning).warnings indexOfObjectIdenticalTo:warning] != NSNotFound);
    XCTAssertTrue([_number.reset().addWarning(warning).warnings indexOfObjectIdenticalTo:warning] != NSNotFound);
    XCTAssertTrue([_string.reset().addWarning(warning).warnings indexOfObjectIdenticalTo:warning] != NSNotFound);
    XCTAssertTrue([_stringOrNumber.reset().addWarning(warning).warnings indexOfObjectIdenticalTo:warning] != NSNotFound);
}

- (void) testAllow {
    NSNumber *b = @YES;
    NSString *s = @"a string";
    NSNumber *n = @3;
    XCTAssertTrue([_boolean.reset().allow(@[b]).allowedValues indexOfObjectIdenticalTo:b] != NSNotFound);
    XCTAssertTrue([_number.reset().allow(@[n]).allowedValues indexOfObjectIdenticalTo:n] != NSNotFound);
    XCTAssertTrue([_string.reset().allow(@[s]).allowedValues indexOfObjectIdenticalTo:s] != NSNotFound);
    XCTAssertTrue([_stringOrNumber.reset().allow(@[n, s]).allowedValues indexOfObjectIdenticalTo:n] != NSNotFound && [_stringOrNumber.allowedValues indexOfObjectIdenticalTo:s]);
}

- (void) testArrayOfStrings {
    NSArray *array = @[@"Okay", @"42%", @2, @YES];
    NSArray *empty = @[];
    NSArray *emptyNumber = @[@"0"];
    NSArray *emptyString = @[@""];
    NSArray *expected;

    // Booleans.
    expected = @[@"NO".localized];
    XCTAssertEqualObjects(expected, _boolean.reset().max(array.count + 1).overrideValues(array).arrayOfStrings);
    XCTAssertEqualObjects(expected, _boolean.reset().max(empty.count + 1).overrideValues(empty).arrayOfStrings);

    // Number.
    expected = @[@"0", @"42%", @"2", @"1", @"0"];
    XCTAssertEqualObjects(expected, _number.reset().max(array.count + 1).overrideValues(array).arrayOfStrings);
    XCTAssertEqualObjects(emptyNumber, _number.reset().max(empty.count + 1).overrideValues(empty).arrayOfStrings);

    // String.
    expected = @[@"Okay", @"42%", @"2", @"1", @""];
    XCTAssertEqualObjects(expected, _string.reset().max(array.count + 1).overrideValues(array).arrayOfStrings);
    XCTAssertEqualObjects(emptyString, _string.reset().max(empty.count + 1).overrideValues(empty).arrayOfStrings);

    // String or number.
    expected = @[@"Okay", @"42%", @"2", @"1", @""];
    XCTAssertEqualObjects(expected, _stringOrNumber.reset().max(array.count + 1).overrideValues(array).arrayOfStrings);
    XCTAssertEqualObjects(emptyString, _stringOrNumber.reset().max(empty.count + 1).overrideValues(empty).arrayOfStrings);
}

- (void) testArrayOfNumbers {
    NSArray *array = @[@"Okay", @"42%", @2, @YES];
    NSArray *empty = @[];
    NSArray *emptyNumber = @[@0];
    NSArray *expected;

    // Booleans.
    XCTAssertEqualObjects(emptyNumber, _boolean.reset().max(array.count + 1).overrideValues(array).arrayOfNumbers);
    XCTAssertEqualObjects(emptyNumber, _boolean.reset().max(empty.count + 1).overrideValues(empty).arrayOfNumbers);
    expected = @[@1];
    XCTAssertEqualObjects(expected, _boolean.reset().overrideValues(@[@YES]).arrayOfNumbers);

    // Number.
    expected = @[@0, @.42, @2, @1, @0];
    XCTAssertEqualObjects(expected, _number.reset().max(array.count + 1).overrideValues(array).arrayOfNumbers);
    XCTAssertEqualObjects(emptyNumber, _number.reset().max(empty.count + 1).overrideValues(empty).arrayOfNumbers);

    // String.
    expected = @[@0, @.42, @2, @1, @0];
    XCTAssertEqualObjects(expected, _string.reset().max(array.count + 1).overrideValues(array).arrayOfNumbers);
    XCTAssertEqualObjects(emptyNumber, _string.reset().max(empty.count + 1).overrideValues(empty).arrayOfNumbers);

    // String or number.
    expected = @[@0, @.42, @2, @1, @0];
    XCTAssertEqualObjects(expected, _stringOrNumber.reset().max(array.count + 1).overrideValues(array).arrayOfNumbers);
    XCTAssertEqualObjects(emptyNumber, _stringOrNumber.reset().max(empty.count + 1).overrideValues(empty).arrayOfNumbers);
}

- (void) testArrayOfStringOrNumbers {
    NSArray *array = @[@"Okay", @"42%", @2, @YES];
    NSArray *empty = @[];
    NSArray *emptyNumber = @[@0];
    NSArray *emptyString = @[@""];
    NSArray *expected;

    // Booleans.
    NSArray *no = @[@"NO".localized];
    NSArray *yes = @[@"YES".localized];
    XCTAssertEqualObjects(no, _boolean.reset().max(array.count + 1).overrideValues(array).arrayOfStringOrNumbers);
    XCTAssertEqualObjects(no, _boolean.reset().max(empty.count + 1).overrideValues(empty).arrayOfStringOrNumbers);
    XCTAssertEqualObjects(yes, _boolean.reset().overrideValues(@[@YES]).arrayOfStringOrNumbers);

    // Number.
    expected = @[@0, @.42, @2, @1, @0];
    XCTAssertEqualObjects(expected, _number.reset().max(array.count + 1).overrideValues(array).arrayOfStringOrNumbers);
    XCTAssertEqualObjects(emptyNumber, _number.reset().max(empty.count + 1).overrideValues(empty).arrayOfStringOrNumbers);

    // String.
    expected = @[@"Okay", @"42%", @"2", @"1", @""];
    XCTAssertEqualObjects(expected, _string.reset().max(array.count + 1).overrideValues(array).arrayOfStringOrNumbers);
    XCTAssertEqualObjects(emptyString, _string.reset().max(empty.count + 1).overrideValues(empty).arrayOfStringOrNumbers);

    // String or number.
    expected = @[@"Okay", @"42%", @2, @1, @""];
    XCTAssertEqualObjects(expected, _stringOrNumber.reset().max(array.count + 1).overrideValues(array).arrayOfStringOrNumbers);
    XCTAssertEqualObjects(emptyString, _stringOrNumber.reset().max(empty.count + 1).overrideValues(empty).arrayOfStringOrNumbers);
}

// Value properties.
- (void) testArrayValue {
    NSArray *array = @[@"Okay", @"42%", @2, @YES];
//    NSArray *nullArray = @[[NSNull null]];
    NSArray *expected;

    // Booleans.
    expected = @[@NO];
    XCTAssertEqualObjects(expected, _boolean.reset().max(array.count + 1).overrideValues(array).arrayValue);

    // Number.
    expected = @[@0, @.42, @2, @1, @0];
    XCTAssertEqualObjects(expected, _number.reset().max(array.count + 1).overrideValues(array).arrayValue);

    // String.
    expected = @[@"Okay", @"42%", @"2", @"1", @""];
    XCTAssertEqualObjects(expected, _string.reset().max(array.count + 1).overrideValues(array).arrayValue);

    // String or number.
    expected = @[@"Okay", @.42, @2, @1, @""];
    XCTAssertEqualObjects(expected, _stringOrNumber.reset().max(array.count + 1).overrideValues(array).arrayValue);
}

- (void) testBoolValue {
    // Boolean
    XCTAssertFalse(_boolean.reset().boolValue);
    XCTAssertTrue(_boolean.reset().provided(YES).boolValue);
    XCTAssertTrue(_boolean.reset().rawValue(@"1").boolValue);
    XCTAssertTrue(_boolean.reset().rawValue(@"ON").boolValue);
    XCTAssertTrue(_boolean.reset().rawValue(@"TRUE").boolValue);
    XCTAssertTrue(_boolean.reset().rawValue(@"YES").boolValue);
    XCTAssertFalse(_boolean.reset().rawValue(@"0").boolValue);
    XCTAssertFalse(_boolean.reset().rawValue(@"OFF").boolValue);
    XCTAssertFalse(_boolean.reset().rawValue(@"FALSE").boolValue);
    XCTAssertFalse(_boolean.reset().rawValue(@"NO").boolValue);

    // Number.
    XCTAssertFalse(_number.reset().rawValue(@"0").boolValue);
    XCTAssertTrue(_number.reset().rawValue(@"1").boolValue);

    // String.
    XCTAssertFalse(_string.reset().rawValue(@"0").boolValue);
    XCTAssertFalse(_string.reset().rawValue(@"1").boolValue);
    XCTAssertFalse(_string.reset().rawValue(@"ON").boolValue);
    XCTAssertFalse(_string.reset().rawValue(@"TRUE").boolValue);
    XCTAssertFalse(_string.reset().rawValue(@"YES").boolValue);
    XCTAssertFalse(_string.reset().rawValue(@"something else").boolValue);

    // String or number.
    XCTAssertFalse(_stringOrNumber.reset().rawValue(@"0").boolValue);
    XCTAssertTrue(_stringOrNumber.reset().rawValue(@"1").boolValue);
    XCTAssertFalse(_stringOrNumber.reset().rawValue(@"ON").boolValue);
    XCTAssertFalse(_stringOrNumber.reset().rawValue(@"TRUE").boolValue);
    XCTAssertFalse(_stringOrNumber.reset().rawValue(@"YES").boolValue);
    XCTAssertFalse(_stringOrNumber.reset().rawValue(@"something else").boolValue);
}

- (void) testConvertValue {
    // Boolean.
    XCTAssertEqualObjects(@NO, [_boolean.reset() convertValue:nil]);
    XCTAssertEqualObjects(@NO, [_boolean.reset() convertValue:[NSNull null]]);
    XCTAssertEqualObjects(@YES, [_boolean.reset().provided(YES) convertValue:nil]);
    XCTAssertEqualObjects(@NO, [_boolean.reset() convertValue:@0]);
    XCTAssertEqualObjects(@YES, [_boolean.reset() convertValue:@1]);
    XCTAssertEqualObjects(@NO, [_boolean.reset() convertValue:@NO]);
    XCTAssertEqualObjects(@YES, [_boolean.reset() convertValue:@YES]);
    XCTAssertEqualObjects(@YES, [_boolean.reset() convertValue:@2]);
    XCTAssertEqualObjects(@YES, [_boolean.reset() convertValue:@"1"]);
    XCTAssertEqualObjects(@YES, [_boolean.reset() convertValue:@"on"]);
    XCTAssertEqualObjects(@YES, [_boolean.reset() convertValue:@"true"]);
    XCTAssertEqualObjects(@YES, [_boolean.reset() convertValue:@"yes"]);
    XCTAssertEqualObjects(@NO, [_boolean.reset() convertValue:@"0"]);
    XCTAssertEqualObjects(@NO, [_boolean.reset() convertValue:@"off"]);
    XCTAssertEqualObjects(@NO, [_boolean.reset() convertValue:@"false"]);
    XCTAssertEqualObjects(@NO, [_boolean.reset() convertValue:@"no"]);
    XCTAssertEqualObjects(@NO, [_boolean.reset() convertValue:@"anything else"]);
    XCTAssertEqualObjects(@NO, [_boolean.reset() convertValue:@{}]);
    XCTAssertEqualObjects(@NO, [_boolean.reset() convertValue:@[]]);

    // Number.
    XCTAssertEqualObjects(@0, [_number.reset() convertValue:nil]);
    XCTAssertEqualObjects(@0, [_number.reset() convertValue:[NSNull null]]);
    XCTAssertEqualObjects(@2, [_number.reset() convertValue:@"2"]);
    XCTAssertEqualObjects(@0, [_number.reset() convertValue:@"non-numeric"]);
    XCTAssertEqualObjects(@0, [_number.reset() convertValue:@NO]);
    XCTAssertEqualObjects(@1, [_number.reset() convertValue:@YES]);
    XCTAssertEqualObjects(@4, [_number.reset() convertValue:@4]);
    XCTAssertEqualObjects(@0, [_number.reset() convertValue:@{}]);
    XCTAssertEqualObjects(@0, [_number.reset() convertValue:@[]]);

    // String.
    XCTAssertEqualObjects(@"", [_string.reset() convertValue:nil]);
    XCTAssertEqualObjects(@"", [_string.reset() convertValue:[NSNull null]]);
    XCTAssertEqualObjects(@"2", [_string.reset() convertValue:@"2"]);
    XCTAssertEqualObjects(@"2", [_string.reset() convertValue:@2]);
    XCTAssertEqualObjects(@"0", [_string.reset() convertValue:@NO]);
    XCTAssertEqualObjects(@"1", [_string.reset() convertValue:@YES]);
    XCTAssertEqualObjects(@"", [_string.reset() convertValue:@{}]);
    XCTAssertEqualObjects(@"", [_string.reset() convertValue:@[]]);

    // String or number.
    XCTAssertEqualObjects(@"", [_stringOrNumber.reset() convertValue:nil]);
    XCTAssertEqualObjects(@"", [_stringOrNumber.reset() convertValue:[NSNull null]]);
    XCTAssertEqualObjects(@2, [_stringOrNumber.reset() convertValue:@"2"]);
    XCTAssertEqualObjects(@.25, [_stringOrNumber.reset() convertValue:@"25%"]);
    XCTAssertEqualObjects(@"25 non-numeric", [_stringOrNumber.reset() convertValue:@"25 non-numeric"]);
    XCTAssertEqualObjects(@2, [_stringOrNumber.reset() convertValue:@2]);
    XCTAssertEqualObjects(@0, [_stringOrNumber.reset() convertValue:@NO]);
    XCTAssertEqualObjects(@1, [_stringOrNumber.reset() convertValue:@YES]);
    XCTAssertEqualObjects(@"", [_stringOrNumber.reset() convertValue:@{}]);
    XCTAssertEqualObjects(@"", [_stringOrNumber.reset() convertValue:@[]]);
}

- (void) testDependsOn {
    NSString *parent = @"a parent";
    XCTAssertTrue(_boolean.reset().dependsOn(parent).parent == parent);
    XCTAssertTrue(_number.reset().dependsOn(parent).parent == parent);
    XCTAssertTrue(_string.reset().dependsOn(parent).parent == parent);
    XCTAssertTrue(_stringOrNumber.reset().dependsOn(parent).parent == parent);
}

- (void) testDeprecates {
    CDOption *deprecated = CDOption.create(CDString, @"deprecated");
    XCTAssertTrue([_boolean.reset().deprecates(@[deprecated]).deprecatedOptions indexOfObjectIdenticalTo:deprecated] != NSNotFound);
    XCTAssertTrue(_boolean.name == deprecated.deprecatedTo);
    XCTAssertTrue([_number.reset().deprecates(@[deprecated]).deprecatedOptions indexOfObjectIdenticalTo:deprecated] != NSNotFound);
    XCTAssertTrue(_number.name == deprecated.deprecatedTo);
    XCTAssertTrue([_string.reset().deprecates(@[deprecated]).deprecatedOptions indexOfObjectIdenticalTo:deprecated] != NSNotFound);
    XCTAssertTrue(_string.name == deprecated.deprecatedTo);
    XCTAssertTrue([_stringOrNumber.reset().deprecates(@[deprecated]).deprecatedOptions indexOfObjectIdenticalTo:deprecated] != NSNotFound);
    XCTAssertTrue(_stringOrNumber.name == deprecated.deprecatedTo);
}

- (void) testDescription {
    XCTAssertEqualObjects(@"USAGE_OPTION_CONTROL_BOOLEAN".localized, _boolean.reset().description);
    XCTAssertEqualObjects(@"USAGE_OPTION_CONTROL_NUMBER".localized, _number.reset().description);
    XCTAssertEqualObjects(@"USAGE_OPTION_CONTROL_STRING".localized, _string.reset().description);
    XCTAssertEqualObjects(@"USAGE_OPTION_CONTROL_STRINGORNUMBER".localized, _stringOrNumber.reset().description);
    XCTAssertEqualObjects(@"USAGE_OPTION_UNICORN_BOOLEAN".localized, _boolean.reset().setScope(@"unicorn").description);
    XCTAssertEqualObjects(@"USAGE_OPTION_UNICORN_NUMBER".localized, _number.reset().setScope(@"unicorn").description);
    XCTAssertEqualObjects(@"USAGE_OPTION_UNICORN_STRING".localized, _string.reset().setScope(@"unicorn").description);
    XCTAssertEqualObjects(@"USAGE_OPTION_UNICORN_STRINGORNUMBER".localized, _stringOrNumber.reset().setScope(@"unicorn").description);
}

- (void) testDisplayValue {
    XCTAssertEqualObjects(@"YES".localized, _boolean.reset().rawValue(@"YES").displayValue);
    XCTAssertEqualObjects(@"42", _number.reset().rawValue(@"42").displayValue);
    XCTAssertEqualObjects(@"\"Okay\"", _string.reset().rawValue(@"Okay").displayValue);
    XCTAssertEqualObjects(@"\"Okay\"", _stringOrNumber.reset().rawValue(@"Okay").displayValue);
    XCTAssertEqualObjects(@"42", _stringOrNumber.reset().overrideValues(@[@42]).displayValue);
    XCTAssertEqualObjects(@"\"42%\"", _stringOrNumber.reset().overrideValues(@[@"42%"]).displayValue);

    NSArray *array = @[@"Okay", @"25", @"42%", @2, @YES];
    XCTAssertEqualObjects(@"NO".localized, _boolean.reset().max(array.count).overrideValues(array).displayValue);
    XCTAssertEqualObjects(@"[(0) 0, (1) 25, (2) 0.42, (3) 2, (4) 1]", _number.reset().max(array.count).overrideValues(array).displayValue);
    XCTAssertEqualObjects(@"[(0) \"Okay\", (1) \"25\", (2) \"42%\", (3) \"2\", (4) \"1\"]", _string.reset().max(array.count).overrideValues(array).displayValue);
    XCTAssertEqualObjects(@"[(0) \"Okay\", (1) 25, (2) \"42%\", (3) 2, (4) 1]", _stringOrNumber.reset().max(array.count).overrideValues(array).displayValue);
}

- (void) testHide {
    XCTAssertTrue(_boolean.reset().hide(YES).hidden == YES);
    XCTAssertTrue(_number.reset().hide(YES).hidden == YES);
    XCTAssertTrue(_string.reset().hide(YES).hidden == YES);
    XCTAssertTrue(_stringOrNumber.reset().hide(YES).hidden == YES);
}

- (void) testInvalidOption {
    XCTAssertThrowsSpecificNamed(CDOption.create(-1, @"a"), NSException, NSInvalidArgumentException);
    XCTAssertThrowsSpecificNamed(CDOption.create(CDString, nil), NSException, NSInvalidArgumentException);
    XCTAssertThrowsSpecificNamed(CDOption.create(CDString, @""), NSException, NSInvalidArgumentException);
}

- (void) testJson {
    NSArray* keys = @[@"allowedValues", @"automaticDefaultValue", @"description", @"defaultValue", @"deprecates", @"hidden", @"maximumValues", @"minimumValues", @"name", @"notes", @"required", @"parent", @"scope", @"typeLabel", @"valueType", @"warnings", @"wasProvided"];

    CDOption* b = _boolean.reset().deprecates(@[_boolean]);
    CDOption* n = _number.reset().deprecates(@[_number]);
    CDOption* s = _string.reset().deprecates(@[_string]);
    CDOption* sn = _stringOrNumber.reset().deprecates(@[_stringOrNumber]);

    NSArray *bJson = ((NSDictionary*)b.jsonValue).allKeys;
    NSArray *nJson = ((NSDictionary*)n.jsonValue).allKeys;
    NSArray *sJson = ((NSDictionary*)s.jsonValue).allKeys;
    NSArray *snJson = ((NSDictionary*)sn.jsonValue).allKeys;

    for (NSString* key in keys) {
        XCTAssertTrue([bJson containsObject:key]);
        XCTAssertTrue([nJson containsObject:key]);
        XCTAssertTrue([sJson containsObject:key]);
        XCTAssertTrue([snJson containsObject:key]);
    }

    // @note this really isn't important since this is a protocol implementation and
    // should be covered elsewhere. However, to ensure 100% coverage of this class
    // it needs to be invoked at least once.
    XCTAssertEqualObjects(b.toJSONString, b.toJSONString);
}

- (void) testLabel {
    XCTAssertEqualObjects(@"--boolean", _boolean.label);
    XCTAssertEqualObjects(@"--number", _number.label);
    XCTAssertEqualObjects(@"--string", _string.label);
    XCTAssertEqualObjects(@"--stringOrNumber", _stringOrNumber.label);
}

- (void) testMaximumValues {
    // Boolean.
    XCTAssertEqual(1, _boolean.reset().max(6).maximumValues.integerValue);

    // Number.
    CDOption* n = _number.reset().max(4);
    XCTAssertEqual(4, n.maximumValues.integerValue);
    XCTAssertEqual(3, n.max(3).maximumValues.integerValue); // DO NOT RESET, tests removal of max values.
    XCTAssertEqual(-1, _number.reset().max(-1).maximumValues.integerValue);

    // String.
    CDOption* s = _string.reset().max(4);
    XCTAssertEqual(4, s.maximumValues.integerValue);
    XCTAssertEqual(3, s.max(3).maximumValues.integerValue); // DO NOT RESET, tests removal of max values.
    XCTAssertEqual(-1, _string.reset().max(-1).maximumValues.integerValue);

    // String or number.
    CDOption* sn = _stringOrNumber.reset().max(4);
    XCTAssertEqual(4, sn.maximumValues.integerValue);
    XCTAssertEqual(3, sn.max(3).maximumValues.integerValue); // DO NOT RESET, tests removal of max values.
    XCTAssertEqual(-1, _stringOrNumber.reset().max(-1).maximumValues.integerValue);
}

- (void) testMinimumValues {
    // Boolean.
    XCTAssertEqual(0, _boolean.reset().minimumValues.integerValue);
    XCTAssertEqual(0, _boolean.reset().min(6).minimumValues.integerValue);

    // Number.
    XCTAssertEqual(1, _number.reset().minimumValues.integerValue);
    XCTAssertEqual(4, _number.reset().min(4).minimumValues.integerValue);

    // String.
    XCTAssertEqual(1, _string.reset().minimumValues.integerValue);
    XCTAssertEqual(2, _string.reset().min(2).minimumValues.integerValue);

    // String or number.
    XCTAssertEqual(1, _stringOrNumber.reset().minimumValues.integerValue);
    XCTAssertEqual(2, _stringOrNumber.reset().min(2).minimumValues.integerValue);
}

- (void) testName {
    XCTAssertEqualObjects(@"boolean", _boolean.name);
    XCTAssertEqualObjects(@"number", _number.name);
    XCTAssertEqualObjects(@"string", _string.name);
    XCTAssertEqualObjects(@"stringOrNumber", _stringOrNumber.name);
}

- (void) testNumberValue {
    // Boolean.
    XCTAssertEqualObjects(@0, _boolean.reset().numberValue);
    XCTAssertEqualObjects(@0, _boolean.reset().rawValue(@"-1").numberValue);
    XCTAssertEqualObjects(@0, _boolean.reset().rawValue(@"0").numberValue);
    XCTAssertEqualObjects(@1, _boolean.reset().rawValue(@"1").numberValue);
    XCTAssertEqualObjects(@0, _boolean.reset().rawValue(@"a").numberValue);

    // Number.
    XCTAssertEqualObjects(@0, _number.reset().numberValue);
    XCTAssertEqualObjects(@-1, _number.reset().rawValue(@"-1").numberValue);
    XCTAssertEqualObjects(@0, _number.reset().rawValue(@"0").numberValue);
    XCTAssertEqualObjects(@1, _number.reset().rawValue(@"1").numberValue);
    XCTAssertEqualObjects(@0, _number.reset().rawValue(@"a").numberValue);

    // String.
    XCTAssertEqualObjects(@0, _string.reset().numberValue);
    XCTAssertEqualObjects(@-1, _string.reset().rawValue(@"-1").numberValue);
    XCTAssertEqualObjects(@0, _string.reset().rawValue(@"0").numberValue);
    XCTAssertEqualObjects(@1, _string.reset().rawValue(@"1").numberValue);
    XCTAssertEqualObjects(@0, _string.reset().rawValue(@"a").numberValue);

    // String or number.
    XCTAssertEqualObjects(nil, _stringOrNumber.reset().numberValue);
    XCTAssertEqualObjects(@-1, _stringOrNumber.reset().rawValue(@"-1").numberValue);
    XCTAssertEqualObjects(@0, _stringOrNumber.reset().rawValue(@"0").numberValue);
    XCTAssertEqualObjects(@1, _stringOrNumber.reset().rawValue(@"1").numberValue);
    XCTAssertEqualObjects(nil, _stringOrNumber.reset().rawValue(@"a").numberValue);

    // Multiple values.
    NSArray* array = @[@"Okay", @"42%", @2, @YES];
    XCTAssertEqualObjects(@0, _boolean.reset().max(array.count).overrideValues(array).numberValue);
    XCTAssertEqualObjects(@1, _boolean.reset().max(array.count).overrideValues(@[@"YES", @"Okay"]).numberValue);
    XCTAssertEqualObjects(@4, _number.reset().max(array.count).overrideValues(array).numberValue);
    XCTAssertEqualObjects(@4, _string.reset().max(array.count).overrideValues(array).numberValue);
    XCTAssertEqualObjects(@4, _stringOrNumber.reset().max(array.count).overrideValues(array).numberValue);
}

- (void) testNumericalProperties {
    NSArray *keys = @[@"doubleValue", @"floatValue", @"intValue", @"integerValue", @"unsignedIntValue", @"unsignedIntegerValue"];
    for (NSString* key in keys) {
        // Boolean.
        XCTAssertEqual([@0 valueForKey:key], [_boolean.reset() valueForKey:key]);
        XCTAssertEqual([@0 valueForKey:key], [_boolean.reset().rawValue(@"-1") valueForKey:key]);
        XCTAssertEqual([@0 valueForKey:key], [_boolean.reset().rawValue(@"0") valueForKey:key]);
        XCTAssertEqual([@1 valueForKey:key], [_boolean.reset().rawValue(@"1") valueForKey:key]);
        XCTAssertEqual([@0 valueForKey:key], [_boolean.reset().rawValue(@"a") valueForKey:key]);

        // Number.
        if (![key isEqualToString:@"unsignedIntValue"] && ![key isEqualToString:@"unsignedIntegerValue"]) {
            XCTAssertEqual([_number.reset().rawValue(@"-1") valueForKey:key], [@-1 valueForKey:key]);
        }
        XCTAssertEqual([@0 valueForKey:key], [_number.reset() valueForKey:key]);
        XCTAssertEqual([@0 valueForKey:key], [_number.reset().rawValue(@"0") valueForKey:key]);
        XCTAssertEqual([@1 valueForKey:key], [_number.reset().rawValue(@"1") valueForKey:key]);
        XCTAssertEqual([@0 valueForKey:key], [_number.reset().rawValue(@"a") valueForKey:key]);

        // String.
        if (![key isEqualToString:@"unsignedIntValue"] && ![key isEqualToString:@"unsignedIntegerValue"]) {
            XCTAssertEqual([@-1 valueForKey:key], [_string.reset().rawValue(@"-1") valueForKey:key]);
        }
        XCTAssertEqual([@0 valueForKey:key], [_string.reset() valueForKey:key]);
        XCTAssertEqual([@0 valueForKey:key], [_string.reset().rawValue(@"0") valueForKey:key]);
        XCTAssertEqual([@1 valueForKey:key], [_string.reset().rawValue(@"1") valueForKey:key]);
        XCTAssertEqual([@0 valueForKey:key], [_string.reset().rawValue(@"a") valueForKey:key]);

        // String or number.
        if (![key isEqualToString:@"unsignedIntValue"] && ![key isEqualToString:@"unsignedIntegerValue"]) {
            XCTAssertEqual([@-1 valueForKey:key], [_stringOrNumber.reset().rawValue(@"-1") valueForKey:key]);
        }
        XCTAssertEqual([@0 valueForKey:key], [_stringOrNumber.reset() valueForKey:key]);
        XCTAssertEqual([@0 valueForKey:key], [_stringOrNumber.reset().rawValue(@"0") valueForKey:key]);
        XCTAssertEqual([@1 valueForKey:key], [_stringOrNumber.reset().rawValue(@"1") valueForKey:key]);
        XCTAssertEqual([@0 valueForKey:key], [_stringOrNumber.reset().rawValue(@"a") valueForKey:key]);
    }
}

- (void) testPercentageOf {
    XCTAssertEqual(25, [_string.reset().rawValue(@"25%") percentageOf:100]);
    XCTAssertEqual(50, [_string.reset().rawValue(@"50%") percentageOf:100]);
    XCTAssertEqual(10.5, [_string.reset().rawValue(@"25%") percentageOf:42]);
    XCTAssertEqual(21, [_string.reset().rawValue(@"50%") percentageOf:42]);
    XCTAssertEqual(25, [_stringOrNumber.reset().rawValue(@"25%") percentageOf:100]);
    XCTAssertEqual(50, [_stringOrNumber.reset().rawValue(@"50%") percentageOf:100]);
    XCTAssertEqual(10.5, [_stringOrNumber.reset().rawValue(@"25%") percentageOf:42]);
    XCTAssertEqual(21, [_stringOrNumber.reset().rawValue(@"50%") percentageOf:42]);
}

- (void) testPercentValue {
    // Boolean.
    XCTAssertEqualObjects(nil, _boolean.reset().rawValue(@"-1").percentValue);
    XCTAssertEqualObjects(nil, _boolean.reset().rawValue(@"0").percentValue);
    XCTAssertEqualObjects(nil, _boolean.reset().rawValue(@"1").percentValue);
    XCTAssertEqualObjects(nil, _boolean.reset().rawValue(@"a").percentValue);
    XCTAssertEqualObjects(nil, _boolean.reset().rawValue(@"0%").percentValue);
    XCTAssertEqualObjects(nil, _boolean.reset().rawValue(@"10%").percentValue);
    XCTAssertEqualObjects(nil, _boolean.reset().rawValue(@"99%").percentValue);

    // Number.
    XCTAssertEqualObjects(nil, _number.reset().rawValue(@"-1").percentValue);
    XCTAssertEqualObjects(nil, _number.reset().rawValue(@"0").percentValue);
    XCTAssertEqualObjects(nil, _number.reset().rawValue(@"1").percentValue);
    XCTAssertEqualObjects(nil, _number.reset().rawValue(@"a").percentValue);
    XCTAssertEqualObjects([NSNumber numberWithDouble:0].percent(YES), _number.reset().rawValue(@"0%").percentValue);
    XCTAssertEqual(YES, _number.reset().rawValue(@"0%").percentValue.isPercent);
    XCTAssertEqualObjects([NSNumber numberWithDouble:10].percent(YES), _number.reset().rawValue(@"10%").percentValue);
    XCTAssertEqual(YES, _number.reset().rawValue(@"10%").percentValue.isPercent);
    XCTAssertEqualObjects([NSNumber numberWithDouble:99].percent(YES), _number.reset().rawValue(@"99%").percentValue);
    XCTAssertEqual(YES, _number.reset().rawValue(@"99%").percentValue.isPercent);

    // String.
    XCTAssertEqualObjects(nil, _string.reset().rawValue(@"-1").percentValue);
    XCTAssertEqualObjects(nil, _string.reset().rawValue(@"0").percentValue);
    XCTAssertEqualObjects(nil, _string.reset().rawValue(@"1").percentValue);
    XCTAssertEqualObjects(nil, _string.reset().rawValue(@"a").percentValue);
    XCTAssertEqualObjects([NSNumber numberWithDouble:0].percent(YES), _string.reset().rawValue(@"0%").percentValue);
    XCTAssertEqual(YES, _string.reset().rawValue(@"0%").percentValue.isPercent);
    XCTAssertEqualObjects([NSNumber numberWithDouble:10].percent(YES), _string.reset().rawValue(@"10%").percentValue);
    XCTAssertEqual(YES, _string.reset().rawValue(@"10%").percentValue.isPercent);
    XCTAssertEqualObjects([NSNumber numberWithDouble:99].percent(YES), _string.reset().rawValue(@"99%").percentValue);
    XCTAssertEqual(YES, _string.reset().rawValue(@"99%").percentValue.isPercent);

    // String or number.
    XCTAssertEqualObjects(nil, _stringOrNumber.reset().rawValue(@"-1").percentValue);
    XCTAssertEqualObjects(nil, _stringOrNumber.reset().rawValue(@"0").percentValue);
    XCTAssertEqualObjects(nil, _stringOrNumber.reset().rawValue(@"1").percentValue);
    XCTAssertEqualObjects(nil, _stringOrNumber.reset().rawValue(@"a").percentValue);
    XCTAssertEqualObjects([NSNumber numberWithDouble:0].percent(YES), _stringOrNumber.reset().rawValue(@"0%").percentValue);
    XCTAssertEqual(YES, _stringOrNumber.reset().rawValue(@"0%").percentValue.isPercent);
    XCTAssertEqualObjects([NSNumber numberWithDouble:10].percent(YES), _stringOrNumber.reset().rawValue(@"10%").percentValue);
    XCTAssertEqual(YES, _stringOrNumber.reset().rawValue(@"10%").percentValue.isPercent);
    XCTAssertEqualObjects([NSNumber numberWithDouble:99].percent(YES), _stringOrNumber.reset().rawValue(@"99%").percentValue);
    XCTAssertEqual(YES, _stringOrNumber.reset().rawValue(@"99%").percentValue.isPercent);
}

- (void) testProcess {
    CDOptionProcessBlock block = ^(CDControl* control) {};
    XCTAssertTrue([_boolean.reset().process(block).processBlocks indexOfObjectIdenticalTo:block] != NSNotFound);
    XCTAssertTrue([_number.reset().process(block).processBlocks indexOfObjectIdenticalTo:block] != NSNotFound);
    XCTAssertTrue([_string.reset().process(block).processBlocks indexOfObjectIdenticalTo:block] != NSNotFound);
    XCTAssertTrue([_stringOrNumber.reset().process(block).processBlocks indexOfObjectIdenticalTo:block] != NSNotFound);
}

- (void) testRequire {
    XCTAssertTrue(_boolean.reset().require(YES).required == YES);
    XCTAssertTrue(_number.reset().require(YES).required == YES);
    XCTAssertTrue(_string.reset().require(YES).required == YES);
    XCTAssertTrue(_stringOrNumber.reset().require(YES).required == YES);
}

- (void) testSetDefaultValue {
    NSNumber *b = @YES;
    NSString *s = @"value";
    NSNumber *n = @2;
    CDOptionAutomaticValueBlock block = (CDOptionAutomaticValueBlock) ^(){return @42;};
    XCTAssertTrue([b isEqualTo:_boolean.reset().setDefaultValue(b).defaultValue]);
    XCTAssertTrue([n isEqualTo:_number.reset().setDefaultValue(n).defaultValue]);
    XCTAssertTrue([s isEqualTo:_string.reset().setDefaultValue(s).defaultValue]);
    XCTAssertTrue([s isEqualTo:_stringOrNumber.reset().setDefaultValue(s).defaultValue]);
    XCTAssertEqualObjects(@YES, _boolean.reset().setDefaultValue(block).defaultValue);
    XCTAssertEqualObjects(@42, _number.reset().setDefaultValue(block).defaultValue);
    XCTAssertEqualObjects(@"42", _string.reset().setDefaultValue(block).defaultValue);
    XCTAssertEqualObjects(@42, _stringOrNumber.reset().setDefaultValue(block).defaultValue);
}

- (void) testSetScope {
    NSString *scope = @"a scope";
    XCTAssertTrue(_boolean.reset().setScope(scope).scope == scope);
    XCTAssertTrue(_number.reset().setScope(scope).scope == scope);
    XCTAssertTrue(_string.reset().setScope(scope).scope == scope);
    XCTAssertTrue(_stringOrNumber.reset().setScope(scope).scope == scope);
}

- (void) testStringValue {
    // Single value.
    XCTAssertEqualObjects(@"YES".localized, _boolean.reset().rawValue(@"YES").stringValue);
    XCTAssertEqualObjects(@"1", _number.reset().rawValue(@"1").stringValue);
    XCTAssertEqualObjects(@"Okay", _string.reset().rawValue(@"Okay").stringValue);
    XCTAssertEqualObjects(@"2", _stringOrNumber.reset().rawValue(@"2").stringValue);
    XCTAssertEqualObjects(@"2", _stringOrNumber.reset().overrideValues(@[@2]).stringValue);

    // Multiple values.
    NSArray* array = @[@"Okay", @"42%", @2, @YES];
    XCTAssertEqualObjects(@"NO".localized, _boolean.reset().max(array.count).overrideValues(array).stringValue);
    XCTAssertEqualObjects(@"0, 42%, 2, 1", _number.reset().max(array.count).overrideValues(array).stringValue);
    XCTAssertEqualObjects(@"Okay, 42%, 2, 1", _string.reset().max(array.count).overrideValues(array).stringValue);
    XCTAssertEqualObjects(@"Okay, 42%, 2, 1", _stringOrNumber.reset().max(array.count).overrideValues(array).stringValue);
}

- (void) testToValueIndex {
    XCTAssertEqualObjects(@2, _boolean.reset().toValueIndex(2).deprecatedValueIndex);
    XCTAssertEqualObjects(@2, _number.reset().toValueIndex(2).deprecatedValueIndex);
    XCTAssertEqualObjects(@2, _string.reset().toValueIndex(2).deprecatedValueIndex);
    XCTAssertEqualObjects(@2, _stringOrNumber.reset().toValueIndex(2).deprecatedValueIndex);
}

- (void) testTypeColor {
    XCTAssertTrue(_boolean.reset().typeColor.fg == CDColorFgMagenta);
    XCTAssertTrue(_number.reset().typeColor.fg == CDColorFgCyan);
    XCTAssertTrue(_string.reset().typeColor.fg == CDColorFgGreen);
    XCTAssertTrue(_stringOrNumber.reset().typeColor.fg == CDColorFgYellow);
}

- (void) testTypeLabel {
    CDOptionAutomaticValueBlock block = (CDOptionAutomaticValueBlock) ^(){return @NO;};
    NSString* booleanLabel = @"<%@>".arguments(@"USAGE_OPTION_TYPE_BOOLEAN".localized, nil);
    NSString* numberLabel = @"<%@>".arguments(@"USAGE_OPTION_TYPE_NUMBER".localized, nil);
    NSString* stringLabel = @"<%@>".arguments(@"USAGE_OPTION_TYPE_STRING".localized, nil);
    NSString* stringOrNumberLabel = @"<%@|%@>".arguments(@"USAGE_OPTION_TYPE_NUMBER".localized, @"USAGE_OPTION_TYPE_STRING".localized, nil);
    XCTAssertEqualObjects(booleanLabel, _boolean.reset().setDefaultValue(block).typeLabel);
    XCTAssertEqualObjects(numberLabel, _number.reset().typeLabel);
    XCTAssertEqualObjects(stringLabel, _string.reset().typeLabel);
    XCTAssertEqualObjects(stringOrNumberLabel, _stringOrNumber.reset().typeLabel);
    XCTAssertEqualObjects(booleanLabel, _boolean.reset().max(-1).typeLabel);
    XCTAssertEqualObjects(numberLabel.append(@" [...]"), _number.reset().max(-1).typeLabel);
    XCTAssertEqualObjects(stringLabel.append(@" [...]"), _string.reset().max(-1).typeLabel);
    XCTAssertEqualObjects(stringOrNumberLabel.append(@" [...]"), _stringOrNumber.reset().max(-1).typeLabel);
    XCTAssertEqualObjects(booleanLabel, _boolean.reset().max(2).typeLabel);
    XCTAssertEqualObjects(numberLabel.append(@" [%@]".arguments(numberLabel, nil)), _number.reset().max(2).typeLabel);
    XCTAssertEqualObjects(stringLabel.append(@" [%@]".arguments(stringLabel, nil)), _string.reset().max(2).typeLabel);
    XCTAssertEqualObjects(stringOrNumberLabel.append(@" [%@]".arguments(stringOrNumberLabel, nil)), _stringOrNumber.reset().max(2).typeLabel);
    XCTAssertEqualObjects(booleanLabel, _boolean.reset().max(3).typeLabel);
    XCTAssertEqualObjects(numberLabel.append(@" [%@, %@]".arguments(numberLabel, numberLabel, nil)), _number.reset().max(3).typeLabel);
    XCTAssertEqualObjects(stringLabel.append(@" [%@, %@]".arguments(stringLabel, stringLabel, nil)), _string.reset().max(3).typeLabel);
    XCTAssertEqualObjects(stringOrNumberLabel.append(@" [%@, %@]".arguments(stringOrNumberLabel, stringOrNumberLabel, nil)), _stringOrNumber.reset().max(3).typeLabel);
}

- (void) testValueType {
    XCTAssertEqual(CDBoolean, _boolean.valueType);
    XCTAssertEqual(CDNumber, _number.valueType);
    XCTAssertEqual(CDString, _string.valueType);
    XCTAssertEqual(CDStringOrNumber, _stringOrNumber.valueType);
}

@end
