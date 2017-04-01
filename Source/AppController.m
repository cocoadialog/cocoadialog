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

- (NSString *) appVersion {
    return [NSBundle mainBundle].infoDictionary[@"CFBundleVersion"];
}

#pragma mark - Initialization
- (void) awakeFromNib {
	NSString *control = nil;
    // Assign arguments
	arguments = [[[NSMutableArray alloc] initWithArray:[NSProcessInfo processInfo].arguments] autorelease];
    // Initialize control
    currentControl = [[[CDControl alloc] init] autorelease];
    // Setup containers
    NSDictionary *globalKeys = [[[NSDictionary alloc] initWithDictionary:[currentControl globalAvailableKeys]] autorelease];
    NSDictionary *depreciatedKeys = [[[NSDictionary alloc] initWithDictionary:[currentControl depreciatedKeys]] autorelease];
    CDOptions *options = [CDOptions getOpts:arguments availableKeys:globalKeys depreciatedKeys:depreciatedKeys];
	if (arguments.count >= 2) {
		[arguments removeObjectAtIndex:0]; // Remove program name.
		control = arguments[0];
		[arguments removeObjectAtIndex:0]; // Remove the control
	}
    // Control is either the PID of a GUI initialization or "about", show the about dialog
    if ([[control substringToIndex:4] isEqualToString:@"-psn"] || [control caseInsensitiveCompare:@"about"] == NSOrderedSame) {
        [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
        [self setHyperlinkForTextField:aboutAppLink replaceString:@"http://mstratman.github.com/cocoadialog/" withURL:@"http://mstratman.github.com/cocoadialog/"];
        [self setHyperlinkForTextField:aboutText replaceString:@"command line interface" withURL:@"http://en.wikipedia.org/wiki/Command-line_interface"];
        [self setHyperlinkForTextField:aboutText replaceString:@"documentation" withURL:@"http://mstratman.github.com/cocoadialog/#documentation"];
		[aboutPanel setFloatingPanel: YES];
		[aboutPanel setLevel:NSFloatingWindowLevel];
        [aboutPanel center];
        [aboutPanel makeKeyAndOrderFront:nil];
        [NSApp run];
    }
    // Control is a notification, these need to be handled much differently
    else if ([control caseInsensitiveCompare:@"notify"] == NSOrderedSame || [control caseInsensitiveCompare:@"bubble"] == NSOrderedSame) {
        // Determine which notification type to use
        // Recapture the arguments
        arguments = [[[NSMutableArray alloc] initWithArray:[NSProcessInfo processInfo].arguments] autorelease];
        // Replace the control with the new one
        arguments[1] = @"CDNotifyControl";
        // Relaunch cocoaDialog with the new control
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
        // Output must be silenced to not hang this process
        task.standardError = [NSFileHandle fileHandleWithNullDevice];
        task.standardOutput = [NSFileHandle fileHandleWithNullDevice];
        task.launchPath = @"/usr/bin/arch";
        task.arguments = arguments;
        [task launch];
        [NSApp terminate:self];
    }
    // Control needs to run through control logic
    else {
        NSMutableDictionary *extraOptions = [[[NSMutableDictionary alloc] init] autorelease];
        // Choose the control
        [self chooseControl:control useOptions:options addExtraOptionsTo:extraOptions];
        if (currentControl != nil) {
            // Initialize the currentControl
            [currentControl init];
            globalKeys = [currentControl globalAvailableKeys];
            // Now that we have the control, we can re-get the options to
            // include the local options for that control.
            options = [currentControl controlOptionsFromArgs:arguments	withGlobalKeys:globalKeys];
            if ([options hasOpt:@"help"]) {
                NSMutableDictionary *allKeys;
                NSDictionary *localKeys = [currentControl availableKeys];
                if (localKeys != nil) {
                    allKeys = [NSMutableDictionary dictionaryWithCapacity:
                               globalKeys.count+localKeys.count];
                    [allKeys addEntriesFromDictionary:globalKeys];
                    [allKeys addEntriesFromDictionary:localKeys];
                } else {
                    allKeys = [NSMutableDictionary dictionaryWithCapacity:globalKeys.count];
                    [allKeys addEntriesFromDictionary:globalKeys];
                    
                }
                [CDOptions printOpts:allKeys.allKeys forControl:control];
            }
            // Add any extras chooseControl came up with
            NSEnumerator *en = [extraOptions keyEnumerator];
            NSString *key;
            while (key = [en nextObject]) {
                [options setOption:extraOptions[key] forKey:key];
            }
            
            // Reload the options for currentControl
            currentControl.options = options;
            
            // Validate currentControl's options and load interface nib
            if ([currentControl validateOptions] && [currentControl loadControlNib:[currentControl controlNib]]) {
                
                // Create the control
                [currentControl createControl];
                
                // Initialize the timer, if one exists
                [currentControl setTimeout];
                
                // Run the control. The control is now responsible for terminating cocoaDialog, which should be invoked by calling the method [self stopControl] from the control's action method(s).
                [currentControl runControl];
            } else {
                if ([options hasOpt:@"debug"]) {
                    NSMutableDictionary *allKeys;
                    NSDictionary *localKeys = [currentControl availableKeys];
                    if (localKeys != nil) {
                        allKeys = [NSMutableDictionary dictionaryWithCapacity:
                                   globalKeys.count+localKeys.count];
                        [allKeys addEntriesFromDictionary:globalKeys];
                        [allKeys addEntriesFromDictionary:localKeys];
                    } else {
                        allKeys = [NSMutableDictionary dictionaryWithCapacity:globalKeys.count];
                        [allKeys addEntriesFromDictionary:globalKeys];
                        
                    }
                    [CDOptions printOpts:allKeys.allKeys forControl:control];
                }
                exit(255);
            }
        } else {
            if ([options hasOpt:@"debug"] || [control isEqualToString:@"--debug"]) {
                [currentControl debug:@"Invalid control provided as first argument."];
            }
            exit(255);
        }
    }
}

#pragma mark - CDControl
+ (NSDictionary *) availableControls {
    return @{@"checkbox": [CDCheckboxControl class],
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
            @"secure-inputbox": [CDInputboxControl class],           
            @"secure-standard-inputbox": [CDStandardInputboxControl class],
            @"standard-dropdown": [CDStandardPopUpButtonControl class],         
            @"standard-inputbox": [CDStandardInputboxControl class],
            @"textbox": [CDTextboxControl class],
            @"yesno-msgbox": [CDYesNoMsgboxControl class]};
}

- (void) chooseControl:(NSString *)name useOptions:options addExtraOptionsTo:(NSMutableDictionary *)extraOptions
{
    NSDictionary *controls = [AppController availableControls];

	if (name == nil) {
        currentControl = nil;
		[CDControl printHelpTo:[NSFileHandle fileHandleWithStandardError]];
	}
    else if ([name isEqualToString:@"--help"]) {
        currentControl = nil;
		[CDControl printHelpTo:[NSFileHandle fileHandleWithStandardOutput]];
	}
    else if ([name caseInsensitiveCompare:@"version"] == NSOrderedSame) {
        currentControl = nil;
        NSFileHandle * fh = [NSFileHandle fileHandleWithStandardOutput];
        if (fh) {
            [fh writeData:[[self appVersion] dataUsingEncoding:NSUTF8StringEncoding]];
        }
        exit(0);
        
    }
    else if ([name caseInsensitiveCompare:@"CDNotifyControl"] == NSOrderedSame) {
        CDControl * notify = [[[CDNotifyControl alloc] initWithOptions:options] autorelease];
        NSDictionary * notifyGlobalKeys = [notify globalAvailableKeys];
        CDOptions * notifyOptions = [notify controlOptionsFromArgs:arguments withGlobalKeys:notifyGlobalKeys];
        NSString * notifyClass = ![notifyOptions hasOpt:@"no-growl"]
                                ? @"CDGrowlControl" : @"CDBubbleControl";
        currentControl = [[(CDControl *)[NSClassFromString(notifyClass) alloc] initWithOptions:options] autorelease];
    }
    else {
        // Bring application into focus.
        // Because this application isn't going to be double-clicked, or
        // launched with the "open" command-line tool, it won't necessarily
        // come to the front automatically.
        [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];

        id control = controls[name.lowercaseString];
        if (control != nil) {
            if ([name caseInsensitiveCompare:@"secure-standard-inputbox"] == NSOrderedSame || [name caseInsensitiveCompare:@"secure-inputbox"] == NSOrderedSame) {
                extraOptions[@"no-show"] = @NO;
            }
            currentControl = [[(CDControl *)[control alloc] initWithOptions:options] autorelease];
            return;
        }
        NSFileHandle *fh = [NSFileHandle fileHandleWithStandardError];
        NSString *output = [NSString stringWithFormat:@"Unknown control: %@\n", name]; 
        if (fh) {
            [fh writeData:[output dataUsingEncoding:NSUTF8StringEncoding]];
        }
        [CDControl printHelpTo:fh];
        currentControl = nil;
	}
}

#pragma mark - Label Hyperlinks
-(void)setHyperlinkForTextField:(NSTextField*)aTextField replaceString:(NSString *)aString withURL:(NSString *)aURL
{
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
+(id)hyperlinkFromString:(NSString*)inString withURL:(NSURL*)aURL withFont:(NSFont *)aFont
{
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
