// CDView.h
// cocoadialog
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.

#ifndef CDView_h
#define CDView_h

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import "CDDialog.h"

@interface CDControlView : NSView;

@property (strong)   IBOutlet    NSView      *contentView;
@property (strong)               CDDialog    *dialog;

+ (instancetype) initWithDialog:(CDDialog *)dialog;
- (instancetype) initWithDialog:(CDDialog *)dialog;
- (void) initView;

@end

#endif /* CDView_h */
