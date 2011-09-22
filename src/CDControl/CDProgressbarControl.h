/*
	CDProgressbarControl.h
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
#import "CDControl.h"
#import "CDProgressbarInputHandlerDelegate.h"

@interface CDProgressbarControl : CDControl <NSWindowDelegate, CDProgressbarInputHandlerDelegate> {
	IBOutlet NSWindow            *window;
	IBOutlet NSTextField         *label;
	IBOutlet NSProgressIndicator *progressBar;
	IBOutlet NSButton            *stopButton;

	@private
	NSAlert	*confirmationSheet;

	@private
	BOOL	stopped;

	@private
	BOOL	stopEnabled;
}

-(IBAction)stop:(id)sender;

@end
