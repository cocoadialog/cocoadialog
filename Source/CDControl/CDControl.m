/*
	CDControl.m
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
#import "CDControl.h"

@implementation CDControl

#pragma mark - Internal Control Methods -
- (NSString *) controlNib { return @""; }
- (CDOptions *) controlOptionsFromArgs:(NSArray *)args {
	return [CDOptions getOpts:args availableKeys:[self availableKeys] depreciatedKeys:[self depreciatedKeys]];
}
- (CDOptions *) controlOptionsFromArgs:(NSArray *)args withGlobalKeys:(NSDictionary *)globalKeys {
	NSMutableDictionary *allKeys = [[[NSMutableDictionary alloc] init] autorelease];
    [allKeys addEntriesFromDictionary:globalKeys];
    
	NSDictionary *localKeys = [self availableKeys];
	if (localKeys != nil) {
		[allKeys addEntriesFromDictionary:localKeys];
	}
    NSDictionary *depreciatedKeys = [self depreciatedKeys];
	return [CDOptions getOpts:args availableKeys:allKeys depreciatedKeys:depreciatedKeys];
}
- (void) dealloc {
    [panel release];
    [icon release];
    [controlExitStatusString release];
    [controlItems release];
    [controlReturnValues release];
	[options release];
    if (timer != nil) {
        [timer invalidate];
        [timer release];
    }
	[super dealloc];
}
- (NSString *) formatSecondsForString:(NSInteger)timeInSeconds {
    static NSString *timerFormat = nil;
    if (timerFormat == nil) {
        if ([options hasOpt:@"timeout-format"]) {
            timerFormat = [options optValue:@"timeout-format"];
        }
        else {
            timerFormat = @"Time remaining: %r...";
        }
    }
    NSString *returnString = timerFormat;
    
    NSInteger seconds = timeInSeconds % 60; 
    NSInteger minutes = (timeInSeconds / 60) % 60; 
    NSInteger hours = timeInSeconds / 3600;     
    NSInteger days = timeInSeconds / (3600 * 24);
    NSString *relative = @"unknown";
    if (days > 0) {
        if (days > 1) {
            relative = [NSString stringWithFormat:@"%d days", days];
        }
        else {
            relative = [NSString stringWithFormat:@"%d day", days];
        }
    }
    else {
        if (hours > 0) {
            if (hours > 1) {
                relative = [NSString stringWithFormat:@"%d hours", hours];
            }
            else {
                relative = [NSString stringWithFormat:@"%d hour", hours];
            }
        }
        else {
            if (minutes > 0) {
                if (minutes > 1) {
                    relative = [NSString stringWithFormat:@"%d minutes", minutes];
                }
                else {
                    relative = [NSString stringWithFormat:@"%d minute", minutes];
                }
            }
            else {
                if (seconds > 0) {
                    if (seconds > 1) {
                        relative = [NSString stringWithFormat:@"%d seconds", seconds];
                    }
                    else {
                        relative = [NSString stringWithFormat:@"%d second", seconds];
                    }
                }
            }
        }
    }
    returnString = [returnString stringByReplacingOccurrencesOfString:@"%s" withString:[NSString stringWithFormat:@"%d", seconds]];
    returnString = [returnString stringByReplacingOccurrencesOfString:@"%m" withString:[NSString stringWithFormat:@"%d", minutes]];
    returnString = [returnString stringByReplacingOccurrencesOfString:@"%h" withString:[NSString stringWithFormat:@"%d", hours]];
    returnString = [returnString stringByReplacingOccurrencesOfString:@"%d" withString:[NSString stringWithFormat:@"%d", days]];
    returnString = [returnString stringByReplacingOccurrencesOfString:@"%r" withString:relative];
    return returnString;
}
- (id)initWithOptions:(CDOptions *)opts {
	self = [super initWithOptions:opts];
    controlExitStatus = -1;
    controlExitStatusString = nil;
    controlReturnValues = [[[NSMutableArray alloc] init] retain];
    controlItems = [[[NSMutableArray alloc] init] retain];
	return self;
}
- (BOOL) loadControlNib:(NSString *)nib {
    // Load nib
    if (nib != nil) {
        if (![nib isEqualToString:@""] && ![NSBundle loadNibNamed:nib owner:self]) {
            if ([options hasOpt:@"debug"]) {
                [self debug:[NSString stringWithFormat:@"Could not load control interface: \"%@.nib\"", nib]];
            }
            return NO;
        }
    }
    else {
        [self debug:@"Control did not specify a NIB interface file to load."];
        return NO;
    }
    panel = [[[CDPanel alloc] initWithOptions:options] retain];
    icon = [[[CDIcon alloc] initWithOptions:options] retain];
    if (controlPanel != nil) {
        [panel setPanel:controlPanel];
        [panel addMinHeight:40.0f];
        [panel addMinWidth:40.0f];
        [icon setPanel:panel];
    }
    if (controlIcon != nil) {
        [icon setControl:controlIcon];
    }
    return YES;
}
+ (void) printHelpTo:(NSFileHandle *)fh {
	if (fh) {
        [fh writeData:[@"Usage: cocoaDialog <run-mode> [options]\n\tAvailable run-modes:\n" dataUsingEncoding:NSUTF8StringEncoding]];
        NSArray *sortedAvailableKeys = [NSArray arrayWithArray:[[[AppController availableControls] allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];
        
        NSEnumerator *en = [sortedAvailableKeys objectEnumerator];
        id key;
        unsigned i = 0;
        unsigned currKey = 0;
        while (key = [en nextObject]) {
            if (i == 0) {
                [fh writeData:[@"\t\t" dataUsingEncoding:NSUTF8StringEncoding]];
            }
            [fh writeData:[key dataUsingEncoding:NSUTF8StringEncoding]];
            if (i <= 6 && currKey != [sortedAvailableKeys count] - 1) {
                [fh writeData:[@", " dataUsingEncoding:NSUTF8StringEncoding]];
                i++;
            }
            if (i == 6) {
                [fh writeData:[@"\n" dataUsingEncoding:NSUTF8StringEncoding]];
                i = 0;
            }
            currKey++;
        }
        
        [fh writeData:[@"\n\tGlobal Options:\n\t\t--help, --debug, --title, --width, --height,\n\t\t--string-output, --no-newline\n\nSee http://mstratman.github.com/cocoadialog/#documentation\nfor detailed documentation.\n" dataUsingEncoding:NSUTF8StringEncoding]];
	}
}
- (void) runControl {
    // The control must either: 1) sub-class -(NSString *) controlNib, return the name of the NIB, and then connect "controlPanel" in IB or 2) set the panel manually with [panel setPanel:(NSPanel *)]  when creating the control. 
    if ([panel panel] != nil) {
        [[panel panel] setDelegate:self];
        // Set icon
        if ([icon control] != nil) {
            [icon setIconFromOptions];
        }
        // Configure panel with options
        [panel configure];
        [NSApp run];
    }
    else {
        if ([options hasOpt:@"debug"]) {
            [self debug:@"The control has not specified the panel it is to use and cocoaDialog cannot continue."];
        }
        exit(255);
    }
}
- (void) setTimeout {
    timeout = 0.0f;
    timer = nil;
    // Only initialize timeout if the option is provided
	if ([options hasOpt:@"timeout"]) {
		if ([[NSScanner scannerWithString:[options optValue:@"timeout"]] scanFloat:&timeout]) {
            mainThread = [NSThread currentThread];
            [NSThread detachNewThreadSelector:@selector(createTimer) toTarget:self withObject:nil];
		} else if ([options hasOpt:@"debug"]) {
            [self debug:@"Could not parse the timeout option."];
		}
	}
    [self setTimeoutLabel];
}
- (void) setTimeoutLabel {
    if (timeoutLabel != nil) {
        float labelNewHeight = -4.0f;
        NSRect labelRect = [timeoutLabel frame];
        float labelHeightDiff = labelNewHeight - labelRect.size.height;
        [timeoutLabel setStringValue:[self formatSecondsForString:(int)timeout]];
        if (![[timeoutLabel stringValue] isEqualToString:@""] && timeout != 0.0f) {
            NSTextStorage *textStorage = [[[NSTextStorage alloc] initWithString: [timeoutLabel stringValue]]autorelease];
            NSTextContainer *textContainer = [[[NSTextContainer alloc] initWithContainerSize:NSMakeSize(labelRect.size.width, FLT_MAX)] autorelease];
            NSLayoutManager *layoutManager = [[[NSLayoutManager alloc]init] autorelease];
            [layoutManager addTextContainer: textContainer];
            [textStorage addLayoutManager: layoutManager];
            [layoutManager glyphRangeForTextContainer:textContainer];
            labelNewHeight = [layoutManager usedRectForTextContainer:textContainer].size.height;
            labelHeightDiff = labelNewHeight - labelRect.size.height;
            // Set label's new height
            NSRect l = NSMakeRect(labelRect.origin.x, labelRect.origin.y - labelHeightDiff, labelRect.size.width, labelNewHeight);
            [timeoutLabel setFrame: l];
        }
        else {
            [timeoutLabel setHidden:YES];
        }
        // Set panel's new width and height
        NSSize p = [[[panel panel] contentView] frame].size;
        p.height += labelHeightDiff;
        [[panel panel] setContentSize:p];
    }
}
- (void) createTimer {
    NSAutoreleasePool *timerPool = [[NSAutoreleasePool alloc] init];
    timerThread = [NSThread currentThread];
    NSRunLoop *_runLoop = [NSRunLoop currentRunLoop];
    timer = [[NSTimer timerWithTimeInterval:1.0f target:self selector:@selector(processTimer) userInfo:nil repeats:YES] retain];
    [_runLoop addTimer:timer forMode:NSRunLoopCommonModes];
    [_runLoop run];
    [timerPool release];
}
- (void) stopTimer {
    [timer invalidate];
    [timer release];
    timer = nil;
    [self performSelector:@selector(stopControl) onThread:mainThread withObject:nil waitUntilDone:YES];
}
- (void) processTimer {
    // Decrease timeout value
    timeout = timeout - 1.0f;
    // Update and position the label if it exists
    if (timeout > 0.0f) {
        if (timeoutLabel != nil) {
            [timeoutLabel setStringValue:[self formatSecondsForString:(int)timeout]];
        }
    }
    else {
        controlExitStatus = 0;
        controlExitStatusString = @"timeout";
        controlReturnValues = [NSMutableArray array];
        [self stopTimer];
    }
}
- (void) stopControl {
    // Stop timer
    if (timerThread != nil) {
        [timerThread cancel];
    }
    // Stop any modal windows currently running
    [NSApp stop:self];
    if (![options hasOpt:@"quiet"] && controlExitStatus > 0) {
        if ([options hasOpt:@"string-output"]) {
            if (controlExitStatusString == nil) {
                controlExitStatusString = [NSString stringWithFormat:@"%d", controlExitStatus];
            }
            [controlReturnValues insertObject:controlExitStatusString atIndex:0];
        }
        else {
            [controlReturnValues insertObject:[NSString stringWithFormat:@"%d", controlExitStatus] atIndex:0];
        }
    }
    if (controlExitStatus < 0) {
        controlExitStatus = controlExitStatus * -1;
    }
    // Print all the returned lines
    if (controlReturnValues != nil) {
        unsigned i;
        NSFileHandle *fh = [NSFileHandle fileHandleWithStandardOutput];
        for (i = 0; i < [controlReturnValues count]; i++) {
            if (fh) {
                [fh writeData:[[controlReturnValues objectAtIndex:i] dataUsingEncoding:NSUTF8StringEncoding]];
            }
            if (![options hasOpt:@"no-newline"] || i+1 < [controlReturnValues count]) 
            {
                if (fh) {
                    [fh writeData:[[NSString stringWithString:@"\n"] dataUsingEncoding:NSUTF8StringEncoding]];
                }
            }
        }
    } else if ([options hasOpt:@"debug"]) {
        [self debug:@"Control returned nil."];
    }
    [self dealloc];
    // Return the exit status
    exit(controlExitStatus);
}

#pragma mark - Subclassable Control Methods -
- (NSDictionary *) availableKeys {return nil;}
- (void) createControl {};
- (BOOL) validateOptions { return YES; }
- (NSDictionary *) depreciatedKeys {return nil;}
- (NSDictionary *) globalAvailableKeys {
    NSNumber *vOne = [NSNumber numberWithInt:CDOptionsOneValue];
	NSNumber *vNone = [NSNumber numberWithInt:CDOptionsNoValues];
    return [NSDictionary dictionaryWithObjectsAndKeys:
            // General
            vNone, @"help",
            vNone, @"debug",
            vNone, @"quiet",
            vOne,  @"timeout",
            vOne,  @"timeout-format",            
            vNone, @"string-output",
            vNone, @"no-newline",
            // Panel
            vNone, @"close",
            vOne,  @"height",
            vOne,  @"max-height",
            vOne,  @"max-width",
            vOne,  @"min-height",
            vOne,  @"min-width",
            vNone, @"minimize",
            vNone, @"no-float",
            vOne,  @"posX",
            vOne,  @"posY",
            vNone, @"resize",
            vOne,  @"screen",
            vOne,  @"title",
            vOne,  @"width",
            // Icon
            vOne,  @"icon",
            vOne,  @"icon-bundle",
            vOne,  @"icon-type",
            vOne,  @"icon-file",
            vOne,  @"icon-size",
            vOne,  @"icon-width",
            vOne,  @"icon-height",
            nil];
}
- (BOOL) validateControl:(CDOptions *)options {return YES;}

#pragma mark - NSWindowDelegate Methods

- (void)windowWillClose:(NSNotification *)notification {
    controlExitStatus = -255;
    [self stopControl];
}

- (BOOL)windowShouldZoom:(NSWindow *)window toFrame:(NSRect)newFrame {
    if (![window isZoomed]) {
        NSRect screen = [self screen];
        CGFloat x = (NSWidth(newFrame) / 2) - (NSWidth([window frame]) / 2);
        CGFloat y = (NSHeight(newFrame) / 2) - (NSHeight([window frame]) / 2);
        newFrame.origin.x -= x;
        newFrame.origin.y += y;
        if (newFrame.origin.x < NSMinX(screen))  newFrame.origin.x = NSMinX(screen);
        if (newFrame.origin.y < NSMinY(screen)) newFrame.origin.y = NSMinY(screen);
        NSLog(@"%@", NSStringFromRect(newFrame));
        [window setFrame:newFrame display:YES animate:YES];
        [window setIsZoomed:YES];
        return NO;
    }
    return YES;
}

@end
