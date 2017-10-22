// CDMarkdown.h
// cocoadialog
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.

@class CDMarkdown;

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import <TSMarkdownParser/TSMarkdownParser.h>

@interface CDMarkdown : NSObject

@property BOOL hasLinks;
@property BOOL enabled;
@property BOOL newFontWeights;
@property(strong) NSColor *headerColor;
@property double headerFontSizeMultiplier;
@property NSFontWeight headerFontWeight;
@property float minimumHeaderFontSize;
@property(strong) TSMarkdownParser *parser;

+ (instancetype)markdown;

- (NSAttributedString *)parseString:(NSString *)string;

@end
