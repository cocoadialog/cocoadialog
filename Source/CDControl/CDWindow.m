//
//  CDWindow.m
//  cocoaDialog
//
//  Created by Mark Whitaker on 10/28/11.
//  Copyright (c) 2011 Mark Whitaker. All rights reserved.
//

#import "CDWindow.h"

CGFloat const CD_CONTROL_PADDING = 8.0f;
CGFloat const CD_WINDOW_Y_PADDING = 12.0f;
CGFloat const CD_WINDOW_X_PADDING = 14.0f;

@implementation CDWindow
@synthesize window;

- (id)initWithOptions:(CDOptions *)opts {
	self = [super initWithOptions:opts];
    controls = [[[NSMutableArray alloc] init] retain];
	return self;
}

- (void) addControl:(id)control {
    if (control != nil) {
//        [self addMinHeight:[control frame].size.height + 8.0f];
        [controls addObject:control];
    }
}

- (void) setWindow:(NSWindow *)aWindow {
    window = aWindow;
    NSSize size = [[window contentView] frame].size;
    size.height += CD_WINDOW_Y_PADDING * 2.0f;
    size.width += CD_WINDOW_X_PADDING * 2.0f;
    [window setContentSize:size];
    
    controlView = [[NSView alloc] initWithFrame:NSMakeRect(CD_WINDOW_X_PADDING, CD_WINDOW_Y_PADDING, [[window contentView] frame].size.width - (CD_WINDOW_X_PADDING * 2.0f), [[window contentView] frame].size.height - (CD_WINDOW_Y_PADDING * 2.0f))];
    
    NSTextField *label = [[[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, [controlView frame].size.width, [controlView frame].size.height)] autorelease];
    [label setEditable:NO];
    [label setBordered:NO];
    [label setBezeled:NO];
    [label setBackgroundColor:[NSColor redColor]];
    [label setDrawsBackground:YES];
    [label setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];

    [controlView addSubview:label];
    
    [controlView setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];

    [[window contentView] addSubview:controlView];
}
- (void) addControlView:(NSView *)view {    
    CGFloat viewHeight = [view frame].size.height;

    // Set defaults to window width/height - padding
    CGFloat maxControlWidth = [controlView frame].size.width;
    // Set default position if no controls exist
    CGFloat x = 0.0f;
    CGFloat y = 0.0f;
    // Add the new control below any existing controls, using the last control as a reference point
    if ([controls count]) {
        id _control = nil;
        NSEnumerator *en = [controls objectEnumerator];
        while (_control = [en nextObject]) {
            if ([_control frame].size.width > maxControlWidth) maxControlWidth = [_control frame].size.width;
        }
        [self addHeight:viewHeight + CD_CONTROL_PADDING];
        id _lastControl = [controls lastObject];
        x = [_lastControl frame].origin.x;
        y = [_lastControl frame].origin.y - [view frame].size.height;
        // Move the last control if it has sizeable height
        if (y < 0.0f) {
            NSRect r = [_lastControl frame];
            r.origin.y += viewHeight + CD_CONTROL_PADDING;
            r.size.height -= viewHeight + CD_CONTROL_PADDING;
            [_lastControl setFrame:r];
            y = 0.0f;
        }
    }
    else {
        NSLog(@"Using default reference point");
        [self addHeight:viewHeight];
    }
    [view setAlphaValue:0.75f];
    [view setFrameSize:NSMakeSize(maxControlWidth, viewHeight)];
    [view setFrameOrigin:NSMakePoint(x, y)];
    NSLog(@"view frame: %@", NSStringFromRect([view frame]));

    [controlView addSubview:view];
    [controls addObject:view];
}
- (void) addHeight:(CGFloat)height {
    NSSize size = [[window contentView] frame].size;
    size.height += height;
    [window setContentSize:size];
}
- (void) addMinHeight:(CGFloat)height {
	NSSize minSize = [window minSize];
	minSize.height += height;
	[window setMinSize:minSize];
}
- (void) addMinWidth:(CGFloat)width {
	NSSize minSize = [window minSize];
	minSize.width += width;
	[window setMinSize:minSize];
}
- (void) configure {
    if (window != nil) {
        // Set title
        [self setTitle];
        // Resize window
        [self resize];
        // Reposition window
        [self setPosition];
        // Determine float
        if ([options hasOpt:@"no-float"]) {
            [window setLevel:NSNormalWindowLevel];
        }
        else {
            [window setLevel:NSScreenSaverWindowLevel];
        }
        // Determine window title buttons
        if (![options hasOpt:@"close"]) {
            [[window standardWindowButton:NSWindowCloseButton] setEnabled:NO];
        }
        if (![options hasOpt:@"minimize"]) {
            [[window standardWindowButton:NSWindowMiniaturizeButton] setEnabled:NO];
        }
        if (![options hasOpt:@"resize"]) {
            [window setStyleMask:window.styleMask^NSResizableWindowMask];
            [[window standardWindowButton:NSWindowZoomButton] setEnabled:NO];
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
            if (minWidth == nil || [minWidth floatValue] < [window frame].size.width) {
                minWidth = [NSNumber numberWithFloat:[window frame].size.width];
            }
            if (minHeight == nil || [minHeight floatValue] < [window frame].size.height) {
                minHeight = [NSNumber numberWithFloat:[window frame].size.height];
            }
            if (maxWidth == nil) maxWidth = [NSNumber numberWithFloat:screen.size.width];
            if (maxHeight == nil) maxHeight = [NSNumber numberWithFloat:screen.size.height];
            if ([maxWidth floatValue] < [window frame].size.width) {
                maxWidth = [NSNumber numberWithFloat:screen.size.width];
            }
            if ([maxHeight floatValue] < [window frame].size.height) {
                maxHeight = [NSNumber numberWithFloat:[window frame].size.height];
            }
            // Set window min and max sizes
            [window setMinSize:NSMakeSize([minWidth floatValue], [minHeight floatValue])];
            [window setMaxSize:NSMakeSize([maxWidth floatValue], [maxHeight floatValue])];
        }
        if (![options hasOpt:@"close"] && ![options hasOpt:@"minimize"] && ![options hasOpt:@"resize"]) {
            [[window standardWindowButton:NSWindowCloseButton] setHidden:YES];
            [[window standardWindowButton:NSWindowMiniaturizeButton] setHidden:YES];
            [[window standardWindowButton:NSWindowZoomButton] setHidden:YES];
        }
        if (![options hasOpt:@"fullscreen"]) {
            [[window standardWindowButton:NSWindowFullScreenButton] setHidden:YES];
        }
        [window makeKeyAndOrderFront:nil];
        
    }
}

- (void) dealloc {
    [controls release];
    [window release];
    [super dealloc];
}

- (NSSize) findNewSize {
	NSSize size = NSZeroSize;
	NSSize oldSize;
	NSString *width, *height;
	if (options == nil || window == nil) {
		return size;
	}
	size = [[window contentView] frame].size;
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
	NSSize minSize = [window contentMinSize];
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
		[window setContentSize:[self findNewSize]];
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
    window = [[[NSWindow alloc] initWithContentRect:NSMakeRect(0, 0, 0, 0)
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
    leftPoint = ((NSWidth(screen)-NSWidth([window frame]))/2) + NSMinX(screen);
    // Has posX option
	if ([options hasOpt:@"posX"]) {
		posX = [options optValue:@"posX"];
        // Left
		if ([posX caseInsensitiveCompare:@"left"] == NSOrderedSame) {
            leftPoint = NSMinX(screen) + padding;
		}
        // Right
        else if ([posX caseInsensitiveCompare:@"right"] == NSOrderedSame) {
            leftPoint = NSMaxX(screen) - NSWidth([window frame]) - padding;
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
    topPoint = NSMaxY(screen) - ((NSHeight(screen)-NSHeight([window frame]))/2);
    // Has posY option
	if ([options hasOpt:@"posY"]) {
		posY = [options optValue:@"posY"];
        // Bottom
		if ([posY caseInsensitiveCompare:@"bottom"] == NSOrderedSame) {
            topPoint = NSMinY(screen) + padding + NSHeight([window frame]);
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
	[window setFrameTopLeftPoint:NSMakePoint(leftPoint, topPoint)];
}

- (void)setTitle {
    // set title
	if ([options optValue:@"title"] != nil) {
		[window setTitle:[options optValue:@"title"]];
	}
    else {
        [window setTitle:@"cocoaDialog"];
    }
}

- (void) setTitle:(NSString *)string {
    if (string != nil && ![string isEqualToString:@""]) {
        [window setTitle:string];
    }
    else {
        [window setTitle:@"cocoaDialog"];
    }
}

@end
