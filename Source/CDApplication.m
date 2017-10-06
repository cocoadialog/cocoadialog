// CDApp.m
// cocoadialog
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.

#import "CDApplication.h"

@implementation CDApplication

@synthesize control;

#pragma mark - Public static methods
+ (NSString *) appName {
    return [NSBundle mainBundle].infoDictionary[@"CFBundleName"];
}

+ (NSString *) appTitle {
    return [NSBundle mainBundle].infoDictionary[@"CFBundleDisplayName"]?: [CDApplication appTitle];
}

+ (NSString *) appVersion {
    return [NSBundle mainBundle].infoDictionary[@"CFBundleVersion"];
}

+ (NSArray<NSString *> *) availableControls {
    return @[
             // Dialogs.
             @"checkbox",
             @"dropdown",
             @"input",
             @"msgbox",
             @"radio",
             @"progressbar",
             @"slider",
             @"textbox",

             // File.
             @"open",
             @"save",
             ].sortedAlphabetically;
}

+ (NSArray <CDControlAlias *> *)controlAliases {
    NSString *standardButtonString = @"--buttons Okay Cancel";
    CDControlAliasDefaultOptions okayButton = ^(CDOptions *options, CDControl *control) {
        options[@"buttons"].wasProvided = YES;
        NSArray <NSString *> *values = options[@"buttons"].arrayValue;
        if (values.count < 1 || (values.count >= 1 && values[0].isBlank)) {
            [options[@"buttons"] setValue:@"Okay" atIndex:0];
        }
    };
    CDControlAliasDefaultOptions cancelButton = ^(CDOptions *options, CDControl *control) {
        options[@"buttons"].wasProvided = YES;
        NSArray <NSString *> *values = options[@"buttons"].arrayValue;
        if (values.count < 2 || (values.count >= 2 && values[1].isBlank)) {
            [options[@"buttons"] setValue:@"Cancel" atIndex:1];
        }
    };
    CDControlAliasDefaultOptions standardButtons = ^(CDOptions *options, CDControl *control) {
        okayButton(options, control);
        cancelButton(options, control);
    };
    return @[
             [CDControlAlias alias:@"about" forControl:@"textbox" helpText:@"Displays the about dialog and contains acknowledgements." block:^(CDOptions *options, CDControl *control) {
                 [options[@"title"] overrideValue:@""];
                 [options[@"icon"] overrideValue:@"cocoadialog"];
                 [options[@"icon-size"] overrideValue:@"96"];
                 [options[@"header"] overrideValue:[NSString stringWithFormat:@"# %@", [CDApplication appName]]];
                 [options[@"width"] overrideValue:@"550"];
                 [options[@"buttons"] overrideValue:@"Okay"];
                 [options[@"markdown"] overrideValue:@"YES"];

                 NSMutableDictionary *data = [NSMutableDictionary dictionary];
                 data[@"app"] = [NSMutableDictionary dictionary];
                 data[@"app"][@"name"] = [CDApplication appName];
                 data[@"app"][@"title"] = [CDApplication appTitle];
                 data[@"app"][@"version"] = [CDApplication appVersion];
                 data[@"app"][@"website"] = @CDSite;
                 data[@"currentYear"] = [NSNumber numberWithInteger:[[NSCalendar currentCalendar] component:NSCalendarUnitYear fromDate:[NSDate date]]];
                 [options[@"message"] overrideValue:[control loadTemplate:@"About" withData:data]];
                 [options[@"file"] overrideValue:[[NSBundle mainBundle] pathForResource:@"Acknowledgements" ofType:@"md"]];
             }],
             [CDControlAlias alias:@"ok"                    forControl:@"msgbox"    helpText:@"--buttons Okay"                          block:okayButton],
             [CDControlAlias alias:@"ok-cancel"             forControl:@"msgbox"    helpText:standardButtonString                       block:standardButtons],
             [CDControlAlias alias:@"secure-input"          forControl:@"input"     helpText:@"--secure"                                block:^(CDOptions *options, CDControl *control) {
                 [options[@"secure"] overrideValue:@"YES"];
             }],
             [CDControlAlias alias:@"secure-standard-input" forControl:@"input"     helpText:[NSString stringWithFormat:@"--secure %@", standardButtonString] block:^(CDOptions *options, CDControl *control) {
                 [options[@"secure"] overrideValue:@"YES"];
                 standardButtons(options, control);
             }],
             [CDControlAlias alias:@"standard-dropdown"     forControl:@"dropdown"  helpText:standardButtonString                       block:standardButtons],
             [CDControlAlias alias:@"standard-input"        forControl:@"input"     helpText:standardButtonString                       block:standardButtons],
             [CDControlAlias alias:@"question"              forControl:@"msgbox"    helpText:@"--buttons Yes No Cancel"                 block:^(CDOptions *options, CDControl *control) {
                 options[@"buttons"].wasProvided = YES;
                 NSArray <NSString *> *values = options[@"buttons"].arrayValue;
                 if (values.count < 1 || (values.count >= 1 && values[0].isBlank)) {
                     [options[@"buttons"] setValue:@"Yes" atIndex:0];
                 }
                 if (values.count < 2 || (values.count >= 2 && values[1].isBlank)) {
                     [options[@"buttons"] setValue:@"No" atIndex:1];
                 }
                 if (options[@"no-cancel"].boolValue) {
                     if (!options[@"cancel-button"].wasProvided) {
                         options[@"cancel-button"].defaultValue = @"No";
                     }
                 }
                 else {
                     if (values.count < 3 || (values.count >= 3 && values[2].isBlank)) {
                         [options[@"buttons"] setValue:@"Cancel" atIndex:2];
                     }
                 }
             }],
             ];
}

+ (NSDictionary<NSString *,NSString *> *) deprecatedControls {
    return @{
             @"fileselect":                     @"open",
             @"filesave":                       @"save",
             @"inputbox":                       @"input",
             @"ok-msgbox":                      @"ok-cancel",
             @"secure-inputbox":                @"secure-input",
             @"secure-standard-inputbox":       @"secure-standard-input",
             @"standard-inputbox":              @"standard-input",
             @"yesno-msgbox":                   @"question",
             };
}

+ (CDControlAlias *)getControlAliasFor:(NSString *)name {
    NSArray *controlAliases = [CDApplication controlAliases];
    for (CDControlAlias *alias in controlAliases) {
        if ([alias.name isEqualToStringCaseInsensitive:name]) {
            return alias;
        }
    }
    return nil;
}

+ (NSDictionary<NSString *,NSString *> *) removedControls {
    return @{
             @"bubble": @"https://github.com/julienXX/terminal-notifier",
             @"notify": @"https://github.com/julienXX/terminal-notifier",
             };
}

#pragma mark - Public instance methods
- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:self];

    // Retrieve the control that should be used.
    control = [self getControl];

    control.app = self;

    // Show control usage.
    if (control.option[@"help"].wasProvided) {
        [control showUsage];
        exit(0);
    }

    [control verbose:@"Initiating control: %@", control.name.doubleQuote, nil];

    // Warn about deprecated options.
    for (NSString *name in control.option.deprecatedOptions) {
        CDOption *deprecated = control.option.deprecatedOptions[name];
        if (deprecated.wasProvided) {
            [control warning:@"The %@ option has been deprecated. Please use the %@ option instead.", deprecated.name.optionFormat, deprecated.deprecatedTo.optionFormat, nil];
        }
    }

    // Warn about unknown options.
    NSArray *unknown = [control.option unknownOptions].sortedAlphabetically;
    if (unknown.count) {
        for (NSString *name in unknown) {
            [control warning:NSLocalizedString(@"UNKNOWN_OPTION", nil), name.optionFormat, nil];
        }
    }

    // Warn if multiple value options don't specify argument breaks.
    for (NSString *name in control.option.missingArgumentBreaks) {
        [control warning:NSLocalizedString(@"MISSING_ARGUMENT_BREAK", nil), name.optionFormat, nil];
    }

    // Validate minimum and maximum values were provided.
    for (NSString *name in control.option) {
        CDOption *option = control.option[name];
        if (option.wasProvided) {
            if (option.providedValues.count < [option.minimumValues unsignedIntegerValue]) {
                [control fatal:CDExitCodeInvalidOption error:@"The %@ control requires a minimum of %@ values for the %@ option.", control.name.doubleQuote, option.minimumValues, name.optionFormat, nil];
            }
            if ([option.maximumValues unsignedIntegerValue] && option.providedValues.count > [option.maximumValues unsignedIntegerValue]) {
                [control fatal:CDExitCodeInvalidOption error:@"The %@ control is limited to a maximum of %@ values for the %@ option.", control.name.doubleQuote, option.maximumValues, name.optionFormat, nil];
            }
        }
    }

    // Validate control option requirements.
    NSMutableArray *missingOptions = [NSMutableArray array];
    NSDictionary *required = control.option.requiredOptions;
    if (required.count) {
        for (NSString *name in required) {
            if (!control.option[name].wasProvided) {
                [missingOptions addObject:name];
            }
        }
    }
    if (missingOptions.count) {
        NSString *missing = [[missingOptions.sortedAlphabetically prependStringsWith:@"--"] componentsJoinedByString:@", "];
        [control fatal:CDExitCodeRequiredOption error:@"The %@ control requires the following options: %@", control.name.doubleQuote, missing, nil];
    }

    // Initialize control.
    [control initControl];

    // Run the control.
    // The control is now responsible for terminating cocoadialog,
    // which should be invoked by calling the method [self stopControl]
    // from the control's action method(s).
    [control runControl];
}

- (NSDictionary *) controlClasses {
    return @{
             @"checkbox": [CDCheckbox class],
             @"dropdown": [CDDropdown class],
             @"open": [CDFileSelect class],
             @"save": [CDFileSave class],
             @"input": [CDInputbox class],
             @"msgbox": [CDDialog class],
             @"progressbar": [CDProgressbar class],
             @"radio": [CDRadio class],
             @"slider": [CDSlider class],
             @"textbox": [CDTextbox class],

             // @todo Add back the notify control class if support is ever added back in.
             // @see https://github.com/mstratman/cocoadialog/issues/92
             // @"notify": [CDNotifyControl class],
             };
}

- (NSString *) controlNameFromArguments:(NSArray *)args {
    NSArray *controls = [CDApplication availableControls];
    for (NSUInteger i = 0; i < args.count; i++) {
        if ([controls containsObject:args[i]]) {
            return args[i];
        }
    }

    CDControl *aControl = [CDControl control];
    NSString *controlName = nil;

    // Dynamically replace deprecated control with new one and show a warning.
    NSDictionary *deprecatedControls = [CDApplication deprecatedControls];
    for (NSUInteger i = 0; i < args.count; i++) {
        NSString *deprecated = args[i];
        NSString *replacement = [deprecatedControls objectForKey:args[i]];
        if (replacement != nil) {
            [aControl warning:@"The %@ control has been deprecated and will be removed in a future release. Please use the %@ control instead.", deprecated.doubleQuote.white, replacement.doubleQuote.white, nil];
            controlName = [deprecatedControls objectForKey:args[i]];
            args = [NSArray arrayWithObjects:controlName, nil];
            break;
        }
    }

    NSDictionary *removedControls = [CDApplication removedControls];
    for (NSUInteger i = 0; i < args.count; i++) {
        NSString *removed = args[i];
        NSString *url = [removedControls objectForKey:args[i]];
        if (url != nil) {
            [aControl fatal:CDExitCodeUnknownControl error:@"The %@ control has been removed. Please use %@ instead.", removed.doubleQuote.white, url.white, nil];
        }
    }

    // No explicit control name was found.
    if (controlName == nil) {
        // Attempt to just use the first argument passed.
        if ([args count] > 0) {
            controlName = [args objectAtIndex:0];
        }
        // Show general usage if in CLI.
        else if (aControl.terminal.isCLI) {
            controlName = @"help";
        }
        // Otherwise, just show the about dialog.
        else {
            controlName = @"about";
        }
    }

    return controlName;
}

- (Class) getControlClass:(NSString *)controlName {
    return controlName != nil ? [[self controlClasses] objectForKey:controlName.lowercaseString] : nil;
}

- (CDControl *) getControl {
    CDControl *aControl = [CDControl control];
    NSString *controlName = [self controlNameFromArguments:aControl.option.arguments];

    CDControlAlias *alias = [CDApplication getControlAliasFor:controlName];
    if (alias) {
        controlName = alias.controlName;
        [aControl verbose:@"Aliasing control: %@ => %@", alias.name.doubleQuote, alias.controlName.doubleQuote, nil];
    }

    // If a control class was provided, use it to contruct the control.
    Class controlClass = [self getControlClass:controlName];
    if (controlClass) {
        controlName = controlName.lowercaseString;

        // Bring application into focus.
        // Because this application isn't going to be double-clicked, or
        // launched with the "open" command-line tool, it won't necessarily
        // come to the front automatically.
        [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];

        aControl = [(CDControl *)[controlClass alloc] initWithAlias:alias seenOptions:aControl.option.seenOptions];
        aControl.name = controlName;
    }
    // Otherwise, just create a base control to handle global tasks.
    else {
        // Show global usage.
        if ([controlName isEqualToStringCaseInsensitive:@"help"] || (controlName == nil && aControl.option[@"help"].wasProvided)) {
            [aControl showUsage];
            exit(0);
        }
        // Show version.
        else if ([controlName isEqualToStringCaseInsensitive:@"version"] || (controlName == nil && aControl.option[@"version"].wasProvided)) {
            [aControl.terminal writeLine:[CDApplication appVersion]];
            exit(0);
        }
        else if (controlName != nil) {
            [aControl fatal:CDExitCodeUnknownControl error:@"Unknown control: %@\n", controlName.doubleQuote, nil];
        }
    }

    return aControl;
}

@end
