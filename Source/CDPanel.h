// CDPanel.h
// cocoadialog
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.

#ifndef CDPanel_h
#define CDPanel_h

@interface CDPanel : NSWindow <NSWindowDelegate>

@property (nonatomic, retain) NSView* vibrantView;

- (NSArray *) getObjects:(Class)objectClass;
- (NSArray *) getObjects:(Class)objectClass fromView:(NSView *)view;
- (void) makeLargerFontsThinner;

@end


#endif /* CDPanel_h */
