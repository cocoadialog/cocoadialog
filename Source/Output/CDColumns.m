// CDColumns.m
// cocoadialog
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.

#import "CDColumns.h"

#pragma mark -
@implementation CDColumns

#pragma mark - Public static methods
+ (NSString *) objectToColumns:(id)object {
    NSMutableArray *output = [NSMutableArray array];

    if ([object isKindOfClass:[NSDictionary class]]) {
        for (NSString *key in object) {
            [output addObject:[NSString stringWithFormat:@"%@:\t%@", key, object[key]]];
        }
    }
    else if ([object isKindOfClass:[NSArray class]]) {
        [output addObject:[object componentsJoinedByString:@" "]];
    }
    else {
        [output addObject:[NSString stringWithFormat:@"%@", object]];
    }
    return [output componentsJoinedByString:@"\n"];
}

+ (NSString *) parseObject:(id)object {
    id value;
    if ([object conformsToProtocol:@protocol(CDColumnsOutputProtocol)]) {
        value = [object toColumnString];
    }
    else {
        value = [object description];
    }
    return value;
}

@end

#pragma mark -
@implementation NSArray (CDColumns)

#pragma mark - Properties
- (id) columnValue {
    NSMutableArray *array = [NSMutableArray array];
    for (id object in self) {
        [array addObject:[CDColumns parseObject:object]];
    }
    return array;
}

- (NSString *) toColumnString {
    return [CDColumns objectToColumns:self.columnValue];
}

@end

#pragma mark -
@implementation NSDictionary (CDColumns)

#pragma mark - Properties
- (id) columnValue {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    NSArray *sortedKeys = self.allKeys.sortedAlphabetically;
    for (NSString *name in sortedKeys) {
        dictionary[name] = [CDColumns parseObject:self[name]];
    }
    return dictionary;
}

- (NSString *) toColumnString {
    return [CDColumns objectToColumns:self.columnValue];
}

@end

#pragma mark -
@implementation NSString (CDColumns)

#pragma mark - Properties
- (NSString *) columnValue {
    return self.removeColor;
}

@end
