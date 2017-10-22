// CDOptions.h
// cocoadialog
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.

@class CDOptions;

#import <Foundation/Foundation.h>

#import "CDJson.h"
#import "CDOption.h"
#import "CDTerminal.h"

typedef void (^CDOptionsCallback)(CDOption *opt);
typedef void (^CDOptionsSetCallback)(CDOption *opt, NSString *key);

@interface CDOptions : NSDictionary <CDJsonOutputProtocol, CDJsonValueProtocol> {
  NSMutableDictionary<NSString *, CDOption *> *_options;
}

@property(strong) CDOptionsCallback getOptionCallback;
@property(strong) CDOptionsCallback getOptionOnceCallback;
@property(strong) CDOptionsSetCallback setOptionCallback;

@property(copy, readonly) NSArray<NSString *> *allKeys;
@property(copy, readonly) NSArray<CDOption *> *allValues;
@property(nonatomic, readonly) NSMutableArray *arguments;
@property(nonatomic, readonly) NSMutableDictionary<NSString *, CDOption *> *deprecatedOptions;
@property(nonatomic, readonly) NSMutableArray<NSString *> *missingArgumentBreaks;
@property(nonatomic, readonly) NSDictionary<NSString *, CDOptions *> *groupByScope;
@property(nonatomic, readonly) NSMutableArray<NSString *> *invalidValues;
@property(nonatomic, readonly) BOOL processedWithControl;
@property(nonatomic, readonly) NSMutableDictionary<NSString *, CDOption *> *requiredOptions;
@property(nonatomic, readonly) NSMutableArray<NSString *> *seenOptions;
@property(nonatomic, readonly) CDTerminal *terminal;
@property(nonatomic, readonly) NSMutableArray<NSString *> *unknownOptions;

+ (BOOL)isOption:(NSString *)arg;
+ (instancetype)options;
+ (instancetype)sharedInstance;

- (NSString *)getArgument:(unsigned int)index;
- (void)remove:(NSString *)name;

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id __unsafe_unretained[])stackbuf count:(NSUInteger)len;
- (CDOption *)objectForKey:(NSString *)key;
- (CDOption *)objectForKeyedSubscript:(NSString *)key;
- (void)setObject:(CDOption *)opt forKey:(NSString *)key;
- (void)setObject:(CDOption *)opt forKeyedSubscript:(NSString *)key;

- (CDOptions *(^)(NSArray <CDOption *> *))addOptions;
- (CDOptions *(^)(NSString *, NSArray <CDOption *> *))addOptionsToScope;
- (CDOptions *(^)(NSArray *))processArguments;
- (CDOptions *(^)(CDControl *))processWithControl;

@end
