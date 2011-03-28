/*
	CDMsgboxControl.m
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

#import "CDMsgboxControl.h"


@implementation CDMsgboxControl

- (NSDictionary *) availableKeys
{
	NSNumber *vOne = [NSNumber numberWithInt:CDOptionsOneValue];
	NSNumber *vNone = [NSNumber numberWithInt:CDOptionsNoValues];

	return [NSDictionary dictionaryWithObjectsAndKeys:
		vOne, @"text",
		vOne, @"informative-text",
		vOne, @"button1",
		vOne, @"button2",
		vOne, @"button3",
		vOne, @"icon",
		vOne, @"icon-file",
		vNone,@"float",
		vOne, @"timeout",
		nil];
}

- (NSArray *) runControlFromOptions:(CDOptions *)options
{
	NSString *returnString = nil;
	
	[self setOptions:options];

	if (![NSBundle loadNibNamed:@"Msgbox" owner:self]) {
		if ([options hasOpt:@"debug"]) {
			[CDControl debug:@"Could not load Msgbox.nib"];
		}
		return nil;
	}
	
	// add the main bold text
	if ([options optValue:@"text"]) {
		[text setStringValue:[options optValue:@"text"]];
	}

	[self setTitleButtonsLabel:[options optValue:@"informative-text"]];

	[self setIcon];

	[self setTimeout];

	[self runAndSetRv];

	// set returnString
	if ([options hasOpt:@"string-output"]) {
		if (rv == 1) {
			returnString = [button1 title];
		} else if (rv == 2) {
			returnString = [button2 title];
		} else if (rv == 3) {
			returnString = [button3 title];
		} else if (rv == 0) {
			returnString = @"timeout";
		}
	} else {
		returnString = [NSString stringWithFormat:@"%d",rv];
	}
	if (returnString == nil) {
		returnString = @"";
	}
	return [NSArray arrayWithObject:returnString];
}

- (void) setIcon
{
	CDOptions *options = [self options];
	NSImage *icon = nil;
	if ([options hasOpt:@"icon-file"]) {
		icon = [[[NSImage alloc ]initWithContentsOfFile:[options optValue:@"icon-file"]] autorelease];
		if (icon == nil && [options hasOpt:@"debug"]) {
			[CDControl debug:[NSString stringWithFormat:@"Could not get image from specified icon file '%@'.", [options optValue:@"icon-file"]]];
		}

	} else if ([options hasOpt:@"icon"]) {
		NSString *iconName = [options optValue:@"icon"];
		NSString *fileName = [[NSBundle mainBundle] pathForResource:iconName ofType:@"icns"];
		if (fileName) {
			icon = [[[NSImage alloc ]initWithContentsOfFile:fileName] autorelease];
			if (icon == nil && [options hasOpt:@"debug"]) {
				[CDControl debug:[NSString stringWithFormat:@"Could not get image from specified icon file '%@'.", fileName]];
			}
		} else if ([options hasOpt:@"debug"]) {
			[CDControl debug:[NSString stringWithFormat:@"Could not file for icon '%@'.", iconName]];
		}
	}
	if (icon != nil) {
		[imageView setImage:icon];
	}
	// Do we need to stick a blank image in there failing the above?...
}

@end
