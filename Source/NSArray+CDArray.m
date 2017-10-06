// NSArray+CDArray.m
// cocoadialog
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.

#import "NSArray+CDArray.h"

@implementation NSArray (CDArray)

#pragma mark - Properties
- (NSArray *) doubleQuote {
    NSMutableArray *array = [NSMutableArray array];
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
- (NSArray *) filterOnly:(Class)className {
    NSMutableArray *array = [NSMutableArray array];
    for (id item in self) {
        if ([item isMemberOfClass:className]) {
            [array addObject:item];
        }
    }
    return array.copy;
}
- (NSArray *) prependStringsWith:(NSString *)prefix {
    NSMutableArray *array = [NSMutableArray array];
    for (id item in self) {
        if ([item isKindOfClass:[NSString class]]) {
            NSMutableString *string = [NSMutableString stringWithString:item];
            [string prepend:prefix];
            [array addObject:string];
        }
    }
    return [NSArray arrayWithArray:array];
}

- (NSArray *) replaceNullValuesWith:(id)value {
    NSMutableArray *items = [NSMutableArray array];
    for (id item in self) {
        if (item == [NSNull null]) {
            [items addObject:value];
        }
        else {
            [items addObject:item];
        }
    }
    return items.copy;
}

- (NSArray *) sliceFrom:(NSUInteger)from {
    if (!self.count || from > (self.count - 1)) {
        return @[];
    }
    return [self subarrayWithRange:NSMakeRange(from, self.count - 1)];
}

- (NSArray *) sliceFrom:(NSUInteger)from to:(NSUInteger)to {
    if (from == 0 || from >= (self.count - 1)) {
        return self;
    }
    return [self subarrayWithRange:NSMakeRange(from, MAX(self.count - 1, to))];
}

@end
