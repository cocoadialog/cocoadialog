//
//  CDIcon.h
//  cocoaDialog
//
//  Created by Mark Whitaker on 10/28/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CDCommon.h"
#import "CDPanel.h"

@interface CDIcon : CDCommon {
@private
    NSImageView                 *control;
    NSMutableArray              *controls;
    NSImage                     *iconImage;
    CDPanel                     *panel;
}
@property (strong) NSImageView *control;
@property (strong) CDPanel *panel;

- (void) addControl:(id)control;
@property (readonly, copy) NSArray *controls;
@property (readonly, copy) NSImage *icon;
@property (readonly, copy) NSData *iconData;
@property (readonly, copy) NSImage *iconWithDefault;
@property (readonly, copy) NSData *iconDataWithDefault;
- (NSImage *) iconFromFile:(NSString *)file;
- (NSImage *) iconFromName:(NSString *)name;
- (void) setIconFromOptions;
@end
