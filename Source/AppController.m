// AppController.m
// cocoadialog
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.

#import "AppController.h"

@implementation AppController

@synthesize aboutAppLink, aboutPanel, aboutText;

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

#pragma mark - Private static methods
+ (CDNotifyControl *) createNotifyControlFromOptions:(CDOptions *)options {
    Class notifyClass = NSClassFromString(!options[@"no-growl"] ? @"CDGrowlControl" : @"CDBubbleControl");
    CDNotifyControl *control = [[(CDNotifyControl *)[notifyClass alloc] init] autorelease];
    control.controlName = @"notify";
    return control;
}

#pragma mark - Public instance methods
- (void) awakeFromNib {
    // Retrieve the control that should be used.
    CDControl *control = [self getControl];

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
    if (![control loadControlNib:[control controlNib]]) {
        [control fatalError:@"Unable to load control NIB.", nil];
    }

    // Setup the control.
    [control createControl];

    // Initialize the timer, if one exists.
    [control setTimeout];

    // Run the control.
    // The control is now responsible for terminating cocoaDialog,
    // which should be invoked by calling the method [self stopControl]
    // from the control's action method(s).
    [control runControl];
}

- (NSDictionary *) controlClasses {
    return @{
             @"bubble": [CDNotifyControl class],
             @"cdnotifycontrol": [CDNotifyControl class],
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

- (void) dealloc {
    [aboutAppLink release];
    [aboutPanel release];
    [aboutText release];
    [super dealloc];
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
    CDControl *control = [CDControl control];
    NSString *controlName = [self controlNameFromArguments:control.option.arguments];
    Class controlClass = [self getControlClass:controlName];

    // If a control class was provided, use it to contruct the control.
    if (controlClass != nil) {
        controlName = controlName.lowercaseString;

        // Bring application into focus.
        // Because this application isn't going to be double-clicked, or
        // launched with the "open" command-line tool, it won't necessarily
        // come to the front automatically.
        [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];

        control = [[(CDControl *)[controlClass alloc] initWithSeenOptions:control.option.seenOptions] autorelease];
        control.controlName = controlName;
    }
    // Otherwise, just create a base control to handle global tasks.
    else {
        // Show global usage.
        if (controlName == nil && ([controlName isEqualToStringCaseInsensitive:@"help"] || control.option[@"help"].wasProvided)) {
            [control showUsage];
            exit(0);
        }
        // Show version.
        else if (controlName != nil && ([controlName isEqualToStringCaseInsensitive:@"version"] || control.option[@"version"].wasProvided)) {
            [control.terminal writeLine:[AppController appVersion]];
            exit(0);
        }
        // Show about.
        else if (controlName == nil || [controlName isEqualToStringCaseInsensitive:@"about"]) {
            [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
            [self setHyperlinkForTextField:aboutAppLink replaceString:NSLocalizedString(@CDSite, nil) withURL:NSLocalizedString(@CDSite, nil)];
            [self setHyperlinkForTextField:aboutText replaceString:NSLocalizedString(@"command line interface", nil) withURL:NSLocalizedString(@"http://en.wikipedia.org/wiki/Command-line_interface", nil)];
            [self setHyperlinkForTextField:aboutText replaceString:NSLocalizedString(@"documentation", nil) withURL:NSLocalizedString(@"http://mstratman.github.com/cocoadialog/#documentation", nil)];
            [aboutPanel setFloatingPanel: YES];
            [aboutPanel setLevel:NSFloatingWindowLevel];
            [aboutPanel center];
            [aboutPanel makeKeyAndOrderFront:nil];
            [NSApp run];
            exit(0);
        }
        else if (controlName != nil) {
            [control fatalError:@"Unknown control: %@\n", controlName.doubleQuote, nil];
        }
    }

    // Control is a notification, these need to be handled much differently.
    // @todo Remove this custom crap and replace with native notification center APIs.
    if ([controlName isEqualToStringCaseInsensitive:@"notify"] || [controlName isEqualToStringCaseInsensitive:@"bubble"]) {
        if (control.option[@"help"].wasProvided) {
            control = [AppController createNotifyControlFromOptions:control.option];
            [control showUsage];
            exit(0);
        }

        // Recapture the arguments.
        NSMutableArray *arguments = [[[NSMutableArray alloc] initWithArray:[NSProcessInfo processInfo].arguments] autorelease];
        arguments[1] = @"CDNotifyControl";
        NSString *launcherSource = [[NSBundle mainBundle] pathForResource:@"relaunch" ofType:@""];
        [arguments insertObject:launcherSource atIndex:0];
#if defined __ppc__
        [arguments insertObject:@"-ppc" atIndex:0];
#elif defined __i368__
        [arguments insertObject:@"-i386" atIndex:0];
#elif defined __ppc64__
        [arguments insertObject:@"-ppc64" atIndex:0];
#elif defined __x86_64__
        [arguments insertObject:@"-x86_64" atIndex:0];
#endif
        NSTask *task = [[[NSTask alloc] init] autorelease];
        task.standardError = [NSFileHandle fileHandleWithStandardError];
        task.standardOutput = [NSFileHandle fileHandleWithStandardOutput];
        task.launchPath = @"/usr/bin/arch";
        task.arguments = arguments;
        [control debug:@"Relaunching: %@ %@", task.launchPath, [arguments componentsJoinedByString:@" "], nil];
        [task launch];
        [task waitUntilExit];
        exit(task.terminationStatus);
    }
    else if ([controlName isEqualToStringCaseInsensitive:@"CDNotifyControl"]) {
        return [AppController createNotifyControlFromOptions:control.option];
    }

    return control;
}

#pragma mark - Label Hyperlinks - @todo move to separate category file
-(void)setHyperlinkForTextField:(NSTextField*)aTextField replaceString:(NSString *)aString withURL:(NSString *)aURL {
    NSMutableAttributedString *textFieldString = [[aTextField.attributedStringValue mutableCopy] autorelease];
    NSRange range = [textFieldString.string rangeOfString:aString];
    
    // both are needed, otherwise hyperlink won't accept mousedown
    [aTextField setAllowsEditingTextAttributes: YES];
    [aTextField setSelectable: YES];
    
    NSMutableAttributedString* replacement = [[[NSMutableAttributedString alloc] init] autorelease];
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
    
    return [attrString autorelease];
}
@end
