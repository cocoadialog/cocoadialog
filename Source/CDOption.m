// CDOption.m
// cocoadialog
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.

#import "CDOption.h"

#import "CDColor.h"
#import "NSArray+CDArray.h"
#import "NSNumber+CDNumber.h"
#import "NSString+CDColor.h"

@implementation CDOption

@synthesize defaultValue;

#pragma mark - Initialization
- (instancetype) initWithType:(CDOptionValueType)type name:(NSString *)name {
    self = [super init];
    if (self) {
        // Required (throws if not valid).
        if (!name || name.isBlank) {
            @throw [NSInvalidArgumentException initWithString:@"CDOption name cannot be nil or blank."];
        }
        _name = name;

        if (type < CDString || type > CDBoolean) {
            @throw [NSInvalidArgumentException initWithString:@"CDOption type must be a valid CDOptionValueType integer."];
        }
        _valueType = type;

        // Containers.
        _allowedValues = @[].mutableCopy;
        _deprecatedOptions = @[].mutableCopy;
        _notes = @[].mutableCopy;
        _values = @[].mutableCopy;
        _warnings = @[].mutableCopy;

        // Readonly properties.
        _scope = @"control";

        // Properties.
        self.minimumValues = @1;
        self.maximumValues = @1;
    }
    return self;
}

#pragma mark - Public static methods
+ (instancetype) type:(CDOptionValueType)type name:(NSString *)name {
    return [[self alloc] initWithType:type name:name];
}

+ (CDOption *(^)(CDOptionValueType type, NSString* name)) create {
    return ^CDOption *(CDOptionValueType type, NSString* name) {
        return [CDOption type:type name:name];
    };
}

#pragma mark - Public instance methods
- (id) convertValue:(id)value {
    // Nil or Null.
    if (!value || [value isKindOfClass:[NSNull class]]) {
        return self.defaultValue;
    }

    // Boolean.
    if (self.valueType == CDBoolean) {
        if ([value isKindOfClass:[NSString class]]) {
            return [NSNumber numberWithBool:((NSString*)value).boolValue];
        }
        else if ([value isKindOfClass:[NSNumber class]]) {
            return [NSNumber numberWithBool:((NSNumber*)value).boolValue];
        }
        return [NSNumber numberWithBool:self.wasProvided];
    }

    // Number.
    if (self.valueType == CDNumber) {
        if ([value isKindOfClass:[NSString class]]) {
            return ((NSString*)value).numberValue ?: self.defaultValue;
        }
        else if ([value isKindOfClass:[NSNumber class]]) {
            return value;
        }

        return @0;
    }
    // Number or string.
    else if (self.valueType == CDStringOrNumber) {
        if ([value isKindOfClass:[NSString class]]) {
            return value;
        }
        else if ([value isKindOfClass:[NSNumber class]]) {
            return value;
        }
        return @"%@".arguments(value, nil).numberValue ?: self.defaultValue;
    }

    // String, passing through formatter just in case.
    return @"%@".arguments(value, nil);
}

- (float) percentageOf:(float)value {
    return (value / 100.0f) * [self.percentValue floatValue];
}

- (void) setMaximumValues:(NSNumber *)maximumValues {
    // Enforce CDBoolean max value.
    if (self.valueType == CDBoolean) {
        maximumValues = @1;
    }

    NSInteger currentMaxIndex = ((int) _values.count) - 1;
    NSInteger max = maximumValues.integerValue;
    NSInteger maxIndex = max - 1;

    // Specific number of maximum values.
    if (max > 0 && maxIndex > currentMaxIndex) {
        NSUInteger missing = maxIndex - currentMaxIndex;

        // Fill missing indicies with NSNull (not default value).
        while (missing > 0) {
            [_values addObject:[NSNull null]];
            missing--;
        }
    }
    else if (max > 0 && max < currentMaxIndex) {
        NSUInteger extra = currentMaxIndex - maxIndex;
        // Remove extra indicies.
        while (extra > 0) {
            [_values removeLastObject];
            extra--;
        }
    }
    else if (max == 0) {
        _values = @[].mutableCopy;
    }

    _maximumValues = maximumValues;
}

- (void) setValue:(id)value atIndex:(NSUInteger)index {
    // Immediately return if index exceeds maximum allowed values.
    if (index > self.maximumValues.unsignedIntegerValue - 1) {
        return;
    }
    [_values replaceObjectAtIndex:index withObject:[self convertValue:value]];
}

- (void) setValues:(NSMutableArray *)values {
    // Immediately return if there are no values.
    if (!values || !values.count) {
        return;
    }

    NSNumber *currentMaximumValues = self.maximumValues.copy;
    self.maximumValues = @0;
    _values = @[].mutableCopy;
    self.maximumValues = currentMaximumValues;

    for (NSUInteger i = 0; i < values.count; i++) {
        [self setValue:values[i] atIndex:i];
    }
}

#pragma mark - Public chainable methods
- (CDOption *(^)(NSString *)) addNote {
    return ^CDOption *(NSString *note){
        [self.notes addObject:note];
        return self;
    };
}

- (CDOption *(^)(NSString *)) addWarning {
    return ^CDOption *(NSString *warning){
        [self.warnings addObject:warning];
        return self;
    };
}

- (CDOption *(^)(NSArray *)) allow {
    return ^CDOption *(NSArray *values){
        [self.allowedValues addObjectsFromArray:values];
        return self;
    };
}

- (CDOption *(^)(NSString *)) dependsOn {
    return ^CDOption *(NSString *name){
        self.parent = name;
        return self;
    };
}

- (CDOption *(^)(NSArray <CDOption *> *)) deprecates {
    return ^CDOption *(NSArray <CDOption *> *options){
        for (CDOption* option in options) {
            option.deprecatedTo = self.name;
            [self.deprecatedOptions addObject:option];
        }
        return self;
    };
}

- (CDOption *(^)(BOOL)) hide {
    return ^CDOption *(BOOL hidden){
        self.hidden = hidden;
        return self;
    };
}

- (CDOption *(^)(NSUInteger)) toValueIndex {
    return ^CDOption *(NSUInteger index){
        self.deprecatedValueIndex = [NSNumber numberWithUnsignedInteger:index];
        return self;
    };
}

- (CDOption *(^)(NSInteger)) max {
    return ^CDOption *(NSInteger max){
        self.maximumValues = [NSNumber numberWithInteger:max];
        return self;
    };
}

- (CDOption *(^)(NSInteger)) min {
    return ^CDOption *(NSInteger min){
        // Enforce CDBoolean min value.
        if (self.valueType == CDBoolean) {
            min = 0;
        }
        _minimumValues = [NSNumber numberWithInteger:min];
        return self;
    };
}

- (CDOption *(^)(NSArray *)) overrideValues {
    return ^CDOption *(NSArray *array){
        self.values = array.mutableCopy;
        return self;
    };
}

- (CDOption *(^)(CDOptionProcessBlock)) process {
    return ^CDOption *(CDOptionProcessBlock block){
        [_processBlocks addObject:[block copy]];
        return self;
    };
}

- (CDOption *(^)(BOOL)) provided {
    return ^CDOption *(BOOL provided){
        self.wasProvided = provided;
        return self;
    };
}

- (CDOption *(^)(NSString *)) rawValue {
    return ^CDOption *(NSString *value){
        [self setValue:value atIndex:0];
        return self;
    };
}

- (CDOption *(^)(BOOL)) require {
    return ^CDOption *(BOOL requred){
        self.required = requred;
        return self;
    };
}

- (CDOption *(^)(id)) setDefaultValue {
    return ^CDOption *(id value){
        defaultValue = [value copy];
        return self;
    };
}

- (CDOption *(^)(NSString *)) setScope {
    return ^CDOption *(NSString *scope){
        _scope = scope;
        return self;
    };
}

#pragma mark - Properties
- (NSArray *) arrayValue {
    return [_values replaceNullValuesWith:self.defaultValue];
}

- (NSArray<NSNumber *> *) arrayOfNumbers {
    NSMutableArray *array = @[].mutableCopy;
    for (id item in self.arrayValue) {
        if (self.valueType == CDBoolean) {
            [array addObject:@"%@".arguments(item, nil).boolValue ? @1 : @0];
        }
        else if (self.valueType == CDString) {
            NSString* string = @"%@".arguments(item, nil);
            if (string.isBlank) {
                [array addObject:@0];
            }
            else {
                [array addObject:string.numberValue ?: @0];
            }
        }
        else if (self.valueType == CDStringOrNumber) {
            if ([item isKindOfClass:[NSString class]]) {
                NSString* string = @"%@".arguments(item, nil);
                if (string.isBlank) {
                    [array addObject:@0];
                }
                else {
                    [array addObject:string.numberValue ?: @0];
                }
            }
            else if ([item isKindOfClass:[NSNumber class]]) {
                [array addObject:item];
            }
            else {
                [array addObject:@0];
            }
        }
        else {
            [array addObject:item];
        }
    }
    return array;
}

- (NSArray<NSString *> *) arrayOfStrings {
    NSMutableArray *array = @[].mutableCopy;
    for (id item in self.arrayValue) {
        if (self.valueType == CDBoolean) {
            [array addObject:@"%@".arguments(item, nil).boolValue ? @"YES".localized : @"NO".localized];
        }
        else if (self.valueType == CDNumber) {
            if ([item isKindOfClass:[NSNumber class]]) {
                if (item && ((NSNumber*)item).isPercent) {
                    NSNumber *number = [NSNumber numberWithDouble:((NSNumber*)item).doubleValue * 100];
                    [array addObject:@"%@%%".arguments(number, nil)];
                }
                else {
                    [array addObject:@"%@".arguments(item, nil)];
                }
            }
            else if ([item isKindOfClass:[NSString class]]) {
                [array addObject:item];
            }
            else {
                [array addObject:@"%@".arguments(item, nil) ?: @"0"];
            }
        }
        else if (self.valueType == CDStringOrNumber) {
            if (item && [item isKindOfClass:[NSNumber class]] && ((NSNumber*)item).isPercent) {
                NSNumber *number = [NSNumber numberWithDouble:((NSNumber*)item).doubleValue * 100];
                [array addObject:@"%@%%".arguments(number, nil)];
            }
            else {
                [array addObject:@"%@".arguments(item, nil) ?: self.defaultValue];
            }
        }
        else {
            [array addObject:@"%@".arguments(item, nil)];
        }
    }
    return array;
}

- (NSArray*) arrayOfStringOrNumbers {
    NSMutableArray *array = @[].mutableCopy;
    for (id item in self.arrayValue) {
        if (self.valueType == CDBoolean) {
            [array addObject:@"%@".arguments(item, nil).boolValue ? @"YES".localized : @"NO".localized];
        }
        else if (self.valueType == CDNumber) {
            [array addObject:@"%@".arguments(item, nil).numberValue ?: item];
        }
        else if (self.valueType == CDString) {
            [array addObject:@"%@".arguments(item, nil)];
        }
        else if (self.valueType == CDStringOrNumber) {
            if ([item isKindOfClass:[NSNumber class]]) {
                [array addObject:item];
            }
            else if ([item isKindOfClass:[NSString class]]) {
                [array addObject:item];
            }
            else {
                [array addObject:@"%@".arguments(item, nil)];
            }
        }
        else {
            [array addObject:@"%@".arguments(item, nil)];
        }
    }
    return array;
}

- (BOOL) boolValue {
    if (self.valueType == CDBoolean || self.valueType == CDNumber || self.valueType == CDStringOrNumber) {
        NSNumber *number = self.numberValue;
        return number != nil ? number.boolValue : NO;
    }
    return NO;
}

- (id) defaultValue {
    id value = nil;

    // Determine if default value is "automatic".
    if (self.hasAutomaticDefaultValue) {
        CDOptionAutomaticValueBlock block = (CDOptionAutomaticValueBlock) defaultValue;
        value = block();
    }
    // Otherwise, just assign the default value.
    else {
        value = defaultValue;
    }

    if (!value) {
        if (self.valueType == CDBoolean) {
            // Default to whether the option was provided so it behaves like a "flag".
            value = [NSNumber numberWithBool:self.wasProvided];
        }
        else if (self.valueType == CDNumber) {
            value = @0;
        }
        else if (self.valueType == CDString || self.valueType == CDStringOrNumber) {
            value = @"";
        }
        else {
            value = [NSNull null];
        }
    }

    return [self convertValue:value];
}

- (NSString *) description {
    return @"USAGE_OPTION_%@_%@".arguments(self.scope, self.name, nil).snakeCase.uppercaseString.localized;
}

- (NSString *) displayValue {
    BOOL multiple = self.maximumValues.integerValue > 1;
    NSMutableArray* displayValue = @[].mutableCopy;
    if (self.valueType == CDBoolean) {
        NSArray<NSNumber*>* numbers = self.arrayOfNumbers;
        for (NSUInteger i = 0; i < numbers.count; i++) {
            NSNumber* index = [NSNumber numberWithUnsignedInteger:i];
            if (multiple) {
                [displayValue addObject:@"(%@) %@".arguments(index, numbers[i].boolValue ? @"YES".localized : @"NO".localized, nil)];
            }
            else {
                [displayValue addObject:@"%@".arguments(numbers[i].boolValue ? @"YES".localized : @"NO".localized, nil)];
            }
        }
    }
    else if (self.valueType == CDNumber) {
        NSArray<NSNumber*>* numbers = self.arrayOfNumbers;
        for (NSUInteger i = 0; i < numbers.count; i++) {
            NSNumber* index = [NSNumber numberWithUnsignedInteger:i];
            if (multiple) {
                [displayValue addObject:@"(%@) %@".arguments(index, numbers[i], nil)];
            }
            else {
                [displayValue addObject:@"%@".arguments(numbers[i], nil)];
            }
        }
    }
    else if (self.valueType == CDString) {
        NSArray<NSString*>* strings = self.arrayOfStrings;
        for (NSUInteger i = 0; i < strings.count; i++) {
            NSNumber* index = [NSNumber numberWithUnsignedInteger:i];
            if (multiple) {
                [displayValue addObject:@"(%@) %@".arguments(index, strings[i].doubleQuote, nil)];
            }
            else {
                [displayValue addObject:strings[i].doubleQuote];
            }
        }
    }
    else if (self.valueType == CDStringOrNumber) {
        NSArray* items = self.arrayOfStringOrNumbers;
        for (NSUInteger i = 0; i < items.count; i++) {
            NSNumber* index = [NSNumber numberWithUnsignedInteger:i];
            if (multiple) {
                if ([items[i] isKindOfClass:[NSString class]]) {
                    [displayValue addObject:@"(%@) %@".arguments(index, ((NSString*)items[i]).doubleQuote, nil)];
                }
                else {
                    [displayValue addObject:@"(%@) %@".arguments(index, items[i], nil)];
                }
            }
            else {
                if ([items[i] isKindOfClass:[NSString class]]) {
                    [displayValue addObject:((NSString*)items[i]).doubleQuote];
                }
                else {
                    [displayValue addObject:@"%@".arguments(items[i], nil)];
                }
            }
        }
    }
    return multiple ? @"[%@]".arguments(displayValue.join(@", ")) : displayValue.lastObject;
}

- (double) doubleValue {
    NSNumber *number = self.numberValue;
    return number != nil ? number.doubleValue : 0;
}

- (float) floatValue {
    NSNumber *number = self.numberValue;
    return number != nil ? number.floatValue : 0;
}

- (BOOL) hasAutomaticDefaultValue {
    // There is no good way to check the "type" of block. The best that can be
    // accomlished here is to see if it is one and then just assume that it's a
    // valid CDOptionAutomaticDefaultValue block.
    // @todo https://github.com/ebf/CTObjectiveCRuntimeAdditions
    // @see http://stackoverflow.com/a/10944983/1226717
    return defaultValue != nil && [defaultValue isKindOfClass:NSClassFromString(@"NSBlock")];
}

- (id) jsonValue {
    NSMutableArray* deprecates = @[].mutableCopy;
    for (CDOption* option in self.deprecatedOptions) {
        [deprecates addObject: option.name];
    }
    return
    @{
      @"allowedValues": self.allowedValues.count > 0 ? self.allowedValues : [NSNull null],
      @"automaticDefaultValue": [NSNumber numberWithBool:self.hasAutomaticDefaultValue],
      @"description": self.description ?: [NSNull null],
      @"defaultValue": self.defaultValue ?: [NSNull null],
      @"deprecates": deprecates ?: [NSNull null],
      @"hidden": [NSNumber numberWithBool:self.hidden],
      @"maximumValues": self.maximumValues,
      @"minimumValues": self.minimumValues,
      @"name": self.name ?: [NSNull null],
      @"notes": self.notes ?: [NSNull null],
      @"required": [NSNumber numberWithBool:self.required],
      @"parent": self.parent ?: [NSNull null],
      @"type": [self className] ?: [NSNull null],
      @"scope": self.scope ?: [NSNull null],
      @"typeLabel": self.typeLabel.removeColor ?: [NSNull null],
      @"warnings": self.warnings ?: @[],
      @"wasProvided": [NSNumber numberWithBool:self.wasProvided],
      };
}

- (NSString *) toJSONString {
    return [CDJson objectToJSON:self.jsonValue];
}

- (int) intValue {
    NSNumber *number = self.numberValue;
    return number != nil ? number.intValue : (int) 0;
}

- (NSInteger) integerValue {
    NSNumber *number = self.numberValue;
    return number != nil ? number.integerValue : (NSInteger) 0;
}

- (BOOL) isPercent {
    NSNumber* number = self.numberValue;
    return number ? number.isPercent : NO;
}

- (NSString *) label {
    return _name.optionFormat;
}

- (NSNumber *) numberValue {
    return self.maximumValues.integerValue == 1 ? self.arrayOfNumbers.lastObject : [NSNumber numberWithUnsignedInteger:self.arrayOfNumbers.count];
}

- (NSNumber *) percentValue {
    NSNumber *number = self.numberValue;
    if (number && number.isPercent) {
        return [NSNumber numberWithDouble:number.doubleValue * 100];
    }
    return nil;
}

- (NSString *) stringValue {
    return self.maximumValues.integerValue == 1 ? self.arrayOfStrings.lastObject : self.arrayOfStrings.join(@", ");
}

- (CDColor *) typeColor {
    if (self.valueType == CDString) {
        return [CDColor fg:CDColorFgGreen];
    }
    if (self.valueType == CDBoolean) {
        return [CDColor fg:CDColorFgMagenta];
    }
    if (self.valueType == CDNumber) {
        return [CDColor fg:CDColorFgCyan];
    }
    if (self.valueType == CDStringOrNumber) {
        return [CDColor fg:CDColorFgYellow];
    }
    return [CDColor fg:CDColorFgNone];
}

- (NSString *) typeLabel {
    NSString* typeLabel;

    // Boolean.
    if (self.valueType == CDBoolean) {
        typeLabel = @"<%@>".arguments(@"USAGE_OPTION_TYPE_BOOLEAN".localized, nil);
    }
    // Number.
    else if (self.valueType == CDNumber) {
        typeLabel = @"<%@>".arguments(@"USAGE_OPTION_TYPE_NUMBER".localized, nil);
    }
    // String.
    else if (self.valueType == CDString) {
        typeLabel = @"<%@>".arguments(@"USAGE_OPTION_TYPE_STRING".localized, nil);
    }
    // String or number.
    else if (self.valueType == CDStringOrNumber) {
        typeLabel = @"<%@|%@>".arguments(@"USAGE_OPTION_TYPE_NUMBER".localized, @"USAGE_OPTION_TYPE_STRING".localized, nil);
    }

    if (self.maximumValues.integerValue == -1) {
        typeLabel = typeLabel.append(@" [...]");
    }
    else if (self.maximumValues.integerValue > 1) {
        NSString* originalTypeLabel = typeLabel.copy;
        NSMutableArray* types = @[].mutableCopy;
        typeLabel = typeLabel.append(@" [");
        NSInteger max = self.maximumValues.integerValue - 1;
        for (NSInteger i = 0; i < max; i++) {
            [types addObject: originalTypeLabel];
        }
        typeLabel = typeLabel.append(types.join(@", ")).append(@"]");
    }

    CDColor* color = self.typeColor;

    // Dim the type value if it has an automatic default value.
    if (self.hasAutomaticDefaultValue) {
        [color addStyle:CDColorStyleDim];
    }

    return typeLabel.addColor(color);
}

- (unsigned int) unsignedIntValue {
    NSNumber *number = [self numberValue];
    return number != nil ? number.unsignedIntValue : (unsigned int) 0;
}

- (NSUInteger) unsignedIntegerValue {
    NSNumber *number = [self numberValue];
    return number != nil ? number.unsignedIntegerValue : (NSUInteger) 0;
}

@end
