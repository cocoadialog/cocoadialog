// CDTextField.m
// cocoadialog
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.

#import "CDTextField.h"
#import "CDControl.h"

@implementation CDTextField

- (instancetype)initWithCoder:(NSCoder *)coder {
  self = [super initWithCoder:coder];
  if (self) {
    [self customInit];
  }
  return self;
}

- (instancetype)initWithFrame:(NSRect)frameRect {
  self = [super initWithFrame:frameRect];
  if (self) {
    [self customInit];
  }
  return self;
}

- (void)customInit {
  _markdown = [CDMarkdown markdown];
}

- (void)setStringValue:(NSString *)stringValue {
  [super setStringValue:stringValue];

  // Immediately return if markdown is not enabled.
  if (!self.markdown.enabled) {
    return;
  }

  // Ensure clicking with mouse doesn't remove the attributes.
  if (!self.allowsEditingTextAttributes) {
    self.allowsEditingTextAttributes = YES;
  }

  self.attributedStringValue = [self.markdown parseString:stringValue];
  self.needsDisplay = YES;
}

- (void)setSelectable:(BOOL)selectable {
  // Enforce labels that have links to be selectable (otherwise they will not work).
  if (self.markdown.hasLinks) {
    selectable = YES;
  }
  [super setSelectable:selectable];
}

@end
