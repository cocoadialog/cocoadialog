/*
	CDProgressbarControl.m
	cocoaDialog
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

- (NSString*) controlNib {
	return @"Progressbar";
}

- (NSDictionary*) availableKeys
{
	NSNumber *vOne = @CDOptionsOneValue;
	NSNumber *vNone = @CDOptionsNoValues;
	
	return @{@"text": vOne,
		@"percent": vOne,
		@"indeterminate": vNone,
		@"float": vNone,
		@"stoppable": vNone};
}

-(void) updateProgress:(NSNumber*)newProgress
{
	[progressBar setDoubleValue:[newProgress doubleValue]];
}

-(void) updateLabel:(NSString*)newLabel
{
	[expandingLabel setStringValue:newLabel];
}

-(void) finish
{
	if (confirmationSheet) {
		[NSApp endSheet:[confirmationSheet window]];
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
	confirmationSheet = NSAlert.new;
	[confirmationSheet addButtonWithTitle:@"Stop"];
	[confirmationSheet addButtonWithTitle:@"Cancel"];
	[confirmationSheet setMessageText:@"Are you sure you want to stop?"];
	[confirmationSheet beginSheetModalForWindow:[self.panel panel] modalDelegate:self didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) contextInfo:nil];
}

- (void) alertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void*)contextInfo
{
	if (confirmationSheet == alert) {
		confirmationSheet = nil;
	}
	if (returnCode == NSAlertFirstButtonReturn && stopEnabled) {
		stopped = YES;
		[self finish];
	}
}

-(IBAction)stop:(id)sender {
	[self confirmStop];
}

-(void) setStopEnabled:(NSNumber*)enabled
{
	stopEnabled = [enabled boolValue];
	[stopButton setEnabled:stopEnabled];
}

- (BOOL) validateOptions {
	return YES;
}

- (void) createControl {
	stopEnabled = YES;
	
	[self.panel addMinWidth:[progressBar frame].size.width + 30.0f];
	[self.icon addControl:expandingLabel];
	[self.icon addControl:progressBar];

	// set text label
	if ([self.options optValue:@"text"]) {
		[expandingLabel setStringValue:[self.options optValue:@"text"]];
	} else {
		[expandingLabel setStringValue:@""];
	}
	
	// hide stop button if not stoppable and resize window/controls
	if (![self.options hasOpt:@"stoppable"]) {
		NSRect progressBarFrame = [progressBar frame];

		NSRect currentWindowFrame = self.panel.panel.frame;
		CGFloat stopButtonWidth = [stopButton frame].size.width;
		NSRect newWindowFrame = {
			.origin = currentWindowFrame.origin,
			.size = NSMakeSize(currentWindowFrame.size.width - stopButtonWidth + 2, currentWindowFrame.size.height)
		};
		[self.panel.panel setFrame:newWindowFrame display:NO];

		[progressBar setFrame:progressBarFrame];
		[stopButton setHidden:YES];
	}

	[self.panel resize];
	
	CDProgressbarInputHandler *inputHandler = CDProgressbarInputHandler.new;
	[inputHandler setDelegate:self];

	[progressBar setMinValue:CDProgressbarMIN];
	[progressBar setMaxValue:CDProgressbarMAX];
	
	// set initial percent
	if ([self.options optValue:@"percent"]) {
		double initialPercent;
		if ([inputHandler parseString:[self.options optValue:@"percent"] intoProgress:&initialPercent]) {
			[progressBar setDoubleValue:initialPercent];
		}
	}
		
	//set window title
	if ([self.options optValue:@"title"]) {
		[self.panel.panel setTitle:[self.options optValue:@"title"]];
	}

	// set indeterminate
	if ([self.options hasOpt:@"indeterminate"]) {
		[progressBar setIndeterminate:YES];
		[progressBar startAnimation:self];
	} else {
		[progressBar setIndeterminate:NO];
	}

	NSOperationQueue* queue = [NSOperationQueue new];
	[queue addOperation:inputHandler];
}

@end
