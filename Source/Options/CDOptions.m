#import "CDOptions.h"

@implementation CDOptions

@synthesize arguments, options, deprecatedOptions, getOptionCallback, getOptionOnceCallback, missingOptions, requiredOptions, seenOptions, setOptionCallback, unknownOptions;


#pragma mark - Properties
- (NSArray *) allKeys {
    return options.allKeys;
}

- (NSArray *) allValues {
    return options.allValues;
}

- (NSDictionary <NSString *, CDOptions *> *) groupByCategories {
    NSMutableDictionary<NSString *, CDOptions *> *categories = [NSMutableDictionary dictionary];
    for (NSString *name in options) {
        CDOption *opt = options[name];
        NSString *category = opt.category != nil ? opt.category : NSLocalizedString(@"USAGE_CATEGORY_CONTROL", nil);
        if (categories[category] == nil) {
            categories[category] = [CDOptions options];
        }
        [categories[category] addOption:opt];
    }
    return categories;
}

- (NSMutableDictionary<NSString *,CDOption *> *)requiredOptions {
    NSMutableDictionary *required = [NSMutableDictionary dictionaryWithDictionary:requiredOptions];
    for (NSString *name in options) {
        if (options[name].required) {
            required[name] = options[name];
        }
    }
    return required;
}

#pragma mark - Private static methods.
+ (BOOL) argIsKey:(NSString *)arg inOptions:(NSDictionary *)options {
    return !!([self isOption:arg] && options[[arg substringFromIndex:2]] != nil);
}

+ (BOOL) isOption:(NSString *)arg {
    return !!(arg.length >= 2 && [[arg substringWithRange:NSMakeRange(0, 2)] isEqualToString:@"--"]);
}

+ (NSString *) optionNameFromArgument:(NSString *)arg {
    return [self isOption:arg] ? [arg substringFromIndex:2] : nil;
}

#pragma mark - Pubic static methods
+ (instancetype) options {
    return [[[self alloc] init] autorelease];
}

#pragma mark - Public instance methods
- (void)addOption:(CDOption *)opt {
    // @todo Add "double dash" note for multiple option values automatically.
    //    [columns addObject:[NSString stringWithFormat:@"%@ %@", opt.helpText, NSLocalizedString(@"OPTION_MULTIPLE_DOUBLE_DASH", nil)]];

    if (opt.minimumValues != 0 && opt.maximumValues == 0) {
        NSString *doubleDash = NSLocalizedString(@"OPTION_MULTIPLE_DOUBLE_DASH", nil);
        if (![opt.notes containsObject:doubleDash]) {
            [opt.notes addObject:doubleDash];
        }
    }


    if ([opt isKindOfClass:[CDOptionDeprecated class]]) {
        CDOptionDeprecated *deprecated = (CDOptionDeprecated *)opt;
        [deprecatedOptions setObject:deprecated forKey:deprecated.from];
    }
    else {
        [options setObject:opt forKey:opt.name];
    }
}

- (NSUInteger) count {
    return options.count;
}

- (void) dealloc {
    [arguments release];
    [deprecatedOptions release];
    [getOptionCallback release];
    [getOptionOnceCallback release];
    [missingOptions release];
    [options release];
    [requiredOptions release];
    [seenOptions release];
    [setOptionCallback release];
    [unknownOptions release];
    [super dealloc];
}

- (NSString *) getArgument:(unsigned int) index {
    return arguments != nil && index < arguments.count ? arguments[index] : nil;
}

- (instancetype) init {
    self = [super init];
    if (self) {
        arguments = [NSMutableArray array];
        deprecatedOptions = [NSMutableDictionary dictionary];
        missingOptions = [NSMutableDictionary dictionary];
        options = [NSMutableDictionary dictionary];
        requiredOptions = [NSMutableDictionary dictionary];
        seenOptions = [NSMutableArray array];
        unknownOptions = [NSMutableArray array];
    }
    return self;
}


- (instancetype )initWithObjects:(id  _Nonnull const [])objects forKeys:(id<NSCopying>  _Nonnull const [])keys count:(NSUInteger)cnt {
    self = [super init];
    if (self) {
        options = [[[NSMutableDictionary alloc] initWithObjects:objects forKeys:keys count:cnt] autorelease];
    }
    return self;
}

- (NSEnumerator *) keyEnumerator {
    return options.keyEnumerator;
}

- (CDOptions *) processArguments {
    NSMutableArray *args = [NSMutableArray arrayWithArray:[NSProcessInfo processInfo].arguments];

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
            if (!options[optionName] && !deprecatedOptions[optionName]) {
                [unknownOptions addObject:optionName];
                continue;
            }

            currentOption = optionName;
            if (argumentValues[currentOption] == nil) {
                argumentValues[currentOption] = [NSMutableArray array];
            }
        }
        //Add a normal argument.
        else {
            [arguments addObject:arg];
        }
    }

    // Handle deprecated options.
    if (deprecatedOptions.count) {
        for (NSString *name in deprecatedOptions) {
            CDOptionDeprecated *deprecated = deprecatedOptions[name];
            if (argumentValues[deprecated.from] != nil && options[deprecated.to] != nil) {
                argumentValues[deprecated.to] = argumentValues[deprecated.from];
                [argumentValues removeObjectForKey:deprecated.from];
            }
        }
    }

    // Set the argument value(s) for the necessary options.
    for (id name in options) {
        CDOption *opt = options[name];
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
                    [arguments addObject:arg];
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
            if (!options[name].wasProvided) {
                missingOptions[name] = required[name];
            }
        }
    }

    return self;
}

#pragma mark - Enumeration
- (NSUInteger) countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id __unsafe_unretained [])stackbuf count:(NSUInteger)len {
    return [options countByEnumeratingWithState:state objects:stackbuf count:len];
}

- (CDOption *) objectForKey:(NSString *)key {
    CDOption *opt = [options objectForKey:key];
    if (self.getOptionOnceCallback != nil && ![seenOptions containsObject:key]) {
        [seenOptions addObject:key];
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
    [options setValue:opt forKey:key];
}

- (void) setObject:(CDOption *)opt forKeyedSubscript:(NSString*)key {
    [self setObject:opt forKey:key];
}

@end
