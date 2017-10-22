// NSArray+CDArray.h
// cocoadialog
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.

#import <Foundation/Foundation.h>

@interface NSArray (CDArray)

@property(readonly) NSArray *doubleQuote;
@property(readonly) NSArray *filterEmpty;
@property(readonly) NSArray *parseCallStackSymbols;
@property(readonly) NSArray *sortedAlphabetically;

- (NSArray *)filterOnly:(Class)className;
- (NSArray *)prependStringsWith:(NSString *)prefix;
- (NSArray *)replaceNullValuesWith:(id)value;
- (NSArray *)sliceFrom:(NSUInteger)from;
- (NSArray *)sliceFrom:(NSUInteger)from to:(NSUInteger)to;

- (NSString *(^)(NSString *string))join;

@end
