/*
	CDOptions.h
	CocoaDialog
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
// This is limiting in that the value associated with a key may not be a key
// itself.  Example: You cannot do "... --text --no-cancel ..." and expect the
// @"text" option to contain @"--no-cancel"

@interface CDOptions : NSObject {
	NSMutableDictionary *_options;
}

// availableKeys should be an NSString key, and an NSNumber int value using
// one of the constants defined above.
+ (CDOptions *) getOpts:(NSArray *)args 
	  availableKeys:(NSDictionary *)availableKeys;
+ (void)printOpts:(NSArray *)availableOptions forRunMode:(NSString *)runMode;

- (BOOL) hasOpt:(NSString *)key;
- (NSString *) optValue:(NSString *)key;
- (NSArray *) optValues:(NSString *)key;
- (id) optValueOrValues:(NSString *)key;
- (NSArray *) allOptions;
- (NSArray *) allOptValues;

- (void) setOption:(id)value forKey:(NSString *)key;

@end
