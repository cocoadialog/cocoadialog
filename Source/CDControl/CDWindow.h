//
//  CDPanel.h
//  cocoaDialog
//
//  Created by Mark Whitaker on 10/28/11.
//  Copyright (c) 2011 Mark Whitaker. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CDCommon.h"


extern CGFloat const CD_CONTROL_PADDING;
extern CGFloat const CD_WINDOW_Y_PADDING;
extern CGFloat const CD_WINDOW_X_PADDING;

@class NSWindow;

@interface CDWindow : CDCommon <NSWindowDelegate> {
    IBOutlet NSWindow   *window;
    NSMutableArray      *controls;
    NSView              *controlView;
    NSNumber *minWidth, *minHeight, *maxWidth, *maxHeight;
}
@property (nonatomic,retain) NSWindow *window;

- (void) addControl:(id)control;
- (void) addControlView:(NSView *)view;
- (void) addHeight:(CGFloat)height;
- (void) addMinHeight:(CGFloat)height;
- (void) addMinWidth:(CGFloat)width;
- (void) configure;
- (NSSize) findNewSize;
- (BOOL) needsResize;
- (void) resize;
- (void) setMaxHeight:(float)height;
- (void) setMaxWidth:(float)width;
- (void) setMinHeight:(float)height;
- (void) setMinWidth:(float)width;
- (void) setPanelEmpty;
- (void) setPosition;
- (void) setTitle;
- (void) setTitle:(NSString *)string;

@end
