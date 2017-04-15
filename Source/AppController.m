/*
	AppController.m
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

#import "AppController.h"

@implementation AppController

+ (NSString *) appVersion {
    return [NSBundle mainBundle].infoDictionary[@"CFBundleVersion"];
}

- (NSString *)appVersion {
    return [AppController appVersion];
}

#pragma mark - Initialization
- (void) awakeFromNib {
    // Retrieve the control that should be used.
    CDControl *control = [self getControl];

    // Show control usage.
    if (control.option[@"help"].wasProvided) {
        [control showUsage];
        exit(0);
    }

    [control verbose:@"Initiating control: %@", control.controlName.doubleQuote, nil];

    for (NSString *name in control.option.deprecatedOptions) {
        CDOptionDeprecated *deprecated = control.option.deprecatedOptions[name];
        if (deprecated.wasProvided) {
            [control warning:@"The %@ option has been deprecated. Please, use the %@ option instead.", deprecated.from.optionFormat, deprecated.to.optionFormat, nil];
        }
    }

    NSArray *unknown = [control.option unknownOptions].sortedAlphabetically;
    if (unknown.count) {
        for (NSString *name in unknown) {
            [control warning:NSLocalizedString(@"UNKNOWN_OPTION", nil), name.optionFormat, nil];
        }
    }

    // Validate control option requirements.
    if (control.option.missingOptions.count) {
        NSString *missing = [[control.option.missingOptions.allKeys.sortedAlphabetically prependStringsWith:@"--"] componentsJoinedByString:@", "];
        [control fatalError:@"The %@ control requires the following options: %@", control.controlName.doubleQuote, missing, nil];
    }

    // Validate control options values.
    if (![control validateOptions]) {
        [control fatalError:@"Invalid options values provided.", nil];
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

#pragma mark - CDControl
+ (NSArray<NSString *> *) availableControls {
    return @[
             @"checkbox", @"dropdown", @"fileselect", @"filesave", @"inputbox", @"msgbox", @"notify",
             @"ok-msgbox", @"progressbar", @"radio", @"slider", @"secure-inputbox", @"secure-standard-inputbox",
             @"standard-dropdown", @"standard-inputbox", @"textbox", @"yesno-msgbox",
             ].sortedAlphabetically;
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


- (NSArray<NSString *> *) getArguments {
    NSMutableArray<NSString *> *arguments = [NSMutableArray array];
    NSMutableArray<NSString *> *args = [NSMutableArray arrayWithArray:[NSProcessInfo processInfo].arguments];

    // Remove the command path.
    [args removeObjectAtIndex:0];

    for (NSUInteger i = 0; i < args.count; i++) {
        NSString *arg = args[i];
        BOOL isOption = !!(arg.length >= 2 && [[arg substringWithRange:NSMakeRange(0, 2)] isEqualToString:@"--"]);
        if (!isOption) {
            [arguments addObject:arg.lowercaseString];
        }
    }
    return arguments;
}

- (Class) getControlClass:(NSString *)controlName {
    return controlName != nil ? [[self controlClasses] objectForKey:controlName.lowercaseString] : nil;
}

- (NSString *) getControlName {
    NSString *controlName = nil;
    NSArray *controls = [self controlClasses].allKeys;

    // Find first matching control name, if any.
    NSArray<NSString *> *args = [self getArguments];
    for (NSUInteger i = 0; i < args.count; i++) {
        if ([controls containsObject:args[i]]) {
            controlName = args[i].lowercaseString;
            break;
        }
    }

    // Return the control name if one was found.
    if (controlName != nil) {
        return controlName;
    }

    // Otherwise, just use the first available argument.
    return args.count ? args[0] : nil;
}

- (CDControl *) getControl {
    CDControl *control;
    NSString *controlName = [self getControlName];
    Class controlClass = [self getControlClass:controlName];

    // If a control class was provided, use it to contruct the control.
    if (controlClass != nil) {
        controlName = controlName.lowercaseString;

        // Bring application into focus.
        // Because this application isn't going to be double-clicked, or
        // launched with the "open" command-line tool, it won't necessarily
        // come to the front automatically.
        [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];

        control = [[(CDControl *)[controlClass alloc] init] autorelease];
        control.controlName = controlName;
    }
    // Otherwise, just create a base control to handle global tasks.
    else {
        control = [[[CDControl alloc] init] autorelease];
        // Show global usage.
        if (controlName == nil && control.option[@"help"].wasProvided) {
            [control showUsage];
            exit(0);
        }
        // Show version.
        else if ([controlName isEqualToStringCaseInsensitive:@"version"] || control.option[@"version"].wasProvided) {
            [control.terminal writeLine:[AppController appVersion]];
            exit(0);
        }
        // Show about.
        else if (controlName == nil || [controlName isEqualToStringCaseInsensitive:@"about"]) {
            [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
            [self setHyperlinkForTextField:aboutAppLink replaceString:@CDSite withURL:@CDSite];
            [self setHyperlinkForTextField:aboutText replaceString:@"command line interface" withURL:@"http://en.wikipedia.org/wiki/Command-line_interface"];
            [self setHyperlinkForTextField:aboutText replaceString:@"documentation" withURL:@"http://mstratman.github.com/cocoadialog/#documentation"];
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

+ (CDNotifyControl *) createNotifyControlFromOptions:(CDOptions *)options {
    Class notifyClass = NSClassFromString(!options[@"no-growl"] ? @"CDGrowlControl" : @"CDBubbleControl");
    CDNotifyControl *control = [[(CDNotifyControl *)[notifyClass alloc] init] autorelease];
    control.controlName = @"notify";
    return control;
}

#pragma mark - Label Hyperlinks
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
