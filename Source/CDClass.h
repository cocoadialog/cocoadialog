// CDClass.h
// cocoadialog
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.
@class CDClass;

#import <Foundation/Foundation.h>

@interface CDClass : NSObject

@property(assign, readonly) Class class;
@property(assign, readonly) Protocol *protocol;

+ (CDClass *(^)(Class aClass))create;
+ (instancetype)init NS_UNAVAILABLE;
+ (instancetype)initWithClass:(Class)class;
- (CDClass *(^)(NSString *aProtocol))ensureProtocol;
- (id(^)(SEL aSelector, ...))methodForSelector;

@end
