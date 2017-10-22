// NSArray+CDArray.m
// cocoadialog
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.

#import "NSArray+CDArray.h"
#import "NSString+CDString.h"

@implementation NSArray (CDArray)

- (NSArray *)doubleQuote {
  NSMutableArray *array = [NSMutableArray array];
  for (NSString *item in self) {
    if ([item isKindOfClass:NSString.class]) {
      [array addObject:item.doubleQuote];
    }
  }
  return [NSArray arrayWithArray:array];
}

- (NSArray *)filterEmpty {
  NSMutableArray *filtered = @[].mutableCopy;
  for (id item in self) {
    if (
      [item isKindOfClass:NSNull.class] ||
        ([item isKindOfClass:NSNumber.class] && ((NSNumber *) item).unsignedIntegerValue == 0) ||
        ([item isKindOfClass:NSString.class] && ((NSString *) item).isBlank) ||
        ([item isKindOfClass:NSArray.class] && ((NSArray *) item).count == 0) ||
        ([item isKindOfClass:NSDictionary.class] && ((NSDictionary *) item).count == 0)
      ) {
      continue;
    }
    [filtered addObject:item];
  }
  return filtered;
}

- (NSArray *)parseCallStackSymbols {
  NSArray *callStackSymbols = [self sliceFrom:1];
  NSMutableArray *array = @[].mutableCopy;
  for (NSString *item in callStackSymbols) {
    NSArray<NSString *> *itemArray = [item componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" -[]+?.,"]].filterEmpty;
    // Ignore this project's classes.
    if (
      [itemArray[3] hasPrefix:@"CDLocale"] ||
        [itemArray[3] hasPrefix:@"NSArray(CD"] ||
        [itemArray[3] hasPrefix:@"NSNumber(CD"] ||
        [itemArray[3] hasPrefix:@"NSPanel(CD"] ||
        [itemArray[3] hasPrefix:@"NSString(CD"]
      ) {
      continue;
    }
    [array addObject:itemArray];
  }
  return array[0];
}

- (NSArray *)sortedAlphabetically {
  return [self sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
}

- (NSArray *)filterOnly:(Class)className {
  NSMutableArray *array = [NSMutableArray array];
  for (id item in self) {
    if ([item isMemberOfClass:className]) {
      [array addObject:item];
    }
  }
  return array.copy;
}
- (NSArray *)prependStringsWith:(NSString *)prefix {
  NSMutableArray *array = [NSMutableArray array];
  for (id item in self) {
    if ([item isKindOfClass:NSString.class]) {
      NSMutableString *string = [NSMutableString stringWithString:item];
      [string prepend:prefix];
      [array addObject:string];
    }
  }
  return [NSArray arrayWithArray:array];
}

- (NSArray *)replaceNullValuesWith:(id)value {
  NSMutableArray *items = [NSMutableArray array];
  for (id item in self) {
    if (item == NSNull.null) {
      [items addObject:value];
    }
    else {
      [items addObject:item];
    }
  }
  return items.copy;
}

- (NSArray *)sliceFrom:(NSUInteger)from {
  if (!self.count || from > (self.count - 1)) {
    return @[];
  }
  return [self subarrayWithRange:NSMakeRange(from, self.count - 1)];
}

- (NSArray *)sliceFrom:(NSUInteger)from to:(NSUInteger)to {
  if (from == 0 || from >= (self.count - 1)) {
    return self;
  }
  return [self subarrayWithRange:NSMakeRange(from, MAX(self.count - 1, to))];
}

- (NSString *(^)(NSString *string))join {
  return ^NSString *(NSString *delimiter) {
    return [self componentsJoinedByString:delimiter];
  };
}

@end
