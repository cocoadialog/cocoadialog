// CDOptions.m
// cocoadialog
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.

#import "CDOptions.h"

@implementation CDOptions

@synthesize options, deprecatedOptions, getOptionCallback, getOptionOnceCallback, missingArgumentBreaks, requiredOptions, seenOptions, setOptionCallback, unknownOptions;


#pragma mark - Properties
- (NSArray<NSString *> *) allKeys {
    return options.allKeys;
}

- (NSArray<CDOption *> *) allValues {
    return options.allValues;
}

- (NSDictionary <NSString *, CDOptions *> *) groupByCategories {
    NSMutableDictionary<NSString *, CDOptions *> *categories = [NSMutableDictionary dictionary];
    for (NSString *name in options) {
        CDOption *opt = options[name];

        // Skip hidden options.
        if (opt.hidden) {
            continue;
        }

        NSString *category = opt.category != nil ? opt.category : NSLocalizedString(@"USAGE_CATEGORY_CONTROL", nil);
        if (categories[category] == nil) {
            categories[category] = [CDOptions options];
        }

        [categories[category] add:opt];
    }
    return categories;
}

- (NSMutableDictionary<NSString *,CDOption *> *)requiredOptions {
    NSMutableDictionary *required = [NSMutableDictionary dictionaryWithDictionary:requiredOptions];
    for (NSString *name in options) {
        CDOption *option = options[name];
        if (option.conditionalRequirements.count) {
            for (NSUInteger i = 0; i < option.conditionalRequirements.count; i++) {
                CDOptionConditionalRequirement block = (CDOptionConditionalRequirement) option.conditionalRequirements[i];
                if (block()) {
                    required[name] = option;
                    break;
                }
            }
        }
        else if (option.required) {
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
    return !!(arg && arg.length >= 2 && [[arg substringWithRange:NSMakeRange(0, 2)] isEqualToString:@"--"]);
}

+ (NSString *) optionNameFromArgument:(NSString *)arg {
    return [self isOption:arg] ? [arg substringFromIndex:2] : nil;
}

#pragma mark - Pubic static methods
+ (instancetype) options {
    return [[self alloc] init];
}

#pragma mark - Public instance methods
- (void) add:(CDOption *)opt {
    // Set the default category for the option if none was provided.
    if (self.defaultCategory != nil && opt.category == nil) {
        opt.category = self.defaultCategory;
    }

    // Add "double dash" note for multiple option values.
    if ([opt.minimumValues unsignedIntegerValue] >= 1 && [opt.maximumValues unsignedIntegerValue] == 0) {
        NSString *doubleDash = NSLocalizedString(@"OPTION_MULTIPLE_DOUBLE_DASH", nil);
        if (![opt.notes containsObject:doubleDash]) {
            [opt.notes addObject:doubleDash];
        }
    }

    // Handle deprecated options.
    if (opt.deprecatedTo != nil) {
        deprecatedOptions[opt.name] = opt;
    }
    else {
        options[opt.name] = opt;
    }
}

- (NSUInteger) count {
    return options.count;
}

- (NSString *) getArgument:(unsigned int)index {
    return self.arguments != nil && index < self.arguments.count ? self.arguments[index] : nil;
}

- (instancetype) init {
    self = [super init];
    if (self) {
        _arguments = [NSMutableArray array];
        deprecatedOptions = [NSMutableDictionary dictionary];
        options = [NSMutableDictionary dictionary];
        missingArgumentBreaks = [NSMutableArray array];
        requiredOptions = [NSMutableDictionary dictionary];
        seenOptions = [NSMutableArray array];
        unknownOptions = [NSMutableArray array];
    }
    return self;
}

- (instancetype )initWithObjects:(id  _Nonnull const [])objects forKeys:(id<NSCopying>  _Nonnull const [])keys count:(NSUInteger)cnt {
    self = [super init];
    if (self) {
        options = [[NSMutableDictionary alloc] initWithObjects:objects forKeys:keys count:cnt];
    }
    return self;
}

- (NSEnumerator *) keyEnumerator {
    return options.keyEnumerator;
}

- (CDOptions *) processArguments:(NSArray *)arguments {
    NSMutableArray *args = [NSMutableArray arrayWithArray:arguments];

    // Parse provided arguments.
    NSString *arg = nil;
    BOOL unknownOption = NO;
    for (NSUInteger i = 0; i < args.count; i++) {
        arg = args[i];

        NSString *optionName = [CDOptions optionNameFromArgument:arg];

        // Capture normal arguments.
        if (optionName == nil) {
            if (!unknownOption) {
                [self.arguments addObject:arg];
            }
            continue;
        }
        // Skip standalone double dash argument breaks.
        else if ([optionName isBlank]) {
            continue;
        }

        CDOption *option = nil;

        // Handle deprecated options.
        CDOption *deprecated = deprecatedOptions[optionName];
        if (deprecated) {
            deprecated.wasProvided = YES;
            option = deprecated;
        }
        else {
            option = options[optionName];
        }

        // If provided option isn't actually an available option,
        // add it to the list of unknown options and skip.
        if (!option) {
            [unknownOptions addObject:optionName];
            unknownOption = YES;
            continue;
        }

        unknownOption = NO;

        // Flag that the option was provided.
        option.wasProvided = YES;

        // Retrieve the minimum and maximum values allowed for this option.
        NSUInteger max = [option.maximumValues unsignedIntegerValue];
        NSUInteger min = [option.minimumValues unsignedIntegerValue];

        // Create an array to store values (in case option allows more than one).
        NSMutableArray<NSString *> *values = [NSMutableArray array];

        // Increase index to next argument.
        i++;

        // Determine how many values should be extracted.
        BOOL argumentBreak = NO;
        BOOL possibleOptionsDetected = NO;
        NSUInteger stop = max == 0 ? args.count : i + max;

        // Make sure we don't go past the argument count.
        if (stop > args.count) {
            stop = args.count;
        }

        // Extract value(s).
        for (; i < stop; i++) {
            // Detect argument breaks.
            argumentBreak = [args[i] isEqualToString:@"--"];

            // Detect possible options.
            if (!argumentBreak && [CDOptions isOption:args[i]]) {
                possibleOptionsDetected = YES;
            }

            // Stop if there are no more arguments, if it's a double dash argument break, or if option has no min.
            if (i >= args.count || !args[i] || argumentBreak || (possibleOptionsDetected && min == 0 && max == 1 && !values.count)) {
                break;
            }
            [values addObject:args[i]];
        }

        // Keep track of multiple arguments that didn't specify argument breaks.
        if ((max == 0) && possibleOptionsDetected && !argumentBreak) {
            [missingArgumentBreaks addObject:optionName];
        }

        // Decrease index since it's exiting the values loop and about
        // to get increased again at the start of the next argument loop.
        i--;

        // Set the provided values on the option.
        [option setValues:values];

        // Determine if parent option was not provided and override this option.
        if (option.parentOption != nil && options[option.parentOption.name] != nil && !options[option.parentOption.name].wasProvided) {
            option.wasProvided = NO;
            [option setValues:[NSArray array]];
        }
    }

    // Process deprecated options.
    for (NSString *name in deprecatedOptions) {
        CDOption *from = deprecatedOptions[name];
        CDOption *to = options[from.deprecatedTo];

        // Skip deprecated options that weren't provided or real options that don't exist.
        if (!from.wasProvided || !to) {
            continue;
        }

        // Indicate that the replacement option was provided.
        to.wasProvided = YES;

        if (from.deprecatedValueIndex) {
            [to setValue:from.stringValue atIndex:from.deprecatedValueIndex.unsignedIntegerValue];
        }
        else {
            [to setValues:from.arrayValue];
        }
    }

    return self;
}

- (void) remove:(NSString *)name {
    [options removeObjectForKey:name];
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
