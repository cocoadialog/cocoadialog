//
//  CDIcon.h
//  cocoaDialog
//
//  Created by Mark Whitaker on 10/28/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CDCommon.h"
#import "CDWindow.h"

@interface CDIcon : CDCommon {
@private
    NSImageView                 *control;
    NSMutableArray              *controls;
    NSImage                     *iconImage;
    CDWindow                    *window;
}
@property (retain) NSImageView *control;
@property (retain) CDWindow    *window;

- (void) addControl:(id)control;
- (NSArray *) controls;
- (NSImage *) icon;
- (NSData *) iconData;
- (NSImage *) iconWithDefault;
- (NSData *) iconDataWithDefault;
- (NSImage *) iconFromFile:(NSString *)file;
- (NSImage *) iconFromName:(NSString *)name;
- (void) setIconFromOptions;
@end
