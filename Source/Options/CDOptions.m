#import "CDOptions.h"

@implementation CDOptions

@synthesize arguments = _arguments;
@synthesize options = _options;
@synthesize deprecatedOptions = _deprecatedOptions;
@synthesize missingOptions = _missingOptions;
@synthesize requiredOptions = _requiredOptions;
@synthesize unknownOptions = _unknownOptions;

// Private static methods.
+ (BOOL) argIsKey:(NSString *)arg inOptions:(NSDictionary *)options {
    return !!([self isOption:arg] && options[[arg substringFromIndex:2]] != nil);
}

+ (BOOL) isOption:(NSString *)arg {
    return !!(arg.length >= 2 && [[arg substringWithRange:NSMakeRange(0, 2)] isEqualToString:@"--"]);
}

+ (NSString *) optionNameFromArgument:(NSString *)arg {
    return [self isOption:arg] ? [arg substringFromIndex:2] : nil;
}

// Pubic static methods.
+ (instancetype) options {
    return [[[self alloc] init] autorelease];
}

// Public instance methods.

- (void)addOption:(CDOption *)opt {
    // @todo Add "double dash" note for multiple option values automatically.
    //    [columns addObject:[NSString stringWithFormat:@"%@ %@", opt.helpText, NSLocalizedString(@"OPTION_MULTIPLE_DOUBLE_DASH", nil)]];

    if (opt.maximumValues == 0) {
        NSString *doubleDash = NSLocalizedString(@"OPTION_MULTIPLE_DOUBLE_DASH", nil);
        if (![opt.notes containsObject:doubleDash]) {
            [opt.notes addObject:doubleDash];
        }
    }


    if ([opt isKindOfClass:[CDOptionDeprecated class]]) {
        CDOptionDeprecated *deprecated = (CDOptionDeprecated *)opt;
        [_deprecatedOptions setObject:deprecated forKey:deprecated.from];
    }
    else {
        [_options setObject:opt forKey:opt.name];
    }
}

- (NSString *) getArgument:(unsigned int) index {
    return _arguments != nil && index < _arguments.count ? _arguments[index] : nil;
}

- (instancetype) init {
    self = [super init];
    if (self) {
        _arguments = [NSMutableArray array];
        _deprecatedOptions = [NSMutableDictionary dictionary];
        _missingOptions = [NSMutableDictionary dictionary];
        _options = [NSMutableDictionary dictionary];
        _requiredOptions = [NSMutableDictionary dictionary];
        _seenOptions = [NSMutableArray array];
        _unknownOptions = [NSMutableArray array];
    }
    return self;
}

- (CDOptions *) processArguments {
    NSMutableArray *args = [[NSMutableArray arrayWithArray:[NSProcessInfo processInfo].arguments] autorelease];

    // Remove the command path.
    [args removeObjectAtIndex:0];

    // Process the arguments first and extract the necessary values.
    // @todo Now that this is back in options and options have min/max values,
    // this needs to parse based on the option type.
    NSString *arg = nil;
    NSString *currentOption = nil;
    NSMutableDictionary<NSString *, NSMutableArray<NSString *> *> *argumentValues = [NSMutableDictionary dictionary];
    for (NSUInteger i = 0; i < args.count; i++) {
        arg = args[i];

        NSString *optionName = [CDOptions optionNameFromArgument:arg];

        // Argument breaks.
        if (currentOption != nil && [optionName isBlank]) {
            currentOption = nil;
            continue;
        }

        // Add an existing option value.
        if (!optionName && currentOption != nil && argumentValues[currentOption]) {
            [argumentValues[currentOption] addObject:arg];
        }
        // Add a option value.
        else if (optionName) {
            // If provided option isn't actually an available or deprecated option,
            // add it to the list of unknown options.
            if (!_options[optionName] && !_deprecatedOptions[optionName]) {
                [_unknownOptions addObject:optionName];
                continue;
            }

            currentOption = optionName;
            if (argumentValues[currentOption] == nil) {
                argumentValues[currentOption] = [NSMutableArray array];
            }
        }
        //Add a normal argument.
        else {
            [_arguments addObject:arg];
        }
    }

    // Handle deprecated options.
    if (_deprecatedOptions.count) {
        for (NSString *name in _deprecatedOptions) {
            CDOptionDeprecated *deprecated = _deprecatedOptions[name];
            if (argumentValues[deprecated.from] != nil && _options[deprecated.to] != nil) {
                argumentValues[deprecated.to] = argumentValues[deprecated.from];
                [argumentValues removeObjectForKey:deprecated.from];
            }
        }
    }

    // Set the argument value(s) for the necessary options.
    for (id name in _options) {
        CDOption *opt = _options[name];
        NSArray *values = argumentValues[name];

        // If there are values, indicate that the option was provided
        // and set the value(s) for the option provided by the arguments.
        if (values != nil) {
            opt.wasProvided = YES;

            // Need to handle flags differently because they can potientally have valid arguments after them.
            // @todo Convert flags to a normal boolean where no value specified acts like a flag currently.
            if ([opt isKindOfClass:[CDOptionFlag class]]) {
                opt.value = @YES;
                // If there are any "values" for this option, then they
                // are actually arguments that should be added back.
                for (arg in values) {
                    [_arguments addObject:arg];
                }
            }
            else {
                [opt setValues:values];
            }
        }
    }

    // Handle missing required options.
    NSDictionary *required = self.requiredOptions;
    if (required.count) {
        for (NSString *name in required) {
            if (!_options[name].wasProvided) {
                _missingOptions[name] = required[name];
            }
        }
    }

    return self;
}

// Properties.

- (NSArray *) allKeys {
    return [_options.allKeys copy];
}

- (NSArray *) allValues {
    return [_options.allValues copy];
}

- (NSDictionary <NSString *, CDOptions *> *) groupByCategories {
    NSMutableDictionary<NSString *, CDOptions *> *categories = [NSMutableDictionary dictionary];
    for (NSString *name in _options) {
        CDOption *opt = _options[name];
        NSString *category = opt.category != nil ? opt.category : NSLocalizedString(@"USAGE_CATEGORY_CONTROL", nil);
        if (categories[category] == nil) {
            categories[category] = [CDOptions options];
        }
        [categories[category] addOption:opt];
    }
    return categories;
}

- (NSMutableDictionary<NSString *,CDOption *> *)requiredOptions {
    NSMutableDictionary *required = [NSMutableDictionary dictionaryWithDictionary:_requiredOptions];
    for (NSString *name in _options) {
        if (_options[name].required) {
            required[name] = _options[name];
        }
    }
    return required;
}

// Enumeration.
- (NSUInteger) countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id __unsafe_unretained [])stackbuf count:(NSUInteger)len {
    NSUInteger count = [[_options copy] countByEnumeratingWithState:state objects:stackbuf count:len];
    return count;
}
- (CDOption *) objectForKey:(NSString *)key {
    CDOption *opt = [_options objectForKey:key];
    if (self.getOptionOnceCallback != nil && ![_seenOptions containsObject:key]) {
        [_seenOptions addObject:key];
        self.getOptionOnceCallback(opt);
    }
    if (self.getOptionCallback != nil) {
        self.getOptionCallback(opt);
    }
    return opt;
}
- (CDOption *) objectForKeyedSubscript:(NSString *)key {
    return [self objectForKey:key];
}
- (void) setObject:(CDOption *)opt forKey:(NSString*)key {
    if (self.setOptionCallback != nil) {
        self.setOptionCallback(opt, key);
    }
    [_options setValue:opt forKey:key];
}
- (void) setObject:(CDOption *)opt forKeyedSubscript:(NSString*)key {
    [self setObject:opt forKey:key];
}

@end
