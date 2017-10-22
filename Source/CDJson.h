// CDJson.h
// cocoadialog
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.

@class CDJson;

#import <Foundation/Foundation.h>

@protocol CDJsonValueProtocol
- (id)jsonValue;
@end

@protocol CDJsonOutputProtocol
- (NSString *)toJSONString;
@end

@interface CDJson : NSObject

+ (NSString *)objectToJSON:(id)object;
+ (NSString *)parseObject:(id)object;

@end

@interface NSArray (CDJson) <CDJsonOutputProtocol, CDJsonValueProtocol>
@end

@interface NSDictionary (CDJson) <CDJsonOutputProtocol, CDJsonValueProtocol>
@end

@interface NSString (CDJson) <CDJsonValueProtocol>
@end
