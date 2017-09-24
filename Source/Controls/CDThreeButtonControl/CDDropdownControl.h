// CDDropdownControl.h
// cocoadialog
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.

#import "CDThreeButtonControl.h"

@interface CDDropdownControl : CDThreeButtonControl

@property (nonatomic, retain) IBOutlet NSPopUpButton *dropdownControl;

- (void) selectionChanged:(id)sender;

@end
