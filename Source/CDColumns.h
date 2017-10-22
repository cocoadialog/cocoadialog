// CDColumns.h
// cocoadialog
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.

@class CDColumns;

#import <Foundation/Foundation.h>

@protocol CDColumnsValueProtocol
- (id)columnValue;
@end

@protocol CDColumnsOutputProtocol
- (NSString *)toColumnString;
@end

@interface CDColumns : NSObject
+ (NSString *)objectToColumns:(id)object;
+ (NSString *)parseObject:(id)object;
@end

@interface NSArray (CDColumns) <CDColumnsOutputProtocol, CDColumnsValueProtocol>
@end


@interface NSDictionary (CDColumns) <CDColumnsOutputProtocol, CDColumnsValueProtocol>
@end


@interface NSString (CDColumns) <CDColumnsValueProtocol>
@end
