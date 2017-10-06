// CDRadio.h
// cocoadialog
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.

#import "CDMatrix.h"

@interface CDRadio : CDMatrix

# pragma mark - Properties
@property (strong)                   NSArray                 *disabled;
@property (strong)                   NSArray                 *items;
@property (strong)                   NSArray                 *mixed;
@property (strong)                   NSMutableArray          *radios;

@end
