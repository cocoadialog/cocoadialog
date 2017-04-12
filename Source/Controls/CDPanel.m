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
	float width, height;
	if (arguments == nil || panel == nil) {
		return size;
	}
	size = panel.contentView.frame.size;
	oldSize.width = size.width;
	oldSize.height = size.height;
	if (arguments.options[@"width"].wasProvided) {
		width = arguments.options[@"width"].floatValue;
		if (width != 0.0) {
			size.width = width;
		}
	}
	if (arguments.options[@"height"].wasProvided) {
		height = arguments.options[@"height"].floatValue;
		if (height != 0.0) {
			size.height = height;
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
    if (arguments.options[@"screen"].wasProvided) {
        NSUInteger index = arguments.options[@"screen"].unsignedIntegerValue;
        NSArray *screens = [NSScreen screens];
        if (index >= [screens count]) {
            [self warning:@"Using screen where keyboard has focus. Unknown screen index: %@", [NSNumber numberWithUnsignedInteger:index], nil];
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
        if (arguments.options[@"no-float"].wasProvided) {
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

    NSString *posX, *posY;

    // Has posX option
    if (arguments.options[@"posX"].wasProvided) {
		posX = arguments.options[@"posX"].stringValue;
        NSNumber *posXNumber = [nf numberFromString:posX];
        // Left
		if ([posX isEqualToStringCaseInsensitive:@"left"]) {
            left += padding;
		}
        // Right
        else if ([posX isEqualToStringCaseInsensitive:@"right"]) {
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
	if (arguments.options[@"posY"].wasProvided) {
		posY = arguments.options[@"posY"].stringValue;
        NSNumber *posYNumber = [nf numberFromString:posY];
        // Bottom
		if ([posY isEqualToStringCaseInsensitive:@"bottom"]) {
            top = y + padding;
		}
        // Top
        else if ([posY isEqualToStringCaseInsensitive:@"top"]) {
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
    panel.title = arguments.options[@"title"].wasProvided ? arguments.options[@"title"].stringValue : NSLocalizedString(@"APP_TITLE", nil);
}

- (void) setTitle:(NSString *)string {
    panel.title = string != nil && ![string isBlank] ? string : NSLocalizedString(@"APP_TITLE", nil);
}

@end
