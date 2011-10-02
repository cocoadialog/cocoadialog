/*
	CDControl.h
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

#import <Foundation/Foundation.h>
#import "CDOptions.h"

// All control objects must include a runControlFromOptions: method.
// This should look at the options and display a control (dialog with message,
// inputbox, or whatever) to the user, get any necessary info from it, and
// return an NSArray of NSString objects.
// Each NSString is printed to stdout on its own line.
// Return an empty NSArray if there is no output to be printed, or nil
// on error.
@protocol CDControlProtocol
- (NSArray *) runControlFromOptions:(CDOptions *)options;
- (NSArray *) runControl;
@end

// CDControl provides a runControl method.  It invokes
// runControlFromOptions: with the options specified in initWithOptions:
// You must override runControlFromOptions.
@interface CDControl : NSObject <CDControlProtocol> {
	CDOptions               *_options;
    IBOutlet NSPanel        *panel;
    IBOutlet NSImageView    *controlIcon;
    NSMutableArray          *controlItems;
}
- (id)initWithOptions:(CDOptions *)options;

// This must be sub-classed if you want options local to your control
- (NSDictionary *) availableKeys;
// This must be sub-classed if you want specify local depreciated keys for your control
- (NSDictionary *) depreciatedKeys;
// This must be sub-classed if you want validate local options for your control
- (BOOL) validateControl:(CDOptions *)options;

- (NSDictionary *) globalAvailableKeys;

- (CDOptions *) controlOptionsFromArgs:(NSArray *)args;
- (CDOptions *) controlOptionsFromArgs:(NSArray *)args withGlobalKeys:(NSDictionary *)globalKeys;
- (CDOptions *) options;
- (void) setOptions:(CDOptions *)options;

- (NSImage *) getIconFromFile:(NSString *)aFile;
- (NSImage *) getIconWithName:(NSString *)aName;

- (void) setIconForWindow:(NSWindow *)aWindow;
- (void) setIconForWindow:(NSWindow *)aWindow withImage:(NSImage *)anImage withSize:(NSSize)aSize;
- (void) setIconForWindow:(NSWindow *)aWindow withImage:(NSImage *)anImage withSize:(NSSize)aSize withControls:(NSArray *)anArray;


// Looks at the --width and --height options and determines if the window
// needs to be resized.  If so, return NSSize, otherwise returns an NSSize
// with 0.0 as width and height. But you shouldn't worry about that, just do:
// if ([control windowNeedsResize:window]) { NSSize newSize = findNewSize...
- (NSSize) findNewSizeForWindow:(NSWindow *)window;
- (BOOL) windowNeedsResize:(NSWindow *)window;

- (void) debug:(NSString *)message;
+ (void) printHelpTo:(NSFileHandle *)fh;

@end
