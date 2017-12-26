// CDTextView.m
// cocoadialog
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.

#import "CDTextView.h"

@implementation CDTextView

- (void)initView {
  self.markdown = [CDMarkdown markdown];
  self.markdown.headerFontSizeMultiplier = 1;
  self.markdown.headerColor = [NSColor lightGrayColor];

  // Editable.
  self.textView.editable = self.dialog.options[@"editable"].boolValue;

  // Set initial text in textview.
  NSAttributedString *text;
  if (self.dialog.options[@"value"].wasProvided) {
    text = [[NSAttributedString alloc] initWithString:self.dialog.options[@"value"].stringValue];
    [self.textView.textStorage setAttributedString:text];
  }
  else if (self.dialog.options[@"file"].wasProvided) {
    NSError *error;
    NSString *file = self.dialog.options[@"file"].stringValue;
    NSString *contents = [NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:&error];
    if (error) {
      self.dialog.terminal.error(@"%@", error.localizedDescription, nil).exit(CDTerminalExitCodeControlFailure);
    }
    if (contents == nil) {
      self.dialog.terminal.warning(@"Could not read file: %@", file.doubleQuote.white.bold, nil);
      return;
    }
    if (([file endsWith:@"md"] || [file endsWith:@"markdown"]) && self.dialog.options[@"markdown"].boolValue && !self.dialog.options[@"editable"].boolValue) {
      text = [self.markdown parseString:contents];
    }
    else {
      text = [[NSAttributedString alloc] initWithString:contents];
    }
    [self.textView.textStorage setAttributedString:text];
  }
  else {
    [self.textView.textStorage setAttributedString:[[NSAttributedString alloc] initWithString:@""]];
  }

  // scroll to top or bottom (do this AFTER resizing, setting the text,
  // etc). Default is top
  if (self.dialog.options[@"scroll-to"].wasProvided && [self.dialog.options[@"scroll-to"].stringValue isEqualToStringCaseInsensitive:@"bottom"]) {
    [self.textView scrollRangeToVisible:NSMakeRange(self.textView.textStorage.length - 1, 0)];
  }
  else {
    [self.textView scrollRangeToVisible:NSMakeRange(0, 0)];
  }

  // select all the text
  if (self.dialog.options[@"selected"].boolValue) {
    [self.textView setSelectedRange:NSMakeRange(0, self.textView.textStorage.length)];
  }
}

@end
