/*
	CDMsgboxControl.m
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

#import "CDMsgboxControl.h"


@implementation CDMsgboxControl

- (NSDictionary *) availableKeys
{
	NSNumber *vOne = @CDOptionsOneValue;
//	NSNumber *vNone = [NSNumber numberWithInt:CDOptionsNoValues];

	return @{@"alert": vOne,
		@"label": vOne};
}

- (NSDictionary *) depreciatedKeys
{
	return @{@"text": @"alert",
            @"informative-text": @"label"};
}

- (NSString *)controlNib {
    return @"Msgbox";
}

- (BOOL) validateOptions {
    return YES;
}

- (void) createControl {
    // Add extra control
    [icon addControl:text];
	// add the main bold text
	if ([options optValue:@"alert"]) {
		[text setStringValue:[options optValue:@"alert"]];
	}
	[self setTitleButtonsLabel:[options optValue:@"label"]];
}

@end
