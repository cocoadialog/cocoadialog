// CDControl.m
// cocoadialog
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.

#import "CDApplication.h"
#import "CDControl.h"

#pragma mark -
@implementation CDControl

#pragma mark - Properties
@synthesize name;
@synthesize option;
@synthesize terminal;

- (NSString *) name {
    return self.alias ? [NSString stringWithFormat:@"%@ (%@)", self.alias.name, name] : name;
}

- (BOOL) isBaseControl {
    return [self class] == [CDControl class];
}

#pragma mark - Public static methods
+ (instancetype) control {
    return [[self alloc] init];
}

#pragma mark - Public instance methods
- (NSBundle *) appBundle {
    return [NSBundle bundleWithIdentifier:option[@"app-bundle"].stringValue] ?: [NSBundle mainBundle];
}

- (CDOptions *) availableOptions {
    CDOptions *options = [CDOptions options];

    // Add special hidden --dev option (doesn't show up in output.
    [options add:[CDOptionBoolean name:@"dev"]];
    options[@"dev"].hidden = YES;

    // --color
    [options add:[CDOptionBoolean                 name:@"color"               category:@"GLOBAL_OPTION"]];
    options[@"color"].defaultValue = (CDOptionAutomaticDefaultValue) ^() {
        return [NSNumber numberWithBool:self.terminal.supportsColor];
    };

    // --debug
    [options add:[CDOptionBoolean                 name:@"debug"               category:@"GLOBAL_OPTION"]];
    [options[@"debug"].warnings addObject:NSLocalizedString(@"OPTION_WARNING_AFFECTS_OUTPUT", nil)];

    // --help
    [options add:[CDOptionBoolean                 name:@"help"                category:@"GLOBAL_OPTION"]];

    // --output
    [options add:[CDOptionSingleString            name:@"output"              category:@"GLOBAL_OPTION"]];
    [options[@"output"].allowedValues addObjectsFromArray:@[@"columns", @"json"]];
    options[@"output"].defaultValue = @"columns";

    // --quiet
    [options add:[CDOptionBoolean                 name:@"quiet"               category:@"GLOBAL_OPTION"]];

    // --screen
    [options add:[CDOptionSingleNumber            name:@"screen"              category:@"GLOBAL_OPTION"]];
    options[@"screen"].defaultValue = (CDOptionAutomaticDefaultValue) ^() {
        return [NSNumber numberWithUnsignedInteger:[[NSScreen screens] indexOfObject:[NSScreen mainScreen]]];
    };

    // --verbose
    [options add:[CDOptionBoolean                 name:@"verbose"             category:@"GLOBAL_OPTION"]];
    [options[@"verbose"].warnings addObject:NSLocalizedString(@"OPTION_WARNING_AFFECTS_OUTPUT", nil)];

    // --version
    [options add:[CDOptionBoolean                 name:@"version"             category:@"GLOBAL_OPTION"]];

    // --warnings
    [options add:[CDOptionBoolean                 name:@"warnings"            category:@"GLOBAL_OPTION"]];
    options[@"warnings"].defaultValue = @YES;

    return options;
}

- (instancetype) init {
    return [self initWithAlias:nil seenOptions:@[]];
}

- (instancetype) initWithAlias:(CDControlAlias *)alias seenOptions:(NSArray *)seenOptions{
    self = [super init];
    if (self) {
        // Properties.
        terminal = [CDTerminal terminal];

        // Default to terminal support.
        NSStringCDColor = terminal.supportsColor;

        exitStatus = CDExitCodeOk;
        controlItems = [NSMutableArray array];
        returnValues = [NSMutableDictionary dictionary];

        self.alias = alias;

        NSArray *arguments;
        // Merge in the alias information.
        if (alias) {
            NSMutableArray *args = [NSMutableArray arrayWithArray:terminal.getArguments];
            NSUInteger controlNameIndex = [args indexOfObject:alias.name];
            if (controlNameIndex < args.count) {
                [args replaceObjectAtIndex:controlNameIndex withObject:alias.controlName];
            }
            arguments = args;
        }
        else {
            arguments = terminal.getArguments;
        }

        option = [[self availableOptions] processArguments:arguments];

        if (alias) {
            alias.process(option, self);
        }

        // Allow option to override whether color should be used.
        NSStringCDColor = option[@"color"].boolValue;

        if (seenOptions != nil) {
            option.seenOptions = [NSMutableArray arrayWithArray:seenOptions];
        }

        __block CDControl *control = self;

        // Provide some useful debugging information for default/automatic values.
        // Note: this must be added here, after avaialble options have populated in
        // case they access the options themselves to add additional properties like
        // "required" or "defaultValue".
        option.getOptionOnceCallback = ^(CDOption *opt) {
            // Immediately return if parent option wasn't provided.
            if (opt.parentOption != nil && !opt.parentOption.wasProvided) {
                return;
            }

            // Option debug info.
            if (!opt.wasProvided) {
                // Ignore if no default value was provided.
                if (opt.defaultValue == nil) {
                    return;
                }
                NSMutableString *value = [NSMutableString stringWithString:opt.displayValue];
                if (opt.hasAutomaticDefaultValue) {
                    [value appendString:[NSString stringWithFormat:@" (%@)", NSLocalizedString(@"OPTION_AUTOMATIC_DEFAULT_VALUE", nil).lowercaseString]];
                }
                if ([opt isKindOfClass:[CDOptionMultipleNumbers class]] || [opt isKindOfClass:[CDOptionMultipleStrings class]] || [opt isKindOfClass:[CDOptionMultipleStringsOrNumbers class]]) {
                    [control debug:@"The %@ option was not provided. Using default values: %@", opt.name.optionFormat, value, nil];
                }
                else {
                    [control debug:@"The %@ option was not provided. Using default value: %@", opt.name.optionFormat, value, nil];
                }
            }
            else {
                if ([opt isKindOfClass:[CDOptionMultipleNumbers class]] || [opt isKindOfClass:[CDOptionMultipleStrings class]] || [opt isKindOfClass:[CDOptionMultipleStringsOrNumbers class]]) {
                    [control debug:@"The %@ option was provided with the values: %@", opt.name.optionFormat, opt.displayValue, nil];
                }
                else {
                    [control debug:@"The %@ option was provided with the value: %@", opt.name.optionFormat, opt.displayValue, nil];
                }
            }
        };
    }
    return self;
}

- (void) initControl {
    // Load nib
    if (!self.xib || self.xib.isBlank) {
        [self fatal: CDExitCodeControlFailure error:@"Control did not specify a XIB interface file to load.", nil];
    }

    if (![[NSBundle mainBundle] loadNibNamed:self.xib owner:self topLevelObjects:nil]) {
        [self fatal: CDExitCodeControlFailure error:@"Unable to load: %@", [NSString stringWithFormat:@"%@.xib", self.xib].doubleQuote, nil];
    }
};

- (NSScreen *) getScreen {
    NSUInteger index = option[@"screen"].unsignedIntegerValue;
    NSArray *screens = [NSScreen screens];
    if (index >= [screens count]) {
        [self warning:@"Unknown screen index: %@. Using screen where keyboard has focus.", [NSNumber numberWithUnsignedInteger:index], nil];
        return [NSScreen mainScreen];
    }
    return [screens objectAtIndex:index];
}

- (NSString *) loadTemplate:(NSString *)templateName withData:(id)data {
    NSError *templateError, *renderError;

    CDTemplate *template = [CDTemplate load:templateName data:data error:&templateError];
    if (templateError) {
        [self fatal:CDExitCodeControlFailure error:@"%@", templateError.localizedDescription, nil];
    }

    NSString *rendered = [template renderError:&renderError];
    if (renderError) {
        [self fatal:CDExitCodeControlFailure error:@"%@", renderError.localizedDescription, nil];
    }

    return rendered;
}

- (void) runControl {
    [NSApp run];
}

- (void) showUsage {
    NSArray <CDControlAlias *> *controlAliases = [CDApplication controlAliases];
    NSArray *controls = [CDApplication availableControls].sortedAlphabetically;
    NSString *version = [CDApplication appVersion];

    NSMutableString *controlUsage = [NSMutableString string];
    if (self.isBaseControl || name == nil) {
        [controlUsage appendString:[NSString stringWithFormat:@"<%@>", NSLocalizedString(@"CONTROL", nil).lowercaseString]];
    }
    else {
        [controlUsage appendString:name];
        if (option.requiredOptions.count) {
            for (NSString *optionName in option.requiredOptions.allKeys.sortedAlphabetically) {
                CDOption *opt = option.requiredOptions[optionName];
                NSMutableString *required = [NSMutableString stringWithString:opt.label.white.bold];
                [controlUsage appendString:@" "];
                NSString *requiredType = opt.typeLabel;
                if (requiredType != nil) {
                    [required appendString:@" "];
                    [required appendString:requiredType];
                }
                [controlUsage appendString:required];
                [controlUsage appendString:@"".white.bold];
            }
        }
    }

    // Output usage as JSON.
    if ([option[@"output"].stringValue isEqualToStringCaseInsensitive:@"json"]) {
        NSMutableDictionary *output = [NSMutableDictionary dictionary];
        output[@"controlAliases"] = controlAliases;
        output[@"controls"] = controls;
        output[@"deprecatedControls"] = [CDApplication deprecatedControls];
        output[@"removedControls"] = [CDApplication removedControls];
        output[@"options"] = option;
        output[@"usage"] = [NSString stringWithFormat:NSLocalizedString(@"USAGE", nil), controlUsage];
        output[@"version"] = version;
        output[@"website"] = @CDSite;
        [self.terminal write:output.toJSONString];
        exit(0);
    }

    NSUInteger margin = 4;

    // If (for whatever reason) there is no terminal width, default to 80.
    NSUInteger terminalColumns = [self.terminal colsWithMinimum:80] - margin;

    [self.terminal writeNewLine];
    [self.terminal writeLine:[NSString stringWithFormat:NSLocalizedString(@"USAGE", nil), controlUsage].white.bold.stop];

    // Show avilable controls if it's the CDControl class printing this.
    if ([self class] == [CDControl class]) {
        NSString *controlsString = [controls componentsJoinedByString:@", "].white.bold.stop;
        [self.terminal writeNewLine];
        [self.terminal writeLine:NSLocalizedString(@"USAGE_CATEGORY_CONTROLS", nil).uppercaseString.white.bold.underline.stop];
        [self.terminal writeNewLine];
        controlsString = [controlsString wrapToLength:terminalColumns];
        controlsString = [controlsString indentNewlinesWith:margin];
        [self.terminal writeLine:[controlsString indent:margin]];
        [self.terminal writeNewLine];

        if (controlAliases.count) {
            [self.terminal writeNewLine];
            [self.terminal writeLine:NSLocalizedString(@"USAGE_CATEGORY_CONTROL_ALIASES", nil).uppercaseString.white.bold.underline.stop];
            [self.terminal writeNewLine];

            for (CDControlAlias *alias in controlAliases) {
                NSMutableString *controlAliasesString = [NSMutableString string];
                if ([alias.name isEqualToStringCaseInsensitive:@"about"]) {
                    [controlAliasesString appendFormat:@"%@\t\t - %@\n", alias.name.bold.white.stop, alias.helpText];
                }
                else {
                    [controlAliasesString appendFormat:@"%@ - Alias for: %@ %@", alias.name.white.bold.stop, alias.controlName.magenta, alias.helpText.magenta];
                }
                [self.terminal writeLine:[[[controlAliasesString wrapToLength:terminalColumns] indentNewlinesWith:margin * 2] indent:margin]];
            }
            [self.terminal writeNewLine];
        }
    }

    // Get all available options and put them in their necessary categories.
    NSDictionary<NSString *, CDOptions *> *categories = [self availableOptions].groupByCategories;

    // Print options for each category.
    NSEnumerator *sortedCategories = [[NSArray arrayWithArray:[categories.allKeys sortedArrayUsingComparator:^NSComparisonResult(NSString *a, NSString *b) {
        // Ensure global options are always at the bottom.
        if ([a isEqualToString:NSLocalizedString(@"GLOBAL_OPTION", nil)]) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        else if ([b isEqualToString:NSLocalizedString(@"GLOBAL_OPTION", nil)]) {
            return (NSComparisonResult)NSOrderedAscending;
        }
        return [a localizedCaseInsensitiveCompare:b];
    }]] objectEnumerator];
    NSString *category;
    while (category = [sortedCategories nextObject]) {
        [self.terminal writeNewLine];
        [self.terminal writeLine:category.uppercaseString.white.bold.underline.stop];
        [self.terminal writeNewLine];

        CDOptions *categoryOptions = categories[category];
        NSArray *sorted = categoryOptions.allKeys.sortedAlphabetically;
        for (NSString *optionName in sorted) {
            CDOption *categoryOption = categoryOptions[optionName];

            NSMutableString *column = [NSMutableString string];
            NSMutableArray *extra = [NSMutableArray array];

            [column appendString:[categoryOption.name.optionFormat indent:margin].white.bold.stop];

            // Add the "type" of option, if available.
            CDColor *typeColor = categoryOption.typeColor;
            NSString *typeLabel = categoryOption.typeLabel;
            if (typeLabel != nil) {
                if (categoryOption.hasAutomaticDefaultValue || [categoryOption isKindOfClass:[CDOptionBoolean class]]) {
                    typeLabel = typeLabel.dim;
                }
                [column appendString:@" "];
                [column appendString:typeLabel.stop];
            }

            // Indicate if option is required.
            if (categoryOption.required) {
                [column appendString:[NSString stringWithFormat:@" (%@)", NSLocalizedString(@"OPTION_REQUIRED_VALUE", nil).lowercaseString].red.bold.stop];
            }

            if (option[@"verbose"].wasProvided) {
                // Add the option help text (description).
                if (categoryOption.helpText != nil) {
                    [column appendString:@"\n"];

                    NSMutableString *helpText = [NSMutableString stringWithString:categoryOption.helpText];

                    // Wrap the column to fit available space.
                    helpText = [NSMutableString stringWithString:[helpText wrapToLength:(terminalColumns - (margin * 2))]];

                    // Replace new lines so they're intented properly.
                    helpText = [NSMutableString stringWithString:[helpText indentNewlinesWith:(margin * 2)]];

                    [column appendString:[helpText indent:(margin * 2)]];
                }

                // Add the allowed values.
                NSMutableArray *allowedValues = [NSMutableArray array];
                id value = nil;
                for (value in categoryOption.allowedValues) {
                    if (value != nil && [value isKindOfClass:[NSString class]]) {
                        NSString *valueString = (NSString *) value;
                        value = valueString.doubleQuote;
                    }
                    else if (value != nil && [value isKindOfClass:[NSNumber class]]) {
                        NSNumber *valueNumber = (NSNumber *) value;
                        if (strcmp([valueNumber objCType], @encode(BOOL)) == 0) {
                            value = [valueNumber boolValue] ? NSLocalizedString(@"YES", nil) : NSLocalizedString(@"NO", nil);
                        }
                        else {
                            value = [valueNumber stringValue];
                        }
                    }
                    [allowedValues addObject:value];
                }

                if (allowedValues.count > 0) {
                    [extra addObject:[NSString stringWithFormat:NSLocalizedString(allowedValues.count == 1 ? @"OPTION_ALLOWED_VALUE" : @"OPTION_ALLOWED_VALUES", nil).white.bold.stop, [[allowedValues componentsJoinedByString:@", "] applyColor:typeColor]]];
                }

                // Add the default/required values.
                id defaultValue = categoryOption.defaultValue;
                if (defaultValue != nil && [defaultValue isKindOfClass:[NSString class]]) {
                    NSString *defaultValueString = (NSString *) defaultValue;
                    defaultValue = defaultValueString.doubleQuote;
                }
                else if (defaultValue != nil && [defaultValue isKindOfClass:[NSNumber class]]) {
                    NSNumber *defaultValueNumber = (NSNumber *) defaultValue;
                    if (strcmp([defaultValueNumber objCType], @encode(BOOL)) == 0) {
                        defaultValue = [defaultValueNumber boolValue] ? NSLocalizedString(@"YES", nil) : NSLocalizedString(@"NO", nil);
                    }
                    else {
                        defaultValue = [defaultValueNumber stringValue];
                    }
                }

                if (defaultValue != nil) {
                    if (categoryOption.hasAutomaticDefaultValue) {
                        defaultValue = [NSString stringWithFormat:@"%@ (%@)", defaultValue, NSLocalizedString(@"OPTION_AUTOMATIC_DEFAULT_VALUE", nil)];
                    }
                    [extra addObject:[NSString stringWithFormat:NSLocalizedString(@"OPTION_DEFAULT_VALUE", nil).white.bold.stop, [defaultValue applyColor:typeColor]]];
                }

                if (extra.count > 0) {
                    [extra insertObject:@"" atIndex:0];
                    [column appendString:[[extra componentsJoinedByString:@"\n\n"] indentNewlinesWith:(margin * 2)]];
                }

                if (categoryOption.notes.count) {
                    [column appendString:@"\n\n"];
                    [column appendString:[[NSString stringWithFormat:@"%@:", NSLocalizedString(@"NOTE", nil).uppercaseString] indent:(margin * 2)].yellow.bold.stop];
                    if (categoryOption.notes.count == 1) {
                        [column appendString:[NSString stringWithFormat:@" %@", categoryOption.notes[0]].yellow.dim.stop];
                    }
                    else {
                        for (NSUInteger i = 0; i < categoryOption.notes.count; i++) {
                            [column appendString:@"\n"];
                            [column appendString:[[NSString stringWithFormat:@"* %@", categoryOption.notes[i]] indent:(margin * 3)].yellow.stop];
                        }
                    }
                }

                if (categoryOption.warnings.count) {
                    [column appendString:@"\n\n"];
                    [column appendString:[[NSString stringWithFormat:@"%@:", NSLocalizedString(@"WARNING", nil).uppercaseString] indent:(margin * 2)].red.bold.stop];
                    if (categoryOption.warnings.count == 1) {
                        [column appendString:[NSString stringWithFormat:@" %@", categoryOption.warnings[0]].red.stop];
                    }
                    else {
                        for (NSUInteger i = 0; i < categoryOption.warnings.count; i++) {
                            [column appendString:@"\n"];
                            [column appendString:[[NSString stringWithFormat:@"* %@", categoryOption.warnings[i]] indent:(margin * 3)].red.stop];
                        }
                    }
                }
                [column appendString:@"\n"];
            }

            [self.terminal writeLine:column];
        }
    }

    [self.terminal writeNewLine];
    [self.terminal writeNewLine];

    [self.terminal writeLine:[NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"USAGE_VERSION", nil).uppercaseString.underline.white.bold.stop, version.cyan]];

    [self.terminal writeNewLine];

    [self.terminal writeLine:[NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"USAGE_WEBSITE", nil).uppercaseString.underline.white.bold.stop, @CDSite.cyan.stop]];

    if (!option[@"verbose"].wasProvided) {
        [self.terminal writeNewLine];
        [self.terminal writeLine:@"---"];
        [self.terminal writeNewLine];
        [self.terminal writeLine:[NSString stringWithFormat:NSLocalizedString(@"USAGE_VERBOSE_OUTPUT", nil), @"--verbose".white.bold.stop]];
    }
}

- (void) stopControl {
    // Stop any modal windows currently running
    [NSApp stop:self];

    // If this is the about dialog, just exit.
    if (self.alias && [self.alias.name isEqualToStringCaseInsensitive:@"about"]) {
        exit(0);
    }

    // Output return values in specified format.
    if ([option[@"output"].stringValue isEqualToStringCaseInsensitive:@"json"]) {
        [self.terminal write:returnValues.toJSONString];
    }
    else {
        [self.terminal write:returnValues.toColumnString];
    }

    if (!option[@"no-newline"].wasProvided) {
        [self.terminal writeNewLine];
    }

    // Return the exit status
    exit(exitStatus);
}

#pragma mark - Logging
- (NSString *) argumentToString:(NSString *)arg lineColor:(CDColor *)lineColor argumentColor:(CDColor *)argumentColor {
    NSMutableString *string = [NSMutableString stringWithString:[arg applyColor:argumentColor]];
    [string appendString:[@"" applyColor:lineColor]];
    return string;
}

- (NSMutableArray *) argumentsToArray:(va_list)args lineColor:(CDColor *)lineColor argumentColor:(CDColor *)argumentColor {
    NSMutableArray *array = [NSMutableArray array];
    id arg;
    while ((arg = va_arg(args, id))) {
        if ([arg isKindOfClass:[NSString class]]) {
            [array addObject:[self argumentToString:arg lineColor:lineColor argumentColor:argumentColor]];
        }
        else {
            [array addObject:arg];
        }
    }
    va_end(args);
    return array;
}

- (void) debug:(NSString *)format, ... {
    // Immediately return if debug messages are disabled.
    if (!option[@"debug"].boolValue) {
        return;
    }

    CDColor *lineColor = [CDColor fg:CDColorFgMagenta];
    CDColor *argumentColor = [CDColor fg:CDColorFgWhite bg:CDColorBgNone style:CDColorStyleBold];

    // Get arguments.
    va_list va_args;
    va_start(va_args, format);
    NSMutableArray *args = [self argumentsToArray:va_args lineColor:lineColor argumentColor:argumentColor];

    format = [[NSMutableString prepend:NSLocalizedString(@"LOG_DEBUG", nil) toString:format] applyColor:lineColor].stop;
    [terminal writeErrorLine:[NSString stringWithFormat:format array:args]];
}

- (void) error:(NSString *)format, ... {
    CDColor *lineColor = [CDColor fg:CDColorFgRed bg:CDColorBgNone style:CDColorStyleBold];
    CDColor *argumentColor = [CDColor fg:CDColorFgWhite bg:CDColorBgNone style:CDColorStyleBold];

    // Get arguments.
    va_list va_args;
    va_start(va_args, format);
    NSMutableArray *args = [self argumentsToArray:va_args lineColor:lineColor argumentColor:argumentColor];

    format = [[NSMutableString prepend:NSLocalizedString(@"LOG_ERROR", nil) toString:format] applyColor:lineColor].stop;
    [terminal writeErrorLine:[NSString stringWithFormat:format array:args]];
}

- (void) fatal: (CDExitCode)exitCode error:(NSString *)format, ... {
    CDColor *lineColor = [CDColor fg:CDColorFgRed bg:CDColorBgNone style:CDColorStyleBold];
    CDColor *argumentColor = [CDColor fg:CDColorFgWhite bg:CDColorBgNone style:CDColorStyleBold];

    // Get arguments.
    va_list va_args;
    va_start(va_args, format);
    NSMutableArray *args = [self argumentsToArray:va_args lineColor:lineColor argumentColor:argumentColor];

    format = [[NSMutableString prepend:NSLocalizedString(@"LOG_ERROR", nil) toString:format] applyColor:lineColor].stop;
    [terminal writeErrorLine:[NSString stringWithFormat:format array:args]];
    exit(exitCode);
}

- (void) verbose:(NSString *)format, ... {
    // Immediately return if verbose messages are disabled.
    if (!option[@"verbose"].boolValue) {
        return;
    }

    CDColor *lineColor = [CDColor fg:CDColorFgCyan];
    CDColor *argumentColor = [CDColor fg:CDColorFgWhite bg:CDColorBgNone style:CDColorStyleBold];

    // Get arguments.
    va_list va_args;
    va_start(va_args, format);
    NSMutableArray *args = [self argumentsToArray:va_args lineColor:lineColor argumentColor:argumentColor];

    format = [[NSMutableString prepend:NSLocalizedString(@"LOG_VERBOSE", nil) toString:format] applyColor:lineColor].stop;
    [terminal writeErrorLine:[NSString stringWithFormat:format array:args]];
}

- (void) warning:(NSString *)format, ... {
    // Immediately return if warning messages are disabled.
    if (!option[@"warnings"].boolValue) {
        return;
    }

    CDColor *lineColor = [CDColor fg:CDColorFgYellow];
    CDColor *argumentColor = [CDColor fg:CDColorFgWhite bg:CDColorBgNone style:CDColorStyleBold];

    // Get arguments.
    va_list va_args;
    va_start(va_args, format);
    NSMutableArray *args = [self argumentsToArray:va_args lineColor:lineColor argumentColor:argumentColor];

    format = [[NSMutableString prepend:NSLocalizedString(@"LOG_WARNING", nil) toString:format] applyColor:lineColor].stop;
    [terminal writeErrorLine:[NSString stringWithFormat:format array:args]];
}

#pragma mark - Icon
- (NSImage *) iconFromFile:(NSString *)file {
    NSImage *image = [[NSImage alloc] initWithContentsOfFile:file];
    if (image == nil) {
        [self warning:@"Could not return icon from specified file: %@.", file.doubleQuote, nil];
    }
    return image;
}

- (NSImage *) iconFromName:(NSString *)value {
    BOOL hasImage = NO;
    NSImage *image = [[NSImage alloc] init];
    NSString *bundle = option[@"icon-bundle"].stringValue;
    NSString *path = nil;

    // Set default bundle identifier
    if (bundle == nil) {
        // Application icon
        if ([value isEqualToStringCaseInsensitive:@"cocoadialog"]) {
            image = NSApp.applicationIconImage;
            hasImage = YES;
        }
        // User specific computer image
        else if ([value isEqualToStringCaseInsensitive:@"computer"]) {
            image = [NSImage imageNamed: NSImageNameComputer];
            hasImage = YES;
        }
        // Bundle Identifications
        else if ([value isEqualToStringCaseInsensitive:@"addressbook"]) {
            value = @"AppIcon";
            bundle = @"com.apple.AddressBook";
        }
        else if ([value isEqualToStringCaseInsensitive:@"airport"]) {
            value = @"AirPort";
            bundle = @"com.apple.AirPortBaseStationAgent";
        }
        else if ([value isEqualToStringCaseInsensitive:@"airport2"]) {
            value = @"AirPort";
            bundle = @"com.apple.wifi.diagnostics";
        }
        else if ([value isEqualToStringCaseInsensitive:@"archive"]) {
            value = @"bah";
            bundle = @"com.apple.archiveutility";
        }
        else if ([value isEqualToStringCaseInsensitive:@"bluetooth"]) {
            value = @"AppIcon";
            bundle = @"com.apple.BluetoothAudioAgent";
        }
        else if ([value isEqualToStringCaseInsensitive:@"application"]) {
            value = @"GenericApplicationIcon";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";
        }
        else if ([value isEqualToStringCaseInsensitive:@"bonjour"] || [value isEqualToStringCaseInsensitive:@"atom"]) {
            value = @"Bonjour";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";
        }
        else if ([value isEqualToStringCaseInsensitive:@"burn"] || [value isEqualToStringCaseInsensitive:@"hazard"]) {
            value = @"BurningIcon";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";
        }
        else if ([value isEqualToStringCaseInsensitive:@"caution"]) {
            value = @"AlertCautionIcon";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";
        }
        else if ([value isEqualToStringCaseInsensitive:@"document"]) {
            value = @"GenericDocumentIcon";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";
        }
        else if ([value isEqualToStringCaseInsensitive:@"documents"]) {
            value = @"ToolbarDocumentsFolderIcon";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";
        }
        else if ([value isEqualToStringCaseInsensitive:@"download"]) {
            value = @"ToolbarDownloadsFolderIcon";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";
        }
        else if ([value isEqualToStringCaseInsensitive:@"eject"]) {
            value = @"EjectMediaIcon";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";
        }
        else if ([value isEqualToStringCaseInsensitive:@"everyone"]) {
            value = @"Everyone";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";
        }
        else if ([value isEqualToStringCaseInsensitive:@"executable"]) {
            value = @"ExecutableBinaryIcon";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";
        }
        else if ([value isEqualToStringCaseInsensitive:@"favorite"] || [value isEqualToStringCaseInsensitive:@"heart"]) {
            value = @"ToolbarFavoritesIcon";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";
        }
        else if ([value isEqualToStringCaseInsensitive:@"fileserver"]) {
            value = @"GenericFileServerIcon";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";
        }
        else if ([value isEqualToStringCaseInsensitive:@"filevault"]) {
            value = @"FileVaultIcon";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";
        }
        else if ([value isEqualToStringCaseInsensitive:@"finder"]) {
            value = @"FinderIcon";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";
        }
        else if ([value isEqualToStringCaseInsensitive:@"folder"]) {
            value = @"GenericFolderIcon";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";
        }
        else if ([value isEqualToStringCaseInsensitive:@"folderopen"]) {
            value = @"OpenFolderIcon";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";
        }
        else if ([value isEqualToStringCaseInsensitive:@"foldersmart"]) {
            value = @"SmartFolderIcon";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";
        }
        else if ([value isEqualToStringCaseInsensitive:@"gear"]) {
            value = @"ToolbarAdvanced";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";
        }
        else if ([value isEqualToStringCaseInsensitive:@"general"]) {
            value = @"General";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";
        }
        else if ([value isEqualToStringCaseInsensitive:@"globe"]) {
            value = @"BookmarkIcon";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";
        }
        else if ([value isEqualToStringCaseInsensitive:@"group"]) {
            value = @"GroupIcon";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";
        }
        else if ([value isEqualToStringCaseInsensitive:@"home"]) {
            value = @"HomeFolderIcon";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";
        }
        else if ([value isEqualToStringCaseInsensitive:@"info"]) {
            value = @"ToolbarInfo";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";
        }
        else if ([value isEqualToStringCaseInsensitive:@"ipod"]) {
            value = @"com.apple.ipod-touch-4";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";
        }
        else if ([value isEqualToStringCaseInsensitive:@"movie"]) {
            value = @"ToolbarMovieFolderIcon";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";
        }
        else if ([value isEqualToStringCaseInsensitive:@"music"]) {
            value = @"ToolbarMusicFolderIcon";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";
        }
        else if ([value isEqualToStringCaseInsensitive:@"network"]) {
            value = @"GenericNetworkIcon";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";
        }
        else if ([value isEqualToStringCaseInsensitive:@"notice"]) {
            value = @"AlertNoteIcon";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";
        }
        else if ([value isEqualToStringCaseInsensitive:@"stop"] || [value isEqualToStringCaseInsensitive:@"x"]) {
            value = @"AlertStopIcon";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";
        }
        else if ([value isEqualToStringCaseInsensitive:@"sync"]) {
            value = @"Sync";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";
        }
        else if ([value isEqualToStringCaseInsensitive:@"trash"]) {
            value = @"TrashIcon";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";
        }
        else if ([value isEqualToStringCaseInsensitive:@"trashfull"]) {
            value = @"FullTrashIcon";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";
        }
        else if ([value isEqualToStringCaseInsensitive:@"url"]) {
            value = @"GenericURLIcon";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";
        }
        else if ([value isEqualToStringCaseInsensitive:@"user"] || [value isEqualToStringCaseInsensitive:@"person"]) {
            value = @"UserIcon";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";
        }
        else if ([value isEqualToStringCaseInsensitive:@"utilities"]) {
            value = @"ToolbarUtilitiesFolderIcon";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";
        }
        else if ([value isEqualToStringCaseInsensitive:@"dashboard"]) {
            value = @"Dashboard";
            bundle = @"com.apple.dashboard.installer";
        }
        else if ([value isEqualToStringCaseInsensitive:@"dock"]) {
            value = @"Dock";
            bundle = @"com.apple.dock";
        }
        else if ([value isEqualToStringCaseInsensitive:@"widget"]) {
            value = @"widget";
            bundle = @"com.apple.dock";
        }
        else if ([value isEqualToStringCaseInsensitive:@"help"]) {
            value = @"HelpViewer";
            bundle = @"com.apple.helpviewer";
        }
        else if ([value isEqualToStringCaseInsensitive:@"installer"]) {
            value = @"Installer";
            bundle = @"com.apple.installer";
        }
        else if ([value isEqualToStringCaseInsensitive:@"package"]) {
            value = @"package";
            bundle = @"com.apple.installer";
        }
        else if ([value isEqualToStringCaseInsensitive:@"firewire"]) {
            value = @"FireWireHD";
            bundle = @"com.apple.iokit.IOSCSIArchitectureModelFamily";
            path = @"/System/Library/Extensions/IOSCSIArchitectureModelFamily.kext";
        }
        else if ([value isEqualToStringCaseInsensitive:@"usb"]) {
            value = @"USBHD";
            bundle = @"com.apple.iokit.IOSCSIArchitectureModelFamily";
            path = @"/System/Library/Extensions/IOSCSIArchitectureModelFamily.kext";
        }
        else if ([value isEqualToStringCaseInsensitive:@"cd"]) {
            value = @"CD";
            bundle = @"com.apple.ODSAgent";
        }
        else if ([value isEqualToStringCaseInsensitive:@"sound"]) {
            value = @"SoundPref";
            path = @"/System/Library/PreferencePanes/Sound.prefPane";
        }
        else if ([value isEqualToStringCaseInsensitive:@"printer"]) {
            value = @"Printer";
            bundle = @"com.apple.print.PrintCenter";
        }
        else if ([value isEqualToStringCaseInsensitive:@"screenshare"]) {
            value = @"ScreenSharing";
            bundle = @"com.apple.ScreenSharing";
        }
        else if ([value isEqualToStringCaseInsensitive:@"security"]) {
            value = @"Security";
            bundle = @"com.apple.securityagent";
        }
        else if ([value isEqualToStringCaseInsensitive:@"update"]) {
            value = @"SoftwareUpdate";
            bundle = @"com.apple.SoftwareUpdate";
        }
        else if ([value isEqualToStringCaseInsensitive:@"search"] || [value isEqualToStringCaseInsensitive:@"find"]) {
            value = @"Spotlight";
            path = @"/System/Library/CoreServices/Search.bundle";
        }
        else if ([value isEqualToStringCaseInsensitive:@"preferences"]) {
            value = @"PrefApp";
            bundle = @"com.apple.systempreferences";
        }
    }

    // Process bundle image path only if image has not already been set from above
    if (!hasImage) {
        if (bundle != nil || path != nil) {
            NSString * fileName = nil;
            if (path == nil) {
                NSWorkspace *workspace = [NSWorkspace sharedWorkspace];
                fileName = [[NSBundle bundleWithPath:[workspace absolutePathForAppBundleWithIdentifier:bundle]] pathForResource:value ofType:option[@"icon-type"].stringValue];
            }
            else {
                fileName = [[NSBundle bundleWithPath:path] pathForResource:value ofType:option[@"icon-type"].stringValue];
            }
            if (fileName != nil) {
                image = [[NSImage alloc] initWithContentsOfFile:fileName];
                if (image == nil) {
                    [self warning:@"Could not retrieve image from specified icon file %@.", fileName.doubleQuote, nil];
                }
            }
            else {
                [self warning:@"Cannot find icon %@ in bundle %@.", value.doubleQuote, bundle.doubleQuote, nil];
            }
        }
        else {
            [self warning:@"Unknown icon %@. No --icon-bundle specified.", value.doubleQuote, nil];
        }
    }
    return image;
}

@end
