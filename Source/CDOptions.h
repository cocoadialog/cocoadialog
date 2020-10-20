#ifdef CD_HEAD
// CDOptions.h
// cocoadialog
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.

@class CDOptions;

#import "CDJson.h"
#import "CDOption.h"
#import "CDTerminal.h"

#pragma mark - Type definitions
typedef void (^CDOptionsCallback)(CDOption *opt);
typedef void (^CDOptionsSetCallback)(CDOption *opt, NSString *key);

@interface CDOptions : NSDictionary <CDJsonOutputProtocol, CDJsonValueProtocol>

#pragma mark - Properties
@property (strong)                  CDOptionsCallback                               getOptionCallback;
@property (strong)                  CDOptionsCallback                               getOptionOnceCallback;
@property (strong)                  CDOptionsSetCallback                            setOptionCallback;

#pragma mark - Properties (readonly)
@property (copy, readonly)          NSArray<NSString *>*                            allKeys;
@property (copy, readonly)          NSArray<CDOption *>*                            allValues;
@property (nonatomic, readonly)     NSMutableArray*                                 arguments;
@property (nonatomic, readonly)     NSMutableDictionary<NSString*,CDOption*>*       deprecatedOptions;
@property (nonatomic, readonly)     NSMutableArray<NSString*>*                      missingArgumentBreaks;
@property (nonatomic, readonly)     NSMutableDictionary<NSString*,CDOption*>*       options;
@property (nonatomic, readonly)     NSDictionary<NSString*,CDOptions*>*             groupByScope;
@property (nonatomic, readonly)     NSMutableArray<NSString*>*                      invalidValues;
@property (nonatomic, readonly)     BOOL                                            processedTerminalArguments;
@property (nonatomic, readonly)     BOOL                                            processedWithControl;
@property (nonatomic, readonly)     NSMutableDictionary<NSString*,CDOption*>*       requiredOptions;
@property (nonatomic, readonly)     NSMutableArray<NSString*>*                      seenOptions;
@property (nonatomic, readonly)     CDTerminal*                                     terminal;
@property (nonatomic, readonly)     NSMutableArray<NSString*>*                      unknownOptions;

#pragma mark - Pubic static methods
+ (BOOL) isOption:(NSString *)arg;
+ (instancetype) options;
+ (instancetype) sharedInstance;

#pragma mark - Pubic instance methods
- (NSString *) getArgument:(unsigned int) index;
- (void) remove:(NSString *) name;

#pragma mark - Enumeration
- (NSUInteger) countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id __unsafe_unretained [])stackbuf count:(NSUInteger)len;
- (CDOption *) objectForKey:(NSString *)key;
- (CDOption *) objectForKeyedSubscript:(NSString *)key;
- (void) setObject:(CDOption *)opt forKey:(NSString*)key;
- (void) setObject:(CDOption *)opt forKeyedSubscript:(NSString*)key;

#pragma mark - Public chainable methods
- (CDOptions *(^)(NSArray <CDOption *> *)) addOptions;
- (CDOptions *(^)(NSString *, NSArray <CDOption *> *)) addOptionsToScope;
- (CDOptions *(^)(void)) processTerminalArguments;
- (CDOptions *(^)(CDControl *)) processWithControl;
#else
/*
	CDOptions.h
	cocoaDialog
	Copyright (C) 2004 Mark A. Stratman <mark@sporkstorms.org>

	This program is free software; you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation; either version 2 of the License, or
	(at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program; if not, write to the Free Software
	Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
*/

#import <Foundation/Foundation.h>

#define CDOptionsNoValues       0
#define CDOptionsOneValue       1
#define CDOptionsMultipleValues 2

// Simple wrapper for commandline options.
// Easily used with [CDOptions getOpts:[[NSProcessInfo processInfo] arguments]]

@interface CDOptions : NSObject {
	NSMutableDictionary *_options;
}

// availableKeys should be an NSString key, and an NSNumber int value using
// one of the constants defined above.
+ (CDOptions *) getOpts:(NSArray *)args availableKeys:(NSDictionary *)availableKeys depreciatedKeys:(NSDictionary *)depreciatedKeys;
+ (void)printOpts:(NSArray *)availableOptions forRunMode:(NSString *)runMode;

- (BOOL) hasOpt:(NSString *)key;
- (NSString *) optValue:(NSString *)key;
- (NSArray *) optValues:(NSString *)key;
- (id) optValueOrValues:(NSString *)key;
- (NSArray *) allOptions;
- (NSArray *) allOptValues;

- (void) setOption:(id)value forKey:(NSString *)key;
#endif

/* */
- (NSComparisonResult)localizedCaseInsensitiveCompare:(NSString *)string;

@end /* This is the end of the same interface from both halves of the ifdef */

/* EOF */
