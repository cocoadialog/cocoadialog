/*
	CDBubbleControl.m
	cocoaDialog
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

- (BOOL) validateOptions {
    BOOL pass = YES;
    if ([options hasOpt:@"title"]) {
        if (![options hasOpt:@"description"]) {
            pass = NO;
        }
    }
    else if ([options hasOpt:@"titles"]) {
        if (![options hasOpt:@"descriptions"]) {
            pass = NO;
        }
    }
    else {
        pass = NO;
    }
    if (!pass && [options hasOpt:@"debug"]) {
        [self debug:@"You must specify either --title and --description, or --titles and --descriptions (with the same number of args)"];
    }
    return YES;
}

- (void) createControl {
    [panel setPanelEmpty];

	float _timeout = 4.;
	float alpha = 0.85;
	int position = 0;

	self.options = options;

    NSString *clickPath = @"";
    if ([options hasOpt:@"click-path"]) {
        clickPath = [options optValue:@"click-path"];
    }
    
    NSString *clickArg = @"";
    if ([options hasOpt:@"click-arg"]) {
        clickArg = [options optValue:@"click-arg"];
    }
	
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
		if (![[NSScanner scannerWithString:[options optValue:@"timeout"]] scanFloat:&_timeout]) {
			[self debug:@"Could not parse the timeout option."];
			_timeout = 4.;
		}
	}

	if ([options hasOpt:@"alpha"]) {
		if (![[NSScanner scannerWithString:[options optValue:@"alpha"]] scanFloat:&alpha]) {
			[self debug:@"Could not parse the alpha option."];
			_timeout = .95;
		}
	}
    BOOL sticky = [options hasOpt:@"sticky"];

	NSArray *titles = [options optValues:@"titles"];
	NSArray *descriptions = [options optValues:@"descriptions"];

	// Multiple bubbles
	if (descriptions != nil && descriptions.count && titles != nil && titles.count && titles.count == descriptions.count) {
		NSArray *givenIconImages = [self notificationIcons];
		NSImage *fallbackIcon = nil;
		NSMutableArray *icons = nil;
		unsigned i;
		// See what icons we got at the command line, or set a fallback
		// icon to use for all bubbles
		if (givenIconImages == nil) {
			fallbackIcon = [icon iconWithDefault];
		} else {
			icons = [NSMutableArray arrayWithArray:givenIconImages];
		}
		// If we were given less icons than we have bubbles, use a default
		// for any extra bubbles
		if (icons.count < descriptions.count) {
			NSImage *defaultIcon = [icon iconWithDefault];
			unsigned long numToAdd = descriptions.count - icons.count;
			for (i = 0; i < numToAdd; i++) {
				[icons addObject:defaultIcon];
			}
		}
        NSArray * clickPaths = [NSArray arrayWithArray:[options optValues:@"click-paths"]];
        NSArray * clickArgs = [NSArray arrayWithArray:[options optValues:@"click-args"]];
		// Create the bubbles
		for (i = 0; i < descriptions.count; i++) {
			NSImage *_icon = fallbackIcon == nil ? (NSImage *)icons[i] : fallbackIcon;
            [self addNotificationWithTitle:titles[i]
                               description:descriptions[i]
                                      icon:_icon
                                  priority:nil
                                    sticky:sticky
                                 clickPath:clickPaths.count ? clickPaths[i] : clickPath
                                  clickArg:clickArgs.count ? clickArgs[i] : clickArg
             ];
		}
	// Single bubble
	} else if ([options hasOpt:@"title"] && [options hasOpt:@"description"]) {
        [self addNotificationWithTitle:[options optValue:@"title"]
                           description:[options optValue:@"description"]
                                  icon:[icon iconWithDefault]
                              priority:nil
                                sticky:sticky
                             clickPath:clickPath
                              clickArg:clickArg
         ];
    }

    NSEnumerator *en = [notifications objectEnumerator];
    id obj;
    int i = 0;
    while (obj = [en nextObject]) {
        NSDictionary * notification = [NSDictionary dictionaryWithDictionary:obj];
        KABubbleWindowController *bubble = [KABubbleWindowController
                                            bubbleWithTitle:notification[@"title"] text:notification[@"description"]
                                            icon:notification[@"icon"]
                                            timeout:_timeout
                                            lightColor:[self _colorForBubble:i fromKey:@"background-tops" alpha:alpha]
                                            darkColor:[self _colorForBubble:i fromKey:@"background-bottoms" alpha:alpha]
                                            textColor:[self _colorForBubble:i fromKey:@"text-colors" alpha:alpha]
                                            borderColor:[self _colorForBubble:i fromKey:@"border-colors" alpha:alpha]
                                            numExpectedBubbles:(unsigned)notifications.count
                                            bubblePosition:position];
        
        [bubble setAutomaticallyFadesOut:![notification[@"sticky"] boolValue]];
        [bubble setDelegate:self];
        [bubble setClickContext:[NSString stringWithFormat:@"%d", activeNotifications]];
        [bubble startFadeIn];
        activeNotifications++;
        i++;
    }
}

- (void) debug:(NSString *)message
{
    [self addNotificationWithTitle:@"cocoaDialog Debug"
                       description:message
                              icon:[icon iconFromName:@"caution"]
                          priority:0
                            sticky:YES
                         clickPath:nil
                          clickArg:nil
     ];
}

- (void)bubbleWasClicked:(id)clickContext
{
    // Launch task
    [self notificationWasClicked:clickContext];
}

- (void) bubbleDidFadeOut:(KABubbleWindowController *) bubble
{
    // Terminate cocoaDialog once all the notifications are complete
    activeNotifications--;
    if (activeNotifications <= 0) {
        [self stopControl];
    }
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
- (NSColor *) _colorForBubble:(unsigned long)i fromKey:(NSString *)key alpha:(CGFloat)alpha {
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
			myKey = [key substringToIndex:(key.length - 1)];
			optValue = [options optValue:myKey];
		}
		colorArgs = optValue ? @[optValue] : @[];
	}
	// If user don't specify enough colors,  use the last 
	// given color for any bubbles past that.
	if (i >= colorArgs.count && colorArgs.count) {
		i = colorArgs.count - 1;
	}
	NSString *hexValue = i < colorArgs.count ?
		colorArgs[i] : nil;

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
