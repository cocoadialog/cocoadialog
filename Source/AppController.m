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
             @"checkbox", @"dropdown", @"fileselect", @"filesave", @"inputbox", @"msgbox", @"notify",
             @"ok-msgbox", @"progressbar", @"radio", @"slider", @"secure-inputbox", @"secure-standard-inputbox",
             @"standard-dropdown", @"standard-inputbox", @"textbox", @"yesno-msgbox",
             ].sortedAlphabetically;
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
                [control fatalError:@"The %@ control requires a minimum of %@ values for the %@ option.", control.controlName.doubleQuote, option.minimumValues, name.optionFormat, nil];
            }
            if ([option.maximumValues unsignedIntegerValue] && option.providedValues.count > [option.maximumValues unsignedIntegerValue]) {
                [control fatalError:@"The %@ control is limited to a maximum of %@ values for the %@ option.", control.controlName.doubleQuote, option.maximumValues, name.optionFormat, nil];
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
        [control fatalError:@"The %@ control requires the following options: %@", control.controlName.doubleQuote, missing, nil];
    }

    // Load the control.
    NSString *nib = [control controlNib];
    if (nib && ![control loadControlNib:nib]) {
        [control fatalError:@"Unable to load control NIB.", nil];
    }

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
             @"dropdown": [CDPopUpButtonControl class],
             @"fileselect": [CDFileSelectControl class],
             @"filesave": [CDFileSaveControl class],
             @"inputbox": [CDInputboxControl class],
             @"msgbox": [CDMsgboxControl class],
             @"notify": [CDNotifyControl class],
             @"ok-msgbox": [CDOkMsgboxControl class],
             @"progressbar": [CDProgressbarControl class],
             @"radio": [CDRadioControl class],
             @"slider": [CDSlider class],
             @"secure-inputbox": [CDSecureInputboxControl class],
             @"secure-standard-inputbox": [CDSecureStandardInputboxControl class],
             @"standard-dropdown": [CDStandardPopUpButtonControl class],
             @"standard-inputbox": [CDStandardInputboxControl class],
             @"textbox": [CDTextboxControl class],
             @"yesno-msgbox": [CDYesNoMsgboxControl class],
             };
}

- (NSString *) controlNameFromArguments:(NSArray *)args {
    NSArray *controls = [AppController availableControls];
    for (NSUInteger i = 0; i < args.count; i++) {
        if ([controls containsObject:args[i]]) {
            return args[i];
        }
    }
    return nil;
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
        if (controlName == nil && ([controlName isEqualToStringCaseInsensitive:@"help"] || aControl.option[@"help"].wasProvided)) {
            [aControl showUsage];
            exit(0);
        }
        // Show version.
        else if (controlName != nil && ([controlName isEqualToStringCaseInsensitive:@"version"] || aControl.option[@"version"].wasProvided)) {
            [aControl.terminal writeLine:[AppController appVersion]];
            exit(0);
        }
        // Show about.
        else if (controlName == nil || [controlName isEqualToStringCaseInsensitive:@"about"]) {
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
            [aControl fatalError:@"Unknown control: %@\n", controlName.doubleQuote, nil];
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
