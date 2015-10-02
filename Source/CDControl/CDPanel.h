//
//  CDPanel.h
//  cocoaDialog
//
//  Created by Mark Whitaker on 10/28/11.
//  Copyright (c) 2011 Mark Whitaker. All rights reserved.
//

#import "CDCommon.h"

@interface CDPanel : CDCommon
{
    IBOutlet NSPanel    *panel;
}
@property (strong) NSPanel *panel;

- (void) addMinHeight:(CGFloat)height;
- (void) addMinWidth:(CGFloat)width;
@property (readonly) NSSize findNewSize;
@property (readonly) BOOL needsResize;
- (void) resize;
- (void) setFloat;
- (void) setPanelEmpty;
- (void) setPosition;
- (void) setTitle;
- (void) setTitle:(NSString *)string;

@end
