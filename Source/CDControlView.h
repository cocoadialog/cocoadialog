// CDView.h
// cocoadialog
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.

@class CDControlView;

#import <Foundation/Foundation.h>

#import "CDDialog.h"

@interface CDControlView : NSView;

@property(strong) IBOutlet    NSView *contentView;
@property(strong) CDDialog *dialog;

+ (instancetype)initWithDialog:(CDDialog *)dialog;
- (instancetype)initWithDialog:(CDDialog *)dialog;
- (void)initView;

@end
