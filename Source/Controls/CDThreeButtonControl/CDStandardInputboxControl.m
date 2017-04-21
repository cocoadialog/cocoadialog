// CDStandardInputboxControl.m
// cocoadialog
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.

#import "CDStandardInputboxControl.h"

@implementation CDStandardInputboxControl

- (CDOptions *) availableOptions {
    CDOptions *options = [super availableOptions];

    [options addOption:[CDOptionSingleString        name:@"no-cancel"]];

    return options;
}

- (void) setButtons {
    button1.title = NSLocalizedString(@"Okay", nil);
	if (option[@"no-cancel"].wasProvided) {
		[button2 setEnabled:NO];
		[button2 setHidden:YES];
	} else {
		button2.title = NSLocalizedString(@"Cancel", nil);
		button2.keyEquivalent = @"\e";
        cancelButton = 2;
	}
	[button3 setEnabled:NO];
	[button3 setHidden:YES];
}

@end
