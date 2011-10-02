//
//  CDGrowl.m
//  CocoaDialog
//
//  Created by Mark Carver on 10/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "CDGrowlControl.h"

@implementation CDGrowlControl

- (NSArray *) runControlFromOptions:(CDOptions *)options
{
//    [GrowlApplicationBridge setGrowlDelegate:self];
    
    if ([GrowlApplicationBridge isGrowlRunning]) {
        // Test Growl
        [GrowlApplicationBridge
         notifyWithTitle:@"Title"
         description:@"Description"
         notificationName:@"General Notification"
         iconData:nil
         priority:0
         isSticky:NO
         clickContext:nil];
    }
	return [NSArray array];
}

@end
