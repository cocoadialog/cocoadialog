/*
	CDOptions.m
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

#import "CDOptions.h"


@implementation CDOptions

- (instancetype) initWithOpts:(NSMutableDictionary *)opts
{
	self = [super init];
	_options = [opts retain];
	return self;
}
- (instancetype) init
{
	return [self initWithOpts:[NSMutableDictionary dictionary]];
}

+ (BOOL) _argIsKey:(NSString *)arg availableKeys:(NSDictionary *)availableKeys depreciatedKeys:(NSDictionary *)depreciatedKeys
{
	if ([arg length] > 2 && [[arg substringWithRange:NSMakeRange(0,2)] isEqualToString:@"--"] &&
        (availableKeys[[arg substringFromIndex:2]] != nil || depreciatedKeys[[arg substringFromIndex:2]] != nil))
	{
		return YES;
	} else {
		return NO;
	}
}

+ (CDOptions *) getOpts:(NSArray *)args availableKeys:(NSDictionary *)availableKeys depreciatedKeys:(NSDictionary *)depreciatedKeys
{
	NSMutableDictionary *options;
	NSString *arg;
	NSMutableArray *values;
	int argType;

	options = [[[NSMutableDictionary alloc] init] autorelease];

	unsigned i = 0;
	while (i < [args count]) {
		arg = args[i];

		// If the arg is a key we specified above...
		if ([CDOptions _argIsKey:arg availableKeys:availableKeys depreciatedKeys:depreciatedKeys]) {
			// strip leading '--'
			arg = [arg substringFromIndex:2];

            // Replace the argument with the newer one if it's depreciated
            NSString * depreciatedArg = depreciatedKeys[arg];
            if (depreciatedArg != nil) {
                arg = depreciatedArg;
            }

            argType = [availableKeys[arg] intValue];

			// If it's a no-value option, store the bool NO to indicate
			// no values for this key, increment i and continue.
			if (argType == CDOptionsNoValues) {
				options[arg] = @NO;
				i++;
				continue;
			}
			// Control reaches here there should be one or more
			// values for key.
            if (argType == CDOptionsMultipleValues) {
                values = [[[NSMutableArray alloc] init] autorelease];
            }
			while (i+1 < [args count]) {
				NSString *nextArg = args[i+1];

				// set single string value for this key,
				// increment i and stop looking for more values
				if (argType == CDOptionsOneValue) {
					options[arg] = nextArg;
					i++;
					break;
				}
				// add a value to the values array
                else if (argType == CDOptionsMultipleValues && ![CDOptions _argIsKey:args[i+1] availableKeys:availableKeys depreciatedKeys:depreciatedKeys]) {
					[values addObject:nextArg];
					i++;

				// Programmer supplied an invalid type for this
				// available key.
				} else {
					break;
				}
			} // End looking for values to add to the key

			// set the array of values for this key
			if (argType == CDOptionsMultipleValues) {
				options[arg] = values;
			}
		} // End "if arg was a key"
		i++;
	} // End processing all args

	return [[[CDOptions alloc] initWithOpts:options] autorelease];
}

+ (void) printOpts:(NSArray *)availableOptions forRunMode:(NSString *)runMode
{
	NSFileHandle *fh = [NSFileHandle fileHandleWithStandardOutput];

	if (fh) {
        [fh writeData:[@"Usage:\tcocoaDialog " dataUsingEncoding:NSUTF8StringEncoding]];
        [fh writeData:[[runMode lowercaseString] dataUsingEncoding:NSUTF8StringEncoding]];
        [fh writeData:[@" [options]\n\tAvailable options:\n" dataUsingEncoding:NSUTF8StringEncoding]];

        NSArray *sortedAvailableKeys = [NSArray arrayWithArray:[availableOptions sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];

        NSEnumerator *en = [sortedAvailableKeys objectEnumerator];
        id key;
        unsigned i = 0;
        unsigned currKey = 0;
        while ((key = [en nextObject])) {
            if (i == 0) {
                [fh writeData:[@"\t\t" dataUsingEncoding:NSUTF8StringEncoding]];
            }
            [fh writeData:[@"--" dataUsingEncoding:NSUTF8StringEncoding]];
            [fh writeData:[key dataUsingEncoding:NSUTF8StringEncoding]];
            if (i <= 6 && currKey != [sortedAvailableKeys count] - 1) {
                [fh writeData:[@", " dataUsingEncoding:NSUTF8StringEncoding]];
                i++;
            }
            if (i == 6 || currKey == [sortedAvailableKeys count] - 1) {
                [fh writeData:[@"\n" dataUsingEncoding:NSUTF8StringEncoding]];
                i = 0;
            }
            currKey++;
        }
        [fh writeData:[@"\nFor detailed documentation, please visit:\nhttp://mstratman.github.com/cocoadialog/#documentation/" dataUsingEncoding:NSUTF8StringEncoding]];
        [fh writeData:[[runMode lowercaseString] dataUsingEncoding:NSUTF8StringEncoding]];
        [fh writeData:[@"_control\n" dataUsingEncoding:NSUTF8StringEncoding]];
        exit(1);
	}
}

- (BOOL) hasOpt:(NSString *)key
{
	return _options[key] != nil;
}
- (NSString *) optValue:(NSString *)key
{
	id value = _options[key];
	// value will be an NSNumber (set in getOpts) if there is no value
	// for that key, NSString of the value, or nil if that key didn't exist
	if (value == nil || ![value isKindOfClass:[NSString class]]) {
		return nil;
	} else {
		return value;
	}
}
- (NSArray *) optValues:(NSString *)key
{
	id value = _options[key];
	if (value == nil || ![value isKindOfClass:[NSArray class]]) {
		return nil;
	} else {
		return value;
	}
}
- (id) optValueOrValues:(NSString *)key
{
	return _options[key];
}


- (NSArray *) allOptions    { return [_options allKeys]; }
- (NSArray *) allOptValues  { return [_options allValues]; }

- (void) setOption:(id)value forKey:(NSString *)key
{
	_options[key] = value;
}

- (void) dealloc
{
	[_options release];
	[super dealloc];
}
@end
