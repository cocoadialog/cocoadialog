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

- (CDOptions *) availableOptions {
    CDOptions *options = [super availableOptions];

    [options addOption:[CDOptionSingleString    name:@"alert"]];

    // Deprecated options.
    [options addOption:[CDOptionDeprecated      from:@"text"                to:@"alert"]];
    [options addOption:[CDOptionDeprecated      from:@"informative-text"    to:@"label"]];

    return options;
}

- (NSString *)controlNib {
    return @"Msgbox";
}

- (void) createControl {
    NSRect expandingLabelRect = expandingLabel.frame;
    
    float alertNewHeight = -4.0f;
    NSRect alertRect = text.frame;
    float alertHeightDiff = alertNewHeight - alertRect.size.height;
    if (option[@"alert"].wasProvided) {
        [self iconAffectedByControl:text];
        text.stringValue = option[@"alert"].stringValue;
    }
    else {
        expandingLabelRect.origin.y -= alertHeightDiff;
        expandingLabel.frame = expandingLabelRect;
        [text setHidden:YES];
    }

    // Set panel's new width and height
    NSSize p = self.panel.contentView.frame.size;
    p.height += alertHeightDiff;
    [self.panel setContentSize:p];

	[self setTitleButtonsLabel:option[@"label"].stringValue];
}

@end
