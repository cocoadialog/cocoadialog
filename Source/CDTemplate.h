// CDTemplate.h
// cocoadialog
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.

@class CDTemplate;

#import <Foundation/Foundation.h>
#import <GRMustache/GRMustache.h>

#import "CDTextField.h"
#import "CDTerminal.h"

@interface CDTemplate : NSObject

@property(strong) id data;
@property(strong) GRMustacheTemplateRepository *repository;
@property(strong) NSMutableDictionary <NSString *, GRMustacheTemplate *> *templates;
@property(strong) CDTerminal *terminal;

+ (instancetype)sharedInstance;

- (NSString *(^)(NSString *name, id data))render;

@end
