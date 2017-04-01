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
	NSNumber *vOne = [NSNumber numberWithInt:CDOptionsOneValue];
//	NSNumber *vNone = [NSNumber numberWithInt:CDOptionsNoValues];

	return [NSDictionary dictionaryWithObjectsAndKeys:
		vOne, @"alert",
		vOne, @"label",
		nil];
}

- (NSDictionary *) depreciatedKeys
{
	return [NSDictionary dictionaryWithObjectsAndKeys:
            @"alert", @"text",
            @"label", @"informative-text",
            nil];
}

- (NSString *)controlNib {
    return @"Msgbox";
}

- (BOOL) validateOptions {
    return YES;
}

- (void) createControl {
    NSRect expandingLabelRect = [expandingLabel frame];
    
    float alertNewHeight = -4.0f;
    NSRect alertRect = [text frame];
    float alertHeightDiff = alertNewHeight - alertRect.size.height;
    if ([options optValue:@"alert"]) {
        [icon addControl:text];
        [text setStringValue:[options optValue:@"alert"]];
    }
    else {
        expandingLabelRect.origin.y -= alertHeightDiff;
        [expandingLabel setFrame:expandingLabelRect];
        [text setHidden:YES];
    }

    // Set panel's new width and height
    NSSize p = [[[panel panel] contentView] frame].size;
    p.height += alertHeightDiff;
    [[panel panel] setContentSize:p];

	[self setTitleButtonsLabel:[options optValue:@"label"]];
}

@end
