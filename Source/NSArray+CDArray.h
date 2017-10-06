// NSArray+CDArray.h
// cocoadialog
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.

#import "NSString+CDString.h"

@interface NSArray (CDArray)

#pragma mark - Properties
@property (readonly) NSArray *doubleQuote;
@property (readonly) NSArray *sortedAlphabetically;

#pragma mark - Public instance methods
- (NSArray *) filterOnly:(Class)className;
- (NSArray *) prependStringsWith:(NSString *)prefix;
- (NSArray *) replaceNullValuesWith:(id)value;
- (NSArray *) sliceFrom:(NSUInteger)from;
- (NSArray *) sliceFrom:(NSUInteger)from to:(NSUInteger)to;

@end
