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
#import "CDArguments.h"
#import "CDOptions.h"
#import "CDOption.h"
#import "CDCommon.h"
#import "CDIcon.h"
#import "CDPanel.h"

// All controls must include the methods createControl and validateOptions.
// This should look at the options and display a control (dialog with message,
// inputbox, or whatever) to the user, get any necessary info from it, and
// return an NSArray of NSString objects.
// Each NSString is printed to stdout on its own line.
// Return an empty NSArray if there is no output to be printed, or nil
// on error.
@protocol CDControlProtocol
- (void) createControl;
@property (NS_NONATOMIC_IOSONLY, readonly) BOOL validateOptions;
@end

// CDControl provides a runControl method.  It invokes
// runControlFromOptions: with the options specified in initWithOptions:
// You must override runControlFromOptions.
@interface CDControl : CDCommon <CDControlProtocol> {
    NSString                    *controlName;

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
    NSMutableArray              *controlItems;
    NSMutableArray              *controlReturnValues;

    // Timer
    NSThread                    *mainThread;
    NSTimer                     *timer;
    NSThread                    *timerThread;
    float                       timeout;
}

#pragma mark - Internal Control Methods -
@property (retain) NSString *controlName;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *controlNib;
- (void) createTimer;
- (NSString *) formatSecondsForString:(NSInteger)timeInSeconds;
- (instancetype) initWithArguments;
- (BOOL) loadControlNib:(NSString *)nib;
- (NSMutableDictionary *) parseOptionsIntoColumns:(NSDictionary *)opts;
- (void) printHelpTo:(NSFileHandle *)fh;
- (void) processTimer;
- (void) runControl;
- (void) setTimeout;
- (void) setTimeoutLabel;
- (void) stopControl;
- (void) stopTimer;

#pragma mark - Subclassable Control Methods -
@property (NS_NONATOMIC_IOSONLY, readonly) BOOL validateOptions;
- (CDOptions *) availableOptions;
- (void) createControl;
- (BOOL) validateControl;

@end
