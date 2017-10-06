// CDTextView.h
// cocoadialog
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.

#ifndef CDTextView_h
#define CDTextView_h

#import "CDControlView.h"
#import "CDMarkdown.h"

@interface CDTextView : CDControlView

@property (strong)                   CDMarkdown         *markdown;
@property (strong)          IBOutlet NSScrollView       *scrollView;
@property (strong) 	        IBOutlet NSTextView         *textView;

@end

#endif /* CDTextView_h */
