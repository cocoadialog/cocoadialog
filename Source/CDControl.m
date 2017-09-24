// CDControl.m
// cocoadialog
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.

#import "AppController.h"
#import "CDControl.h"

@implementation CDControl

#pragma mark - Properties
@synthesize controlName;
@synthesize iconView;
@synthesize option;
@synthesize panel;
@synthesize terminal;
@synthesize timeoutLabel;

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

    // Global.

//    @todo Add these options back if notification support is ever added back in.
//    @see https://github.com/mstratman/cocoadialog/issues/92
//    [options addOption:[CDOptionSingleString            name:@"app-bundle"          category:@"GLOBAL_OPTION"]];
//    options[@"app-bundle"].defaultValue = [NSBundle mainBundle].bundleIdentifier;
//
//    [options addOption:[CDOptionSingleString            name:@"app-title"           category:@"GLOBAL_OPTION"]];
//    options[@"app-title"].defaultValue = (CDOptionAutomaticDefaultValue) ^() {
//        NSBundle *appBundle = [self appBundle];
//        return [appBundle objectForInfoDictionaryKey:@"CFBundleDisplayName"] ?: [appBundle objectForInfoDictionaryKey:@"CFBundleName"];
//    };

    [options addOption:[CDOptionBoolean                 name:@"color"               category:@"GLOBAL_OPTION"]];
    options[@"color"].defaultValue = (CDOptionAutomaticDefaultValue) ^() {
        return [NSNumber numberWithBool:self.terminal.supportsColor];
    };

    [options addOption:[CDOptionFlag                    name:@"debug"               category:@"GLOBAL_OPTION"]];
    [options[@"debug"].warnings addObject:NSLocalizedString(@"OPTION_WARNING_AFFECTS_OUTPUT", nil)];

    [options addOption:[CDOptionFlag                    name:@"help"                category:@"GLOBAL_OPTION"]];
    [options addOption:[CDOptionFlag                    name:@"no-newline"          category:@"GLOBAL_OPTION"]];
    [options addOption:[CDOptionFlag                    name:@"no-warnings"         category:@"GLOBAL_OPTION"]];
    [options addOption:[CDOptionSingleString            name:@"output"              category:@"GLOBAL_OPTION"]];
    [options addOption:[CDOptionFlag                    name:@"quiet"               category:@"GLOBAL_OPTION"]];

    [options addOption:[CDOptionSingleNumber            name:@"screen"              category:@"GLOBAL_OPTION"]];
    options[@"screen"].defaultValue = (CDOptionAutomaticDefaultValue) ^() {
        return [NSNumber numberWithUnsignedInteger:[[NSScreen screens] indexOfObject:[NSScreen mainScreen]]];
    };

    [options addOption:[CDOptionFlag                    name:@"string-output"       category:@"GLOBAL_OPTION"]];
    [options addOption:[CDOptionSingleNumber            name:@"timeout"             category:@"GLOBAL_OPTION"]];
    [options addOption:[CDOptionSingleString            name:@"timeout-format"      category:@"GLOBAL_OPTION"]];
    options[@"timeout-format"].defaultValue = @"Time remaining: %r...";
    options[@"timeout-format"].parentOption = options[@"timeout"];

    [options addOption:[CDOptionFlag                    name:@"verbose"             category:@"GLOBAL_OPTION"]];
    [options addOption:[CDOptionFlag                    name:@"version"             category:@"GLOBAL_OPTION"]];
    [options[@"verbose"].warnings addObject:NSLocalizedString(@"OPTION_WARNING_AFFECTS_OUTPUT", nil)];

    // Panel.
    [options addOption:[CDOptionSingleNumber            name:@"height"              category:@"DIALOG_OPTION"]];
    [options addOption:[CDOptionFlag                    name:@"no-float"            category:@"DIALOG_OPTION"]];
    //    @todo Add max/min height/width options back once there is logic in place to support them.
    //    [options addOption:[CDOptionSingleNumber            name:@"max-height"          category:@"DIALOG_OPTION"]];
    //    [options addOption:[CDOptionSingleNumber            name:@"max-width"           category:@"DIALOG_OPTION"]];
    //    [options addOption:[CDOptionSingleNumber            name:@"min-height"          category:@"DIALOG_OPTION"]];
    //    [options addOption:[CDOptionSingleNumber            name:@"min-width"           category:@"DIALOG_OPTION"]];

    [options addOption:[CDOptionSingleStringOrNumber    name:@"posX"                category:@"DIALOG_OPTION"]];
    options[@"posX"].defaultValue = @"center";

    [options addOption:[CDOptionSingleStringOrNumber    name:@"posY"                category:@"DIALOG_OPTION"]];
    options[@"posY"].defaultValue = @"center";

    [options addOption:[CDOptionFlag                    name:@"resize"              category:@"DIALOG_OPTION"]];
    [options addOption:[CDOptionSingleString            name:@"title"               category:@"DIALOG_OPTION"]];
    options[@"title"].defaultValue = (CDOptionAutomaticDefaultValue) ^() {
        return option[@"app-title"].stringValue;
    };

    [options addOption:[CDOptionFlag                    name:@"titlebar-close"      category:@"DIALOG_OPTION"]];
    [options addOption:[CDOptionFlag                    name:@"titlebar-minimize"   category:@"DIALOG_OPTION"]];
    [options addOption:[CDOptionFlag                    name:@"titlebar-zoom"       category:@"DIALOG_OPTION"]];
    [options addOption:[CDOptionSingleNumber            name:@"width"               category:@"DIALOG_OPTION"]];

    // Icon.
    [options addOption:[CDOptionSingleString            name:@"icon"                category:@"ICON_OPTION"]];
    [options addOption:[CDOptionSingleString            name:@"icon-bundle"         category:@"ICON_OPTION"]];
    [options addOption:[CDOptionSingleString            name:@"icon-file"           category:@"ICON_OPTION"]];
    [options addOption:[CDOptionSingleNumber            name:@"icon-height"         category:@"ICON_OPTION"]];
    [options addOption:[CDOptionSingleNumber            name:@"icon-size"           category:@"ICON_OPTION"]];
    [options addOption:[CDOptionSingleNumber            name:@"icon-width"          category:@"ICON_OPTION"]];
    [options addOption:[CDOptionSingleString            name:@"icon-type"           category:@"ICON_OPTION"]];

    return options;
}

- (void) createControl {};

- (NSString *) controlNib {
    return nil;
}

- (void) dealloc {
    if (timer != nil) {
        [timer invalidate];
    }
}

- (instancetype) init {
    return [self initWithSeenOptions:[NSMutableArray array]];
}

- (instancetype) initWithSeenOptions:(NSMutableArray *)seenOptions {
    self = [super init];
    if (self) {
        // Properties.
        _iconControls = [NSMutableArray array];
        terminal = [CDTerminal terminal];

        // Default to terminal support.
        NSStringCDColor = terminal.supportsColor;

        exitStatus = CDExitCodeOk;
        returnValues = [NSMutableArray array];
        controlItems = [NSMutableArray array];


        option = [[self availableOptions] processArguments];

        // Allow option to override whether color should be used.
        NSStringCDColor = option[@"color"].boolValue;

        if (seenOptions != nil) {
            option.seenOptions = seenOptions;
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
                if (opt.defaultValue != nil) {
                    NSMutableString *value = [NSMutableString stringWithString:opt.stringValue];
                    if (opt.hasAutomaticDefaultValue) {
                        [value appendString:[NSString stringWithFormat:@" (%@)", NSLocalizedString(@"OPTION_AUTOMATIC_DEFAULT_VALUE", nil).lowercaseString]];
                    }
                    [control debug:@"The %@ option was not provided. Using default value: %@", opt.name.optionFormat, value, nil];
                }
            }
            else if ([opt isKindOfClass:[CDOptionFlag class]]) {
                [control debug:@"The %@ option was provided.", opt.name.optionFormat, nil];
            }
            else {
                [control debug:@"The %@ option was provided with the value: %@", opt.name.optionFormat, opt.stringValue, nil];
            }
        };
    }
    return self;
}

- (void) loadControlNib {
    NSString *nib = [self controlNib];

    // Load nib
    if (nib != nil) {
        if (![nib isEqualToString:@""] && ![[NSBundle mainBundle] loadNibNamed:nib owner:self topLevelObjects:nil]) {
            [self fatal: CDExitCodeControlFailure error:@"Could not load control interface: \"%@.nib\"", nib, nil];
        }
    }
    else {
        [self fatal: CDExitCodeControlFailure error:@"Control did not specify a NIB interface file to load.", nil];
    }

    if (panel == nil) {
        [self fatal: CDExitCodeControlFailure error:@"Control panel failed to bind.", nil];
    }

    // Handle titlebar close.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowWillClose:) name:NSWindowWillCloseNotification object:panel];

    BOOL close = option[@"titlebar-close"].boolValue;
    [panel standardWindowButton:NSWindowCloseButton].enabled = close;
    if (!close) {
        panel.styleMask = panel.styleMask^NSClosableWindowMask;
    }

    BOOL minimize = option[@"titlebar-minimize"].boolValue;
    [panel standardWindowButton:NSWindowMiniaturizeButton].enabled = minimize;
    if (!minimize) {
        panel.styleMask = panel.styleMask^NSMiniaturizableWindowMask;
    }

    // Handle --resize option.
    BOOL resize = option[@"resize"].boolValue;
    [panel standardWindowButton:NSWindowZoomButton].enabled = resize && option[@"titlebar-zoom"].wasProvided;
    if (!resize) {
        panel.styleMask = panel.styleMask^NSResizableWindowMask;
    }
}

- (void) runControl {
    // Handle panels if the control specified one.
    if (self.panel != nil) {
        // Set icon
        if (self.iconView != nil) {
            [self setIconFromOptions];
        }
        // Reposition Panel
        [self setPosition];
        [self setFloat];
    }

    [NSApp run];
}

- (void) showUsage {
    NSArray *controls = [AppController availableControls].sortedAlphabetically;
    NSString *version = [AppController appVersion];

    NSMutableString *controlUsage = [NSMutableString string];
    if (self.isBaseControl || controlName == nil) {
        [controlUsage appendString:[NSString stringWithFormat:@"<%@>", NSLocalizedString(@"CONTROL", nil).lowercaseString]];
    }
    else {
        [controlUsage appendString:controlName];
        if (option.requiredOptions.count) {
            for (NSString *name in option.requiredOptions.allKeys.sortedAlphabetically) {
                [controlUsage appendString:@" "];
                CDOption *opt = option.requiredOptions[name];
                NSMutableString *required = [NSMutableString stringWithString:opt.label.white.bold];
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
        NSMutableDictionary *json = [NSMutableDictionary dictionary];
        json[@"usage"] = [NSString stringWithFormat:NSLocalizedString(@"USAGE", nil), controlUsage];
        json[@"controls"] = controls;
        json[@"deprecatedControls"] = [AppController deprecatedControls];
        json[@"removedControls"] = [AppController removedControls];
        json[@"options"] = option;
        json[@"version"] = version;
        json[@"website"] = @CDSite;
        [self.terminal write:json.toJSONString];
        exit(0);
    }

    NSUInteger margin = 4;

    // If (for whatever reason) there is no terminal width, default to 80.
    NSUInteger terminalColumns = [self.terminal colsWithMinimum:80] - margin;

    [self.terminal writeNewLine];
    [self.terminal writeLine:[NSString stringWithFormat:NSLocalizedString(@"USAGE", nil), controlUsage].white.bold.stop];

    // Show avilable controls if it's the CDControl class printing this.
    if ([self class] == [CDControl class]) {
        [self.terminal writeNewLine];
        [self.terminal writeLine:NSLocalizedString(@"USAGE_CATEGORY_CONTROLS", nil).uppercaseString.white.bold.underline.stop];
        [self.terminal writeNewLine];


        NSString *controlsString = [[AppController availableControls] componentsJoinedByString:@", "];
        controlsString = [controlsString wrapToLength:terminalColumns];
        controlsString = [controlsString indentNewlinesWith:margin];
        [self.terminal writeLine:[controlsString indent:margin]];

        [self.terminal writeNewLine];
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
        for (NSString *name in sorted) {
            CDOption *categoryOption = categoryOptions[name];

            NSMutableString *column = [NSMutableString string];
            NSMutableString *extra = [NSMutableString string];

            [column appendString:[categoryOption.name.optionFormat indent:margin].white.bold.stop];

            // Add the "type" of option, if available.
            CDColor *typeColor = categoryOption.typeColor;
            NSString *typeLabel = categoryOption.typeLabel;
            if (typeLabel != nil) {
                if (categoryOption.hasAutomaticDefaultValue) {
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
                        defaultValue = [NSString stringWithFormat:@"%@ (%@)", defaultValue, NSLocalizedString(@"OPTION_AUTOMATIC_DEFAULT_VALUE", nil).lowercaseString];
                    }
                    [extra appendString:[NSString stringWithFormat:NSLocalizedString(@"OPTION_DEFAULT_VALUE", nil).white.bold.stop, [defaultValue applyColor:typeColor]].stop];
                }

                if (![extra isBlank]) {
                    [column appendString:@"\n\n"];
                    [column appendString:[extra indent:(margin * 2)]];
                }

                if (categoryOption.notes.count) {
                    [column appendString:@"\n\n"];
                    [column appendString:[[NSString stringWithFormat:@"%@:", NSLocalizedString(@"NOTE", nil).uppercaseString] indent:(margin * 2)].yellow.bold.stop];
                    if (categoryOption.notes.count == 1) {
                        [column appendString:[NSString stringWithFormat:@" %@", categoryOption.notes[0]].yellow.stop];
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
    // Stop timer.
    if (timer != nil) {
        [timer invalidate];
        timer = nil;
    }
    if (timerThread != nil) {
        [timerThread cancel];
    }

    // Stop any modal windows currently running
    [NSApp stop:self];

    // Print all the returned lines
    if (returnValues != nil) {
        for (unsigned i = 0; i < returnValues.count; i++) {
            [self.terminal write:returnValues[i]];
            if (!option[@"no-newline"].wasProvided || i+1 < returnValues.count) {
                [self.terminal writeNewLine];
            }
        }
    }
    else {
        [self fatal:CDExitCodeControlFailure error:@"Control did not return any values.", nil];
    }

    // Return the exit status
    exit(exitStatus);
}

- (void) windowWillClose:(NSNotification *)notification {
    exitStatus = CDExitCodeCancel;
    [self stopControl];
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
    if (option[@"debug"].wasProvided) {
        CDColor *lineColor = [CDColor fg:CDColorFgMagenta];
        CDColor *argumentColor = [CDColor fg:CDColorFgWhite bg:CDColorBgNone style:CDColorStyleBold];

        // Get arguments.
        va_list va_args;
        va_start(va_args, format);
        NSMutableArray *args = [self argumentsToArray:va_args lineColor:lineColor argumentColor:argumentColor];

        format = [[NSMutableString prepend:NSLocalizedString(@"LOG_DEBUG", nil) toString:format] applyColor:lineColor].stop;
        [terminal writeErrorLine:[NSString stringWithFormat:format array:args]];
    }
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
    if (option[@"verbose"].wasProvided) {
        CDColor *lineColor = [CDColor fg:CDColorFgCyan];
        CDColor *argumentColor = [CDColor fg:CDColorFgWhite bg:CDColorBgNone style:CDColorStyleBold];

        // Get arguments.
        va_list va_args;
        va_start(va_args, format);
        NSMutableArray *args = [self argumentsToArray:va_args lineColor:lineColor argumentColor:argumentColor];

        format = [[NSMutableString prepend:NSLocalizedString(@"LOG_VERBOSE", nil) toString:format] applyColor:lineColor].stop;
        [terminal writeErrorLine:[NSString stringWithFormat:format array:args]];
    }
}

- (void) warning:(NSString *)format, ... {
    if (!option[@"no-warnings"].wasProvided) {
        CDColor *lineColor = [CDColor fg:CDColorFgYellow];
        CDColor *argumentColor = [CDColor fg:CDColorFgWhite bg:CDColorBgNone style:CDColorStyleBold];

        // Get arguments.
        va_list va_args;
        va_start(va_args, format);
        NSMutableArray *args = [self argumentsToArray:va_args lineColor:lineColor argumentColor:argumentColor];

        format = [[NSMutableString prepend:NSLocalizedString(@"LOG_WARNING", nil) toString:format] applyColor:lineColor].stop;
        [terminal writeErrorLine:[NSString stringWithFormat:format array:args]];
    }
}

#pragma mark - Icon
- (void) iconAffectedByControl:(id)obj {
    if (obj != nil) {
        [_iconControls addObject:obj];
    }
}

- (NSImage *) icon {
    if (option[@"icon-file"].wasProvided) {
        _iconImage = [self iconFromFile:option[@"icon-file"].stringValue];
    }
    else if (option[@"icon"].wasProvided) {
        _iconImage = [self iconFromName:option[@"icon"].stringValue];
    }
    return _iconImage;
}

- (NSData *) iconData {
    return [self icon].TIFFRepresentation;
}

- (NSImage *) iconWithDefault {
    if ([self icon] == nil) {
        _iconImage = NSApp.applicationIconImage;
    }
    return _iconImage;
}

- (NSData *) iconDataWithDefault {
    return [self iconWithDefault].TIFFRepresentation;
}

- (NSImage *) iconFromFile:(NSString *)file {
    NSImage *image = [[NSImage alloc] initWithContentsOfFile:file];
    if (image == nil) {
        [self warning:@"Could not return icon from specified file: %@.", file.doubleQuote, nil];
    }
    return image;
}

- (NSImage *) iconFromName:(NSString *)name {
    BOOL hasImage = NO;
    NSImage *image = [[NSImage alloc] init];
    NSString *bundle = nil;
    NSString *path = nil;
    NSString *iconType = @"icns";
    if (option[@"icon-type"].wasProvided) {
        iconType = option[@"icon-type"].stringValue;
    }
    // Use bundle identifier
    if (option[@"icon-bundle"].wasProvided) {
        bundle = option[@"icon-bundle"].stringValue;
    }
    // Set default bundle identifier
    if (bundle == nil) {
        // Application icon
        if ([name isEqualToStringCaseInsensitive:@"cocoadialog"]) {
            image = NSApp.applicationIconImage;
            hasImage = YES;
        }
        // User specific computer image
        else if ([name isEqualToStringCaseInsensitive:@"computer"]) {
            image = [NSImage imageNamed: NSImageNameComputer];
            hasImage = YES;
        }
        // Bundle Identifications
        else if ([name isEqualToStringCaseInsensitive:@"addressbook"]) {
            name = @"AppIcon";
            bundle = @"com.apple.AddressBook";
        }
        else if ([name isEqualToStringCaseInsensitive:@"airport"]) {
            name = @"AirPort";
            bundle = @"com.apple.AirPortBaseStationAgent";
        }
        else if ([name isEqualToStringCaseInsensitive:@"airport2"]) {
            name = @"AirPort";
            bundle = @"com.apple.wifi.diagnostics";
        }
        else if ([name isEqualToStringCaseInsensitive:@"archive"]) {
            name = @"bah";
            bundle = @"com.apple.archiveutility";
        }
        else if ([name isEqualToStringCaseInsensitive:@"bluetooth"]) {
            name = @"AppIcon";
            bundle = @"com.apple.BluetoothAudioAgent";
        }
        else if ([name isEqualToStringCaseInsensitive:@"application"]) {
            name = @"GenericApplicationIcon";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";
        }
        else if ([name isEqualToStringCaseInsensitive:@"bonjour"] || [name isEqualToStringCaseInsensitive:@"atom"]) {
            name = @"Bonjour";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";
        }
        else if ([name isEqualToStringCaseInsensitive:@"burn"] || [name isEqualToStringCaseInsensitive:@"hazard"]) {
            name = @"BurningIcon";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";
        }
        else if ([name isEqualToStringCaseInsensitive:@"caution"]) {
            name = @"AlertCautionIcon";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";
        }
        else if ([name isEqualToStringCaseInsensitive:@"document"]) {
            name = @"GenericDocumentIcon";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";
        }
        else if ([name isEqualToStringCaseInsensitive:@"documents"]) {
            name = @"ToolbarDocumentsFolderIcon";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";
        }
        else if ([name isEqualToStringCaseInsensitive:@"download"]) {
            name = @"ToolbarDownloadsFolderIcon";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";
        }
        else if ([name isEqualToStringCaseInsensitive:@"eject"]) {
            name = @"EjectMediaIcon";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";
        }
        else if ([name isEqualToStringCaseInsensitive:@"everyone"]) {
            name = @"Everyone";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";
        }
        else if ([name isEqualToStringCaseInsensitive:@"executable"]) {
            name = @"ExecutableBinaryIcon";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";
        }
        else if ([name isEqualToStringCaseInsensitive:@"favorite"] || [name isEqualToStringCaseInsensitive:@"heart"]) {
            name = @"ToolbarFavoritesIcon";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";
        }
        else if ([name isEqualToStringCaseInsensitive:@"fileserver"]) {
            name = @"GenericFileServerIcon";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";
        }
        else if ([name isEqualToStringCaseInsensitive:@"filevault"]) {
            name = @"FileVaultIcon";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";
        }
        else if ([name isEqualToStringCaseInsensitive:@"finder"]) {
            name = @"FinderIcon";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";
        }
        else if ([name isEqualToStringCaseInsensitive:@"folder"]) {
            name = @"GenericFolderIcon";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";
        }
        else if ([name isEqualToStringCaseInsensitive:@"folderopen"]) {
            name = @"OpenFolderIcon";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";
        }
        else if ([name isEqualToStringCaseInsensitive:@"foldersmart"]) {
            name = @"SmartFolderIcon";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";
        }
        else if ([name isEqualToStringCaseInsensitive:@"gear"]) {
            name = @"ToolbarAdvanced";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";
        }
        else if ([name isEqualToStringCaseInsensitive:@"general"]) {
            name = @"General";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";
        }
        else if ([name isEqualToStringCaseInsensitive:@"globe"]) {
            name = @"BookmarkIcon";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";
        }
        else if ([name isEqualToStringCaseInsensitive:@"group"]) {
            name = @"GroupIcon";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";
        }
        else if ([name isEqualToStringCaseInsensitive:@"home"]) {
            name = @"HomeFolderIcon";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";
        }
        else if ([name isEqualToStringCaseInsensitive:@"info"]) {
            name = @"ToolbarInfo";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";
        }
        else if ([name isEqualToStringCaseInsensitive:@"ipod"]) {
            name = @"com.apple.ipod-touch-4";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";
        }
        else if ([name isEqualToStringCaseInsensitive:@"movie"]) {
            name = @"ToolbarMovieFolderIcon";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";
        }
        else if ([name isEqualToStringCaseInsensitive:@"music"]) {
            name = @"ToolbarMusicFolderIcon";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";
        }
        else if ([name isEqualToStringCaseInsensitive:@"network"]) {
            name = @"GenericNetworkIcon";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";
        }
        else if ([name isEqualToStringCaseInsensitive:@"notice"]) {
            name = @"AlertNoteIcon";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";
        }
        else if ([name isEqualToStringCaseInsensitive:@"stop"] || [name isEqualToStringCaseInsensitive:@"x"]) {
            name = @"AlertStopIcon";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";
        }
        else if ([name isEqualToStringCaseInsensitive:@"sync"]) {
            name = @"Sync";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";
        }
        else if ([name isEqualToStringCaseInsensitive:@"trash"]) {
            name = @"TrashIcon";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";
        }
        else if ([name isEqualToStringCaseInsensitive:@"trashfull"]) {
            name = @"FullTrashIcon";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";
        }
        else if ([name isEqualToStringCaseInsensitive:@"url"]) {
            name = @"GenericURLIcon";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";
        }
        else if ([name isEqualToStringCaseInsensitive:@"user"] || [name isEqualToStringCaseInsensitive:@"person"]) {
            name = @"UserIcon";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";
        }
        else if ([name isEqualToStringCaseInsensitive:@"utilities"]) {
            name = @"ToolbarUtilitiesFolderIcon";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";
        }
        else if ([name isEqualToStringCaseInsensitive:@"dashboard"]) {
            name = @"Dashboard";
            bundle = @"com.apple.dashboard.installer";
        }
        else if ([name isEqualToStringCaseInsensitive:@"dock"]) {
            name = @"Dock";
            bundle = @"com.apple.dock";
        }
        else if ([name isEqualToStringCaseInsensitive:@"widget"]) {
            name = @"widget";
            bundle = @"com.apple.dock";
        }
        else if ([name isEqualToStringCaseInsensitive:@"help"]) {
            name = @"HelpViewer";
            bundle = @"com.apple.helpviewer";
        }
        else if ([name isEqualToStringCaseInsensitive:@"installer"]) {
            name = @"Installer";
            bundle = @"com.apple.installer";
        }
        else if ([name isEqualToStringCaseInsensitive:@"package"]) {
            name = @"package";
            bundle = @"com.apple.installer";
        }
        else if ([name isEqualToStringCaseInsensitive:@"firewire"]) {
            name = @"FireWireHD";
            bundle = @"com.apple.iokit.IOSCSIArchitectureModelFamily";
            path = @"/System/Library/Extensions/IOSCSIArchitectureModelFamily.kext";
        }
        else if ([name isEqualToStringCaseInsensitive:@"usb"]) {
            name = @"USBHD";
            bundle = @"com.apple.iokit.IOSCSIArchitectureModelFamily";
            path = @"/System/Library/Extensions/IOSCSIArchitectureModelFamily.kext";
        }
        else if ([name isEqualToStringCaseInsensitive:@"cd"]) {
            name = @"CD";
            bundle = @"com.apple.ODSAgent";
        }
        else if ([name isEqualToStringCaseInsensitive:@"sound"]) {
            name = @"SoundPref";
            path = @"/System/Library/PreferencePanes/Sound.prefPane";
        }
        else if ([name isEqualToStringCaseInsensitive:@"printer"]) {
            name = @"Printer";
            bundle = @"com.apple.print.PrintCenter";
        }
        else if ([name isEqualToStringCaseInsensitive:@"screenshare"]) {
            name = @"ScreenSharing";
            bundle = @"com.apple.ScreenSharing";
        }
        else if ([name isEqualToStringCaseInsensitive:@"security"]) {
            name = @"Security";
            bundle = @"com.apple.securityagent";
        }
        else if ([name isEqualToStringCaseInsensitive:@"update"]) {
            name = @"SoftwareUpdate";
            bundle = @"com.apple.SoftwareUpdate";
        }
        else if ([name isEqualToStringCaseInsensitive:@"search"] || [name isEqualToStringCaseInsensitive:@"find"]) {
            name = @"Spotlight";
            path = @"/System/Library/CoreServices/Search.bundle";
        }
        else if ([name isEqualToStringCaseInsensitive:@"preferences"]) {
            name = @"PrefApp";
            bundle = @"com.apple.systempreferences";
        }
    }

    // Process bundle image path only if image has not already been set from above
    if (!hasImage) {
        if (bundle != nil || path != nil) {
            NSString * fileName = nil;
            if (path == nil) {
                NSWorkspace *workspace = [NSWorkspace sharedWorkspace];
                fileName = [[NSBundle bundleWithPath:[workspace absolutePathForAppBundleWithIdentifier:bundle]] pathForResource:name ofType:iconType];
            }
            else {
                fileName = [[NSBundle bundleWithPath:path] pathForResource:name ofType:iconType];
            }
            if (fileName != nil) {
                image = [[NSImage alloc] initWithContentsOfFile:fileName];
                if (image == nil) {
                    [self warning:@"Could not retrieve image from specified icon file %@.", fileName.doubleQuote, nil];
                }
            }
            else {
                [self warning:@"Cannot find icon %@ in bundle %@.", name.doubleQuote, bundle.doubleQuote, nil];
            }
        }
        else {
            [self warning:@"Unknown icon %@. No --icon-bundle specified.", name.doubleQuote, nil];
        }
    }
    return image;
}

- (void) setIconFromOptions {
    if (iconView != nil) {
        NSImage *image = [self icon];
        if (option[@"icon-file"].wasProvided) {
            image = [self iconFromFile:option[@"icon-file"].stringValue];
        }
        else if (option[@"icon"].wasProvided) {
            image = [self iconFromName:option[@"icon"].stringValue];
        }

        // Set default icon sizes
        float iconWidth = iconView.frame.size.width;
        float iconHeight = iconView.frame.size.height;
        NSSize resize = NSMakeSize(iconWidth, iconHeight);

        // Control should display icon, process image.
        if (image != nil) {
            // Set default icon height
            // Get icon sizes from user options
            if (option[@"icon-size"].wasProvided) {
                NSUInteger iconSize = option[@"icon-size"].unsignedIntegerValue;
                switch (iconSize) {
                    case 256: iconWidth = 256.0; iconHeight = 256.0; break;
                    case 128: iconWidth = 128.0; iconHeight = 128.0; break;
                    case 48: iconWidth = 48.0; iconHeight = 48.0; break;
                    case 32: iconWidth = 32.0; iconHeight = 32.0; break;
                    case 16: iconWidth = 16.0; iconHeight = 16.0; break;
                }
            }
            else {
                if (option[@"icon-width"].wasProvided) {
                    iconWidth = option[@"icon-width"].floatValue;
                }
                if (option[@"icon-height"].wasProvided) {
                    iconHeight = option[@"icon-height"].floatValue;
                }
            }
            // Set sizes
            resize = NSMakeSize(iconWidth, iconHeight);
            [self setIconWithImage:image withSize:resize withControls:_iconControls];
        }
        // Control shouldn't display icon, remove it and resize.
        else {
            [self setIconWithImage:nil withSize:resize withControls:_iconControls];
        }
    }
}

- (void) setIconWithImage:(NSImage *)anImage withSize:(NSSize)aSize {
    if (anImage != nil) {
        NSSize originalSize = anImage.size;
        // Resize Icon
        if (originalSize.width != aSize.width || originalSize.height != aSize.height) {
            NSImage *resizedImage = [[NSImage alloc] initWithSize: aSize];
            [resizedImage lockFocus];
            [anImage drawInRect: NSMakeRect(0, 0, aSize.width, aSize.height) fromRect: NSMakeRect(0, 0, originalSize.width, originalSize.height) operation: NSCompositeSourceOver fraction: 1.0];
            [resizedImage unlockFocus];
            iconView.image = resizedImage;
        }
        else {
            iconView.image = anImage;
        }
        // Resize icon frame
        NSRect iconFrame = iconView.frame;
        float iconHeightDiff = aSize.height - iconFrame.size.height;
        NSRect newIconFrame = NSMakeRect(iconFrame.origin.x, iconFrame.origin.y - iconHeightDiff, aSize.width, aSize.height);
        iconView.frame = newIconFrame;
        iconFrame = iconView.frame;

        // Add the icon to the panel's minimum content size
        NSSize panelMinSize = panel.contentMinSize;
        panelMinSize.height += iconFrame.size.height + 40.0f;
        panelMinSize.width += iconFrame.size.width + 30.0f;
        panel.contentMinSize = panelMinSize;
    }
}

- (void) setIconWithImage:(NSImage *)anImage withSize:(NSSize)aSize withControls:(NSArray *)anArray {
    // Icon has image
    if (anImage != nil) {
        // Set current icon frame
        NSRect iconFrame = iconView.frame;

        // Set image and resize icon
        [self setIconWithImage:anImage withSize:aSize];

        float iconWidthDiff = iconView.frame.size.width - iconFrame.size.width;
        NSEnumerator *en = [anArray objectEnumerator];
        NSControl *_control;
        while (_control = [en nextObject]) {
            // Make sure the control exists
            if (_control != nil) {
                NSRect controlFrame = [_control frame];
                NSRect newControlFrame = NSMakeRect(controlFrame.origin.x + iconWidthDiff, controlFrame.origin.y, controlFrame.size.width - iconWidthDiff, controlFrame.size.height);
                [_control setFrame:newControlFrame];
            }
        }

    }
    // Icon does not have image
    else {
        // Set current icon frame
        NSRect iconFrame = iconView.frame;
        // Remove the icon
        [iconView removeFromSuperview];
        iconView = nil;
        // Move the controls to the left and increase their width
        NSEnumerator *en = [anArray objectEnumerator];
        id _control;
        while (_control = [en nextObject]) {
            // Make sure the control exists
            if (_control != nil) {
                NSRect controlFrame = [_control frame];
                float newControlWidth = controlFrame.size.width + (controlFrame.origin.x - iconFrame.origin.x);
                NSRect newControlFrame = NSMakeRect(iconFrame.origin.x, controlFrame.origin.y, newControlWidth, controlFrame.size.height);
                [_control setFrame:newControlFrame];
            }
        }
    }
}

#pragma mark - Panel
- (void) addMinHeight:(CGFloat)height {
    NSSize panelMinSize = panel.contentMinSize;
    panelMinSize.height += height;
    panel.contentMinSize = panelMinSize;
}

- (void) addMinWidth:(CGFloat)width {
    NSSize panelMinSize = panel.contentMinSize;
    panelMinSize.width += width;
    panel.contentMinSize = panelMinSize;
}

- (NSSize) findNewSize {
    NSRect screenFrame = self.getScreen.frame;
    NSSize size = NSZeroSize;
    NSSize oldSize;
    float width, height;

    size = panel.contentView.frame.size;
    oldSize.width = size.width;
    oldSize.height = size.height;
    if (option[@"width"].wasProvided) {
        NSNumber *percent = option[@"width"].percentValue;
        if (percent != nil) {
            width = ((float) screenFrame.size.width / 100) * [percent floatValue];
        }
        else {
            width = option[@"width"].floatValue;
        }
        if (width != 0.0) {
            size.width = width;
        }
    }
    if (option[@"height"].wasProvided) {
        NSNumber *percent = option[@"height"].percentValue;
        if (percent != nil) {
            height = ((float) screenFrame.size.height / 100) * [percent floatValue];
        }
        else {
            height = option[@"height"].floatValue;
        }
        if (height != 0.0) {
            size.height = height;
        }
    }
    NSSize minSize = panel.contentMinSize;
    if (size.height < minSize.height) {
        size.height = minSize.height;
    }
    if (size.width < minSize.width) {
        size.width = minSize.width;
    }
    if (size.width != oldSize.width || size.height != oldSize.height) {
        return size;
    } else {
        return NSMakeSize(0.0,0.0);
    }
}

- (NSScreen *) getScreen {
    NSUInteger index = option[@"screen"].unsignedIntegerValue;
    NSArray *screens = [NSScreen screens];
    if (index >= [screens count]) {
        [self warning:@"Unknown screen index: %@. Using screen where keyboard has focus.", [NSNumber numberWithUnsignedInteger:index], nil];
        return [NSScreen mainScreen];
    }
    return [screens objectAtIndex:index];
}

- (BOOL) needsResize {
    NSSize size = [self findNewSize];
    if (size.width != 0.0 || size.height != 0.0) {
        return YES;
    } else {
        return NO;
    }
}

- (void) resize {
    // resize if necessary
    if ([self needsResize]) {
        [panel setContentSize:[self findNewSize]];
    }
}

- (void) setFloat {
    if (panel != nil) {
        if (option[@"no-float"].wasProvided) {
            [panel setFloatingPanel:NO];
            [panel setLevel:NSNormalWindowLevel];
        }
        else {
            [panel setFloatingPanel: YES];
            [panel setLevel:NSFloatingWindowLevel];
        }
        [panel makeKeyAndOrderFront:nil];
    }
}

- (void) setPanelEmpty {
    panel = [[NSPanel alloc] initWithContentRect:NSMakeRect(0, 0, 0, 0)
                                       styleMask:NSBorderlessWindowMask
                                         backing:NSBackingStoreBuffered
                                           defer:NO];
}

- (void) setPosition {
    NSScreen *screen = [self getScreen];
    CGFloat x = NSMinX(screen.visibleFrame);
    CGFloat y = NSMinY(screen.visibleFrame);
    CGFloat height = NSHeight(screen.visibleFrame);
    CGFloat width = NSWidth(screen.visibleFrame);
    CGFloat top = y + height;
    CGFloat left = x;
    CGFloat padding = 20.0;
    NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];

    NSString *posX, *posY;

    // Has posX option
    if (option[@"posX"].wasProvided) {
        posX = option[@"posX"].stringValue;
        NSNumber *posXNumber = [nf numberFromString:posX];
        // Left
        if ([posX isEqualToStringCaseInsensitive:@"left"]) {
            left += padding;
        }
        // Right
        else if ([posX isEqualToStringCaseInsensitive:@"right"]) {
            left = left + width - NSWidth(panel.frame) - padding;
        }
        // Manual posX coords
        else if (posXNumber != nil) {
            left += [posXNumber floatValue];
        }
        // Center
        else {
            left = left + ((width - NSWidth(panel.frame)) / 2 - padding);
        }
    }
    // Center
    else {
        left = left + ((width - NSWidth(panel.frame)) / 2 - padding);
    }

    // Has posY option
    if (option[@"posY"].wasProvided) {
        posY = option[@"posY"].stringValue;
        NSNumber *posYNumber = [nf numberFromString:posY];
        // Bottom
        if ([posY isEqualToStringCaseInsensitive:@"bottom"]) {
            top = y + padding;
        }
        // Top
        else if ([posY isEqualToStringCaseInsensitive:@"top"]) {
            top = top - NSHeight(panel.frame) - padding;
        }
        // Manual posY coords
        else if (posYNumber != nil) {
            top = top - NSHeight(panel.frame) - [posYNumber floatValue];
        }
        // Center
        else {
            top = (height / 1.8) - (NSHeight(panel.frame) / 1.8);
        }
    }
    // Center
    else {
        top = (height / 1.8) - (NSHeight(panel.frame) / 1.8);
    }

    // Ensure the panel has the correct relative frame origins.
    [panel setFrameOrigin:NSMakePoint(left, top)];
}

- (void) setTitle {
    panel.title = option[@"title"].wasProvided ? option[@"title"].stringValue : NSLocalizedString(@"APP_TITLE", nil);
}

- (void) setTitle:(NSString *)string {
    panel.title = string != nil && ![string isBlank] ? string : NSLocalizedString(@"APP_TITLE", nil);
}

#pragma mark - Timer
- (void) createTimer {
    @autoreleasepool {
        timerThread = [NSThread currentThread];
        NSRunLoop *_runLoop = [NSRunLoop currentRunLoop];
        timer = [NSTimer timerWithTimeInterval:1.0f target:self selector:@selector(processTimer) userInfo:nil repeats:YES];
        [_runLoop addTimer:timer forMode:NSRunLoopCommonModes];
        [_runLoop run];
    }
}

- (NSString *) formatSecondsForString:(NSInteger)timeInSeconds {
    NSString *timerFormat = option[@"timeout-format"].stringValue;
    NSString *returnString = timerFormat;

    NSInteger seconds = timeInSeconds % 60;
    NSInteger minutes = (timeInSeconds / 60) % 60;
    NSInteger hours = timeInSeconds / 3600;
    NSInteger days = timeInSeconds / (3600 * 24);
    NSString *relative = @"unknown";
    if (days > 0) {
        if (days > 1) {
            relative = [NSString stringWithFormat:@"%id days", (int) days];
        }
        else {
            relative = [NSString stringWithFormat:@"%id day", (int) days];
        }
    }
    else {
        if (hours > 0) {
            if (hours > 1) {
                relative = [NSString stringWithFormat:@"%ld hours", (long)hours];
            }
            else {
                relative = [NSString stringWithFormat:@"%ld hour", (long)hours];
            }
        }
        else {
            if (minutes > 0) {
                if (minutes > 1) {
                    relative = [NSString stringWithFormat:@"%ld minutes", (long)minutes];
                }
                else {
                    relative = [NSString stringWithFormat:@"%ld minute", (long)minutes];
                }
            }
            else {
                if (seconds > 0) {
                    if (seconds > 1) {
                        relative = [NSString stringWithFormat:@"%ld seconds", (long)seconds];
                    }
                    else {
                        relative = [NSString stringWithFormat:@"%ld second", (long)seconds];
                    }
                }
            }
        }
    }
    returnString = [returnString stringByReplacingOccurrencesOfString:@"%s" withString:[NSString stringWithFormat:@"%ld", (long)seconds]];
    returnString = [returnString stringByReplacingOccurrencesOfString:@"%m" withString:[NSString stringWithFormat:@"%ld", (long)minutes]];
    returnString = [returnString stringByReplacingOccurrencesOfString:@"%h" withString:[NSString stringWithFormat:@"%ld", (long)hours]];
    returnString = [returnString stringByReplacingOccurrencesOfString:@"%d" withString:[NSString stringWithFormat:@"%ld", (long)days]];
    returnString = [returnString stringByReplacingOccurrencesOfString:@"%r" withString:relative];
    return returnString;
}

- (void) processTimer {
    // Decrease timeout value
    timeout = timeout - 1.0f;
    // Update and position the label if it exists
    if (timeout > 0.0f) {
        if (timeoutLabel != nil) {
            timeoutLabel.stringValue = [self formatSecondsForString:(NSInteger) ceil(timeout)];
        }
    }
    else {
        exitStatus = CDExitCodeTimeout;
        returnValues = [NSMutableArray array];
        [self performSelector:@selector(stopControl) onThread:mainThread withObject:nil waitUntilDone:YES];
    }
}

- (void) setTimeout {
    timer = nil;
    // Only initialize timeout if the option is provided
    if (option[@"timeout"].wasProvided) {
        timeout = option[@"timeout"].doubleValue;
        if (timeout) {
            mainThread = [NSThread currentThread];
            [NSThread detachNewThreadSelector:@selector(createTimer) toTarget:self withObject:nil];
        }
    }
    [self setTimeoutLabel];
}

- (void) setTimeoutLabel {
    if (timeoutLabel != nil) {
        float labelNewHeight = -4.0f;
        NSRect labelRect = timeoutLabel.frame;
        float labelHeightDiff = labelNewHeight - labelRect.size.height;
        timeoutLabel.stringValue = [self formatSecondsForString:(int)timeout];
        if (![timeoutLabel.stringValue isEqualToString:@""] && timeout != 0.0f) {
            NSTextStorage *textStorage = [[NSTextStorage alloc] initWithString: timeoutLabel.stringValue];
            NSTextContainer *textContainer = [[NSTextContainer alloc] initWithContainerSize:NSMakeSize(labelRect.size.width, FLT_MAX)];
            NSLayoutManager *layoutManager = [[NSLayoutManager alloc]init];
            [layoutManager addTextContainer: textContainer];
            [textStorage addLayoutManager: layoutManager];
            [layoutManager glyphRangeForTextContainer:textContainer];
            labelNewHeight = [layoutManager usedRectForTextContainer:textContainer].size.height;
            labelHeightDiff = labelNewHeight - labelRect.size.height;
            // Set label's new height
            NSRect l = NSMakeRect(labelRect.origin.x, labelRect.origin.y - labelHeightDiff, labelRect.size.width, labelNewHeight);
            timeoutLabel.frame = l;
        }
        else {
            [timeoutLabel setHidden:YES];
        }
        // Set panel's new width and height
        NSSize p = panel.contentView.frame.size;
        p.height += labelHeightDiff;
        [panel setContentSize:p];
    }
}

@end
