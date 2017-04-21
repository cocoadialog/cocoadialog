// CDOkMsgboxControl.m
// cocoadialog
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.

#import "CDOkMsgboxControl.h"

@implementation CDOkMsgboxControl

- (CDOptions *) availableOptions {
    CDOptions *options = [super availableOptions];

    [options addOption:[CDOptionFlag    name:@"no-cancel"]];

    return options;
}

- (void) setButtons {
	button1.title = NSLocalizedString(@"Ok", nil);
	if (option[@"no-cancel"].wasProvided) {
		[button2 setEnabled:NO];
		[button2 setHidden:YES];
	} else {
		button2.title = NSLocalizedString(@"Cancel", nil);
		button2.keyEquivalent = @"\e";
		[button2 setEnabled:YES];
		[button2 setHidden:NO];
	}
	[button3 setEnabled:NO];
	[button3 setHidden:YES];
}

@end
