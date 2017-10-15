// CDJson.h
// cocoadialog
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.

@class CDJson;

#pragma mark -
@protocol CDJsonValueProtocol
- (id) jsonValue;
@end

#pragma mark -
@protocol CDJsonOutputProtocol
- (NSString *) toJSONString;
@end

#pragma mark -
@interface CDJson : NSObject

#pragma mark - Public static methods
+ (NSString *) objectToJSON:(id)object;
+ (NSString *) parseObject:(id)object;

@end

#pragma mark -
@interface NSArray (CDJson) <CDJsonOutputProtocol, CDJsonValueProtocol> @end

#pragma mark -
@interface NSDictionary (CDJson) <CDJsonOutputProtocol, CDJsonValueProtocol> @end

#pragma mark -
@interface NSString (CDJson) <CDJsonValueProtocol> @end
