//
//  CDOptionTests.m
//  CDOptionTests
//
//  Created by Mark Carver on 10/9/17.
//

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

- (void) testArrayOfStrings {
    NSArray *array = @[@"Okay", @"42%", @2, @YES];
    NSArray *expected;

    // Booleans.
    expected = @[@"NO".localized];
    XCTAssertEqualObjects(expected, _boolean.reset().max(array.count + 1).overrideValues(array).arrayOfStrings);

    // Number.
    expected = @[@"0", @"42%", @"2", @"1", @"0"];
    XCTAssertEqualObjects(expected, _number.reset().max(array.count + 1).overrideValues(array).arrayOfStrings);

    // String.
    expected = @[@"Okay", @"42%", @"2", @"1", @""];
    XCTAssertEqualObjects(expected, _string.reset().max(array.count + 1).overrideValues(array).arrayOfStrings);

    // String or number.
    expected = @[@"Okay", @"42%", @"2", @"1", @""];
    XCTAssertEqualObjects(expected, _stringOrNumber.reset().max(array.count + 1).overrideValues(array).arrayOfStrings);
}

- (void) testArrayOfNumbers {
    NSArray *array = @[@"Okay", @"42%", @2, @YES];
    NSArray *expected;

    // Booleans.
    expected = @[@0];
    XCTAssertEqualObjects(expected, _boolean.reset().max(array.count + 1).overrideValues(array).arrayOfNumbers);

    // Number.
    expected = @[@0, @.42, @2, @1, @0];
    XCTAssertEqualObjects(expected, _number.reset().max(array.count + 1).overrideValues(array).arrayOfNumbers);

    // String.
    expected = @[@0, @.42, @2, @1, @0];
    XCTAssertEqualObjects(expected, _string.reset().max(array.count + 1).overrideValues(array).arrayOfNumbers);

    // String or number.
    expected = @[@0, @.42, @2, @1, @0];
    XCTAssertEqualObjects(expected, _stringOrNumber.reset().max(array.count + 1).overrideValues(array).arrayOfNumbers);
}

- (void) testArrayOfStringOrNumbers {
    NSArray *array = @[@"Okay", @"42%", @2, @YES];
    NSArray *expected;

    // Booleans.
    expected = @[@"NO".localized];
    XCTAssertEqualObjects(expected, _boolean.reset().max(array.count + 1).overrideValues(array).arrayOfStringOrNumbers);

    // Number.
    expected = @[@0, @.42, @2, @1, @0];
    XCTAssertEqualObjects(expected, _number.reset().max(array.count + 1).overrideValues(array).arrayOfStringOrNumbers);

    // String.
    expected = @[@"Okay", @"42%", @"2", @"1", @""];
    XCTAssertEqualObjects(expected, _string.reset().max(array.count + 1).overrideValues(array).arrayOfStringOrNumbers);

    // String or number.
    expected = @[@"Okay", @"42%", @2, @1, @""];
    XCTAssertEqualObjects(expected, _stringOrNumber.reset().max(array.count + 1).overrideValues(array).arrayOfStringOrNumbers);
}

// Value properties.
- (void) testArrayValue {
    NSArray *array = @[@"Okay", @"42%", @2, @YES];
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
    expected = @[@"Okay", @"42%", @2, @1, @""];
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

- (void) testDisplayValue {
    XCTAssertEqualObjects(@"YES".localized, _boolean.reset().rawValue(@"YES").displayValue);
    XCTAssertEqualObjects(@"42", _number.reset().rawValue(@"42").displayValue);
    XCTAssertEqualObjects(@"\"Okay\"", _string.reset().rawValue(@"Okay").displayValue);
    XCTAssertEqualObjects(@"\"Okay\"", _stringOrNumber.reset().rawValue(@"Okay").displayValue);
    XCTAssertEqualObjects(@"42", _stringOrNumber.reset().overrideValues(@[@42]).displayValue);

    NSArray *array = @[@"Okay", @"42%", @2, @YES];
    XCTAssertEqualObjects(@"NO".localized, _boolean.reset().max(array.count).overrideValues(array).displayValue);
    XCTAssertEqualObjects(@"[(0) 0, (1) 0.42, (2) 2, (3) 1]", _number.reset().max(array.count).overrideValues(array).displayValue);
    XCTAssertEqualObjects(@"[(0) \"Okay\", (1) \"42%\", (2) \"2\", (3) \"1\"]", _string.reset().max(array.count).overrideValues(array).displayValue);
    XCTAssertEqualObjects(@"[(0) \"Okay\", (1) \"42%\", (2) 2, (3) 1]", _stringOrNumber.reset().max(array.count).overrideValues(array).displayValue);
}

- (void) testInvalidOption {
    XCTAssertThrowsSpecificNamed(CDOption.create(-1, @"a"), NSException, NSInvalidArgumentException);
    XCTAssertThrowsSpecificNamed(CDOption.create(CDString, nil), NSException, NSInvalidArgumentException);
    XCTAssertThrowsSpecificNamed(CDOption.create(CDString, @""), NSException, NSInvalidArgumentException);
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
    XCTAssertEqual(4, _number.reset().max(4).maximumValues.integerValue);
    XCTAssertEqual(-1, _number.reset().max(-1).maximumValues.integerValue);

    // String.
    XCTAssertEqual(2, _string.reset().max(2).maximumValues.integerValue);
    XCTAssertEqual(-1, _string.reset().max(-1).maximumValues.integerValue);

    // String or number.
    XCTAssertEqual(2, _stringOrNumber.reset().max(2).maximumValues.integerValue);
    XCTAssertEqual(-1, _stringOrNumber.reset().max(-1).maximumValues.integerValue);
}

- (void) testMinimumValues {
    // Boolean.
    XCTAssertEqual(0, _boolean.reset().min(6).minimumValues.integerValue);

    // Number.
    XCTAssertEqual(4, _number.reset().min(4).minimumValues.integerValue);

    // String.
    XCTAssertEqual(2, _string.reset().min(2).minimumValues.integerValue);

    // String or number.
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
    XCTAssertEqualObjects(@0, _boolean.reset().rawValue(@"-1").numberValue);
    XCTAssertEqualObjects(@0, _boolean.reset().rawValue(@"0").numberValue);
    XCTAssertEqualObjects(@1, _boolean.reset().rawValue(@"1").numberValue);
    XCTAssertEqualObjects(@0, _boolean.reset().rawValue(@"a").numberValue);

    // Number.
    XCTAssertEqualObjects(@-1, _number.reset().rawValue(@"-1").numberValue);
    XCTAssertEqualObjects(@0, _number.reset().rawValue(@"0").numberValue);
    XCTAssertEqualObjects(@1, _number.reset().rawValue(@"1").numberValue);
    XCTAssertEqualObjects(@0, _number.reset().rawValue(@"a").numberValue);

    // String.
    XCTAssertEqualObjects(@-1, _string.reset().rawValue(@"-1").numberValue);
    XCTAssertEqualObjects(@0, _string.reset().rawValue(@"0").numberValue);
    XCTAssertEqualObjects(@1, _string.reset().rawValue(@"1").numberValue);
    XCTAssertEqualObjects(@0, _string.reset().rawValue(@"a").numberValue);

    // String or number.
    XCTAssertEqualObjects(@-1, _stringOrNumber.reset().rawValue(@"-1").numberValue);
    XCTAssertEqualObjects(@0, _stringOrNumber.reset().rawValue(@"0").numberValue);
    XCTAssertEqualObjects(@1, _stringOrNumber.reset().rawValue(@"1").numberValue);
    XCTAssertEqualObjects(@0, _stringOrNumber.reset().rawValue(@"a").numberValue);

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
        XCTAssertEqual([@0 valueForKey:key], [_boolean.reset().rawValue(@"-1") valueForKey:key]);
        XCTAssertEqual([@0 valueForKey:key], [_boolean.reset().rawValue(@"0") valueForKey:key]);
        XCTAssertEqual([@1 valueForKey:key], [_boolean.reset().rawValue(@"1") valueForKey:key]);
        XCTAssertEqual([@0 valueForKey:key], [_boolean.reset().rawValue(@"a") valueForKey:key]);

        // Number.
        if (![key isEqualToString:@"unsignedIntValue"] && ![key isEqualToString:@"unsignedIntegerValue"]) {
            XCTAssertEqual([_number.reset().rawValue(@"-1") valueForKey:key], [@-1 valueForKey:key]);
        }
        XCTAssertEqual([@0 valueForKey:key], [_number.reset().rawValue(@"0") valueForKey:key]);
        XCTAssertEqual([@1 valueForKey:key], [_number.reset().rawValue(@"1") valueForKey:key]);
        XCTAssertEqual([@0 valueForKey:key], [_number.reset().rawValue(@"a") valueForKey:key]);

        // String.
        if (![key isEqualToString:@"unsignedIntValue"] && ![key isEqualToString:@"unsignedIntegerValue"]) {
            XCTAssertEqual([@-1 valueForKey:key], [_string.reset().rawValue(@"-1") valueForKey:key]);
        }
        XCTAssertEqual([@0 valueForKey:key], [_string.reset().rawValue(@"0") valueForKey:key]);
        XCTAssertEqual([@1 valueForKey:key], [_string.reset().rawValue(@"1") valueForKey:key]);
        XCTAssertEqual([@0 valueForKey:key], [_string.reset().rawValue(@"a") valueForKey:key]);

        // String or number.
        if (![key isEqualToString:@"unsignedIntValue"] && ![key isEqualToString:@"unsignedIntegerValue"]) {
            XCTAssertEqual([@-1 valueForKey:key], [_stringOrNumber.reset().rawValue(@"-1") valueForKey:key]);
        }
        XCTAssertEqual([@0 valueForKey:key], [_stringOrNumber.reset().rawValue(@"0") valueForKey:key]);
        XCTAssertEqual([@1 valueForKey:key], [_stringOrNumber.reset().rawValue(@"1") valueForKey:key]);
        XCTAssertEqual([@0 valueForKey:key], [_stringOrNumber.reset().rawValue(@"a") valueForKey:key]);
    }
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

- (void) testTypeLabel {
    NSString* booleanLabel = @"<%@>".arguments(@"USAGE_OPTION_TYPE_BOOLEAN".localized, nil);
    NSString* numberLabel = @"<%@>".arguments(@"USAGE_OPTION_TYPE_NUMBER".localized, nil);
    NSString* stringLabel = @"<%@>".arguments(@"USAGE_OPTION_TYPE_STRING".localized, nil);
    NSString* stringOrNumberLabel = @"<%@|%@>".arguments(@"USAGE_OPTION_TYPE_NUMBER".localized, @"USAGE_OPTION_TYPE_STRING".localized, nil);
    XCTAssertEqualObjects(booleanLabel, _boolean.reset().typeLabel);
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
