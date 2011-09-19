/*
	CDProgressbarControl.m
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

#import "CDProgressbarControl.h"
#import "CDProgressbarInputHandler.h"
#import <sys/select.h>

/*
 NOTE: I'm using C's select to do the non-blocking reading of stdin.
 If you can get it to work with purely NSFileHandle, let me know.
 */

@implementation CDProgressbarControl

- (NSDictionary *) availableKeys
{
	NSNumber *vOne = [NSNumber numberWithInt:CDOptionsOneValue];
	NSNumber *vNone = [NSNumber numberWithInt:CDOptionsNoValues];
	
	return [NSDictionary dictionaryWithObjectsAndKeys:
		vOne,  @"text",
		vOne,  @"percent",
		vNone, @"indeterminate",
		vNone, @"float",
		nil];
}

-(void) updateProgress:(NSNumber*)newProgress
{
	[progressBar setDoubleValue:[newProgress doubleValue]];
}

-(void) updateLabel:(NSString*)newLabel
{
	[label setStringValue:newLabel];
}

-(void) finish
{
	[NSApp terminate:nil];
}

- (NSArray *) runControlFromOptions:(CDOptions *)options
{
	[self setOptions:options];
	
	// Load nib or return nil
	if (![NSBundle loadNibNamed:@"Progressbar" owner:self]) {
		if ([options hasOpt:@"debug"]) {
			[CDControl debug:@"Could not load Progressbar.nib"];
		}
		return nil;
	}
	
	// set text label
	if ([options optValue:@"text"]) {
		[label setStringValue:[options optValue:@"text"]];
	} else {
		[label setStringValue:@""];
	}
	
	// resize if necessary
	if ([self windowNeedsResize:panel]) {
		[panel setContentSize:[self findNewSizeForWindow:panel]];
	}
	
	CDProgressbarInputHandler *inputHandler = [[CDProgressbarInputHandler alloc] init];
	[inputHandler setDelegate:self];

	[progressBar setMinValue:CDProgressbarMIN];
	[progressBar setMaxValue:CDProgressbarMAX];
	
	// set initial percent
	if ([options optValue:@"percent"]) {
		double initialPercent;
		if ([inputHandler parseString:[options optValue:@"percent"] intoProgress:&initialPercent]) {
			[progressBar setDoubleValue:initialPercent];
		}
	}
	
	//set window title
	if ([options optValue:@"title"]) {
		[panel setTitle:[options optValue:@"title"]];
	}

	// set indeterminate
	if ([options hasOpt:@"indeterminate"]) {
		[progressBar setIndeterminate:YES];
		[progressBar startAnimation:self];
	} else {
		[progressBar setIndeterminate:NO];
	}

	[panel center];
	if ([[self options] hasOpt:@"float"]) {
		[panel setFloatingPanel: YES];
		[panel setLevel:NSScreenSaverWindowLevel];
	}

	NSOperationQueue* queue = [NSOperationQueue new];

	[panel makeKeyAndOrderFront:nil];

	[queue addOperation:inputHandler];
	[inputHandler release];

	[NSApp run];

	return [NSArray array];
}

@end
