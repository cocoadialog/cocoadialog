// NSArray+CocoaDialog.h
// cocoadialog
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.

#import "NSString+CocoaDialog.h"

@interface NSArray (CocoaDialog)

#pragma mark - Properties
@property (nonatomic, readonly) NSArray *doubleQuote;
@property (nonatomic, readonly) NSArray *sortedAlphabetically;

#pragma mark - Public instance methods
- (NSArray *) prependStringsWith:(NSString *)prefix;

@end
