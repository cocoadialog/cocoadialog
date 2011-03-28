/*
	CDBubbleControl.m
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

#import "CDBubbleControl.h"
#import "KABubbleWindowController.h"

@implementation CDBubbleControl

- (NSDictionary *) availableKeys
{
	NSNumber *vOne = [NSNumber numberWithInt:CDOptionsOneValue];
	NSNumber *vNone = [NSNumber numberWithInt:CDOptionsNoValues];
	NSNumber *vMul = [NSNumber numberWithInt:CDOptionsMultipleValues];

	return [NSDictionary dictionaryWithObjectsAndKeys:
		// Options for one bubble
		vOne, @"text",
		vOne, @"title",
		vOne, @"icon",
		vOne, @"icon-file",
		vOne, @"text-color",
		vOne, @"border-color",
		vOne, @"background-top",
		vOne, @"background-bottom",

		// Options for multiple bubble
		vMul, @"texts",
		vMul, @"titles",
		vMul, @"icons",      // Multiple bubbles can also use --icon or
		vMul, @"icon-files", // --icon-file.
		vMul, @"text-colors",
		vMul, @"border-colors",
		vMul, @"background-tops",
		vMul, @"background-bottoms",
		vNone, @"independent", // With this set, clicking one 
		                       // bubble won't kill the rest.

		// General options, apply to all scenarios
		vOne, @"x-placement",
		vOne, @"y-placement",
		vOne, @"alpha",
		vOne, @"timeout",
		vNone, @"no-timeout", // Times out by default, this prevents it.
		nil];
}

- (NSArray *) runControlFromOptions:(CDOptions *)options
{
	float timeout = 4.;
	float alpha = 0.95;
	int position = 0;

	[self setOptions:options];
	activeBubbles = [[NSMutableArray array] retain];
	fadingBubbles = [[NSMutableArray array] retain];
	
	if ([options hasOpt:@"x-placement"]) {
		NSString *xplace = [options optValue:@"x-placement"];
		if ([xplace isEqualToString:@"left"]) {
			position |= BUBBLE_HORIZ_LEFT;
		} else if ([xplace isEqualToString:@"center"]) {
			position |= BUBBLE_HORIZ_CENTER;
		} else {
			position |= BUBBLE_HORIZ_RIGHT;
		}
	} else {
		position |= BUBBLE_HORIZ_RIGHT;
	}
	if ([options hasOpt:@"y-placement"]) {
		NSString *yplace = [options optValue:@"y-placement"];
		if ([yplace isEqualToString:@"bottom"]) {
			position |= BUBBLE_VERT_BOTTOM;
		} else if ([yplace isEqualToString:@"center"]) {
			position |= BUBBLE_VERT_CENTER;
		} else {
			position |= BUBBLE_VERT_TOP;
		}
	} else {
		position |= BUBBLE_VERT_TOP;
	}	

	if ([options hasOpt:@"timeout"]) {
		if (![[NSScanner scannerWithString:[options optValue:@"timeout"]] scanFloat:&timeout]) {
			[CDControl debug:@"Could not parse the timeout option."];
			timeout = 4.;
		}
	}

	if ([options hasOpt:@"alpha"]) {
		if (![[NSScanner scannerWithString:[options optValue:@"alpha"]] scanFloat:&alpha]) {
			[CDControl debug:@"Could not parse the alpha option."];
			timeout = .95;
		}
	}

	NSArray *texts = [options optValues:@"texts"];
	NSArray *titles = [options optValues:@"titles"];

	// Multiple bubbles
	if (texts != nil && [texts count]
	    && titles != nil && [titles count]
	    && [titles count] == [texts count])
	{
		NSArray *givenIconImages = [self _iconImages];
		NSImage *fallbackIcon = nil;
		NSMutableArray *icons = nil;
		int i;
		// See what icons we got at the command line, or set a fallback
		// icon to use for all bubbles
		if (givenIconImages == nil) {
			fallbackIcon = [self _iconImage];
		} else {
			icons = [NSMutableArray arrayWithArray:givenIconImages];
		}
		// If we were given less icons than we have bubbles, use a default
		// for any extra bubbles
		if ([icons count] < [texts count]) {
			NSImage *defaultIcon = [self _iconImage];
			int numToAdd = [texts count] - [icons count];
			for (i = 0; i < numToAdd; i++) {
				[icons addObject:defaultIcon];
			}
		}
		// Create the bubbles
		for (i = 0; i < [texts count]; i++) {
			NSString *text  = [texts objectAtIndex:i];
			NSString *title = [titles objectAtIndex:i];
			NSImage *icon = fallbackIcon == nil ? (NSImage *)[icons objectAtIndex:i] : fallbackIcon;
			KABubbleWindowController *bubble = [KABubbleWindowController
				bubbleWithTitle:title text:text
				icon:icon
				timeout:timeout
				lightColor:[self _colorForBubble:i fromKey:@"background-tops" alpha:alpha]
				darkColor:[self _colorForBubble:i fromKey:@"background-bottoms" alpha:alpha]
				textColor:[self _colorForBubble:i fromKey:@"text-colors" alpha:alpha]
				borderColor:[self _colorForBubble:i fromKey:@"border-colors" alpha:alpha]
				numExpectedBubbles:[texts count]
				bubblePosition:position];
			
			[bubble setAutomaticallyFadesOut:(![options hasOpt:@"no-timeout"])];
			[bubble setDelegate:self];
			[activeBubbles addObject:bubble];
			[bubble startFadeIn];
		}

	// Single bubble
	} else if ([options hasOpt:@"title"] && [options hasOpt:@"text"]) {
		NSImage *icon = [self _iconImage];
		KABubbleWindowController *bubble = [KABubbleWindowController
			bubbleWithTitle:[options optValue:@"title"]
			text:[options optValue:@"text"]
			icon:icon
			timeout:timeout
			lightColor:[self _colorForBubble:0 fromKey:@"background-top" alpha:alpha]
			darkColor:[self _colorForBubble:0 fromKey:@"background-bottom" alpha:alpha]
			textColor:[self _colorForBubble:0 fromKey:@"text-color" alpha:alpha]
			borderColor:[self _colorForBubble:0 fromKey:@"border-color" alpha:alpha]
			numExpectedBubbles:1
			bubblePosition:position];

		[bubble setAutomaticallyFadesOut:(![options hasOpt:@"no-timeout"])];
		[bubble setDelegate:self];
		[activeBubbles addObject:bubble];
		[bubble startFadeIn];

	// Error
	} else {
		if ([options hasOpt:@"debug"]) {
			[CDControl debug:@"You must specify either --title and --text, or --titles and --texts (with the same number of args)"];
		}
		return nil;
	}

	[NSApp run];
	return [NSArray array];
}

/*
- (void) bubbleWillFadeIn:(KABubbleWindowController *) bubble {}
- (void) bubbleDidFadeIn:(KABubbleWindowController *) bubble  {}
*/

- (void) bubbleWillFadeOut:(KABubbleWindowController *) bubble
{
	[activeBubbles removeObject:bubble];
	[fadingBubbles addObject:bubble];

	// Don't fade other bubbles if this option is provided.
	if ([[self options] hasOpt:@"independent"]) {
		return;
	}

	// When a bubble fades, make the others start to fade as well.
	KABubbleWindowController *aBubble;
	NSEnumerator *en = [activeBubbles objectEnumerator];
	while (aBubble = (KABubbleWindowController *)[en nextObject]) {
		[aBubble startFadeOut];
	}
}
- (void) bubbleDidFadeOut:(KABubbleWindowController *) bubble
{
	[fadingBubbles removeObject:bubble];
	if (![fadingBubbles count] && ![activeBubbles count]) {
		[NSApp stop:self];
		[NSApp terminate:nil];
	}
}

- (void) dealloc
{
	[activeBubbles release];
	[fadingBubbles release];
	activeBubbles = nil;
	fadingBubbles = nil;
	[super dealloc];
}

// We really ought to stick this in a proper NSColor category
+ (NSColor *) colorFromHex:(NSString *) hexValue alpha:(float)alpha
{
	unsigned char r, g, b;
	unsigned int value;
	[[NSScanner scannerWithString:hexValue] scanHexInt:&value];
	r = (unsigned char)(value >> 16);
	g = (unsigned char)(value >> 8);
	b = (unsigned char)value;
	NSColor *rv = nil;
	rv = [NSColor colorWithCalibratedRed:(float)r/255 green:(float)g/255 blue:(float)b/255 alpha:alpha];
	return rv;
}

// the `i` index is zero based.
- (NSColor *) _colorForBubble:(int)i fromKey:(NSString *)key alpha:(float)alpha
{
	CDOptions *options = [self options];
	NSArray *colorArgs = nil;
	NSString *myKey = key;
	// first check to see if this key returns multiple values
	colorArgs = [options optValues:myKey];
	if (colorArgs == nil) {
		// It didn't return an array, so see if it returns a single value
		NSString *optValue = [options optValue:myKey];

		// Failing that...
		// If we were looking for text-colors and didn't find it, try
		// text-color instead (for example).
		if (optValue == nil && [myKey hasSuffix:@"s"]) {
			myKey = [key substringToIndex:([key length] - 1)];
			optValue = [options optValue:myKey];
		}
		colorArgs = optValue ? [NSArray arrayWithObject:optValue] : [NSArray array];
	}
	// If user don't specify enough colors,  use the last 
	// given color for any bubbles past that.
	if (i >= [colorArgs count] && [colorArgs count]) {
		i = [colorArgs count] - 1;
	}
	NSString *hexValue = i < [colorArgs count] ?
		[colorArgs objectAtIndex:i] : nil;

	if ([myKey hasPrefix:@"text-color"]) {
		return hexValue
			? [CDBubbleControl colorFromHex:hexValue alpha:1.]
			: [NSColor controlTextColor];
	} else if ([myKey hasPrefix:@"border-color"]) {
		return hexValue
			? [CDBubbleControl colorFromHex:hexValue alpha:alpha]
			: [CDBubbleControl colorFromHex:@"808080" alpha:alpha];
	} else if ([myKey hasPrefix:@"background-top"]) {
		return hexValue
			? [CDBubbleControl colorFromHex:hexValue alpha:alpha]
			: [CDBubbleControl colorFromHex:@"B1D4F4" alpha:alpha];
	} else if ([myKey hasPrefix:@"background-bottom"]) {
		return hexValue
			? [CDBubbleControl colorFromHex:hexValue alpha:alpha]
			: [CDBubbleControl colorFromHex:@"EFF7FD" alpha:alpha];
	}
	return [NSColor yellowColor]; //only happen on programmer error
}

// returns an NSArray of NSImage's or nil if there's only one.
- (NSArray *) _iconImages
{
	CDOptions *options = [self options];
	NSMutableArray *icons = [NSMutableArray array];
	NSArray *iconArgs;
	NSEnumerator *en;

	if ([options hasOpt:@"icons"] && [[options optValues:@"icons"] count]) {
		iconArgs = [options optValues:@"icons"];
		en = [iconArgs objectEnumerator];
		NSString *iconName;
		while (iconName = (NSString *)[en nextObject]) {
			NSString *fileName = [[NSBundle mainBundle] pathForResource:iconName ofType:@"icns"];
			NSImage *icon = nil;
			if (fileName) {
				icon = [[[NSImage alloc ]initWithContentsOfFile:fileName] autorelease];
				if (icon == nil && [options hasOpt:@"debug"]) {
					[CDControl debug:[NSString stringWithFormat:@"Could not get image from specified icon file '%@'.", fileName]];
				}
			} else {
				[CDControl debug:[NSString stringWithFormat:@"Could not file for icon '%@'.", iconName]];
			}
			if (icon == nil) {
				icon = [NSApp applicationIconImage];
			}
			[icons addObject:icon];
		}

	} else if ([options hasOpt:@"icon-files"]
	           && [[options optValues:@"icon-files"] count])
	{
		iconArgs = [options optValues:@"icon-files"];
		en = [iconArgs objectEnumerator];
		NSString *fileName;
		while (fileName = (NSString *)[en nextObject]) {
			NSImage *icon = [[[NSImage alloc ]initWithContentsOfFile:fileName] autorelease];
			if (icon == nil) {
				if ([options hasOpt:@"debug"]) {
					[CDControl debug:[NSString stringWithFormat:@"Could not get image from specified icon file '%@'.", fileName]];
				}
				icon = [NSApp applicationIconImage];
			}
			[icons addObject:icon];
		}

	} else {
		return nil;
	}

	return icons;
}

// Should always return an image
- (NSImage *) _iconImage
{
	CDOptions *options = [self options];
	NSImage *icon = nil;

	if ([options hasOpt:@"icon-file"]) {
		icon = [[[NSImage alloc ]initWithContentsOfFile:[options optValue:@"icon-file"]] autorelease];
		if (icon == nil && [options hasOpt:@"debug"]) {
			[CDControl debug:[NSString stringWithFormat:@"Could not get image from specified icon file '%@'.", [options optValue:@"icon-file"]]];
		}

	} else if ([options hasOpt:@"icon"]) {
		NSString *iconName = [options optValue:@"icon"];
		NSString *fileName = [[NSBundle mainBundle] pathForResource:iconName ofType:@"icns"];
		if (fileName) {
			icon = [[[NSImage alloc ]initWithContentsOfFile:fileName] autorelease];
			if (icon == nil && [options hasOpt:@"debug"]) {
				[CDControl debug:[NSString stringWithFormat:@"Could not get image from specified icon file '%@'.", fileName]];
			}
		} else if ([options hasOpt:@"debug"]) {
			[CDControl debug:[NSString stringWithFormat:@"Could not file for icon '%@'.", iconName]];
		}
	}

	if (icon == nil) {
		icon = [NSApp applicationIconImage];
	}
	return icon;
}

@end
