/*
	CDYesNoMsgboxControl.m
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

#import "CDYesNoMsgboxControl.h"


@implementation CDYesNoMsgboxControl

- (NSMutableDictionary *) availableOptions {
    NSMutableDictionary *availableOptions = [super availableOptions];
    [availableOptions addEntriesFromDictionary:@{
                                     @"alert": @CDOptionsOneValue,
                                     @"label": @CDOptionsOneValue,
                                     @"no-cancel": @CDOptionsNoValues,
                                     }];
    return availableOptions;
}

- (void) setButtons {
	button1.title = @"Yes";
	[button2 setEnabled:YES];
	[button2 setHidden:NO];
	button2.title = @"No";
	if ([options hasOpt:@"no-cancel"]) {
		[button3 setEnabled:NO];
		[button3 setHidden:YES];
	} else {
		button3.title = @"Cancel";
		button3.keyEquivalent = @"\e";
		[button3 setEnabled:YES];
		[button3 setHidden:NO];
	}
}

@end
