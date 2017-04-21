// CDJson.h
// cocoadialog
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.

#import "NSString+CocoaDialog.h"
#import "CDTerminal.h"

#ifndef CDJson_h
#define CDJson_h

#pragma mark -
@protocol CDJsonProtocol

#pragma mark - Properties
- (id) jsonValue;
- (NSString *) toJSONString;

@end

#pragma mark -
@interface CDJson : NSObject

#pragma mark - Public static methods
+ (NSString *) objectToJSON:(id)object;
+ (NSString *) parseObject:(id)object;

@end

#pragma mark -
@interface NSArray (CDJson) <CDJsonProtocol> @end

#pragma mark -
@interface NSDictionary (CDJson) <CDJsonProtocol> @end

#endif /* CDJson_h */
