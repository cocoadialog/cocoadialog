// CDTextbox.h
// cocoadialog
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.

@class CDTextbox;

#import "CDDialog.h"
#import "CDTextView.h"

@interface CDTextbox : CDDialog

@property (retain)       CDTextView      *textView;

@end
