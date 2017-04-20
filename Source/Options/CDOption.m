#import "CDOption.h"

@implementation CDOption

@synthesize maximumValues, minimumValues;

#pragma mark - Properties
- (NSArray *) arrayValue {
    return [self.value isKindOfClass:[NSArray class]] ? self.value : nil;
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
      @"warnings": self.warnings ?: [NSNull null],
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
        NSNumberFormatter *f = [[[NSNumberFormatter alloc] init] autorelease];
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

#pragma mark - Public instance methods
- (void) addConditionalRequirement:(CDOptionConditionalRequirement)block {
    [_conditionalRequirements addObject:[block copy]];
}

- (instancetype) init {
    self = [super init];
    if (self) {
        minimumValues = @0;
        maximumValues = @1;
        _conditionalRequirements = [NSMutableArray array];
        _notes = [NSMutableArray array];
        _providedValues = [NSMutableArray array];
        _warnings = [NSMutableArray array];
    }
    return self;
}

- (void) dealloc {
    [_defaultValue release];
    [super dealloc];
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

- (void) setValues:(NSArray<NSString *> *)values {
    _providedValues = [NSMutableArray arrayWithArray:values];
}

@end

#pragma mark -
@implementation CDOptionDeprecated

#pragma mark - Public static methods
+ (instancetype) from:(NSString *)from to:(NSString *)to {
    return [[[CDOptionDeprecated alloc] from:from to:to] autorelease];
}

#pragma mark - Public instance methods
- (instancetype) from:(NSString *)from to:(NSString *)to {
    _from = from;
    _to = to;
    return self;
}

@end

// Boolean.
#pragma mark -
@implementation CDOptionBoolean

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
    if (!values.count) {
        return;
    }
    // Retrieve only the last specified value.
    NSString *value = values[values.count - 1];
    self.value = [NSNumber numberWithBool:[value isEqualToStringCaseInsensitive:@"yes"] || [value isEqualToStringCaseInsensitive:@"true"] || [value isEqualToStringCaseInsensitive:@"1"]];
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

// Flag - @todo Convert to CDOptionBoolean where
// no values passed acts like flag does currently.
#pragma mark -
@implementation CDOptionFlag

#pragma mark - Public instance methods
- (instancetype) init {
    self = [super init];
    if (self) {
        self.minimumValues = @0;
        self.maximumValues = @0;
    }
    return self;
}

#pragma mark - Properties
- (NSString *) stringValue {
    BOOL boolValue = self.boolValue;
    return boolValue ? NSLocalizedString(@"YES", nil) : NSLocalizedString(@"NO", nil);
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
    self.value = values[values.count - 1];
}

#pragma mark - Properties
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
