#ifdef CD_HEAD
// CDOptions.m
// cocoadialog
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.
#else
/*
	CDOptions.m
	cocoaDialog
	Copyright (C) 2004 Mark A. Stratman <mark@sporkstorms.org>

	This program is free software; you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation; either version 2 of the License, or
	(at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program; if not, write to the Free Software
	Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
*/
#endif

#import "CDOptions.h"

#import "NSString+CDString.h"

@implementation CDOptions

#ifdef CD_HEAD
@synthesize requiredOptions;

- (instancetype) init {
    self = [super init];
    if (self) {
        _arguments = @[].mutableCopy;
        _deprecatedOptions = @{}.mutableCopy;
        _options = @{}.mutableCopy;
        _missingArgumentBreaks = @[].mutableCopy;
        _terminal = [CDTerminal sharedInstance];
        requiredOptions = @{}.mutableCopy;
        _seenOptions = @[].mutableCopy;
        _unknownOptions = @[].mutableCopy;
    }
    return self;
}

#pragma mark - Properties
- (NSArray<NSString *> *) allKeys {
    return self.options.allKeys;
}

- (NSArray<CDOption *> *) allValues {
    return self.options.allValues;
}

- (NSDictionary <NSString *, CDOptions *> *) groupByScope {
    NSMutableDictionary<NSString *, CDOptions *> *scopes = [NSMutableDictionary dictionary];
    for (NSString *name in self.options) {
        CDOption *opt = self.options[name];

        // Skip hidden options.
        if (opt.hidden) {
            continue;
        }

        NSString *scope = opt.scope != nil ? opt.scope : @"USAGE_CATEGORY_CONTROLS".localized;
        if (scopes[scope] == nil) {
            scopes[scope] = [CDOptions options];
        }

        scopes[scope][opt.name] = opt;
    }
    return scopes;
}

- (NSMutableDictionary<NSString *,CDOption *> *) requiredOptions {
    NSMutableDictionary *required = [NSMutableDictionary dictionaryWithDictionary:requiredOptions];
    for (NSString *name in self.options) {
        if (self.options[name].required) {
            required[name] = self.options[name];
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

+ (instancetype) sharedInstance {
    static CDOptions *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[CDOptions alloc] init];
    });
    return sharedInstance;
}

#pragma mark - Public instance methods
- (NSUInteger) count {
    return self.options.count;
}

- (NSString *) getArgument:(unsigned int)index {
    return self.arguments != nil && index < self.arguments.count ? self.arguments[index] : nil;
}

- (instancetype )initWithObjects:(id  _Nonnull const [])objects forKeys:(id<NSCopying>  _Nonnull const [])keys count:(NSUInteger)cnt {
    self = [super init];
    if (self) {
        _options = [[NSMutableDictionary alloc] initWithObjects:objects forKeys:keys count:cnt];
    }
    return self;
}

- (NSEnumerator *) keyEnumerator {
    return self.options.keyEnumerator;
}

- (void) remove:(NSString *)name {
    [self.options removeObjectForKey:name];
}

#pragma mark - Enumeration
- (NSUInteger) countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id __unsafe_unretained [])stackbuf count:(NSUInteger)len {
    return [self.options countByEnumeratingWithState:state objects:stackbuf count:len];
}

- (CDOption *) objectForKey:(NSString *)key {
    CDOption *opt = self.options[key];
    if (opt) {
        if (self.getOptionOnceCallback && ![self.seenOptions containsObject:key]) {
            [self.seenOptions addObject:key];
            self.getOptionOnceCallback(opt);
    	}
        if (self.getOptionCallback) {
            self.getOptionCallback(opt);
        }
    }
    return opt;
}
#else
- initWithOpts:(NSMutableDictionary *)opts
{
	self = [super init];
	_options = [opts retain];
	return self;
}
- init
{
	return [self initWithOpts:[NSMutableDictionary dictionary]];
}

+ (BOOL) _argIsKey:(NSString *)arg availableKeys:(NSDictionary *)availableKeys depreciatedKeys:(NSDictionary *)depreciatedKeys
{
	if ([arg length] > 2 && [[arg substringWithRange:NSMakeRange(0,2)] isEqualToString:@"--"] &&
        ([availableKeys objectForKey:[arg substringFromIndex:2]] != nil || [depreciatedKeys objectForKey:[arg substringFromIndex:2]] != nil))
	{
		return YES;
	} else {
		return NO;
	}
}

+ (CDOptions *) getOpts:(NSArray *)args availableKeys:(NSDictionary *)availableKeys depreciatedKeys:(NSDictionary *)depreciatedKeys
{
	NSMutableDictionary *options;
	NSString *arg;
	NSMutableArray *values;
	int argType;

	options = [[[NSMutableDictionary alloc] init] autorelease];

	unsigned i = 0;
	while (i < [args count]) {
		arg = [args objectAtIndex:i];

		// If the arg is a key we specified above...
		if ([CDOptions _argIsKey:arg availableKeys:availableKeys depreciatedKeys:depreciatedKeys]) {
			// strip leading '--'
			arg = [arg substringFromIndex:2];

            // Replace the argument with the newer one if it's depreciated
            NSString * depreciatedArg = [depreciatedKeys objectForKey:arg];
            if (depreciatedArg != nil) {
                arg = depreciatedArg;
            }

            argType = [[availableKeys objectForKey:arg] intValue];

			// If it's a no-value option, store the bool NO to indicate
			// no values for this key, increment i and continue.
			if (argType == CDOptionsNoValues) {
				[options setObject:[NSNumber numberWithBool:NO] forKey:arg];
				i++;
				continue;
			}
			// Control reaches here there should be one or more
			// values for key.
            if (argType == CDOptionsMultipleValues) {
                values = [[[NSMutableArray alloc] init] autorelease];
            }
			while (i+1 < [args count]) {
				NSString *nextArg = [args objectAtIndex:i+1];

				// set single string value for this key,
				// increment i and stop looking for more values
				if (argType == CDOptionsOneValue) {
					[options setObject:nextArg
						    forKey:arg];
					i++;
					break;
				}
				// add a value to the values array
                else if (argType == CDOptionsMultipleValues && ![CDOptions _argIsKey:[args objectAtIndex:i+1] availableKeys:availableKeys depreciatedKeys:depreciatedKeys]) {
					[values addObject:nextArg];
					i++;

				// Programmer supplied an invalid type for this
				// available key.
				} else {
					break;
				}
			} // End looking for values to add to the key

			// set the array of values for this key
			if (argType == CDOptionsMultipleValues) {
				[options setObject:values forKey:arg];
			}
		} // End "if arg was a key"
		i++;
	} // End processing all args

	return [[[CDOptions alloc] initWithOpts:options] autorelease];
}

+ (void) printOpts:(NSArray *)availableOptions forRunMode:(NSString *)runMode
{
	NSFileHandle *fh = [NSFileHandle fileHandleWithStandardOutput];

	if (fh) {
        [fh writeData:[@"Usage:\tcocoaDialog " dataUsingEncoding:NSUTF8StringEncoding]];
        [fh writeData:[[runMode lowercaseString] dataUsingEncoding:NSUTF8StringEncoding]];
        [fh writeData:[@" [options]\n\tAvailable options:\n" dataUsingEncoding:NSUTF8StringEncoding]];

        NSArray *sortedAvailableKeys = [NSArray arrayWithArray:[availableOptions sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];

        NSEnumerator *en = [sortedAvailableKeys objectEnumerator];
        id key;
        unsigned i = 0;
        unsigned currKey = 0;
        while ((key = [en nextObject])) {
            if (i == 0) {
                [fh writeData:[@"\t\t" dataUsingEncoding:NSUTF8StringEncoding]];
            }
            [fh writeData:[@"--" dataUsingEncoding:NSUTF8StringEncoding]];
            [fh writeData:[key dataUsingEncoding:NSUTF8StringEncoding]];
            if (i <= 6 && currKey != [sortedAvailableKeys count] - 1) {
                [fh writeData:[@", " dataUsingEncoding:NSUTF8StringEncoding]];
                i++;
            }
            if (i == 6 || currKey == [sortedAvailableKeys count] - 1) {
                [fh writeData:[@"\n" dataUsingEncoding:NSUTF8StringEncoding]];
                i = 0;
            }
            currKey++;
        }
        if (self.getOptionCallback) {
            self.getOptionCallback(opt);
        }
    }
    return opt;
}
#endif

- (CDOption *) objectForKeyedSubscript:(NSString *)key {
    return [self objectForKey:key];
}

- (void) setObject:(CDOption *)opt forKey:(NSString*)key {
    if (self.setOptionCallback != nil) {
        self.setOptionCallback(opt, key);
    }
    if (!self.options[key]) {
        // Add "double dash" note for multiple option values.
        if (opt.minimumValues.unsignedIntegerValue >= 1 && opt.maximumValues.unsignedIntegerValue == 0) {
            NSString *doubleDash = @"OPTION_MULTIPLE_DOUBLE_DASH".localized;
            if (![opt.notes containsObject:doubleDash]) {
                [opt.notes addObject:doubleDash];
            }
        }

        // Handle deprecated options.
        if (opt.deprecatedTo != nil) {
            self.deprecatedOptions[opt.name] = opt;
        }
        else {
            self.options[opt.name] = opt;
        }

        // Add any deprecated options this option contains.
        for (CDOption* depOpt in opt.deprecatedOptions) {
            self[depOpt.name] = depOpt;
        }
    }

    self.options[key] = opt;
}

#ifdef CD_HEAD
- (void) setObject:(CDOption *)opt forKeyedSubscript:(NSString*)key {
    [self setObject:opt forKey:key];
}
#else
- (NSString *) optValue:(NSString *)key
{
	id value = [_options objectForKey:key];
	// value will be an NSNumber (set in getOpts) if there is no value
	// for that key, NSString of the value, or nil if that key didn't exist
	if ((value == nil) || ![value isKindOfClass:[NSString class]]) {
		return nil;
	} else {
		return value;
	}
}
#endif


#pragma mark - Public chainable methods

- (CDOptions *(^)(NSArray <CDOption *> *)) addOptions {
    return ^CDOptions *(NSArray <CDOption *> *opts) {
        for (CDOption *option in opts) {
            self[option.name] = option;
        }
        return self;
    };
}

- (CDOptions *(^)(NSString *, NSArray <CDOption *> *)) addOptionsToScope {
    return ^CDOptions *(NSString *scope, NSArray <CDOption *> *opts) {
        for (CDOption *option in opts) {
            self[option.name] = option.setScope(scope);
        }
        return self;
    };
}

- (CDOptions *(^)(void)) processTerminalArguments {
    return ^CDOptions *(void) {
        // Immediately return if these options have already been processed by
        if (self.processedTerminalArguments) {
            return self;
        }

        NSMutableArray *args = self.terminal.arguments.mutableCopy;
        NSInteger count = args.count;

        // Parse provided arguments.
        NSString *arg;
        BOOL unknownOption = NO;
        for (NSInteger i = 0; i < count; i++) {
            arg = args[i];

            NSString *optionName = [CDOptions optionNameFromArgument:arg];

            // Capture normal arguments.
            if (!optionName) {
                if (!unknownOption) {
                    [self.arguments addObject:arg];
                }
                continue;
            }
            // Skip standalone double dash argument breaks.
            else if ([optionName isBlank]) {
                continue;
            }

            CDOption *option;

            // Handle deprecated options.
            CDOption *deprecated = self.deprecatedOptions[optionName];
            if (deprecated) {
                deprecated.wasProvided = YES;
                option = deprecated;
            }
            else {
                option = self.options[optionName];
            }

            // If provided option isn't actually an available option,
            // add it to the list of unknown options and skip.
            if (!option) {
                [self.unknownOptions addObject:optionName];
                unknownOption = YES;
                continue;
            }

            unknownOption = NO;

            // Flag that the option was provided.
            option.wasProvided = YES;

            // Retrieve the minimum and maximum values allowed for this option.
            NSInteger max = option.maximumValues.integerValue;
            NSInteger min = option.minimumValues.integerValue;

            // Create an array to store values (in case option allows more than one).
            NSMutableArray<NSString *> *values = [NSMutableArray array];

            // Increase index to next argument.
            i++;

            // Determine how many values should be extracted.
            BOOL argumentBreak = NO;
            BOOL possibleOptionsDetected = NO;
            NSInteger stop = max == 0 ? count : i + max;

            // Make sure we don't go past the argument count.
            if (stop > count) {
                stop = count;
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
                if (i >= count || !args[i] || argumentBreak || (possibleOptionsDetected && min == 0 && max == 1 && !values.count)) {
                    break;
                }
                [values addObject:args[i]];
            }

            // Keep track of multiple arguments that didn't specify argument breaks.
            if ((max == 0) && possibleOptionsDetected && !argumentBreak) {
                [self.missingArgumentBreaks addObject:optionName];
            }

            // Decrease index since it's exiting the values loop and about
            // to get increased again at the start of the next argument loop.
            i--;

            // Determine if parent option was not provided and override this option.
            if (option.parentOption != nil && self.options[option.parentOption.name] != nil && !self.options[option.parentOption.name].wasProvided) {
                option.wasProvided = NO;
                option.values = @[].mutableCopy;
            }
            // Set the provided values on the option.
            else {
                option.values = values.mutableCopy;
            }
        }

        // Process deprecated options.
        for (NSString *name in self.deprecatedOptions) {
            CDOption *from = self.deprecatedOptions[name];
            CDOption *to = self.options[from.deprecatedTo];

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
                to.values = from.arrayValue.mutableCopy;
            }
        }

        // Determine the current log level. must be done immediately after options
        // have been processed so logging respects any passed values).
        CDTerminalLogLevel logLevel = CDTerminalLogLevelNone;
        if (!_options[@"quiet"].boolValue) {
            if (_options[@"debug"].boolValue)   logLevel |= CDTerminalLogLevelDebug;
            if (_options[@"dev"].boolValue)     logLevel |= CDTerminalLogLevelDev;
            if (_options[@"error"].boolValue)   logLevel |= CDTerminalLogLevelError;
            if (_options[@"verbose"].boolValue) logLevel |= CDTerminalLogLevelVerbose;
            if (_options[@"warning"].boolValue) logLevel |= CDTerminalLogLevelWarning;
        }
        self.terminal.setLogLevel(logLevel);

        // Indicate that this has been processed.
        _processedTerminalArguments = YES;

        return self;
    };
}

- (CDOptions *(^)(CDControl *)) processWithControl {
    return ^CDOptions *(CDControl* control) {
        if (self.processedWithControl) {
            return self;
        }

        for (NSString* name in self.options) {
            if (self.options[name].processBlocks.count) {
                for (CDOptionProcessBlock block in self.options[name].processBlocks) {
                    block(control);
                }
            }
        }

        _processedWithControl = YES;

        return self;
    };
}

#ifndef CD_HEAD
- (NSComparisonResult)localizedCaseInsensitiveCompare:(NSString *)string
{
    return [string localizedCaseInsensitiveCompare:string];
}
#endif

@end
