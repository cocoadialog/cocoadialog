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
		vNone, @"stoppable",
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
	if (confirmationSheet) {
		[NSApp endSheet:[confirmationSheet window]];
		[confirmationSheet release];
		confirmationSheet = nil;
	}

	if (stopped) {
		NSFileHandle *fh = [NSFileHandle fileHandleWithStandardOutput];
		[fh writeData:[@"stopped\n" dataUsingEncoding:NSUTF8StringEncoding]];
	}

	[NSApp terminate:nil];
}

-(void) confirmStop
{
	confirmationSheet = [[NSAlert alloc] init];
	[confirmationSheet addButtonWithTitle:@"Stop"];
	[confirmationSheet addButtonWithTitle:@"Cancel"];
	[confirmationSheet setMessageText:@"Are you sure you want to stop?"];
	[confirmationSheet beginSheetModalForWindow:window modalDelegate:self didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) contextInfo:nil];
}

- (void) alertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
	if (confirmationSheet == alert) {
		[confirmationSheet release];
		confirmationSheet = nil;
	}
	if (returnCode == NSAlertFirstButtonReturn && stopEnabled) {
		stopped = YES;
		[self finish];
	}
}

-(IBAction)stop:(id)sender
{
	[self confirmStop];
}

-(void) setStopEnabled:(NSNumber*)enabled
{
	stopEnabled = [enabled boolValue];
	[stopButton setEnabled:stopEnabled];
}

- (NSArray *) runControlFromOptions:(CDOptions *)options
{
	stopEnabled = YES;
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
	
	// hide stop button if not stoppable and resize window/controls
	if (![options hasOpt:@"stoppable"]) {
		NSRect progressBarFrame = [progressBar frame];

		NSRect currentWindowFrame = [window frame];
		CGFloat stopButtonWidth = [stopButton frame].size.width;
		NSRect newWindowFrame = {
			.origin = currentWindowFrame.origin,
			.size = NSMakeSize(currentWindowFrame.size.width - stopButtonWidth + 2, currentWindowFrame.size.height)
		};
		[window setFrame:newWindowFrame display:NO];

		[progressBar setFrame:progressBarFrame];
		[stopButton setHidden:YES];
	}


	// resize if necessary
	if ([self windowNeedsResize:window]) {
		[window setContentSize:[self findNewSizeForWindow:window]];
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
		[window setTitle:[options optValue:@"title"]];
	}

	// set indeterminate
	if ([options hasOpt:@"indeterminate"]) {
		[progressBar setIndeterminate:YES];
		[progressBar startAnimation:self];
	} else {
		[progressBar setIndeterminate:NO];
	}

	[window center];
	if ([[self options] hasOpt:@"float"]) {
		[window setLevel:NSScreenSaverWindowLevel];
	}

	NSOperationQueue* queue = [NSOperationQueue new];

	[window makeKeyAndOrderFront:nil];

	[queue addOperation:inputHandler];
	[inputHandler release];

	[NSApp run];

	return [NSArray array];
}

@end
