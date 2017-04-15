/*
	CDControl.h
	cocoaDialog
	Copyright (C) 2004-2011 Mark A. Stratman <mark@sporkstorms.org>
 
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

#import <Foundation/Foundation.h>
#import "NSArray+CocoaDialog.h"
#import "NSString+CocoaDialog.h"

#import "CDTerminal.h"
#import "CDOptions.h"
#import "CDOption.h"

// All controls must include the methods createControl and validateOptions.
// This should look at the options and display a control (dialog with message,
// inputbox, or whatever) to the user, get any necessary info from it, and
// return an NSArray of NSString objects.
// Each NSString is printed to stdout on its own line.
// Return an empty NSArray if there is no output to be printed, or nil
// on error.
@protocol CDControlProtocol <NSWindowDelegate>
- (void) createControl;
@property (NS_NONATOMIC_IOSONLY, readonly) BOOL validateOptions;
@end

// CDControl provides a runControl method.  It invokes
// runControlFromOptions: with the options specified in initWithOptions:
// You must override runControlFromOptions.
@interface CDControl : NSObject <CDControlProtocol> {
    // For DX/readability use "option" opposed to "options".
    CDOptions *option;

    NSString                    *controlName;

    // Variables
    int                         controlExitStatus;
    NSString                    *controlExitStatusString;
    NSMutableArray              *controlItems;
    NSMutableArray              *controlReturnValues;

    // Timer
    NSThread                    *mainThread;
    NSTimer                     *timer;
    NSThread                    *timerThread;
    double                      timeout;
}

+ (instancetype) control;

@property (nonatomic, readonly) BOOL isBaseControl;

// Logging.
- (void) debug:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2) NS_REQUIRES_NIL_TERMINATION;
- (void) error:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2) NS_REQUIRES_NIL_TERMINATION;
- (void) fatalError:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2) NS_REQUIRES_NIL_TERMINATION;
- (void) verbose:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2) NS_REQUIRES_NIL_TERMINATION;
- (void) warning:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2) NS_REQUIRES_NIL_TERMINATION;

// Icon.
@property (nonatomic, readonly) NSImage *icon;
@property (nonatomic, readonly) NSMutableArray *iconControls;
@property (nonatomic, retain) IBOutlet NSImageView *iconView;
@property (nonatomic, readonly) NSImage *iconImage;
@property (nonatomic, readonly) NSData *iconData;
@property (nonatomic, readonly) NSImage *iconWithDefault;
@property (nonatomic, readonly) NSData *iconDataWithDefault;

- (void) iconAffectedByControl:(id)control;
- (NSImage *) iconFromFile:(NSString *)file;
- (NSImage *) iconFromName:(NSString *)name;
- (void) setIconFromOptions;

// Panel.
@property (nonatomic, retain) IBOutlet NSPanel *panel;
@property (nonatomic, readonly) NSSize findNewSize;
@property (nonatomic, readonly) NSScreen *getScreen;
@property (nonatomic, readonly) BOOL needsResize;


- (void) addMinHeight:(CGFloat)height;
- (void) addMinWidth:(CGFloat)width;
- (void) resize;
- (void) setFloat;
- (void) setPanelEmpty;
- (void) setPosition;
- (void) setTitle;
- (void) setTitle:(NSString *)string;

// Timeout.
@property (nonatomic, retain) IBOutlet NSTextField *timeoutLabel;

// For DX/readability use "option" opposed to "options".
@property (nonatomic, retain) CDOptions *option;

@property (nonatomic, retain) CDTerminal *terminal;

#pragma mark - Internal Control Methods -
@property (retain) NSString *controlName;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *controlNib;
- (void) createTimer;
- (NSString *) formatSecondsForString:(NSInteger)timeInSeconds;
- (BOOL) loadControlNib:(NSString *)nib;
- (void) processTimer;
- (void) runControl;
- (void) setTimeout;
- (void) setTimeoutLabel;
- (void) showUsage;
- (void) stopControl;
- (void) stopTimer;

#pragma mark - Subclassable Control Methods -
@property (NS_NONATOMIC_IOSONLY, readonly) BOOL validateOptions;
- (CDOptions *) availableOptions;
- (void) createControl;
- (BOOL) validateControl;

@end
