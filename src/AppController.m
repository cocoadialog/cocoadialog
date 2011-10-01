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

#import "CDBubbleControl.h"
#import "CDFileSelectControl.h"
#import "CDFileSaveControl.h"
#import "CDProgressbarControl.h"

#import "CDMsgboxControl.h"
#import "CDYesNoMsgboxControl.h"
#import "CDOkMsgboxControl.h"

#import "CDTextboxControl.h"

#import "CDInputboxControl.h"
#import "CDStandardInputboxControl.h"

#import "CDPopUpButtonControl.h"
#import "CDStandardPopUpButtonControl.h"

#import "CDCheckboxControl.h"
#import "CDRadioControl.h"

@implementation AppController

- (void) awakeFromNib
{
	CDControl *control = [[[CDControl alloc] init] autorelease];
	CDOptions *options = nil;
	NSArray *rv;
	NSMutableArray *arguments = [[[NSMutableArray alloc] init] autorelease];
	NSString *runMode = nil;
	NSMutableDictionary *extraOptions = [[[NSMutableDictionary alloc] init] autorelease];
    
	NSDictionary *globalKeys = [[[NSDictionary alloc] init] autorelease];
	NSDictionary *depreciatedKeys = [[[NSDictionary alloc] init] autorelease];
    
    globalKeys = [control globalAvailableKeys];
    depreciatedKeys = [control depreciatedKeys];
    
	[arguments addObjectsFromArray:[[NSProcessInfo processInfo] arguments]];
	if ([arguments count] >= 2) {
		[arguments removeObjectAtIndex:0]; // Remove program name.
		runMode = [arguments objectAtIndex:0];
		[arguments removeObjectAtIndex:0]; // Remove the run-mode
	}
    
    // Bring application into focus.
    // Because this application isn't going to be double-clicked, or
    // launched with the "open" command-line tool, it won't necessarily
    // come to the front automatically.
    [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
    
    // Show the about dialog if cocoaDialog was ran from GUI and not the command line
    if ([[runMode substringToIndex:4] isEqualToString:@"-psn"]) {
        [self setHyperlinkForTextField:aboutAppLink replaceString:@"http://mstratman.github.com/cocoadialog/" withURL:@"http://mstratman.github.com/cocoadialog/"];
        [self setHyperlinkForTextField:aboutText replaceString:@"command line interface" withURL:@"http://en.wikipedia.org/wiki/Command-line_interface"];    
        [self setHyperlinkForTextField:aboutText replaceString:@"documentation" withURL:@"http://mstratman.github.com/cocoadialog/#documentation"];    
		[aboutPanel setFloatingPanel: YES];
		[aboutPanel setLevel:NSFloatingWindowLevel];
        [aboutPanel center];
        [aboutPanel makeKeyAndOrderFront:nil];
        [NSApp run];
    }
    // Otherwise, continue processing arguments from command line
    else {
        options = [CDOptions getOpts:arguments availableKeys:globalKeys depreciatedKeys:depreciatedKeys];

        control = [[[self chooseControl:runMode useOptions:options addExtraOptionsTo:extraOptions] init] autorelease];

        if (control != nil) {
            globalKeys = [control globalAvailableKeys];
            depreciatedKeys = [control depreciatedKeys];

            // Now that we have the control, we can re-get the options to
            // include the local options for that control.
            options = [control controlOptionsFromArgs:arguments	withGlobalKeys:globalKeys];
            
            if ([options hasOpt:@"help"]) {
                NSMutableDictionary *allKeys;
                NSDictionary *localKeys = [control availableKeys];
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
            
            // Set options for the control sub-class
            [control setOptions:options];
            
            // Run the control (a modal window)
            rv = [control runControlFromOptions:options];
            
            // print all the returned lines
            if (rv != nil) {
                unsigned i;
                NSFileHandle *fh = [NSFileHandle fileHandleWithStandardOutput];
                for (i = 0; i < [rv count]; i++) {
                    if (fh) {
                        [fh writeData:[[rv objectAtIndex:i] dataUsingEncoding:NSUTF8StringEncoding]];
                    }
                    if (![options hasOpt:@"no-newline"] || i+1 < [rv count]) 
                    {
                        if (fh) {
                            [fh writeData:[[NSString stringWithString:@"\n"] dataUsingEncoding:NSUTF8StringEncoding]];
                        }
                    }
                }
            } else if ([options hasOpt:@"debug"]) {
                [CDControl debug:@"Control returned nil."];
            }
        } else if ([options hasOpt:@"debug"]
               || [runMode isEqualToString:@"--debug"]) 
        {
            [CDControl debug:@"No run-mode, or invalid runmode provided as first argument."];
        }
    }
    [NSApp terminate:self];
}

+ (NSDictionary *) availableControls {
    return [NSDictionary dictionaryWithObjectsAndKeys:
            [CDBubbleControl class],                @"bubble",
            [CDCheckboxControl class],              @"checkbox",
            [CDPopUpButtonControl class],           @"dropdown",
            [CDFileSelectControl class],            @"fileselect",
            [CDFileSaveControl class],              @"filesave",
            [CDInputboxControl class],              @"inputbox",
            [CDMsgboxControl class],                @"msgbox",
            [CDOkMsgboxControl class],              @"ok-msgbox",
            [CDProgressbarControl class],           @"progressbar",
            [CDRadioControl class],                 @"radio",
            [CDInputboxControl class],              @"secure-inputbox",           
            [CDStandardInputboxControl class],      @"secure-standard-inputbox",
            [CDStandardPopUpButtonControl class],   @"standard-dropdown",         
            [CDStandardInputboxControl class],      @"standard-inputbox",
            [CDYesNoMsgboxControl class],           @"yesno-msgbox",
            nil];
}

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

- (NSString *) appVersion
{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];

}

- (CDControl *) chooseControl:(NSString *)runMode useOptions:options addExtraOptionsTo:(NSMutableDictionary *)extraOptions
{
    NSDictionary *controls = [AppController availableControls];

	if (runMode == nil) {
		[CDControl printHelpTo:[NSFileHandle fileHandleWithStandardError]];
		return nil;
	}
    else if ([runMode isEqualToString:@"--help"]) {
		[CDControl printHelpTo:[NSFileHandle fileHandleWithStandardOutput]];
		return nil;
	}
    else if ([runMode caseInsensitiveCompare:@"version"] == NSOrderedSame) {
        NSFileHandle * fh = [NSFileHandle fileHandleWithStandardOutput];
        if (fh) {
            [fh writeData:[[self appVersion] dataUsingEncoding:NSUTF8StringEncoding]];
        }
        exit(0);
    }
    else {
        id control = [controls objectForKey:[runMode lowercaseString]];
        if (control != nil) {
            if ([runMode caseInsensitiveCompare:@"secure-standard-inputbox"] == NSOrderedSame || [runMode caseInsensitiveCompare:@"secure-inputbox"] == NSOrderedSame) {
                [extraOptions setObject:[NSNumber numberWithBool:NO] forKey:@"no-show"];
            }
            return [[(CDControl *)[control alloc] initWithOptions:options] autorelease];
        }
        NSFileHandle *fh = [NSFileHandle fileHandleWithStandardError];
        NSString *output = [NSString stringWithFormat:@"Unknown dialog type: %@\n", runMode]; 
        if (fh) {
            [fh writeData:[output dataUsingEncoding:NSUTF8StringEncoding]];
        }
        [CDControl printHelpTo:fh];
        return nil;
	}
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
