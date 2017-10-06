// CDTemplate.h
// cocoadialog
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.

#import "CDTextField.h"
#import <GRMustache/GRMustache.h>

#ifndef CDTemplate_h
#define CDTemplate_h

@interface CDTemplate : CDTextField

@property (strong)      id                                      data;
@property (strong)      GRMustacheTemplateRepository            *repository;
@property (strong)      GRMustacheTemplate                      *tpl;

+ (instancetype) load:(NSString *)templateName data:(id)data error:(NSError **)error;

- (NSString *) renderError:(NSError **)error;

@end


#endif /* CDTemplate_h */

