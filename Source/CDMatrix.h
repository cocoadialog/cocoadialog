// CDMatrix.h
// cocoadialog
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.

@class CDMatrix;

#import <Foundation/Foundation.h>

#import "CDDialog.h"

@interface CDMatrix : CDDialog

@property(strong) NSMutableArray<NSCell *> *cells;
@property(nonatomic) NSUInteger columns;
@property(nonatomic) BOOL expandColumns;
@property(strong) NSMatrix *matrix;
@property(nonatomic) NSUInteger rows;

- (void)initMatrix;
- (BOOL)isCellSelected:(NSUInteger)index;

@end
