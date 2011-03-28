/*
	CDFileDialogControl.m
	CocoaDialog
	Copyright (C) 2004-2006 Mark A. Stratman <mark@sporkstorms.org>
 
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

#import "CDFileDialogControl.h"

@implementation CDFileDialogControl

// You really need to override this. And be sure to
// include the options below
- (NSDictionary *) availableKeys
{
	NSNumber *vMul = [NSNumber numberWithInt:CDOptionsMultipleValues];
	NSNumber *vOne = [NSNumber numberWithInt:CDOptionsOneValue];
	NSNumber *vNone = [NSNumber numberWithInt:CDOptionsNoValues];

	return [NSDictionary dictionaryWithObjectsAndKeys:
		vOne,  @"text",
		vMul,  @"with-extensions",
		vOne,  @"with-directory",
		vOne,  @"with-file",
		vNone, @"packages-as-directories",
		nil];
}

- (NSArray *) extensionsFromOptionKey:(NSString *)key
{
	CDOptions *options = [self options];
	NSArray *extensions = [options optValues:key];
	NSMutableArray *newTypes = nil;
	if (extensions != nil && [extensions count]) {
		// Strip leading '.' from each extension
		newTypes = [NSMutableArray arrayWithCapacity:[extensions count]];
		NSEnumerator *en;
		NSString *extension;
		en = [extensions objectEnumerator];
		while (extension = [en nextObject]) {
			if ([extension length] > 1
			    && [[extension substringWithRange:NSMakeRange(0,1)]
				    isEqualToString:@"."])
			{
				extension = [extension substringFromIndex:1];
			}
			[newTypes addObject:extension];
		}
	}
	return newTypes;
}

// Set options common to any file save panel
- (void) setMisc:(NSSavePanel *)panel
{
	CDOptions *options = [self options];
	// Set title
	if ([options optValue:@"title"] != nil) {
		[panel setTitle:[options optValue:@"title"]];
	}
	// set message displayed on file select panel
	if ([options optValue:@"text"] != nil) {
		[panel setMessage:[options optValue:@"text"]];
	}
}

- (void) dealloc
{
	[super dealloc];
}


@end
