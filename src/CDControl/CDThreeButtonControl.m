/*
	CDThreeButtonControl.m
	CocoaDialog
	Copyright (C) 2004-2006 Mark A. Stratman <mark@sporkstorms.org>
 
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

#import "CDThreeButtonControl.h"

@implementation CDThreeButtonControl

- (void) runAndSetRv
{
	// Run modal
	[panel center];
	if ([[self options] hasOpt:@"float"]) {
		[panel setFloatingPanel: YES];
		[panel setLevel:NSScreenSaverWindowLevel];
	}		
	
	[panel makeKeyAndOrderFront:nil];
	[NSApp run];
}

- (void) setTitle:(NSString*)aTitle forButton:(NSButton*)aButton
{
	if (aTitle && ![aTitle isEqualToString:@""]) {
		[aButton setTitle:aTitle];
		if ([aTitle isEqualToString:@"Cancel"]) {
			[aButton setKeyEquivalent:@"\e"];
		}

		float maxX = NSMaxX([aButton frame]);
		[aButton sizeToFit];
		NSRect r = [aButton frame];
		r.size.width += 12.0f;
		if (maxX > 100.0f) { // button is in the right side
			r.origin.x = maxX - NSWidth(r);
		}
		[aButton setFrame:r];
		[aButton setEnabled:YES];
		[aButton setHidden:NO];
	} else {
		[aButton setEnabled:NO];
		[aButton setHidden:YES];
	}
}

// This resizes
- (void) setTitleButtonsLabel:(NSString *)labelText
{
	[self setTitle];
	[self setButtons];

	if ([self windowNeedsResize:panel]) {
		[panel setContentSize:[self findNewSizeForWindow:panel]];
	}

	[self setLabel:labelText];

	if ([self windowNeedsResize:panel]) {
		[panel setContentSize:[self findNewSizeForWindow:panel]];
	}
}

- (void) setButtons
{
	unsigned i;
	struct { NSString *key; NSButton *button; } const buttons[] = {
		{ @"button1", button1 },
		{ @"button2", button2 },
		{ @"button3", button3 }
	};

	CDOptions *options = [self options];

	float minWidth = 2 * 20.0f; // margin
	for (i = 0; i != sizeof(buttons)/sizeof(buttons[0]); i++) {
		[self setTitle:[options optValue:buttons[i].key] forButton:buttons[i].button];
		if ([buttons[i].button isHidden] == NO) {
			minWidth += NSWidth([buttons[i].button frame]);
		}
	}

	// move button2 so that it aligns with button1
	NSRect r = [button2 frame];
	r.origin.x = NSMinX([button1 frame]) - NSWidth(r);
	[button2 setFrame:r];

	// move button3 to the left
	r = [button3 frame];
	r.origin.x = 14;
	[button3 setFrame:r];

	// ensure that the buttons never gets clipped
	NSSize s = [panel contentMinSize];
	s.width = minWidth;
	[panel setContentMinSize:s];
}

// Should be called after setButtons, and before resize
- (void) setLabel:(NSString *)labelText
{
	if (labelText != nil) {
		[expandingLabel setStringValue:labelText];
	} else {
		[expandingLabel setStringValue:@""];
	}

	NSRect frame = [expandingLabel frame];
	float oldHeight = frame.size.height;
	NSSize windowContentSize = [[panel contentView] frame].size;
	NSRect dummyRect = NSMakeRect(0., 0., frame.size.width, 800.);
	frame.size = [[expandingLabel cell] cellSizeForBounds:dummyRect];
	float deltaHeight = frame.size.height - oldHeight;

	[expandingLabel setFrame:frame];

	windowContentSize.height += deltaHeight;
	[panel setContentMinSize:windowContentSize];
}

- (void) setTitle
{
	CDOptions *options = [self options];
	// set title
	if ([options optValue:@"title"] != nil) {
		[panel setTitle:[options optValue:@"title"]];
	}
}

- (void) setTimeout
{
	CDOptions *options = [self options];
	if ([options hasOpt:@"timeout"]) {
		NSTimeInterval t;
		if ([[NSScanner scannerWithString:[options optValue:@"timeout"]] scanDouble:&t]) {
			[self performSelector:@selector(timeout:) withObject:panel afterDelay:t];
		} else {
			if ([options hasOpt:@"debug"]) {
				[CDControl debug:@"Could not parse the timeout option"];
			}
		}
	}
}

// TODO - this needs to return a value properly
- (IBAction) timeout:(id)sender
{
	rv = 0;
	// For some reason, this doesn't return the run loop until the mouse is moved over the window or something. I think it has something to do with threading.
	[NSApp stop:self];
	// So termination is needed or it won't return
	// But since that doesn't return, we have to put the exit stuff here.
	// Bah.
	NSFileHandle *fh = [NSFileHandle fileHandleWithStandardOutput];
	if ([[self options] hasOpt:@"string-output"]) {
		if (fh) {
			[fh writeData:[@"timeout" dataUsingEncoding:NSUTF8StringEncoding]];
		}
	} else {
		if (fh) {
			[fh writeData:[@"0" dataUsingEncoding:NSUTF8StringEncoding]];
		}
	}
	if (![[self options] hasOpt:@"no-newline"]) {
		[fh writeData:[@"\n" dataUsingEncoding:NSUTF8StringEncoding]];
	}
	[NSApp terminate:nil];
}

- (IBAction) button1Pressed:(id)sender
{
	rv = 1;
	[NSApp stop:nil];
	return;
}

- (IBAction) button2Pressed:(id)sender
{
	rv = 2;
	[NSApp stop:nil];
	return;
}

- (IBAction) button3Pressed:(id)sender
{
	rv = 3;
	[NSApp stop:nil];
	return;
}

@end
