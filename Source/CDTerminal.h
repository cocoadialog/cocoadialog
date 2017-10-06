// CDTerminal.h
// cocoadialog
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.

#import "NSArray+CDArray.h"
#import "NSString+CDString.h"

@interface CDTerminal : NSObject {
    NSFileHandle        *fhErr;
    NSFileHandle        *fhOut;
    NSFileHandle        *fhIn;
    NSMutableDictionary *which;
}

#pragma mark - Properties
@property (readonly) NSUInteger     colors;
@property (readonly) NSUInteger     cols;
@property (readonly) BOOL           isCLI;
@property (readonly) BOOL           supportsColor;

#pragma mark - Public static methods
+ (instancetype) terminal;

#pragma mark - Public instance methods
- (NSUInteger) colsWithMinimum:(NSUInteger)minimum;
- (NSString *) execute:(NSString *)command withArguments:(NSArray *)arguments;
- (NSArray *) getArguments;
- (void) write:(NSString *)string;
- (void) writeLine:(NSString *)string;
- (void) writeNewLine;
- (void) writeError:(NSString *)string;
- (void) writeErrorLine:(NSString *)string;
- (void) writeErrorNewLine;
- (NSString *) which:(NSString *)command;

@end
