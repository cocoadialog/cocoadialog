// CDProgressbarView.h
// cocoadialog
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.

@class CDProgressbarView;

#import <Foundation/Foundation.h>

#import "CDControlView.h"

@interface CDProgressbarView : CDControlView

# pragma mark - Properties

@property(nonatomic) IBInspectable BOOL indeterminate;
@property(nonatomic, strong) IBOutlet NSButton *stopButton;
@property(nonatomic, strong) NSArray <NSString *> *labels;
@property(nonatomic, strong) IBOutlet NSTextField *primaryLabel;
@property(nonatomic, strong) IBOutlet NSProgressIndicator *progressbar;
@property(nonatomic, strong) IBOutlet NSLayoutConstraint *progressbarBottomConstraint;
@property(nonatomic, strong) IBOutlet NSLayoutConstraint *progressbarTopConstraint;
@property(nonatomic, strong) IBOutlet NSTextField *secondaryLabel;
@property(nonatomic) BOOL stopped;
@property(nonatomic) IBInspectable BOOL stoppable;
@property(nonatomic) IBInspectable double value;

@end
