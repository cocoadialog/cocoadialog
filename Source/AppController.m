/*
	AppController.m
	CocoaDialog
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

- (NSString *) appVersion
{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    
}

- (BOOL) updaterShouldPromptInstall:(SUUpdater *)updater {
    return NO;
}

- (BOOL) updaterShouldRelaunchApplication:(SUUpdater *)updater {
    return NO;
}

- (void) updaterAborted {
    exit(1);
}

- (void) updaterDidNotFindUpdate:(SUUpdater *)update {
    exit(0);
}

- (void)dealloc
{
    [super dealloc];
}


#pragma mark - Initialization
- (void) awakeFromNib
{
	NSString *runMode = nil;
    // Assign arguments
	arguments = [[[NSMutableArray alloc] initWithArray:[[NSProcessInfo processInfo] arguments]] autorelease];
    // Initialize control
    currentControl = [[[CDControl alloc] init] autorelease];
    // Setup containers
    NSDictionary *globalKeys = [[[NSDictionary alloc] initWithDictionary:[currentControl globalAvailableKeys]] autorelease];
    NSDictionary *depreciatedKeys = [[[NSDictionary alloc] initWithDictionary:[currentControl depreciatedKeys]] autorelease];
    CDOptions *options = [CDOptions getOpts:arguments availableKeys:globalKeys depreciatedKeys:depreciatedKeys];
	if ([arguments count] >= 2) {
		[arguments removeObjectAtIndex:0]; // Remove program name.
		runMode = [arguments objectAtIndex:0];
		[arguments removeObjectAtIndex:0]; // Remove the run-mode
	}
    // runMode is either the PID of a GUI initialization or "about", show the about dialog
    if ([[runMode substringToIndex:4] isEqualToString:@"-psn"] || [runMode caseInsensitiveCompare:@"about"] == NSOrderedSame) {
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
    // runMode is a notification, these need to be handled much differently
    else if ([runMode caseInsensitiveCompare:@"notify"] == NSOrderedSame || [runMode caseInsensitiveCompare:@"bubble"] == NSOrderedSame) {
        // Determine which notification type to use
        // Recapture the arguments
        arguments = [[[NSMutableArray alloc] initWithArray:[[NSProcessInfo processInfo] arguments]] autorelease];
        // Replace the runMode with the new one
        [arguments replaceObjectAtIndex:1 withObject:@"CDNotifyControl"];
        // Relaunch cocoaDialog with the new runMode
        NSString *launcherSource = [[NSBundle mainBundle] pathForResource:@"relaunch" ofType:@""];
        NSString *launcherTarget = [NSTemporaryDirectory() stringByAppendingPathComponent:[launcherSource lastPathComponent]];
        NSString *pid = [NSString stringWithFormat:@"%d", [[NSProcessInfo processInfo] processIdentifier]];
        [arguments insertObject:pid atIndex:1];
        [arguments insertObject:launcherTarget atIndex:0];
#if defined __ppc__ || defined __i368__
        [arguments insertObject:@"-32" atIndex:0];
#elif defined __ppc64__ || defined __x86_64__
        [arguments insertObject:@"-64" atIndex:0];
#endif
        [[NSFileManager defaultManager] removeItemAtPath:launcherTarget error:NULL];
        [[NSFileManager defaultManager] copyItemAtPath:launcherSource toPath:launcherTarget error:NULL];
        NSTask *task = [[[NSTask alloc] init] autorelease];
        // Output must be silenced to not hang this process
        [task setStandardError:[NSPipe pipe]];
        [task setStandardOutput:[NSPipe pipe]];
        [task setLaunchPath:@"/usr/bin/arch"];
        [task setArguments:arguments];
        [task launch];
        [NSApp terminate:self];
    }
    else if ([runMode caseInsensitiveCompare:@"update"] == NSOrderedSame) {
        SUUpdater * updater = [SUUpdater sharedUpdater];
        [updater setDelegate:self];
        NSURL *appcastURL = [NSURL URLWithString:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"SUFeedURL"]];
        if (appcastURL != nil) {
            [updater setFeedURL:appcastURL];
        }
        else {
            [updater setFeedURL:[NSURL URLWithString:@"https://raw.github.com/mstratman/cocoadialog/master/sparkle-release/appcast.xml"]];
        }
        [updater setSendsSystemProfile:YES];
        [updater resetUpdateCycle];
        [updater setAutomaticallyChecksForUpdates:YES];
        if ([options hasOpt:@"quiet"]) {
            [updater setAutomaticallyDownloadsUpdates:YES];
            [updater checkForUpdatesInBackground];
        }
        else {
            [updater setAutomaticallyDownloadsUpdates:NO];
            [updater checkForUpdates:nil];
        }
        [NSApp run];
    }
    // runMode needs to run through control logic
    else {
        NSMutableDictionary *extraOptions = [[[NSMutableDictionary alloc] init] autorelease];
        // Choose the control
        [self chooseControl:runMode useOptions:options addExtraOptionsTo:extraOptions];
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
                               [globalKeys count]+[localKeys count]];
                    [allKeys addEntriesFromDictionary:globalKeys];
                    [allKeys addEntriesFromDictionary:localKeys];
                } else {
                    allKeys = [NSMutableDictionary dictionaryWithCapacity:[globalKeys count]];
                    [allKeys addEntriesFromDictionary:globalKeys];
                    
                }
                [CDOptions printOpts:[allKeys allKeys] forRunMode:runMode];
            }
            // Add any extras chooseControl came up with
            NSEnumerator *en = [extraOptions keyEnumerator];
            NSString *key;
            while (key = [en nextObject]) {
                [options setOption:[extraOptions objectForKey:key] forKey:key];
            }
            
            // Reload the options for currentControl
            [currentControl setOptions:options];
            
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
                                   [globalKeys count]+[localKeys count]];
                        [allKeys addEntriesFromDictionary:globalKeys];
                        [allKeys addEntriesFromDictionary:localKeys];
                    } else {
                        allKeys = [NSMutableDictionary dictionaryWithCapacity:[globalKeys count]];
                        [allKeys addEntriesFromDictionary:globalKeys];
                        
                    }
                    [CDOptions printOpts:[allKeys allKeys] forRunMode:runMode];
                }
                exit(255);
            }
        } else {
            if ([options hasOpt:@"debug"] || [runMode isEqualToString:@"--debug"]) {
                [currentControl debug:@"No run-mode, or invalid runmode provided as first argument."];
            }
            exit(255);
        }
    }
}

#pragma mark - CDControl
+ (NSDictionary *) availableControls {
    return [NSDictionary dictionaryWithObjectsAndKeys:
            [CDCheckboxControl class],              @"checkbox",
            [CDPopUpButtonControl class],           @"dropdown",
            [CDFileSelectControl class],            @"fileselect",
            [CDFileSaveControl class],              @"filesave",
            [CDInputboxControl class],              @"inputbox",
            [CDMsgboxControl class],                @"msgbox",
            [CDNotifyControl class],                @"notify",
            [CDOkMsgboxControl class],              @"ok-msgbox",
            [CDProgressbarControl class],           @"progressbar",
            [CDRadioControl class],                 @"radio",
            [CDInputboxControl class],              @"secure-inputbox",           
            [CDStandardInputboxControl class],      @"secure-standard-inputbox",
            [CDStandardPopUpButtonControl class],   @"standard-dropdown",         
            [CDStandardInputboxControl class],      @"standard-inputbox",
            [CDTextboxControl class],               @"textbox",
            [CDYesNoMsgboxControl class],           @"yesno-msgbox",
            nil];
}

- (void) chooseControl:(NSString *)runMode useOptions:options addExtraOptionsTo:(NSMutableDictionary *)extraOptions
{
    NSDictionary *controls = [AppController availableControls];

	if (runMode == nil) {
        currentControl = nil;
		[CDControl printHelpTo:[NSFileHandle fileHandleWithStandardError]];
	}
    else if ([runMode isEqualToString:@"--help"]) {
        currentControl = nil;
		[CDControl printHelpTo:[NSFileHandle fileHandleWithStandardOutput]];
	}
    else if ([runMode caseInsensitiveCompare:@"version"] == NSOrderedSame) {
        currentControl = nil;
        NSFileHandle * fh = [NSFileHandle fileHandleWithStandardOutput];
        if (fh) {
            [fh writeData:[[self appVersion] dataUsingEncoding:NSUTF8StringEncoding]];
        }
        exit(0);
        
    }
    else if ([runMode caseInsensitiveCompare:@"CDNotifyControl"] == NSOrderedSame) {
        CDControl * notify = [[[CDNotifyControl alloc] initWithOptions:options] autorelease];
        NSDictionary * notifyGlobalKeys = [notify globalAvailableKeys];
        CDOptions * notifyOptions = [notify controlOptionsFromArgs:arguments withGlobalKeys:notifyGlobalKeys];
        NSString * notifyClass = [GrowlApplicationBridge isGrowlInstalled]
                                && [GrowlApplicationBridge isGrowlRunning]
                                && ![notifyOptions hasOpt:@"no-growl"]
                                ? @"CDGrowlControl" : @"CDBubbleControl";
        currentControl = [[(CDControl *)[NSClassFromString(notifyClass) alloc] initWithOptions:options] autorelease];
    }
    else {
        // Bring application into focus.
        // Because this application isn't going to be double-clicked, or
        // launched with the "open" command-line tool, it won't necessarily
        // come to the front automatically.
        [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];

        id control = [controls objectForKey:[runMode lowercaseString]];
        if (control != nil) {
            if ([runMode caseInsensitiveCompare:@"secure-standard-inputbox"] == NSOrderedSame || [runMode caseInsensitiveCompare:@"secure-inputbox"] == NSOrderedSame) {
                [extraOptions setObject:[NSNumber numberWithBool:NO] forKey:@"no-show"];
            }
            currentControl = [[(CDControl *)[control alloc] initWithOptions:options] autorelease];
            return;
        }
        NSFileHandle *fh = [NSFileHandle fileHandleWithStandardError];
        NSString *output = [NSString stringWithFormat:@"Unknown dialog type: %@\n", runMode]; 
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
    NSMutableAttributedString *textFieldString = [[[aTextField attributedStringValue] mutableCopy] autorelease];
    NSRange range = [[textFieldString string] rangeOfString:aString];
    
    // both are needed, otherwise hyperlink won't accept mousedown
    [aTextField setAllowsEditingTextAttributes: YES];
    [aTextField setSelectable: YES];
    
    NSMutableAttributedString* replacement = [[[NSMutableAttributedString alloc] init] autorelease];
    [replacement setAttributedString: [NSAttributedString hyperlinkFromString:aString withURL:[NSURL URLWithString:aURL] withFont:[aTextField font]]];
    
    [textFieldString replaceCharactersInRange:range withAttributedString:replacement];
    
    // set the attributed string to the NSTextField
    [aTextField setAttributedStringValue: textFieldString];
    // Refresh the text field
	[aTextField selectText:self];
    [[aTextField currentEditor] setSelectedRange:NSMakeRange(0, 0)];
}

@end

@implementation NSAttributedString (Hyperlink)
+(id)hyperlinkFromString:(NSString*)inString withURL:(NSURL*)aURL withFont:(NSFont *)aFont
{
    NSMutableAttributedString* attrString = [[NSMutableAttributedString alloc] initWithString: inString];
    NSRange range = NSMakeRange(0, [attrString length]);
    
    [attrString beginEditing];
    [attrString addAttribute:NSFontAttributeName value:aFont range:range];
    [attrString addAttribute:NSLinkAttributeName value:[aURL absoluteString] range:range];
    
    // make the text appear in blue
    [attrString addAttribute:NSForegroundColorAttributeName value:[NSColor blueColor] range:range];
    
    [attrString addAttribute:NSCursorAttributeName value:[NSCursor pointingHandCursor]range:range];
    
    // next make the text appear with an underline
    [attrString addAttribute:
     NSUnderlineStyleAttributeName value:[NSNumber numberWithInt:NSSingleUnderlineStyle] range:range];
    
    [attrString endEditing];
    
    return [attrString autorelease];
}
@end
