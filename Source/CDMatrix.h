// CDMatrix.h
// cocoadialog
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.

@class CDMatrix;

#import "CDDialog.h"

@interface CDMatrix : CDDialog

#pragma mark - Properties
@property (strong)                   NSMutableArray<NSCell *>            *cells;
@property (nonatomic)                NSUInteger                          columns;
@property (nonatomic)                BOOL                                expandColumns;
@property (strong)                   NSMatrix                            *matrix;
@property (nonatomic)                NSUInteger                          rows;

#pragma mark - Public instance methods
- (void) initMatrix;
- (BOOL) isCellSelected:(NSUInteger)index;

@end
