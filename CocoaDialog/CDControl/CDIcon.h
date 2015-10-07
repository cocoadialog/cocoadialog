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

@interface CDIcon : CDCommon

@property NSImageView *control;
@property CDPanel *panel;

- (void) addControl:control;

@property (readonly, copy) NSArray *controls;
@property (readonly, copy) NSImage *icon, *iconWithDefault;
@property (readonly, copy) NSData *iconData, *iconDataWithDefault;

- (NSImage*) iconFromFile:(NSString*)file;
- (NSImage*) iconFromName:(NSString*)name;

- (void) setIconFromOptions;
@end
