//
//  CDPanel.m
//  cocoaDialog
//
//  Created by Mark Whitaker on 10/28/11.
//  Copyright (c) 2011 Mark Whitaker. All rights reserved.
//

#import "CDPanel.h"

@implementation CDPanel
@synthesize panel;

- (void)addMinHeight:(CGFloat)height {
	NSSize panelMinSize = panel.contentMinSize;
	panelMinSize.height += height;
	panel.contentMinSize = panelMinSize;
}
- (void)addMinWidth:(CGFloat)width {
	NSSize panelMinSize = panel.contentMinSize;
	panelMinSize.width += width;
	panel.contentMinSize = panelMinSize;
}

- (void) dealloc {
    [panel release];
    [super dealloc];
}

- (NSSize) findNewSize {
	NSSize size = NSZeroSize;
	NSSize oldSize;
	NSString *width, *height;
	if (arguments == nil || panel == nil) {
		return size;
	}
	size = panel.contentView.frame.size;
	oldSize.width = size.width;
	oldSize.height = size.height;
	if ([arguments hasOption:@"width"]) {
		width = [arguments getOption:@"width"];
		if (width.floatValue != 0.0) {
			size.width = width.floatValue;
		}
	}
	if ([arguments hasOption:@"height"]) {
		height = [arguments getOption:@"height"];
		if (height.floatValue != 0.0) {
			size.height = height.floatValue;
		}
	}
	NSSize minSize = panel.contentMinSize;
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

- (NSScreen *)getScreen {
    if ([arguments hasOption:@"screen"]) {
        int index = (int) [arguments getOption:@"screen"];
        NSArray *screens = [NSScreen screens];
        if ((int) [screens count] - 1 < index) {
            [self warning:@"Using screen where keyboard has focus. Unknown screen index: %d", index];
            return [NSScreen mainScreen];
        }
        return [screens objectAtIndex:index];
    }
    else {
        return [NSScreen mainScreen];
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
- (void) setFloat {
    if (panel != nil) {
        if ([arguments hasOption:@"no-float"]) {
            [panel setFloatingPanel:NO];
            [panel setLevel:NSNormalWindowLevel];
        }
        else {
            [panel setFloatingPanel: YES];
            [panel setLevel:NSFloatingWindowLevel];
        }		
        [panel makeKeyAndOrderFront:nil];
    }
}
- (void) setPanelEmpty {
    panel = [[[NSPanel alloc] initWithContentRect:NSMakeRect(0, 0, 0, 0)
                                                styleMask:NSBorderlessWindowMask
                                                  backing:NSBackingStoreBuffered
                                                    defer:NO] autorelease];
}
- (void) setPosition {
    NSScreen *screen = [self getScreen];
    CGFloat x = NSMinX(screen.visibleFrame);
    CGFloat y = NSMinY(screen.visibleFrame);
    CGFloat height = NSHeight(screen.visibleFrame);
    CGFloat width = NSWidth(screen.visibleFrame);
    CGFloat top = y + height;
    CGFloat left = x;
    CGFloat padding = 20.0;
    NSNumberFormatter *nf = [[[NSNumberFormatter alloc] init] autorelease];

    id posX;
    id posY;

    // Has posX option
    if ([arguments hasOption:@"posX"]) {
		posX = [arguments getOption:@"posX"];
        NSNumber *posXNumber = [nf numberFromString:posX];
        // Left
		if ([posX caseInsensitiveCompare:@"left"] == NSOrderedSame) {
            left += padding;
		}
        // Right
        else if ([posX caseInsensitiveCompare:@"right"] == NSOrderedSame) {
            left = left + width - NSWidth(panel.frame) - padding;
		}
        // Manual posX coords
        else if (posXNumber != nil) {
            left += [posXNumber floatValue];
        }
        // Center
        else {
            left = left + ((width - NSWidth(panel.frame)) / 2 - padding);
		}
	}
    // Center
    else {
        left = left + ((width - NSWidth(panel.frame)) / 2 - padding);
	}

    // Has posY option
	if ([arguments hasOption:@"posY"]) {
		posY = [arguments getOption:@"posY"];
        NSNumber *posYNumber = [nf numberFromString:posY];
        // Bottom
		if ([posY caseInsensitiveCompare:@"bottom"] == NSOrderedSame) {
            top = y + padding;
		}
        // Top
        else if ([posY caseInsensitiveCompare:@"top"] == NSOrderedSame) {
            top = top - NSHeight(panel.frame) - padding;
		}
        // Manual posY coords
        else if (posYNumber != nil) {
            top = top - NSHeight(panel.frame) - [posYNumber floatValue];
        }
        // Center
        else {
            top = (height / 1.8) - (NSHeight(panel.frame) / 1.8);
		}
	}
    // Center
    else {
        top = (height / 1.8) - (NSHeight(panel.frame) / 1.8);
	}

    // Ensure the panel has the correct relative frame origins.
    [panel setFrameOrigin:NSMakePoint(left, top)];
}

- (void)setTitle {
    // set title
	if ([arguments getOption:@"title"] != nil) {
		panel.title = [arguments getOption:@"title"];
	}
    else {
        panel.title = NSLocalizedString(@"APP_TITLE", nil);
    }
}

- (void) setTitle:(NSString *)string {
    if (string != nil && ![string isEqualToString:@""]) {
        panel.title = string;
    }
    else {
        panel.title = NSLocalizedString(@"APP_TITLE", nil);
    }
}

@end
