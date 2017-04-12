#import "CDOption.h"

@implementation CDOption

- (instancetype) init {
    self = [super init];
    if (self) {
        _notes = [NSMutableArray array];
        _warnings = [NSMutableArray array];
    }
    return self;
}

- (instancetype) name:(NSString *)name value:(id)value category:(NSString *) category helpText:(NSString *)helpText {
    self = [self init];
    if (self) {
        _name = name;
        _value = value;

        if (category != nil) {
            _category = NSLocalizedString(category, nil);
        }

        if (helpText == nil) {
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
        else {
            _helpText = NSLocalizedString(helpText, nil);
        }
    }
    return self;
}

+ (instancetype) name:(NSString *)name {
    return [[[self alloc] name:name value:nil category:nil helpText:nil] autorelease];
}

+ (instancetype) name:(NSString *)name value:(id)value {
    return [[[self alloc] name:name value:value category:nil helpText:nil] autorelease];
}

+ (instancetype) name:(NSString *)name category:(NSString *) category {
    return [[[self alloc] name:name value:nil category:category helpText:nil] autorelease];
}

+ (instancetype) name:(NSString *)name value:(id)value category:(NSString *) category {
    return [[[self alloc] name:name value:value category:category helpText:nil] autorelease];
}

+ (instancetype) name:(NSString *)name value:(id)value category:(NSString *) category helpText:(NSString *)helpText {
    return [[[self alloc] name:name value:value category:category helpText:helpText] autorelease];
}

- (NSArray *) arrayValue {
    return [self.value isKindOfClass:[NSArray class]] ? self.value : nil;
}
- (BOOL) boolValue {
    NSNumber *number = [self numberValue];
    return number != nil ? number.boolValue : NO;
}
- (double) doubleValue {
    NSNumber *number = [self numberValue];
    return number != nil ? number.doubleValue : 0;
}
- (float) floatValue {
    NSNumber *number = [self numberValue];
    return number != nil ? number.floatValue : 0;
}
- (int) intValue {
    NSNumber *number = [self numberValue];
    return number != nil ? number.intValue : (int) 0;
}
- (NSInteger) integerValue {
    NSNumber *number = [self numberValue];
    return number != nil ? number.integerValue : (NSInteger) 0;
}
- (unsigned int) unsignedIntValue {
    NSNumber *number = [self numberValue];
    return number != nil ? number.unsignedIntValue : (unsigned int) 0;
}
- (NSUInteger) unsignedIntegerValue {
    NSNumber *number = [self numberValue];
    return number != nil ? number.unsignedIntegerValue : (NSUInteger) 0;
}
- (NSNumber *) numberValue {
    if ([self.value isKindOfClass:[NSString class]]) {
        NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
        f.numberStyle = NSNumberFormatterDecimalStyle;
        return [f numberFromString:self.value];
    }
    else if ([self.value isKindOfClass:[NSNumber class]]) {
        return self.value;
    }
    return nil;
}
- (NSString *) stringValue {
    if ([self.value isKindOfClass:[NSString class]]) {
        return self.value;
    }
    else if ([self.value isKindOfClass:[NSNumber class]]) {
        NSNumber *number = self.value;
        return number.stringValue;
    }
    return nil;
}

// Must be overridden by subclasses to have values set by arguments.
- (void) setValues:(NSArray<NSString *> *)values {}

@end

// Deprecated.
@implementation CDOptionDeprecated

- (instancetype) from:(NSString *)from to:(NSString *)to {
    _from = from;
    _to = to;
    return self;
}

+ (instancetype) from:(NSString *)from to:(NSString *)to {
    return [[[CDOptionDeprecated alloc] from:from to:to] autorelease];
}

@end

// Boolean.
@implementation CDOptionBoolean

- (void) setValues:(NSArray<NSString *> *)values {
    if (!values.count) {
        return;
    }
    // Retrieve only the last specified value.
    NSString *value = values[values.count - 1];
    self.value = [NSNumber numberWithBool:[value isEqualToStringCaseInsensitive:@"yes"] || [value isEqualToStringCaseInsensitive:@"true"] || [value isEqualToStringCaseInsensitive:@"1"]];
}

@end

// @todo Convert the "flag" option to just a boolean
// where no values passed acts like flag does currently.
@implementation CDOptionFlag @end

// Single string.
@implementation CDOptionSingleString

- (void) setValues:(NSArray<NSString *> *)values {
    if (!values.count) {
        return;
    }
    self.value = values[values.count - 1];
}

@end

// Single number.
@implementation CDOptionSingleNumber

- (void) setValues:(NSArray<NSString *> *)values {
    if (!values.count) {
        return;
    }
    self.value = [NSNumber numberWithLongLong:[values[values.count - 1] longLongValue]];
}

@end

// Single string or number.
@implementation CDOptionSingleStringOrNumber

- (void) setValues:(NSArray<NSString *> *)values {
    if (!values.count) {
        return;
    }
    self.value = values[values.count - 1];
}

@end

@implementation CDOptionMultipleStrings

- (void) setValues:(NSArray<NSString *> *)values {
    self.value = values;
}

@end

@implementation CDOptionMultipleNumbers

- (void) setValues:(NSArray<NSString *> *)values {
    NSMutableArray *numbers = [NSMutableArray array];
    for (NSUInteger i = 0; i < values.count; i++) {
        numbers[i] = [NSNumber numberWithLongLong:[values[i] longLongValue]];
    }
    self.value = numbers;
}

@end

@implementation CDOptionMultipleStringsOrNumbers

- (void) setValues:(NSArray<NSString *> *)values {
    self.value = values;
}

@end
