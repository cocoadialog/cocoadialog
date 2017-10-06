// CDOptions.h
// cocoadialog
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.

#import "NSString+CDString.h"
#import "CDJson.h"
#import "CDOption.h"

@interface CDOptions : NSDictionary <CDJsonOutputProtocol, CDJsonValueProtocol>

#pragma mark - Properties
@property (copy) void (^getOptionCallback)(CDOption *opt);
@property (copy) void (^getOptionOnceCallback)(CDOption *opt);
@property (copy) void (^setOptionCallback)(CDOption *opt, NSString *key);
@property (retain) NSString *defaultCategory;
@property (retain) NSMutableArray <NSString *> *seenOptions;

#pragma mark - Properties (readonly)
@property (copy, readonly) NSArray<NSString *> *allKeys;
@property (copy, readonly) NSArray<CDOption *> *allValues;
@property (retain, readonly) NSMutableArray *arguments;
@property (retain, readonly) NSMutableDictionary <NSString *, CDOption *> *deprecatedOptions;
@property (retain, readonly) NSMutableArray <NSString *> *missingArgumentBreaks;
@property (retain, readonly) NSMutableDictionary <NSString *, CDOption *> *options;
@property (retain, readonly) NSDictionary <NSString *, CDOptions *> *groupByCategories;
@property (retain, readonly) NSMutableArray <NSString *> *invalidValues;
@property (retain, readonly) NSMutableDictionary <NSString *, CDOption *> *requiredOptions;
@property (retain, readonly) NSMutableArray <NSString *> *unknownOptions;

#pragma mark - Pubic static methods
+ (instancetype) options;

#pragma mark - Pubic instance methods
- (void) add:(CDOption *) opt;
- (NSString *) getArgument:(unsigned int) index;
- (CDOptions *) processArguments:(NSArray *)arguments;
- (void) remove:(NSString *) name;

#pragma mark - Enumeration
- (NSUInteger) countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id __unsafe_unretained [])stackbuf count:(NSUInteger)len;
- (CDOption *) objectForKey:(NSString *)key;
- (CDOption *) objectForKeyedSubscript:(NSString *)key;
- (void) setObject:(CDOption *)opt forKey:(NSString*)key;
- (void) setObject:(CDOption *)opt forKeyedSubscript:(NSString*)key;

@end
