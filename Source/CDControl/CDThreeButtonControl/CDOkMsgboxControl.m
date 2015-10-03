/*
	CDOkMsgboxControl.m
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

#import "CDThreeButtonControl.h"

@implementation CDOkMsgboxControl

- (NSDictionary *) availableKeys
{
	return @{@"alert":  @CDOptionsOneValue, @"label":@CDOptionsOneValue, @"no-cancel": @CDOptionsNoValues};
}

- (void) setButtons {

	button1.title = @"Ok";

	if ([self.options hasOpt:@"no-cancel"])

    BUTTON_SET(button2,NO,YES);

  else {
		button2.title         = @"Cancel";
		button2.keyEquivalent = @"\e";
		BUTTON_SET(button2,YES,NO);
	}

	BUTTON_SET(button3, NO, YES);
}

@end
