// AppController.m
// cocoadialog
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.

#import "AppController.h"

@implementation AppController

@synthesize aboutAppLink, aboutPanel, aboutText, control;

#pragma mark - Properties
- (NSString *)appVersion {
    return [AppController appVersion];
}

#pragma mark - Public static methods
+ (NSString *) appVersion {
    return [NSBundle mainBundle].infoDictionary[@"CFBundleVersion"];
}

+ (NSArray<NSString *> *) availableControls {
    return @[
             // TBC.
             @"checkbox",
             @"inputbox",
             @"msgbox",
             @"radio",
             @"slider",

             // Dropdown
             @"dropdown",

             // File.
             @"fileselect", @"filesave",

             // Progressbar.
             @"progressbar",

             // Textbox.
             @"textbox",
             ].sortedAlphabetically;
}

+ (NSDictionary<NSString *,NSString *> *) deprecatedControls {
    return @{
             @"bubble": @"notify",
             };
}

+ (NSDictionary<NSString *,NSString *> *) removedControls {
    return @{
             @"notify": @"https://github.com/julienXX/terminal-notifier",
             @"ok-msgbox": @"msgbox --button1 \"Okay\" --button2 \"Cancel\"",
             @"secure-inputbox": @"inputbox --no-show",
             @"secure-standard-inputbox": @"inputbox --no-show --button1 \"Okay\" --button2 \"Cancel\"",
             @"standard-dropdown": @"dropdown --button1 \"Okay\" --button2 \"Cancel\"",
             @"standard-inputbox": @"inputbox --button1 \"Okay\" --button2 \"Cancel\"",
             @"yesno-msgbox": @"msgbox --button1 \"Yes\" --button2 \"No\" --button3 \"Cancel\"",
             };
}

#pragma mark - Public instance methods

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:self];

    NSUserNotification *userNotification = notification.userInfo[NSApplicationLaunchUserNotificationKey];
    if (userNotification) {
        CDNotifyControl *notify = [CDNotifyControl control];
        [notify notificationActivated:userNotification];
        return;
    }

    // Retrieve the control that should be used.
    control = [self getControl];

    control.app = self;

    // Show control usage.
    if (control.option[@"help"].wasProvided) {
        [control showUsage];
        exit(0);
    }

    [control verbose:@"Initiating control: %@", control.controlName.doubleQuote, nil];

    // Warn about deprecated options.
    for (NSString *name in control.option.deprecatedOptions) {
        CDOptionDeprecated *deprecated = control.option.deprecatedOptions[name];
        if (deprecated.wasProvided) {
            [control warning:@"The %@ option has been deprecated. Please, use the %@ option instead.", deprecated.from.optionFormat, deprecated.to.optionFormat, nil];
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
                [control fatal:CDExitCodeInvalidOption error:@"The %@ control requires a minimum of %@ values for the %@ option.", control.controlName.doubleQuote, option.minimumValues, name.optionFormat, nil];
            }
            if ([option.maximumValues unsignedIntegerValue] && option.providedValues.count > [option.maximumValues unsignedIntegerValue]) {
                [control fatal:CDExitCodeInvalidOption error:@"The %@ control is limited to a maximum of %@ values for the %@ option.", control.controlName.doubleQuote, option.maximumValues, name.optionFormat, nil];
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
        [control fatal:CDExitCodeRequiredOption error:@"The %@ control requires the following options: %@", control.controlName.doubleQuote, missing, nil];
    }

    // Load the control NIB.
    [control loadControlNib];

    // Setup the control.
    [control createControl];

    // Initialize the timer, if one exists.
    [control setTimeout];

    // Run the control.
    // The control is now responsible for terminating cocoadialog,
    // which should be invoked by calling the method [self stopControl]
    // from the control's action method(s).
    [control runControl];
}

- (NSDictionary *) controlClasses {
    return @{
             @"checkbox": [CDCheckboxControl class],
             @"dropdown": [CDDropdownControl class],
             @"fileselect": [CDFileSelectControl class],
             @"filesave": [CDFileSaveControl class],
             @"inputbox": [CDInputboxControl class],
             @"msgbox": [CDMsgboxControl class],
             @"progressbar": [CDProgressbarControl class],
             @"radio": [CDRadioControl class],
             @"slider": [CDSlider class],
             @"textbox": [CDTextboxControl class],

             // @todo Add back the notify control class if support is ever added back in.
             // @see https://github.com/mstratman/cocoadialog/issues/92
             // @"notify": [CDNotifyControl class],
             };
}

- (NSString *) controlNameFromArguments:(NSArray *)args {
    NSArray *controls = [AppController availableControls];
    for (NSUInteger i = 0; i < args.count; i++) {
        if ([controls containsObject:args[i]]) {
            return args[i];
        }
    }

    CDControl *aControl = [CDControl control];
    NSString *controlName = nil;

    // Dynamically replace deprecated control with new one and show a warning.
    NSDictionary *deprecatedControls = [AppController deprecatedControls];
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

    NSDictionary *removedControls = [AppController removedControls];
    for (NSUInteger i = 0; i < args.count; i++) {
        NSString *removed = args[i];
        NSString *url = [removedControls objectForKey:args[i]];
        if (url != nil) {
            [aControl fatal:CDExitCodeUnknownControl error:@"The %@ control has been removed. Please use %@ instead.", removed.doubleQuote.white, url.white, nil];
        }
    }

    // If no explicit control names were found, attempt to just use the first argument passed.
    if (controlName == nil && [args count] > 0) {
        controlName = [args objectAtIndex:0];
    }

    return controlName;
}

- (Class) getControlClass:(NSString *)controlName {
    return controlName != nil ? [[self controlClasses] objectForKey:controlName.lowercaseString] : nil;
}

- (CDControl *) getControl {
    CDControl *aControl = [CDControl control];
    NSString *controlName = [self controlNameFromArguments:aControl.option.arguments];
    Class controlClass = [self getControlClass:controlName];

    // If a control class was provided, use it to contruct the control.
    if (controlClass != nil) {
        controlName = controlName.lowercaseString;

        // Bring application into focus.
        // Because this application isn't going to be double-clicked, or
        // launched with the "open" command-line tool, it won't necessarily
        // come to the front automatically.
        [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];

        aControl = [(CDControl *)[controlClass alloc] initWithSeenOptions:aControl.option.seenOptions];
        aControl.controlName = controlName;
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
            [aControl.terminal writeLine:[AppController appVersion]];
            exit(0);
        }
        // Show about.
        else if ([controlName isEqualToStringCaseInsensitive:@"about"]) {
            [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
            [self setHyperlinkForTextField:aboutAppLink replaceString:NSLocalizedString(@CDSite, nil) withURL:NSLocalizedString(@CDSite, nil)];
            [self setHyperlinkForTextField:aboutText replaceString:NSLocalizedString(@"command line interface", nil) withURL:NSLocalizedString(@"http://en.wikipedia.org/wiki/Command-line_interface", nil)];
            [self setHyperlinkForTextField:aboutText replaceString:NSLocalizedString(@"documentation", nil) withURL:NSLocalizedString(@"http://mstratman.github.com/cocoadialog/#documentation", nil)];

            [aboutPanel makeLargerFontsThinner];
            [aboutPanel setLevel:NSFloatingWindowLevel];
            [aboutPanel center];
            [aboutPanel makeKeyAndOrderFront:nil];
            [NSApp run];
            exit(0);
        }
        else if (controlName != nil) {
            [aControl fatal:CDExitCodeUnknownControl error:@"Unknown control: %@\n", controlName.doubleQuote, nil];
        }
    }

    return aControl;
}

- (void) userNotificationCenter:(NSUserNotificationCenter *)center didActivateNotification:(NSUserNotification *)notification {
    CDNotifyControl *notify = [CDNotifyControl control];
    [notify notificationActivated:notification];
}

- (void)userNotificationCenter:(NSUserNotificationCenter *)center didDeliverNotification:(NSUserNotification *)notification {
    [control stopControl];
}

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification{
    return YES;
}

#pragma mark - Label Hyperlinks - @todo move to separate category file
-(void)setHyperlinkForTextField:(NSTextField*)aTextField replaceString:(NSString *)aString withURL:(NSString *)aURL {
    NSMutableAttributedString *textFieldString = [aTextField.attributedStringValue mutableCopy];
    NSRange range = [textFieldString.string rangeOfString:aString];
    
    // both are needed, otherwise hyperlink won't accept mousedown
    [aTextField setAllowsEditingTextAttributes: YES];
    [aTextField setSelectable: YES];
    
    NSMutableAttributedString* replacement = [[NSMutableAttributedString alloc] init];
    [replacement setAttributedString: [NSAttributedString hyperlinkFromString:aString withURL:[NSURL URLWithString:aURL] withFont:aTextField.font]];
    
    [textFieldString replaceCharactersInRange:range withAttributedString:replacement];
    
    // set the attributed string to the NSTextField
    aTextField.attributedStringValue = textFieldString;
    // Refresh the text field
	[aTextField selectText:self];
    [aTextField currentEditor].selectedRange = NSMakeRange(0, 0);
}

@end

@implementation NSAttributedString (Hyperlink)
+(id)hyperlinkFromString:(NSString*)inString withURL:(NSURL*)aURL withFont:(NSFont *)aFont {
    NSMutableAttributedString* attrString = [[NSMutableAttributedString alloc] initWithString: inString];
    NSRange range = NSMakeRange(0, attrString.length);
    
    [attrString beginEditing];
    [attrString addAttribute:NSFontAttributeName value:aFont range:range];
    [attrString addAttribute:NSLinkAttributeName value:aURL.absoluteString range:range];
    
    // make the text appear in blue
    [attrString addAttribute:NSForegroundColorAttributeName value:[NSColor blueColor] range:range];
    
    [attrString addAttribute:NSCursorAttributeName value:[NSCursor pointingHandCursor]range:range];
    
    // next make the text appear with an underline
    [attrString addAttribute:
     NSUnderlineStyleAttributeName value:@(NSSingleUnderlineStyle) range:range];
    
    [attrString endEditing];
    
    return attrString;
}
@end
