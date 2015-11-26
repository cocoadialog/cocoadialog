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

@implementation CDOptions { NSMutableDictionary *_options; }

+ (instancetype) optionsWithDictionary:(NSDictionary *)d { return [self.alloc initWithOpts:d]; }

- initWithOpts:opts
{
  return self = super.init ? _options = opts ? [opts mutableCopy] : @{}.mutableCopy, self : nil;
}

- init { return [self initWithOpts:nil]; }

+ (BOOL) _argIsKey:(NSString *)arg availableKeys:(NSDictionary *)availableKeys depreciatedKeys:(NSDictionary *)depreciatedKeys
{
  return arg.length > 2 && [[arg substringWithRange:(NSRange){0,2}] isEqualToString:@"--"]
                        && (  availableKeys[[arg substringFromIndex:2]]
                        ||  depreciatedKeys[[arg substringFromIndex:2]]);
}

+ (instancetype) getOpts:(NSArray *)args availableKeys:(NSDictionary *)availableKeys depreciatedKeys:(NSDictionary *)depreciatedKeys
{

  NSMutableDictionary *options = @{}.mutableCopy;

  !args ?: [args enumerateObjectsUsingBlock:^(NSString *arg, NSUInteger i, BOOL *stop) {

    // If the arg is a key we specified above...
    if (![self _argIsKey:arg availableKeys:availableKeys depreciatedKeys:depreciatedKeys]) return;

    NSMutableArray *values;

    // strip leading '--'
    arg = [arg substringFromIndex:2];

    // Replace the argument with the newer one if it's depreciated
    arg = depreciatedKeys[arg] ?: arg;

    int argType = [availableKeys[arg] intValue];

    // If it's a no-value option, store the bool NO to indicate no values for this key, increment i and continue.
    if (argType == CDOptionsNoValues) return [options setValue:@NO forKey:arg];

    // Control reaches here there should be one or more values for key.
    if (argType == CDOptionsMultipleValues) values = @[].mutableCopy;

    while (i+1 < args.count) {

      NSString *nextArg = args[i+1];

      // set single string value for this key, increment i and stop looking for more values
      if (argType == CDOptionsOneValue) { options[arg] = nextArg; i++; break; }

      // add a value to the values array
      else if (argType == CDOptionsMultipleValues && ![self.class _argIsKey:args[i+1] availableKeys:availableKeys depreciatedKeys:depreciatedKeys]) {

        [values addObject:nextArg]; i++;

        // Programmer supplied an invalid type for this available key.

      } else break;

    } // End looking for values to add to the key

    // set the array of values for this key
    if (argType == CDOptionsMultipleValues) options[arg] = values;

  }]; // End processing all args

  return [CDOptions.alloc initWithOpts:options];
}

+ (void) printOpts:(NSArray *)availableOptions forRunMode:(NSString *)runMode
{
  #define WRITE(X) [NSFileHandle.fileHandleWithStandardOutput writeData:[X dataUsingEncoding:NSUTF8StringEncoding]]

  if (!NSFileHandle.fileHandleWithStandardOutput) return;

  WRITE(@"Usage:\tcocoaDialog ");
  WRITE(runMode.lowercaseString);
  WRITE(@" [options]\n\tAvailable options:\n");

  NSArray *sortedAvailableKeys = [NSArray arrayWithArray:[availableOptions sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];

  __block unsigned i = 0, currKey = 0;
  [sortedAvailableKeys enumerateObjectsUsingBlock:^(id key, NSUInteger idx, BOOL *stop) {

    if (!i) WRITE(@"\t\t");

    WRITE(@"--");
    WRITE(key);

    if (i <= 6 && currKey != [sortedAvailableKeys count] - 1) {
      WRITE(@", ");
      i++;
    }

    if (i == 6 || currKey == [sortedAvailableKeys count] - 1) {
      WRITE(@"\n");
      i = 0;
    }
    currKey++;
  }];

  WRITE(({[NSString stringWithFormat:@"\nFor detailed documentation, please visit:\nhttp://mstratman.github.com/cocoadialog/#documentation/\n%@\n_control\n", runMode.lowercaseString];}));
  exit(1);
}

- (BOOL) hasOpt:(NSString*)key { return !!_options[key]; }

- (NSString*) optValue:(NSString*)key {

  id value = _options[key];
  // value will be an NSNumber (set in getOpts) if there is no value for that key, NSString of the value, or nil if that key didn't exist
  return value || [value isKindOfClass:NSString.class] ? value : nil;
}

- (NSArray*) optValues:(NSString*)key {

  id value = _options[key];
  return value && [value isKindOfClass:NSArray.class] ? value : nil;
}

- optValueOrValues:(NSString*)key { return _options[key]; }
- (NSArray*) allOptions           { return _options.allKeys; }
- (NSArray*) allOptValues         { return _options.allValues; }

- (void) setOption:val forKey:(NSString*)key { _options[key] = val; }

/// Keyed subscript protocol implementation

- (void) setObject:val forKeyedSubscript:(id<NSCopying>)key { [self setOption:val forKey:key]; }

- objectForKeyedSubscript:(id<NSCopying>)key { return [self optValue:key]; }

@end
