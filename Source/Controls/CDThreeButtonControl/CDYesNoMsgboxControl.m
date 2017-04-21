// CDYesNoMsgboxControl.m
// cocoadialog
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.

#import "CDYesNoMsgboxControl.h"

@implementation CDYesNoMsgboxControl

- (CDOptions *) availableOptions {
    CDOptions *options = [super availableOptions];

    [options addOption:[CDOptionFlag    name:@"no-cancel"]];

    return options;
}

- (void) setButtons {
	button1.title = NSLocalizedString(@"Yes", nil);
	[button2 setEnabled:YES];
	[button2 setHidden:NO];
	button2.title = NSLocalizedString(@"No", nil);
	if (option[@"no-cancel"].wasProvided) {
		[button3 setEnabled:NO];
		[button3 setHidden:YES];
	} else {
		button3.title = NSLocalizedString(@"Cancel", nil);
		button3.keyEquivalent = @"\e";
		[button3 setEnabled:YES];
		[button3 setHidden:NO];
	}
}

@end
