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
@property (retain) NSImageView *control;
@property (retain) CDPanel *panel;

- (void) addControl:(id)control;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSArray *controls;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSImage *icon;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSData *iconData;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSImage *iconWithDefault;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSData *iconDataWithDefault;
- (NSImage *) iconFromFile:(NSString *)file;
- (NSImage *) iconFromName:(NSString *)name;
- (void) setIconFromOptions;
@end
