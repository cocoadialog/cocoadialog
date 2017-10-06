// CDOption.m
// cocoadialog
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.

#import "CDOption.h"

@implementation CDOption

@synthesize maximumValues, minimumValues;

#pragma mark - Properties
- (NSArray *) arrayValue {
    NSUInteger i = 0;
    NSMutableArray *values = [NSMutableArray array];
    NSArray *originalValues = self.value ? [self.value isKindOfClass:[NSArray class]] ? self.value : @[self.value] : @[];
    for (NSString *value in originalValues) {
        [values addObject:value];
        i++;
    }
    if (self.maximumValues.unsignedIntegerValue > 0) {
        for (; i < self.maximumValues.unsignedIntegerValue; i++) {
            [values addObject:[NSNull null]];
        }
    }
    return values;
}

- (BOOL) boolValue {
    NSNumber *number = [self numberValue];
    return number != nil ? number.boolValue : NO;
}

- (id) defaultValue {
    id value = nil;

    // Determine if default values is "automatic".
    if (self.hasAutomaticDefaultValue) {
        CDOptionAutomaticDefaultValue block = (CDOptionAutomaticDefaultValue) _defaultValue;
        value = block();
    }
    // Otherwise, just assign the default value.
    else {
        value = _defaultValue;
    }
    return value;
}

- (NSString *) displayValue {
    return self.stringValue;
}

- (double) doubleValue {
    NSNumber *number = [self numberValue];
    return number != nil ? number.doubleValue : 0;
}

- (float) floatValue {
    NSNumber *number = [self numberValue];
    return number != nil ? number.floatValue : 0;
}

- (id) jsonValue {
    return
    @{
      @"allowedValues": self.allowedValues.count > 0 ? self.allowedValues : [NSNull null],
      @"automaticDefaultValue": [NSNumber numberWithBool:self.hasAutomaticDefaultValue],
      @"category": self.category ?: [NSNull null],
      @"description": self.helpText ?: [NSNull null],
      @"defaultValue": self.defaultValue ?: [NSNull null],
      @"maximumValues": self.maximumValues,
      @"minimumValues": self.minimumValues,
      @"name": self.name ?: [NSNull null],
      @"notes": self.notes ?: [NSNull null],
      @"required": [NSNumber numberWithBool:self.required],
      @"type": [self className] ?: [NSNull null],
      @"typeLabel": self.typeLabel.removeColor ?: [NSNull null],
      @"warnings": self.warnings ?: @[],
      @"wasProvided": [NSNumber numberWithBool:self.wasProvided],
      };
}

- (NSString *) toJSONString {
    return [CDJson objectToJSON:self.jsonValue];
}

- (BOOL) hasAutomaticDefaultValue {
    // There is no good way to check the "type" of block. The best that can be
    // accomlished here is to see if it is one and then just assume that it's a
    // valid CDOptionAutomaticDefaultValue block.
    // @todo https://github.com/ebf/CTObjectiveCRuntimeAdditions
    // @see http://stackoverflow.com/a/10944983/1226717
    return _defaultValue != nil && [_defaultValue isKindOfClass:NSClassFromString(@"NSBlock")];
}

- (int) intValue {
    NSNumber *number = [self numberValue];
    return number != nil ? number.intValue : (int) 0;
}

- (NSInteger) integerValue {
    NSNumber *number = [self numberValue];
    return number != nil ? number.integerValue : (NSInteger) 0;
}

- (NSString *) label {
    return _name.optionFormat;
}

- (NSNumber *) numberValue {
    id value = self.value;
    if (value != nil && [value isKindOfClass:[NSString class]]) {
        NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
        f.numberStyle = NSNumberFormatterDecimalStyle;
        return [f numberFromString:value];
    }
    else if (value != nil && [value isKindOfClass:[NSNumber class]]) {
        return value;
    }
    return nil;
}

- (NSNumber *) percentValue {
    NSNumber *number = self.numberValue;
    if (_isPercent && number != nil) {
        return [NSNumber numberWithDouble:[number doubleValue] * 100];
    }
    return nil;
}

- (NSString *) stringValue {
    id value = self.value;
    if (value != nil && [value isKindOfClass:[NSString class]]) {
        return value;
    }
    else if (value != nil && [value isKindOfClass:[NSNumber class]]) {
        NSNumber *number = value;
        return number.stringValue;
    }
    return nil;
}

- (CDColor *) typeColor {
    return [CDColor color];
}

- (unsigned int) unsignedIntValue {
    NSNumber *number = [self numberValue];
    return number != nil ? number.unsignedIntValue : (unsigned int) 0;
}

- (NSUInteger) unsignedIntegerValue {
    NSNumber *number = [self numberValue];
    return number != nil ? number.unsignedIntegerValue : (NSUInteger) 0;
}

- (id) value {
    // Use default value if none was provided.
    if (!_wasProvided && _value == nil && _defaultValue != nil) {
        // Determine if default values is "automatic".
        if (self.hasAutomaticDefaultValue) {
            CDOptionAutomaticDefaultValue block = (CDOptionAutomaticDefaultValue) _defaultValue;
            _value = block();
        }
        // Otherwise, just assign the default value.
        else {
            _value = _defaultValue;
        }
    }
    return _value;
}

#pragma mark - Public static methods
+ (instancetype) name:(NSString *)name {
    return [[self alloc] initWithName:name category:nil];
}

+ (instancetype) name:(NSString *)name category:(NSString *) category {
    return [[self alloc] initWithName:name category:category];
}

+ (instancetype) name:(NSString *)name replacedBy:(NSString *)replacement {
    CDOption *option = [[self alloc] initWithName:name category:nil];
    option.deprecatedTo = replacement;
    return option;
}

+ (instancetype) name:(NSString *)name replacedBy:(NSString *)replacement valueIndex:(NSUInteger)valueIndex {
    CDOption *option = [[self alloc] initWithName:name category:nil];
    option.deprecatedTo = replacement;
    option.deprecatedValueIndex = [NSNumber numberWithUnsignedInteger:valueIndex];
    return option;
}

#pragma mark - Public instance methods
- (void) addConditionalRequirement:(CDOptionConditionalRequirement)block {
    [_conditionalRequirements addObject:[block copy]];
}

- (instancetype) init {
    self = [super init];
    if (self) {
        minimumValues = @0;
        maximumValues = @1;
        _allowedValues = [NSMutableArray array];
        _conditionalRequirements = [NSMutableArray array];
        _notes = [NSMutableArray array];
        _providedValues = [NSMutableArray array];
        _warnings = [NSMutableArray array];
    }
    return self;
}

- (instancetype) initWithName:(NSString *)name category:(NSString *) category {
    self = [self init];
    if (self) {
        _name = name;

        if (category != nil) {
            _category = NSLocalizedString(category, nil);
        }

        NSCharacterSet *nonAlphanumericSet = [[NSCharacterSet alphanumericCharacterSet] invertedSet];
        NSMutableString *autoHelpText = [NSMutableString string];
        if (category != nil) {
            [autoHelpText appendString:[category.uppercaseString stringByReplacingCharactersInSet:nonAlphanumericSet withString:@"_"]];
        }
        else {
            [autoHelpText appendString:[NSLocalizedString(@"USAGE_CATEGORY_CONTROL", nil).uppercaseString stringByReplacingCharactersInSet:nonAlphanumericSet withString:@"_"]];
        }
        [autoHelpText appendString:@"_"];
        [autoHelpText appendString:[name.uppercaseString stringByReplacingCharactersInSet:nonAlphanumericSet withString:@"_"]];
        _helpText = NSLocalizedString(autoHelpText, nil);
    }
    return self;
}

- (void) overrideValue:(NSString *)value {
    self.wasProvided = YES;
    [self setValues:@[value]];
}

- (float) percentageOf:(float)value {
    return (value / 100.0f) * [self.percentValue floatValue];
}

- (void) setValue:(id)value atIndex:(NSInteger)index {
    if (value == nil) {
        value = [NSNull null];
    }

    NSMutableArray *values = [NSMutableArray arrayWithArray:_providedValues];
    NSInteger count = (int) values.count - 1;

    if (index > count) {
        NSUInteger missingItemsCount = index - (values.count - 1);
        while (missingItemsCount > 0) {
            [values addObject:[NSNull null]];
            missingItemsCount--;
        }
    }

    [values replaceObjectAtIndex:index withObject:value];

    [self setValues:values];
}

- (void) setValues:(NSArray<NSString *> *)values {
    _providedValues = [NSMutableArray arrayWithArray:values];
}

@end

// Boolean.
#pragma mark -
@implementation CDOptionBoolean

#pragma mark - Public static methods
+ (BOOL) boolFromString:(NSString *)string {
    return [string isEqualToStringCaseInsensitive:@"1"]
        || [string isEqualToStringCaseInsensitive:@"on"]
        || [string isEqualToStringCaseInsensitive:@"true"]
        || [string isEqualToStringCaseInsensitive:@"yes"]
    ;
}

#pragma mark - Public instance methods
- (instancetype) init {
    self = [super init];
    if (self) {
        self.minimumValues = @0;
        self.maximumValues = @1;
    }
    return self;
}

- (void) setValues:(NSArray<NSString *> *)values {
    // Retrieve only the last specified value, defaulting to YES if none were provided.
    self.value = [NSNumber numberWithBool:[CDOptionBoolean boolFromString:values.count ? values[values.count - 1] : @"YES"]];
}

#pragma mark - Properties
- (NSString *) stringValue {
    BOOL boolValue = self.boolValue;
    return boolValue ? NSLocalizedString(@"YES", nil) : NSLocalizedString(@"NO", nil);
}

- (CDColor *) typeColor {
    return [CDColor fg:CDColorFgMagenta];
}

- (NSString *) typeLabel {
    NSString *typeLabel = [NSString stringWithFormat:@"<%@>", NSLocalizedString(@"OPTION_TYPE_BOOLEAN", nil)].magenta;
    if (self.hasAutomaticDefaultValue) {
        typeLabel = typeLabel.dim;
    }
    return typeLabel;
}

@end

// Single string.
#pragma mark -
@implementation CDOptionSingleString

#pragma mark - Public instance methods
- (instancetype) init {
    self = [super init];
    if (self) {
        self.minimumValues = @1;
        self.maximumValues = @1;
    }
    return self;
}

- (void) setValues:(NSArray<NSString *> *)values {
    [super setValues:values];
    if (!values.count) {
        return;
    }
    self.value = values[values.count - 1];
}

#pragma mark - Properties
- (NSString *) displayValue {
    return self.stringValue.doubleQuote;
}

- (CDColor *) typeColor {
    return [CDColor fg:CDColorFgGreen];
}

- (NSString *) typeLabel {
    NSString *typeLabel = [NSString stringWithFormat:@"<%@>", NSLocalizedString(@"OPTION_TYPE_STRING", nil)].green;
    if (self.hasAutomaticDefaultValue) {
        typeLabel = typeLabel.dim;
    }
    return typeLabel;
}

@end

// Single number.
#pragma mark -
@implementation CDOptionSingleNumber

#pragma mark - Public instance methods
- (instancetype) init {
    self = [super init];
    if (self) {
        self.minimumValues = @1;
        self.maximumValues = @1;
    }
    return self;
}

- (void) setValues:(NSArray<NSString *> *)values {
    [super setValues:values];
    if (!values.count) {
        return;
    }
    BOOL percent = NO;
    NSString *stringValue = values[values.count - 1];
    double doubleValue = [stringValue doubleValue];
    NSString *percentRange = [stringValue endsWith:@"%"];
    if (percentRange != nil) {
        percent = YES;
        stringValue = [stringValue stringByReplacingCharactersInRange:NSRangeFromString(percentRange) withString:@""];
        doubleValue = [stringValue doubleValue];
    }
    if (percent) {
        _isPercent = YES;
        doubleValue /= 100;
    }
    self.value = [NSNumber numberWithDouble:doubleValue];
}

#pragma mark - Properties
- (NSString *) stringValue {
    NSNumber *number = self.numberValue;
    if (number != nil) {
        if (_isPercent) {
            NSUInteger percent = [number doubleValue] * 100;
            return [NSString stringWithFormat:@"%lu%%", percent];
        }
        else {
            return [number stringValue];
        }
    }
    return nil;
}

- (CDColor *) typeColor {
    return [CDColor fg:CDColorFgCyan];
}

- (NSString *) typeLabel {
    NSString *typeLabel = [NSString stringWithFormat:@"<%@>", NSLocalizedString(@"OPTION_TYPE_NUMBER", nil)].cyan;
    if (self.hasAutomaticDefaultValue) {
        typeLabel = typeLabel.dim;
    }
    return typeLabel;
}


@end

// Single string or number.
#pragma mark -
@implementation CDOptionSingleStringOrNumber

#pragma mark - Public instance methods
- (instancetype) init {
    self = [super init];
    if (self) {
        self.minimumValues = @1;
        self.maximumValues = @1;
    }
    return self;
}

- (void) setValues:(NSArray<NSString *> *)values {
    [super setValues:values];
    if (!values.count) {
        return;
    }

    NSString *stringValue = values[values.count - 1];
    NSNumber *number = [[NSNumberFormatter alloc] numberFromString:stringValue];

    BOOL percent = NO;
    NSString *percentRange = [stringValue endsWith:@"%"];
    if (percentRange != nil) {
        percent = YES;
        stringValue = [stringValue stringByReplacingCharactersInRange:NSRangeFromString(percentRange) withString:@""];
        _isPercent = YES;
        self.value = [NSNumber numberWithDouble:[stringValue doubleValue] / 100];
    }
    else if (number != nil) {
        self.value = number;
    }
    else {
        self.value = stringValue;
    }
}

#pragma mark - Properties
- (NSString *) displayValue {
    return [self.value isKindOfClass:[NSString class]] ? self.stringValue.doubleQuote : self.stringValue;
}

- (CDColor *) typeColor {
    return [CDColor fg:CDColorFgYellow];
}

- (NSString *) typeLabel {
    NSString *typeLabel = [NSString stringWithFormat:@"<%@|%@>", NSLocalizedString(@"OPTION_TYPE_NUMBER", nil), NSLocalizedString(@"OPTION_TYPE_STRING", nil)].yellow;
    if (self.hasAutomaticDefaultValue) {
        typeLabel = typeLabel.dim;
    }
    return typeLabel;
}

@end

// Multiple strings.
#pragma mark -
@implementation CDOptionMultipleStrings

#pragma mark - Public instance methods
- (instancetype) init {
    self = [super init];
    if (self) {
        self.minimumValues = @1;
        self.maximumValues = @0;
    }
    return self;
}

- (void) setValues:(NSArray<NSString *> *)values {
    [super setValues:values];
    self.value = values;
}

#pragma mark - Properties
- (NSArray *) arrayValue {
    return [[super arrayValue] replaceNullValuesWith: @""];
}

- (NSString *) displayValue {
    NSArray *originalValues = self.arrayValue;
    NSMutableArray *values = [NSMutableArray array];
    for (NSUInteger i = 0; i < originalValues.count; i++) {
        NSString *value = originalValues[i];
        [values addObject:[NSString stringWithFormat:@"(%li) %@", i, value.doubleQuote]];
    }
    return [NSString stringWithFormat:@"[ %@ ]", [values componentsJoinedByString:@", "]];
}

- (NSNumber *) numberValue {
    return [NSNumber numberWithUnsignedInteger:self.arrayValue.count];
}

- (NSString *) stringValue {
    return [self.arrayValue.doubleQuote componentsJoinedByString:@", "];
}

- (CDColor *) typeColor {
    return [CDColor fg:CDColorFgGreen];
}

- (NSString *) typeLabel {
    NSString *typeLabel = [NSString stringWithFormat:@"<%@> [...] --", NSLocalizedString(@"OPTION_TYPE_STRING", nil)].green;
    if (self.hasAutomaticDefaultValue) {
        typeLabel = typeLabel.dim;
    }
    return typeLabel;
}

@end

// Multiple numbers.
#pragma mark -
@implementation CDOptionMultipleNumbers

#pragma mark - Public instance methods
- (instancetype) init {
    self = [super init];
    if (self) {
        self.minimumValues = @1;
        self.maximumValues = @0;
    }
    return self;
}

- (void) setValues:(NSArray<NSString *> *)values {
    [super setValues:values];
    NSMutableArray *numbers = [NSMutableArray array];
    for (NSUInteger i = 0; i < values.count; i++) {
        numbers[i] = [NSNumber numberWithLongLong:[values[i] longLongValue]];
    }
    self.value = numbers;
}

#pragma mark - Properties
- (NSArray *) arrayValue {
    return [[super arrayValue] replaceNullValuesWith: @0];
}

- (NSString *) displayValue {
    NSArray *originalValues = self.arrayValue;
    NSMutableArray *values = [NSMutableArray array];
    for (NSUInteger i = 0; i < originalValues.count; i++) {
        NSString *value = originalValues[i];
        [values addObject:[NSString stringWithFormat:@"(%li) %@", i, value]];
    }
    return [NSString stringWithFormat:@"[ %@ ]", [values componentsJoinedByString:@", "]];
}

- (NSNumber *) numberValue {
    return [NSNumber numberWithUnsignedInteger:self.arrayValue.count];
}

- (NSString *) stringValue {
    return [self.arrayValue componentsJoinedByString:@", "];
}

- (CDColor *) typeColor {
    return [CDColor fg:CDColorFgCyan];
}

- (NSString *) typeLabel {
    NSString *typeLabel = [NSString stringWithFormat:@"<%@> [...] --", NSLocalizedString(@"OPTION_TYPE_NUMBER", nil)].cyan;
    if (self.hasAutomaticDefaultValue) {
        typeLabel = typeLabel.dim;
    }
    return typeLabel;
}

@end

// Multiple strings or numbers.
#pragma mark -
@implementation CDOptionMultipleStringsOrNumbers

#pragma mark - Public instance methods
- (instancetype) init {
    self = [super init];
    if (self) {
        self.minimumValues = @1;
        self.maximumValues = @0;
    }
    return self;
}

- (void) setValues:(NSArray<NSString *> *)values {
    [super setValues:values];
    self.value = values;
}

#pragma mark - Properties
- (NSArray *) arrayValue {
    return [[super arrayValue] replaceNullValuesWith: @0];
}

- (NSString *) displayValue {
    NSArray *originalValues = self.arrayValue;
    NSMutableArray *values = [NSMutableArray array];
    for (NSUInteger i = 0; i < originalValues.count; i++) {
        NSString *value = originalValues[i];
        [values addObject:[NSString stringWithFormat:@"(%li) %@", i, [value isKindOfClass:[NSString class]] ? value.doubleQuote : value]];
    }
    return [NSString stringWithFormat:@"[ %@ ]", [values componentsJoinedByString:@", "]];
}

- (NSNumber *) numberValue {
    return [NSNumber numberWithUnsignedInteger:self.arrayValue.count];
}

- (NSString *) stringValue {
    return [self.arrayValue componentsJoinedByString:@", "];
}

- (CDColor *) typeColor {
    return [CDColor fg:CDColorFgYellow];
}

- (NSString *) typeLabel {
    NSString *typeLabel = [NSString stringWithFormat:@"<%@|%@> [...] --", NSLocalizedString(@"OPTION_TYPE_NUMBER", nil), NSLocalizedString(@"OPTION_TYPE_STRING", nil)].yellow;
    if (self.hasAutomaticDefaultValue) {
        typeLabel = typeLabel.dim;
    }
    return typeLabel;
}

@end
