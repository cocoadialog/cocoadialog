//
//  CDPanel.m
//  cocoaDialog
//
//  Created by Mark Whitaker on 10/28/11.
//  Copyright (c) 2011 Mark Whitaker. All rights reserved.
//

#import "CDPanel.h"

@implementation CDPanel
@synthesize  panel;

- (id)initWithOptions:(CDOptions *)opts {
	self = [super initWithOptions:opts];
    controls = [[[NSMutableArray alloc] init] retain];
	return self;
}

- (void) addControl:(id)control {
    if (control != nil) {
        [self addMinHeight:[control frame].size.height + 8.0f];
        [controls addObject:control];
    }
}
- (void) addControlView:(NSView *)view {
    [self addHeight:[view frame].size.height + 8.0f];
    CGFloat maxControlWidth = 0.0f;
    // Set default position if no controls exist
    CGFloat x = 76;
    CGFloat y = NSHeight([panel frame]) - 40.f - [view frame].size.height;
    // Add the new control below any existing controls, using the last control as position reference points
    if ([controls count]) {
        id _control = nil;
        NSEnumerator *en = [controls objectEnumerator];
        while (_control = [en nextObject]) {
            if ([_control frame].size.width > maxControlWidth) maxControlWidth = [_control frame].size.width;
        }
        id _lastControl = [controls lastObject];
        x = [_lastControl frame].origin.x;
        y = [_lastControl frame].origin.y - 8.0f - [view frame].size.height;
    }
    [view setFrameSize:NSMakeSize(maxControlWidth, [view frame].size.height)];
    [view setFrameOrigin:NSMakePoint(x, y)];

    [[panel contentView] addSubview:view];
    [panel setViewsNeedDisplay:YES];
    [controls addObject:view];
}
- (void) addHeight:(CGFloat)height {
    NSSize size = [panel frame].size;
    size.height += height;
    [panel setContentSize:size];
}
- (void) addMinHeight:(CGFloat)height {
	NSSize minSize = [panel minSize];
	minSize.height += height;
	[panel setMinSize:minSize];
}
- (void) addMinWidth:(CGFloat)width {
	NSSize minSize = [panel minSize];
	minSize.width += width;
	[panel setMinSize:minSize];
}
- (void) configure {
    if (panel != nil) {
        // Set title
        [self setTitle];
        // Resize panel
        [self resize];
        // Reposition Panel
        [self setPosition];
        // Determine float
        if ([options hasOpt:@"no-float"]) {
            [panel setFloatingPanel:NO];
            [panel setLevel:NSNormalWindowLevel];
        }
        else {
            [panel setFloatingPanel: YES];
            [panel setLevel:NSScreenSaverWindowLevel];
        }
        // Determine panel title buttons
        if (![options hasOpt:@"close"]) {
            [[panel standardWindowButton:NSWindowCloseButton] setEnabled:NO];
        }
        if (![options hasOpt:@"minimize"]) {
            [[panel standardWindowButton:NSWindowMiniaturizeButton] setEnabled:NO];
        }
        if (![options hasOpt:@"resize"]) {
            [panel setStyleMask:panel.styleMask^NSResizableWindowMask];
            [[panel standardWindowButton:NSWindowZoomButton] setEnabled:NO];
        }
        else {
            if ([options hasOpt:@"min-width"]) {
                float num;
                if (![[NSScanner scannerWithString:[options optValue:@"min-width"]] scanFloat:&num]) {
                    if ([options hasOpt:@"debug"]) {
                        [self debug:@"Unable to parse the --min-width option."];
                    }
                }
                else {
                    minWidth = [NSNumber numberWithFloat:num];
                }
            }
            if ([options hasOpt:@"min-height"]) {
                float num;
                if (![[NSScanner scannerWithString:[options optValue:@"min-height"]] scanFloat:&num]) {
                    if ([options hasOpt:@"debug"]) {
                        [self debug:@"Unable to parse the --min-height option."];
                    }
                }
                else {
                    minHeight = [NSNumber numberWithFloat:num];
                }
            }
            if ([options hasOpt:@"max-width"]) {
                float num;
                if (![[NSScanner scannerWithString:[options optValue:@"max-width"]] scanFloat:&num]) {
                    if ([options hasOpt:@"debug"]) {
                        [self debug:@"Unable to parse the --max-width option."];
                    }
                }
                else {
                    maxWidth = [NSNumber numberWithFloat:num];
                }
            }
            if ([options hasOpt:@"max-height"]) {
                float num;
                if (![[NSScanner scannerWithString:[options optValue:@"max-height"]] scanFloat:&num]) {
                    if ([options hasOpt:@"debug"]) {
                        [self debug:@"Unable to parse the --max-height option."];
                    }
                }
                else {
                    maxHeight = [NSNumber numberWithFloat:num];
                }
            }
            NSRect screen = [self screen];
            // Set defaults if not set by options or control
            if (minWidth == nil || [minWidth floatValue] < [panel frame].size.width) {
                minWidth = [NSNumber numberWithFloat:[panel frame].size.width];
            }
            if (minHeight == nil || [minHeight floatValue] < [panel frame].size.height) {
                minHeight = [NSNumber numberWithFloat:[panel frame].size.height];
            }
            if (maxWidth == nil) maxWidth = [NSNumber numberWithFloat:screen.size.width];
            if (maxHeight == nil) maxHeight = [NSNumber numberWithFloat:screen.size.height];
            if ([maxWidth floatValue] < [panel frame].size.width) {
                maxWidth = [NSNumber numberWithFloat:screen.size.width];
            }
            if ([maxHeight floatValue] < [panel frame].size.height) {
                maxHeight = [NSNumber numberWithFloat:[panel frame].size.height];
            }
            // Set panel min and max sizes
            [panel setMinSize:NSMakeSize([minWidth floatValue], [minHeight floatValue])];
            [panel setMaxSize:NSMakeSize([maxWidth floatValue], [maxHeight floatValue])];
        }
        if (![options hasOpt:@"close"] && ![options hasOpt:@"minimize"] && ![options hasOpt:@"resize"]) {
            [[panel standardWindowButton:NSWindowCloseButton] setHidden:YES];
            [[panel standardWindowButton:NSWindowMiniaturizeButton] setHidden:YES];
            [[panel standardWindowButton:NSWindowZoomButton] setHidden:YES];
        }
        if (![options hasOpt:@"fullscreen"]) {
            [[panel standardWindowButton:NSWindowFullScreenButton] setHidden:YES];
        }
        [panel makeKeyAndOrderFront:nil];
        
    }
}

- (void) dealloc {
    [controls release];
    [panel release];
    [super dealloc];
}

- (NSSize) findNewSize {
	NSSize size = NSZeroSize;
	NSSize oldSize;
	NSString *width, *height;
	if (options == nil || panel == nil) {
		return size;
	}
	size = [[panel contentView] frame].size;
	oldSize.width = size.width;
	oldSize.height = size.height;
	if ([options hasOpt:@"width"]) {
		width = [options optValue:@"width"];
		if ([width floatValue] != 0.0) {
			size.width = [width floatValue];
		}
	}
	if ([options hasOpt:@"height"]) {
		height = [options optValue:@"height"];
		if ([height floatValue] != 0.0) {
			size.height = [height floatValue];
		}
	}
	NSSize minSize = [panel contentMinSize];
	if (size.height < minSize.height) {
		size.height = minSize.height;
	}
	if (size.width < minSize.width) {
		size.width = minSize.width;
	}
	if (size.width != oldSize.width || size.height != oldSize.height) {
		return size;
	} else {
		return NSMakeSize(0.0,0.0);
	}
}
- (BOOL) needsResize {
	NSSize size = [self findNewSize];
	if (size.width != 0.0 || size.height != 0.0) {
		return YES;
	} else {
		return NO;
	}
}
- (void) resize {
    // resize if necessary
	if ([self needsResize]) {
		[panel setContentSize:[self findNewSize]];
	}
}
- (void)setMaxHeight:(float)height {
    maxHeight = [NSNumber numberWithFloat:height];
}
- (void)setMaxWidth:(float)width {
    maxWidth = [NSNumber numberWithFloat:width];
}
- (void)setMinHeight:(float)height {
    minHeight = [NSNumber numberWithFloat:height];
}
- (void)setMinWidth:(float)width {
    minWidth = [NSNumber numberWithFloat:width];
}
- (void) setPanelEmpty {
    panel = [[[NSPanel alloc] initWithContentRect:NSMakeRect(0, 0, 0, 0)
                                                styleMask:NSBorderlessWindowMask
                                                  backing:NSBackingStoreBuffered
                                                    defer:NO] autorelease];
}
- (void) setPosition {
    NSRect screen = [self screen];
    CGFloat leftPoint = 0.0;
	CGFloat topPoint = 0.0;
    CGFloat padding = 10.0;
    id posX;
    id posY;
    // Center horizontally
    leftPoint = ((NSWidth(screen)-NSWidth([panel frame]))/2) + NSMinX(screen);
    // Has posX option
	if ([options hasOpt:@"posX"]) {
		posX = [options optValue:@"posX"];
        // Left
		if ([posX caseInsensitiveCompare:@"left"] == NSOrderedSame) {
            leftPoint = NSMinX(screen) + padding;
		}
        // Right
        else if ([posX caseInsensitiveCompare:@"right"] == NSOrderedSame) {
            leftPoint = NSMaxX(screen) - NSWidth([panel frame]) - padding;
		}
        // Manual posX coords
        else if ([posX floatValue] > 0.0) {
            leftPoint = NSMinX(screen) + [posX floatValue];
        }
        else if ([options hasOpt:@"debug"]) {
            [self debug:@"Unable to parse option --posX, centering"];
        }
	}
    // Center vertically
    topPoint = NSMaxY(screen) - ((NSHeight(screen)-NSHeight([panel frame]))/2);
    // Has posY option
	if ([options hasOpt:@"posY"]) {
		posY = [options optValue:@"posY"];
        // Bottom
		if ([posY caseInsensitiveCompare:@"bottom"] == NSOrderedSame) {
            topPoint = NSMinY(screen) + padding + NSHeight([panel frame]);
		}
        // Top
        else if ([posY caseInsensitiveCompare:@"top"] == NSOrderedSame) {
            topPoint = NSMaxY(screen) - padding;
		}
        // Manual posY coords
        else if ([posY floatValue] > 0.0) {
            topPoint = NSMaxY(screen) - [posY floatValue];
        }
        else if ([options hasOpt:@"debug"]) {
            [self debug:@"Unable to parse option --posY, centering"];
        }
	}
	[panel setFrameTopLeftPoint:NSMakePoint(leftPoint, topPoint)];
}

- (void)setTitle {
    // set title
	if ([options optValue:@"title"] != nil) {
		[panel setTitle:[options optValue:@"title"]];
	}
    else {
        [panel setTitle:@"cocoaDialog"];
    }
}

- (void) setTitle:(NSString *)string {
    if (string != nil && ![string isEqualToString:@""]) {
        [panel setTitle:string];
    }
    else {
        [panel setTitle:@"cocoaDialog"];
    }
}

@end
