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

  panel.contentMinSize = (NSSize){panel.contentMinSize.width,panel.contentMinSize.height +height};
}
- (void)addMinWidth:(CGFloat)width {

  panel.contentMinSize = (NSSize){panel.contentMinSize.width + width,panel.contentMinSize.height};
}
- (NSSize) findNewSize {

  NSSize size = NSZeroSize, oldSize;
  NSString *width, *height;

  if (!self.options || !panel) return size;

  size = [panel.contentView frame].size;

  oldSize.width   = size.width;
  oldSize.height  = size.height;

  if ([self.options hasOpt:@"width"]) {
    width = [self.options optValue:@"width"];
    if (width.floatValue != 0.0) size.width = width.floatValue;
  }
  if ([self.options hasOpt:@"height"]) {

    height = [self.options optValue:@"height"];
    if ([height floatValue] != 0.0) size.height = height.floatValue;
  }
  NSSize minSize = [panel contentMinSize];
  if (size.height < minSize.height) size.height = minSize.height;
  if (size.width < minSize.width)   size.width = minSize.width;

  return size.width != oldSize.width || size.height != oldSize.height ? size :NSZeroSize;
}
- (BOOL) needsResize {

  NSSize size = self.findNewSize;
  return size.width != 0.0 || size.height != 0.0;
}
- (void) resize { // resize if necessary

  !self.needsResize ?: [panel setContentSize:self.findNewSize];
}
- (void) setFloat {

  if (!panel) return;

  [panel setFloatingPanel:![self.options hasOpt:@"no-float"]];
  [panel setLevel:![self.options hasOpt:@"no-float"] ? NSNormalWindowLevel : NSScreenSaverWindowLevel];
  [panel makeKeyAndOrderFront:nil];
}
- (void) setPanelEmpty {

  panel = [NSPanel.alloc initWithContentRect:NSZeroRect
                                   styleMask:NSBorderlessWindowMask
                                     backing:NSBackingStoreBuffered
                                       defer:NO];
}
- (void) setPosition {

  NSRect screen = NSScreen.mainScreen.visibleFrame;
  CGFloat leftPoint = 0, topPoint = 0, padding = 10;
  id posX, posY;

  // Has posX option
  if ([self.options hasOpt:@"posX"]) {
    posX = [self.options optValue:@"posX"];
    leftPoint =
      // Left
      [posX caseInsensitiveCompare:@"left"] == NSOrderedSame ? padding :
      // Right
      [posX caseInsensitiveCompare:@"right"] == NSOrderedSame ? NSWidth(screen) - NSWidth([panel frame]) - padding :
      // Manual posX coords
      [posX floatValue] > 0.0 ? [posX floatValue] :
      // Center
      (NSWidth(screen)-NSWidth([panel frame]))/2 - padding;
  }
  // Center
  else {
    leftPoint = (NSWidth(screen)-NSWidth([panel frame]))/2 - padding;
  }
  // Has posY option
  if ([self.options hasOpt:@"posY"]) {
    posY = [self.options optValue:@"posY"];
    topPoint =
      // Bottom
      [posY caseInsensitiveCompare:@"bottom"] == NSOrderedSame ? NSMinY(screen) + padding + NSHeight([panel frame]) :
      // Top
      [posY caseInsensitiveCompare:@"top"] == NSOrderedSame ? NSMaxY(screen) - padding :
      // Manual posY coords
      [posY floatValue] > 0.0 ? NSMaxY(screen) - [posY floatValue] :
      // Center
      NSMaxY(screen)/1.8 + NSHeight([panel frame]);
  }
  // Center
  else topPoint = NSMaxY(screen)/1.8 + NSHeight([panel frame]);

  [panel setFrameTopLeftPoint:NSMakePoint(leftPoint, topPoint)];
}

- (void)setTitle {

  [panel setTitle:[self.options optValue:@"title"] ? [self.options optValue:@"title"] : @"cocoaDialog"];
}

- (void) setTitle:(NSString *)string {

  [panel setTitle:string != nil && ![string isEqualToString:@""] ? string : @"cocoaDialog"];
}

@end
