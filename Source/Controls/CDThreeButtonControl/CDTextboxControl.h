// CDTextboxControl.h
// cocoadialog
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.

#import "CDThreeButtonControl.h"

@interface CDTextboxControl : CDThreeButtonControl

@property (nonatomic, retain) IBOutlet  NSTextView      *textView;
@property (nonatomic, retain) IBOutlet  NSScrollView    *scrollView;

- (void) setLabel:(NSString *)labelText;

@end
