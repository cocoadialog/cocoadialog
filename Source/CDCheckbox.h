// CDCheckbox.h
// cocoadialog
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.

@class CDCheckbox;

#import <Foundation/Foundation.h>

#import "CDMatrix.h"

@interface CDCheckbox : CDMatrix

@property(strong) NSMutableArray *checkboxes;
@property(strong) NSArray *checked;
@property(strong) NSArray *disabled;
@property(strong) NSArray *items;
@property(strong) NSArray *mixed;

@end
