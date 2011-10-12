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

- (NSArray *) runControlFromOptions:(CDOptions *)options
{
	float timeout = 4.;
	float alpha = 0.85;
	int position = 0;

	[self setOptions:options];

	activeBubbles = [[NSMutableArray array] retain];
	fadingBubbles = [[NSMutableArray array] retain];
	
	if ([options hasOpt:@"posX"]) {
		NSString *xplace = [options optValue:@"posX"];
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
	if ([options hasOpt:@"posY"]) {
		NSString *yplace = [options optValue:@"posY"];
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
			[self debug:@"Could not parse the timeout option."];
			timeout = 4.;
		}
	}

	if ([options hasOpt:@"alpha"]) {
		if (![[NSScanner scannerWithString:[options optValue:@"alpha"]] scanFloat:&alpha]) {
			[self debug:@"Could not parse the alpha option."];
			timeout = .95;
		}
	}
	NSArray *texts = [options optValues:@"descriptions"];
	NSArray *titles = [options optValues:@"titles"];

	// Multiple bubbles
	if (texts != nil && [texts count]
	    && titles != nil && [titles count]
	    && [titles count] == [texts count])
	{
		NSArray *givenIconImages = [self notificationIcons];
		NSImage *fallbackIcon = nil;
		NSMutableArray *icons = nil;
		unsigned i;
		// See what icons we got at the command line, or set a fallback
		// icon to use for all bubbles
		if (givenIconImages == nil) {
			fallbackIcon = [self notificationIcon];
		} else {
			icons = [NSMutableArray arrayWithArray:givenIconImages];
		}
		// If we were given less icons than we have bubbles, use a default
		// for any extra bubbles
		if ([icons count] < [texts count]) {
			NSImage *defaultIcon = [self notificationIcon];
			unsigned long numToAdd = [texts count] - [icons count];
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
				numExpectedBubbles:(unsigned)[texts count]
				bubblePosition:position];
			
			[bubble setAutomaticallyFadesOut:(![options hasOpt:@"sticky"])];
			[bubble setDelegate:self];
			[activeBubbles addObject:bubble];
			[bubble startFadeIn];
		}

	// Single bubble
	} else if ([options hasOpt:@"title"] && [options hasOpt:@"description"]) {
		NSImage *icon = [self notificationIcon];
		KABubbleWindowController *bubble = [KABubbleWindowController
			bubbleWithTitle:[options optValue:@"title"]
			text:[options optValue:@"description"]
			icon:icon
			timeout:timeout
			lightColor:[self _colorForBubble:0 fromKey:@"background-top" alpha:alpha]
			darkColor:[self _colorForBubble:0 fromKey:@"background-bottom" alpha:alpha]
			textColor:[self _colorForBubble:0 fromKey:@"text-color" alpha:alpha]
			borderColor:[self _colorForBubble:0 fromKey:@"border-color" alpha:alpha]
			numExpectedBubbles:1
			bubblePosition:position];

		[bubble setAutomaticallyFadesOut:(![options hasOpt:@"sticky"])];
		[bubble setDelegate:self];
		[activeBubbles addObject:bubble];
		[bubble startFadeIn];

	// Error
	} else {
		if ([options hasOpt:@"debug"]) {
			[self debug:@"You must specify either --title and --description, or --titles and --descriptions (with the same number of args)"];
		}
		return nil;
	}
    hasFinished = YES;
	[NSApp run];
	return [NSArray array];
}

- (void) debug:(NSString *)message
{
    [[self options] setOption:[NSNumber numberWithInt:1] forKey:@"independent"];
    int position = 0;
    position |= BUBBLE_HORIZ_RIGHT;
    position |= BUBBLE_VERT_TOP;
    KABubbleWindowController *bubble = [KABubbleWindowController
                                        bubbleWithTitle:@"cocoaDialog Debug"
                                        text:message
                                        icon:[self getIconWithName:@"caution"]
                                        timeout:4.0
                                        lightColor:[self _colorForBubble:0 fromKey:@"background-top" alpha:0.85]
                                        darkColor:[self _colorForBubble:0 fromKey:@"background-bottom-" alpha:0.85]
                                        textColor:[self _colorForBubble:0 fromKey:@"text-color" alpha:0.85]
                                        borderColor:[self _colorForBubble:0 fromKey:@"border-color" alpha:0.85]
                                        numExpectedBubbles:1
                                        bubblePosition:position];
    
    [bubble setAutomaticallyFadesOut:NO];
    [bubble setDelegate:self];
    [activeBubbles addObject:bubble];
    [bubble startFadeIn];
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
+ (NSColor *) colorFromHex:(NSString *) hexValue alpha:(CGFloat)alpha
{
	unsigned char r, g, b;
	unsigned int value;
	[[NSScanner scannerWithString:hexValue] scanHexInt:&value];
	r = (CGFloat)(value >> 16);
	g = (CGFloat)(value >> 8);
	b = (CGFloat)value;
	NSColor *rv = nil;
	rv = [NSColor colorWithCalibratedRed:(CGFloat)r/255 green:(CGFloat)g/255 blue:(CGFloat)b/255 alpha:alpha];
	return rv;
}

// the `i` index is zero based.
- (NSColor *) _colorForBubble:(unsigned long)i fromKey:(NSString *)key alpha:(CGFloat)alpha
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
			? [CDBubbleControl colorFromHex:hexValue alpha:alpha]
			: [NSColor whiteColor];
	} else if ([myKey hasPrefix:@"border-color"]) {
		return hexValue
			? [CDBubbleControl colorFromHex:hexValue alpha:alpha]
			: [CDBubbleControl colorFromHex:@"000000" alpha:alpha];
	} else if ([myKey hasPrefix:@"background-top"]) {
		return hexValue
			? [CDBubbleControl colorFromHex:hexValue alpha:alpha]
			: [CDBubbleControl colorFromHex:@"000000" alpha:alpha];
	} else if ([myKey hasPrefix:@"background-bottom"]) {
		return hexValue
			? [CDBubbleControl colorFromHex:hexValue alpha:alpha]
			: [CDBubbleControl colorFromHex:@"000000" alpha:alpha];
	}
	return [NSColor yellowColor]; //only happen on programmer error
}

@end
