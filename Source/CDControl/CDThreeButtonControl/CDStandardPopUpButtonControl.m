/*
	CDStandardPopUpButtonControl.m
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

#import "CDStandardPopUpButtonControl.h"


@implementation CDStandardPopUpButtonControl

- (NSDictionary *) availableKeys
{
    NSNumber *vOne = @CDOptionsOneValue;
	NSNumber *vNone = @CDOptionsNoValues;
	NSNumber *vMul = @CDOptionsMultipleValues;
    
	return @{@"items": vMul,
            @"selected": vOne,
            @"exit-onchange": vNone,
            @"pulldown": vNone,
            @"no-cancel": vNone};
}

- (void) setButtons {
	[button1 setTitle:@"Okay"];
	if ([self.options hasOpt:@"no-cancel"]) {
		[button2 setEnabled:NO];
		[button2 setHidden:YES];
	} else {
		[button2 setTitle:@"Cancel"];
		[button2 setKeyEquivalent:@"\e"];
	}
	[button3 setEnabled:NO];
	[button3 setHidden:YES];
}

@end
