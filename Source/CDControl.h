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
#import "CDOptions.h"

// All controls must include a createControlWithOptions: method.
// This should look at the options and display a control (dialog with message,
// inputbox, or whatever) to the user, get any necessary info from it, and
// return an NSArray of NSString objects.
// Each NSString is printed to stdout on its own line.
// Return an empty NSArray if there is no output to be printed, or nil
// on error.
@class NSObject;
@protocol CDControlProtocol
- (void) createControlWithOptions:(CDOptions *)options;
- (void) controlHasFinished;
- (BOOL) controlValidateOptions:(CDOptions *)options;
@end

// CDControl provides a runControl method.  It invokes
// runControlFromOptions: with the options specified in initWithOptions:
// You must override runControlFromOptions.
@interface CDControl : NSObject <CDControlProtocol,NSApplicationDelegate> {
    int                         controlExitStatus;
    NSString                    *controlExitStatusString;
    IBOutlet NSImageView        *controlIcon;
    NSMutableArray              *controlItems;
    NSMutableArray              *controlReturnValues;
    BOOL                        hasFinished;
    IBOutlet NSPanel            *panel;
    int                         timeout;
    IBOutlet NSTextField        *timeoutLabel;
    NSTimer                     *timer;
@private
    CDOptions                   *options;
}
@property BOOL hasFinished;
@property (retain) CDOptions *options;

#pragma mark - Internal Control Methods -
- (CDOptions *) controlOptionsFromArgs:(NSArray *)args;
- (CDOptions *) controlOptionsFromArgs:(NSArray *)args withGlobalKeys:(NSDictionary *)globalKeys;
- (NSSize) findNewSizeForWindow:(NSWindow *)window;
- (void) findPositionForWindow:(NSWindow *)window;
- (NSImage *) getIcon;
- (NSImage *) getIconFromFile:(NSString *)aFile;
- (NSImage *) getIconWithName:(NSString *)aName;
- (id) initWithOptions:(CDOptions *)newOptions;
+ (void) printHelpTo:(NSFileHandle *)fh;
- (void) runControl;
- (void) setIconForWindow:(NSWindow *)aWindow;
- (void) setIconForWindow:(NSWindow *)aWindow withImage:(NSImage *)anImage withSize:(NSSize)aSize;
- (void) setIconForWindow:(NSWindow *)aWindow withImage:(NSImage *)anImage withSize:(NSSize)aSize withControls:(NSArray *)anArray;
- (void) setTimeout;
- (void) timeout;
- (BOOL) windowNeedsResize:(NSWindow *)window;

#pragma mark - Subclassable Control Methods -
// This must be sub-classed if you want options local to your control
- (NSDictionary *) availableKeys;
- (void) createControlWithOptions:(CDOptions *)options;
- (void) controlHasFinished;
- (BOOL) controlValidateOptions:(CDOptions *)options;
- (void) debug:(NSString *)message;
// This must be sub-classed if you want specify local depreciated keys for your control
- (NSDictionary *) depreciatedKeys;
// This must be overridden if you want local global options for your control
- (NSDictionary *) globalAvailableKeys;
// This must be sub-classed if you want validate local options for your control
- (BOOL) validateControl:(CDOptions *)options;

@end
