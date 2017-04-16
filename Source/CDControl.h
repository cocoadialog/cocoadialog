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

// Categories.
#import "NSArray+CocoaDialog.h"
#import "NSString+CocoaDialog.h"

// Classes.
#import "CDJson.h"
#import "CDOptions.h"
#import "CDOption.h"
#import "CDTerminal.h"

@protocol CDControlProtocol <NSWindowDelegate>

@property (nonatomic, readonly) BOOL validateControl;
@property (nonatomic, readonly) BOOL validateOptions;

- (CDOptions *) availableOptions;
- (void) createControl;
- (BOOL) loadControlNib:(NSString *)nib;
- (void) runControl;
- (void) showUsage;
- (void) stopControl;

@end

#pragma mark -
@interface CDControl : NSObject <CDControlProtocol> {
    // For DX/readability use "option" opposed to "options".
    CDOptions                   *option;

    // Variables
    int                         controlExitStatus;
    NSString                    *controlExitStatusString;
    NSString                    *controlName;
    NSMutableArray              *controlItems;
    NSMutableArray              *controlReturnValues;

    // Timer
    NSThread                    *mainThread;
    NSTimer                     *timer;
    NSThread                    *timerThread;
    double                      timeout;
}

#pragma mark - Properties
@property (nonatomic, retain)               NSString        *controlName;
@property (nonatomic, readonly)             NSString        *controlNib;
@property (nonatomic, readonly)             BOOL            isBaseControl;
// For DX/readability use "option" opposed to "options".
@property (nonatomic, retain)               CDOptions       *option;
@property (nonatomic, retain)               CDTerminal      *terminal;

#pragma mark - Public static methods
+ (instancetype) control;

#pragma mark - Public instance methods
- (NSString *) formatSecondsForString:(NSInteger)timeInSeconds;
- (instancetype) initWithSeenOptions:(NSMutableArray *)seenOptions NS_DESIGNATED_INITIALIZER;

#pragma mark - Icon
@property (nonatomic, readonly)             NSImage         *icon;
@property (nonatomic, readonly)             NSMutableArray  *iconControls;
@property (nonatomic, readonly)             NSData          *iconData;
@property (nonatomic, readonly)             NSData          *iconDataWithDefault;
@property (nonatomic, readonly)             NSImage         *iconImage;
@property (nonatomic, readonly)             NSImage         *iconWithDefault;
@property (nonatomic, retain)   IBOutlet    NSImageView     *iconView;

- (void) iconAffectedByControl:(id)control;
- (NSImage *) iconFromFile:(NSString *)file;
- (NSImage *) iconFromName:(NSString *)name;
- (void) setIconFromOptions;

#pragma mark - Logging
- (void) debug:(NSString *)format, ...      NS_FORMAT_FUNCTION(1,2) NS_REQUIRES_NIL_TERMINATION;
- (void) error:(NSString *)format, ...      NS_FORMAT_FUNCTION(1,2) NS_REQUIRES_NIL_TERMINATION;
- (void) fatalError:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2) NS_REQUIRES_NIL_TERMINATION;
- (void) verbose:(NSString *)format, ...    NS_FORMAT_FUNCTION(1,2) NS_REQUIRES_NIL_TERMINATION;
- (void) warning:(NSString *)format, ...    NS_FORMAT_FUNCTION(1,2) NS_REQUIRES_NIL_TERMINATION;

#pragma mark - Panel
@property (nonatomic, readonly)             NSSize          findNewSize;
@property (nonatomic, readonly)             NSScreen        *getScreen;
@property (nonatomic, readonly)             BOOL            needsResize;
@property (nonatomic, retain)   IBOutlet    NSPanel         *panel;

- (void) addMinHeight:(CGFloat)height;
- (void) addMinWidth:(CGFloat)width;
- (void) resize;
- (void) setFloat;
- (void) setPanelEmpty;
- (void) setPosition;
- (void) setTitle;
- (void) setTitle:(NSString *)string;

#pragma mark - Timer
@property (nonatomic, retain)   IBOutlet    NSTextField     *timeoutLabel;

- (void) createTimer;
- (void) processTimer;
- (void) setTimeout;
- (void) setTimeoutLabel;
- (void) stopTimer;

@end
