#import "CDArguments.h"

@implementation CDArguments

// Private methods.
+ (BOOL) argIsKey:(NSString *)arg inOptions:(NSDictionary *)options {
    return !!([CDArguments isOption:arg] && options[[arg substringFromIndex:2]] != nil);
}

+ (BOOL) isOption:(NSString *)arg {
    return !!(arg.length >= 2 && [[arg substringWithRange:NSMakeRange(0, 2)] isEqualToString:@"--"]);
}

// Pubic static methods.
+ (instancetype) initWithAvailableOptions:(CDOptions *)options {
    return [[[CDArguments alloc] initWithAvailableOptions:options] autorelease];
}

- (NSString *) getArgument:(unsigned int) index {
    return _arguments != nil && index < _arguments.count ? _arguments[index] : nil;
}

- (instancetype) initWithAvailableOptions:(CDOptions *)options {
    self = [super init];
    if (self) {
        _arguments = [NSMutableArray array];
        _deprecatedOptions = [NSMutableDictionary dictionary];
        _missingOptions = [NSMutableDictionary dictionary];
        _options = options;
        _unknownOptions = [NSMutableArray array];

        NSMutableArray *args = [[NSMutableArray arrayWithArray:[NSProcessInfo processInfo].arguments] autorelease];

        // Remove the command path.
        [args removeObjectAtIndex:0];

        // Process the arguments first and extract the necessary values.
        NSString *arg = nil;
        NSString *currentOption = nil;
        NSMutableDictionary<NSString *, NSMutableArray<NSString *> *> *argumentValues = [NSMutableDictionary dictionary];
        for (NSUInteger i = 0; i < args.count; i++) {
            arg = args[i];

            // Argument breaks.
            if (currentOption != nil && [arg isEqualToString:@"--"]) {
                currentOption = nil;
                continue;
            }

            BOOL isOption = [CDArguments isOption:arg];

            // Add an existing option value.
            if (!isOption && currentOption != nil && argumentValues[currentOption]) {
                [argumentValues[currentOption] addObject:arg];
            }
            // Add a new option.
            else if (isOption) {
                currentOption = [arg substringFromIndex:2];
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
        if (options.deprecatedOptions.count) {
            for (NSString *name in options.deprecatedOptions) {
                CDOptionDeprecated *deprecated = options.deprecatedOptions[name];
                if (argumentValues[deprecated.from] != nil && options[deprecated.to] != nil) {
                    argumentValues[deprecated.to] = argumentValues[deprecated.from];
                    [argumentValues removeObjectForKey:deprecated.from];
                    _deprecatedOptions[deprecated.from] = deprecated;
                }
            }
        }

        // Set the argument value(s) for the necessary options.
        for (id name in argumentValues) {
            // If provided option isn't actually an option, add it
            // to the list of unknown options.
            if (!options[name]) {
                [_unknownOptions addObject:name];
                continue;
            }

            CDOption *option = options[name];

            // Indicate that the option was provided.
            option.wasProvided = YES;

            // Need to handle flags differently because they can potientally have valid arguments after them.
            // @todo Convert flags to a normal boolean where no value specified acts like a flag currently.
            if ([option isKindOfClass:[CDOptionFlag class]]) {
                option.value = @YES;
                // If there are any "values" for this option, then they
                // are actually arguments that should be added back.
                for (arg in argumentValues[name]) {
                    [_arguments addObject:arg];
                }
            }
            else {
                [option setValues:argumentValues[name]];
            }
        }

        // Handle missing required options.
        if (options.requiredOptions.count) {
            for (NSString *name in options.requiredOptions) {
                if (!options[name].wasProvided) {
                    _missingOptions[name] = options.requiredOptions[name];
                }
            }
        }

        _options = options;
    }
    return self;
}

@end
