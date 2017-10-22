// CDDropdownControl.h
// cocoadialog
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.

@class CDDropdown;

#import <Foundation/Foundation.h>

#import "CDDialog.h"

@interface CDDropdown : CDDialog

@property(retain) IBOutlet NSPopUpButton *dropdownControl;

- (void)selectionChanged:(id)sender;

@end
