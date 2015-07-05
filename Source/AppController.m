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

#import <Dialogs/Dialogs.h>
#import "CDUpdate.h"

NSAttributedString * hyperlinkFromStringWithURLWithFont(NSString* inString, NSURL* aURL, NSFont *aFont);

@interface       AppController : NSObject

@property IBOutlet     NSPanel * aboutPanel;
@property IBOutlet NSTextField * aboutAppLink, * aboutText;
@property       NSMutableArray * arguments;
@property            CDControl * currentControl;
@end

@implementation AppController

- (void) awakeFromNib {

  NSString *runMode = nil;
  // Assign arguments
  arguments = NSProcessInfo.processInfo.arguments.mutableCopy;
  // Initialize control
  currentControl = CDControl.new;

  CDOptions *options = [CDOptions getOpts:arguments
                            availableKeys:currentControl.globalAvailableKeys  ?: @{}
                          depreciatedKeys:currentControl.depreciatedKeys      ?: @{}];
  if (arguments.count >= 2) {
    [arguments removeObjectAtIndex:0]; // Remove program name.
    runMode = arguments[0];
    [arguments removeObjectAtIndex:0]; // Remove the run-mode
  }
  // runMode is either the PID of a GUI initialization or "about", show the about dialog
  if ([[runMode substringToIndex:4] isEqualToString:@"-psn"] || [runMode caseInsensitiveCompare:@"about"] == NSOrderedSame) {
    NSLog(@"args: %@ isatty:%i ", arguments, isatty(0));
    if (isatty(0)) [self showAboutBox];
  }
  // runMode is a notification, these need to be handled much differently
  else if ([runMode caseInsensitiveCompare:@"notify"] == NSOrderedSame ||
           [runMode caseInsensitiveCompare:@"bubble"] == NSOrderedSame)
    [self notifyOrBubble];

  else if ([runMode caseInsensitiveCompare:@"update"] == NSOrderedSame)
    [[CDUpdate.alloc initWithOptions:options] update];

  // runMode needs to run through control logic
  else [self runInMode:runMode withOptions:options];
}

- (void) runInMode:(NSString*)runMode withOptions:(CDOptions*)options {

  NSMutableDictionary *extraOptions = @{}.mutableCopy;

  // Choose the control

  [self chooseControl:runMode useOptions:options addExtraOptionsTo:extraOptions];

  if (currentControl) {

    // Initialize the currentControl
    [currentControl init];

    // Now that we have the control, we can re-get the options to include the local options for that control.

    options = [currentControl controlOptionsFromArgs:arguments	withGlobalKeys:currentControl.globalAvailableKeys];

    if ([options hasOpt:@"help"]) {

      NSMutableDictionary *allKeys = !currentControl.availableKeys ? currentControl.globalAvailableKeys.mutableCopy : ({

        id x = currentControl.globalAvailableKeys.mutableCopy; [x addEntriesFromDictionary:currentControl.availableKeys]; x; });

      [CDOptions printOpts:allKeys.allKeys forRunMode:runMode];
    }

    // Add any extras chooseControl came up with
    [extraOptions enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
      [options setOption:obj forKey:key];
    }];

    // Reload the options for currentControl
    [currentControl setOptions:options];

    // Validate currentControl's options and load interface nib
    if (currentControl.validateOptions && [currentControl loadControlNib:currentControl.controlNib]) {

      // Create the control
      [currentControl createControl];

      // Initialize the timer, if one exists
      [currentControl setTimeout];

      // Run the control. The control is now responsible for terminating cocoaDialog, which should be invoked by calling the method [self stopControl] from the control's action method(s).
      [currentControl runControl];
    } else {

      if ([options hasOpt:@"debug"]) {

        NSMutableDictionary *allKeys = !currentControl.availableKeys ? currentControl.globalAvailableKeys.mutableCopy : ({

          id x = currentControl.globalAvailableKeys.mutableCopy; [x addEntriesFromDictionary:currentControl.availableKeys]; x; });

        [CDOptions printOpts:allKeys.allKeys forRunMode:runMode];
      }
      exit(255);
    }
  }

  else { // No currentControl !!

    if ([options hasOpt:@"debug"] || [runMode isEqualToString:@"--debug"])

      [currentControl debug:@"No run-mode, or invalid runmode provided as first argument."];

    exit(255);
  }
}

- (void) chooseControl:(NSString*)runMode useOptions:options addExtraOptionsTo:(NSMutableDictionary *)extraOptions
{
  NSDictionary *controls = CDControl.availableControls;

  if (!runMode || [runMode isEqualToString:@"--help"] || [runMode caseInsensitiveCompare:@"version"] == NSOrderedSame) {

    currentControl = nil;

    NSFileHandle * fh = !runMode ? NSFileHandle.fileHandleWithStandardError : NSFileHandle.fileHandleWithStandardOutput;

    [runMode caseInsensitiveCompare:@"version"] != NSOrderedSame ? [CDControl printHelpTo:fh]:
    [fh writeData:[self.appVersion dataUsingEncoding:NSUTF8StringEncoding]];
    exit(0);

  }
  else if ([runMode caseInsensitiveCompare:@"CDNotifyControl"] == NSOrderedSame) {

    CDControl * notify        = [CDNotifyControl.alloc initWithOptions:options];
    CDOptions * notifyOptions = [notify controlOptionsFromArgs:arguments withGlobalKeys:notify.globalAvailableKeys];
    NSString  * notifyClass   = ![notifyOptions hasOpt:@"no-growl"] ? @"CDGrowlControl" : @"CDBubbleControl";

    currentControl = [(CDControl*)NSClassFromString(notifyClass).alloc initWithOptions:options];
  }
  else {

    /*! Bring application into focus. Because this application isn't going to be double-clicked,
     or launched with the "open" command-line tool, it won't necessarily come to the front automatically.
     */
    [NSApplication.sharedApplication activateIgnoringOtherApps:YES];

    id control;

    if ((control = controls[runMode.lowercaseString])) {

      if ([runMode caseInsensitiveCompare:@"secure-standard-inputbox"] == NSOrderedSame || [runMode caseInsensitiveCompare:@"secure-inputbox"] == NSOrderedSame)
        extraOptions[@"no-show"] = @NO;

      currentControl = [(CDControl*)[control alloc] initWithOptions:options];
      return;
    }
    NSFileHandle *handle;
    if ((handle = NSFileHandle.fileHandleWithStandardError)) {

      [handle writeData:[[NSString stringWithFormat:@"Unknown dialog type: %@\n", runMode] dataUsingEncoding:NSUTF8StringEncoding]];

      [CDControl printHelpTo:handle];
      currentControl = nil;
    }
  }
}

- (NSString *) appVersion {
  return NSBundle.mainBundle.infoDictionary[@"CFBundleVersion"];
}

#pragma mark - Initialization

- (void) notifyOrBubble {

  // Determine which notification type to use & Recapture the arguments
  arguments = NSProcessInfo.processInfo.arguments.mutableCopy;
  // Replace the runMode with the new one
  arguments[1] = @"CDNotifyControl";
  // Relaunch cocoaDialog with the new runMode
  NSString *launcherSource = [NSBundle.mainBundle pathForResource:@"relaunch" ofType:@""];
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
  NSTask *task        = NSTask.new;
  // Output must be silenced to not hang this process
  task.standardError  = NSFileHandle.fileHandleWithNullDevice;
  task.standardOutput = NSFileHandle.fileHandleWithNullDevice;
  task.launchPath     = @"/usr/bin/arch";
  task.arguments      = arguments;
  [task launch];
  [NSApp terminate:self];
}

#pragma mark - Label Hyperlinks

- (void) setHyperlinkForTextField:(NSTextField*)aTextField replaceString:(NSString *)aString withURL:(NSString *)aURL {

  NSMutableAttributedString *textFieldString = aTextField.attributedStringValue.mutableCopy;
  NSRange range = [textFieldString.string rangeOfString:aString];

  // both are needed, otherwise hyperlink won't accept mousedown
  [aTextField setAllowsEditingTextAttributes: YES];
  [aTextField setSelectable: YES];

  NSMutableAttributedString* replacement = NSMutableAttributedString.new;
  [replacement setAttributedString: hyperlinkFromStringWithURLWithFont(aString,[NSURL URLWithString:aURL],[aTextField font])];
  [textFieldString replaceCharactersInRange:range withAttributedString:replacement];
  // set the attributed string to the NSTextField
  [aTextField setAttributedStringValue: textFieldString];
  // Refresh the text field
  [aTextField selectText:self];
  [aTextField.currentEditor setSelectedRange:NSMakeRange(0, 0)];
}

- (void) showAboutBox {

  [NSApplication.sharedApplication activateIgnoringOtherApps:YES];
  [self setHyperlinkForTextField:aboutAppLink replaceString:@"http://mstratman.github.com/cocoadialog/" withURL:@"http://mstratman.github.com/cocoadialog/"];
  [self setHyperlinkForTextField:aboutText    replaceString:@"command line interface" withURL:@"http://en.wikipedia.org/wiki/Command-line_interface"];
  [self setHyperlinkForTextField:aboutText    replaceString:@"documentation" withURL:@"http://mstratman.github.com/cocoadialog/#documentation"];
  [aboutPanel setFloatingPanel: YES];
  [aboutPanel setLevel:NSFloatingWindowLevel];
  [aboutPanel center];
  [aboutPanel makeKeyAndOrderFront:nil];
  [NSApp run];
}

@synthesize arguments, currentControl, aboutAppLink, aboutText, aboutPanel;

@end

NSAttributedString * hyperlinkFromStringWithURLWithFont(NSString* inString, NSURL* aURL, NSFont *aFont) {

  NSMutableAttributedString* attrString = [NSMutableAttributedString.alloc initWithString: inString];
  NSRange range = NSMakeRange(0,attrString.length);

  [attrString beginEditing];
  [attrString addAttribute:NSFontAttributeName value:aFont range:range];
  [attrString addAttribute:NSLinkAttributeName value:aURL.absoluteString range:range];
  // make the text appear in blue
  [attrString addAttribute:NSForegroundColorAttributeName value:NSColor.blueColor range:range];
  [attrString addAttribute:NSCursorAttributeName value:NSCursor.pointingHandCursor range:range];
  // next make the text appear with an underline
  [attrString addAttribute:NSUnderlineStyleAttributeName value:@(NSSingleUnderlineStyle) range:range];
  [attrString endEditing];

  return attrString;
}

int main(int argc, const char *argv[]) { return NSApplicationMain(argc, argv); }

