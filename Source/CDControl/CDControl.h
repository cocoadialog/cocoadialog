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

#import "CDCommon.h"
#import "CDOptions.h"
#import "CDPanel.h"
#import "CDIcon.h"


/*! All controls must include the methods createControl and validateOptions.
    This should look at the options and display a control (dialog with message, inputbox, or whatever) to the user, 
    get any necessary info from it, and return an NSArray of NSString objects.
    Each NSString is printed to stdout on its own line.
    @return an empty NSArray if there is no output to be printed, or nil on error.
 */
@protocol CDControl

- (void) createControl;
- (BOOL) validateOptions;

- (CDOptions *) controlOptionsFromArgs:(NSArray *)args;
- (CDOptions *) controlOptionsFromArgs:(NSArray *)args withGlobalKeys:(NSDictionary *)globalKeys;

@property (readonly) BOOL validateOptions;

#pragma mark - Internal Control Methods
@required
@property (readonly, copy) NSString *controlNib;

#pragma mark - Subclassable Control Methods -

@property (readonly, copy) NSDictionary

* availableKeys,        // must be sub-classed if you want options local to your control
* depreciatedKeys,      // must be sub-classed if you want specify local depreciated keys for your control
* globalAvailableKeys;  // must be overridden if you want local global options for your control

// This must be sub-classed if you want validate local options for your control
- (BOOL) validateControl:(CDOptions *)options;
@end

/*! CDControl provides a runControl method.
    It invokes runControlFromOptions: with the options specified in initWithOptions:
    @note You must override runControlFromOptions.
 */
@interface CDControl : CDCommon <CDControl> {
// Classes
    CDIcon                      *icon;
    CDPanel                     *panel;
// Outlets
    IBOutlet NSPanel            *controlPanel;
    IBOutlet NSImageView        *controlIcon;
    IBOutlet NSTextField        *timeoutLabel;
// Variables
    int                         controlExitStatus;
    NSString                    *controlExitStatusString;
    NSMutableArray              *controlItems,
                                *controlReturnValues;

// Timer
    NSThread                    *mainThread,
                                *timerThread;
    NSTimer                     *timer;
    float                       timeout;
}

- (void) createTimer;
- (NSString *) formatSecondsForString:(NSInteger)timeInSeconds;
- (BOOL) loadControlNib:(NSString *)nib;
+ (void) printHelpTo:(NSFileHandle *)fh;
- (void) processTimer;
- (void) runControl;
- (void) setTimeout;
- (void) setTimeoutLabel;
- (void) stopControl;
- (void) stopTimer;

+ (NSDictionary*) availableControls;

@end
