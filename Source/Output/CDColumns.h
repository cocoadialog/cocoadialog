// CDColumns.h
// cocoadialog
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.

#import "NSArray+CocoaDialog.h"
#import "NSString+CocoaDialog.h"
#import "CDTerminal.h"

#ifndef CDColumns_h
#define CDColumns_h

#pragma mark -
@protocol CDColumnsValueProtocol
- (id) columnValue;
@end

#pragma mark -
@protocol CDColumnsOutputProtocol
- (NSString *) toColumnString;
@end

#pragma mark -
@interface CDColumns : NSObject

#pragma mark - Public static methods
+ (NSString *) objectToColumns:(id)object;
+ (NSString *) parseObject:(id)object;

@end

#pragma mark -
@interface NSArray (CDColumns) <CDColumnsOutputProtocol, CDColumnsValueProtocol> @end

#pragma mark -
@interface NSDictionary (CDColumns) <CDColumnsOutputProtocol, CDColumnsValueProtocol> @end

#pragma mark -
@interface NSString (CDColumns) <CDColumnsValueProtocol> @end

#endif /* CDColumns_h */
