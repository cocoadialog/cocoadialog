#import "CDArguments.h"

@implementation CDArguments

// Private methods.
+ (BOOL) argIsKey:(NSString *)arg inOptions:(NSDictionary *)options {
    return !!([CDArguments isOption:arg] && options[[arg substringFromIndex:2]] != nil);
}

+ (BOOL) isOption:(NSString *)arg {
    return !!(arg.length > 1 && [[arg substringWithRange:NSMakeRange(0, 1)] isEqualToString:@"-"]);
}

+ (BOOL) isLongOption:(NSString *)arg {
    return !!(arg.length > 2 && [[arg substringWithRange:NSMakeRange(0, 2)] isEqualToString:@"--"]);
}

+ (BOOL) isShortOption:(NSString *)arg {
    return [CDArguments isOption:arg] && ![CDArguments isLongOption:arg];
}

// Pubic static methods.
+ (instancetype) initWithAvailableOptions:(CDOptions *)options {
    return [[[CDArguments alloc] initWithAvailableOptions:options] autorelease];
}

// Public instance methods.
- (void) dealloc {
    [_arguments release];
    [_options release];
    [_unknownOptions release];
    [super dealloc];
}

- (NSString *) getArgument:(unsigned int) index {
    return _arguments != nil && index < _arguments.count ? _arguments[index] : nil;
}

- (BOOL) hasOption:(NSString *)key {
    return _options[key] != nil;
}

- (instancetype) initWithAvailableOptions:(CDOptions *)options {
    self = [super init];
    if (self) {
        _arguments = [NSMutableArray array];
        _deprecatedOptions = [NSMutableArray array];
        _unknownOptions = [NSMutableArray array];

        CDOptions *optionsFromArgs = [CDOptions options];
        NSMutableArray *args = [[NSMutableArray arrayWithArray:[NSProcessInfo processInfo].arguments] autorelease];

        // Remove the command path.
        [args removeObjectAtIndex:0];

        // Process the arguments first and extract the necessary values.
        NSString *arg = nil;
        NSString *currentOption = nil;
        NSMutableDictionary *providedOptions = [NSMutableDictionary dictionary];
        unsigned i = 0;
        for (i = 0; i < args.count; i++) {
            arg = args[i];

            // Argument breaks.
            if (currentOption != nil && [arg isEqualToString:@"--"]) {
                currentOption = nil;
                continue;
            }

            BOOL isOption = [CDArguments isOption:arg];

            // Add an existing option value.
            if (!isOption && currentOption != nil) {
                [providedOptions[currentOption] addObject:arg];
            }
            // Add a new option.
            else if (isOption) {
                currentOption = [arg substringFromIndex:2];
                if (providedOptions[currentOption] == nil) {
                    providedOptions[currentOption] = [NSMutableArray array];
                }
            }
            //Add a normal argument.
            else {
                [_arguments addObject:arg];
            }
        }

        // Handle deprecated options.
        for (i = 0; i < options.deprecatedOptions.count; i++) {
            CDOptionDeprecated *deprecated = [options.deprecatedOptions objectAtIndex:i];
            if (providedOptions[deprecated.from] != nil && options[deprecated.to] != nil) {
                providedOptions[deprecated.to] = providedOptions[deprecated.from];
                [providedOptions removeObjectForKey:deprecated.from];
                [_deprecatedOptions addObject:deprecated.from];
            }
        }

        for (id name in providedOptions) {
            CDOption *option = options[name];
            NSMutableArray *providedValues = providedOptions[name];

            // If provided option isn't available, add it to
            // the list of unknown options and then remove it.
            if (option == nil) {
                [_unknownOptions addObject:name];
                continue;
            }

            // If option is a flag, store the bool YES to indicate
            // that the option has been set and continue.
            if ([option isKindOfClass:[CDOptionFlag class]]) {
                option.value = @YES;
                // If there are any "values" for this option, then they
                // are actually arguments that should be added back.
                for (arg in providedOptions[name]) {
                    [_arguments addObject:arg];
                }
            }
            // Boolean.
            else if ([option isKindOfClass:[CDOptionBoolean class]]) {
                if (providedValues.count) {
                    BOOL value = NO;
                    // Retrieve the last value
                    NSString *providedValue = providedValues[providedValues.count - 1];
                    if ([providedValue isEqualToStringCaseInsensitive:@"yes"] || [providedValue isEqualToStringCaseInsensitive:@"true"] || [providedValue isEqualToStringCaseInsensitive:@"1"]) {
                        value = YES;
                    }
                    option.value = [NSNumber numberWithBool:value];
                }
            }
            // Single string (or number).
            else if ([option isKindOfClass:[CDOptionSingleString class]] || [option isKindOfClass:[CDOptionSingleStringOrNumber class]]) {
                if (providedValues.count) {
                    option.value = providedValues[providedValues.count - 1];
                }
            }
            // Single number.
            else if ([option isKindOfClass:[CDOptionSingleNumber class]]) {
                if (providedValues.count) {
                    option.value = [NSNumber numberWithInt:[providedValues[providedValues.count - 1] intValue]];
                }
            }
            // Multiple strings (or numbers).
            else if ([option isKindOfClass:[CDOptionMultipleStrings class]] || [option isKindOfClass:[CDOptionMultipleStringsOrNumbers class]]) {
                option.value = [NSArray arrayWithArray:providedValues];
            }
            // Multiple numbers.
            else if ([option isKindOfClass:[CDOptionMultipleNumbers class]]) {
                NSMutableArray *values = [NSMutableArray array];
                for (i = 0; i < providedValues.count; i++) {
                    values[i] = [NSNumber numberWithInt:[providedValues[i] intValue]];
                }
                option.value = [NSArray arrayWithArray:values];
            }

            optionsFromArgs[name] = option;
        }

        _options = optionsFromArgs;
    }
    return self;
}

- (id) getOption:(NSString *)key {
    return _options[key].value;
}

- (NSArray *)optionAsArray:(NSString *)key {
    return [NSArray arrayWithArray:_options[key].value];
}

- (BOOL)optionAsBoolean:(NSString *)key {
    return [_options[key].value boolValue];
}

- (int)optionAsInt:(NSString *)key {
    return [_options[key].value intValue];
}

- (NSNumber *)optionAsNumber:(NSString *)key {
    return [NSNumber numberWithInt:[_options[key].value intValue]];
}

- (NSString *)optionAsString:(NSString *)key {
    return [_options[key].value string];
}

- (void) setOption:(NSString *)key value:(id)value {
	_options[key] = value;
}

@end
