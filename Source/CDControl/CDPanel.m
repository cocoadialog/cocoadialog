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
	NSSize panelMinSize = [panel contentMinSize];
	panelMinSize.height += height;
	[panel setContentMinSize:panelMinSize];
}
- (void)addMinWidth:(CGFloat)width {
	NSSize panelMinSize = [panel contentMinSize];
	panelMinSize.width += width;
	[panel setContentMinSize:panelMinSize];
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
- (void) setFloat {
    if (panel != nil) {
        if ([options hasOpt:@"no-float"]) {
            [panel setFloatingPanel:NO];
            [panel setLevel:NSNormalWindowLevel];
        }
        else {
            [panel setFloatingPanel: YES];
            [panel setLevel:NSScreenSaverWindowLevel];
        }		
        [panel makeKeyAndOrderFront:nil];
    }
}
- (void) setPanelEmpty {
    panel = [[NSPanel alloc] initWithContentRect:NSMakeRect(0, 0, 0, 0)
                                                styleMask:NSBorderlessWindowMask
                                                  backing:NSBackingStoreBuffered
                                                    defer:NO];
}
- (void) setPosition {
    NSRect screen = [[NSScreen mainScreen] visibleFrame];
    CGFloat leftPoint = 0.0;
	CGFloat topPoint = 0.0;
    CGFloat padding = 10.0;
    id posX;
    id posY;
    // Has posX option
	if ([options hasOpt:@"posX"]) {
		posX = [options optValue:@"posX"];
        // Left
		if ([posX caseInsensitiveCompare:@"left"] == NSOrderedSame) {
            leftPoint = padding;
		}
        // Right
        else if ([posX caseInsensitiveCompare:@"right"] == NSOrderedSame) {
            leftPoint = NSWidth(screen) - NSWidth([panel frame]) - padding;
		}
        // Manual posX coords
        else if ([posX floatValue] > 0.0) {
            leftPoint = [posX floatValue];
        }
        // Center
        else {
            leftPoint = (NSWidth(screen)-NSWidth([panel frame]))/2 - padding;
		}
	}
    // Center
    else {
        leftPoint = (NSWidth(screen)-NSWidth([panel frame]))/2 - padding;
	}
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
        // Center
        else {
            topPoint = NSMaxY(screen)/1.8 + NSHeight([panel frame]);
		}
	}
    // Center
    else {
		topPoint = NSMaxY(screen)/1.8 + NSHeight([panel frame]);
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
