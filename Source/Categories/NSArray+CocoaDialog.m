// NSArray+CocoaDialog.m
// cocoadialog
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.

#import "NSArray+CocoaDialog.h"

@implementation NSArray (CocoaDialog)

#pragma mark - Properties
- (NSArray *) doubleQuote {
    NSMutableArray *array = [[[NSMutableArray alloc] init] autorelease];
    for (NSString *item in self) {
        if ([item isKindOfClass:[NSString class]]) {
            [array addObject:item.doubleQuote];
        }
    }
    return [NSArray arrayWithArray:array];
}

- (NSArray *) sortedAlphabetically {
    return [self sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
}

#pragma mark - Public instance methods
- (NSArray *) prependStringsWith:(NSString *)prefix {
    NSMutableArray *array = [[[NSMutableArray alloc] init] autorelease];
    for (id item in self) {
        if ([item isKindOfClass:[NSString class]]) {
            NSMutableString *string = [NSMutableString stringWithString:item];
            [string prepend:prefix];
            [array addObject:string];
        }
    }
    return [NSArray arrayWithArray:array];
}

@end
