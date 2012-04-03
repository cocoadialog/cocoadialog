//
//  CDPanel.h
//  cocoaDialog
//
//  Created by Mark Whitaker on 10/28/11.
//  Copyright (c) 2011 Mark Whitaker. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CDCommon.h"

@class NSObject;

@interface CDPanel : CDCommon <NSWindowDelegate> {
    IBOutlet NSPanel    *panel;
    NSNumber *minWidth, *minHeight, *maxWidth, *maxHeight;
}
@property (retain) NSPanel *panel;

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
