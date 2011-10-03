//
//  CDNotifyControl.h
//  CocoaDialog
//
//  Created by Mark Carver on 10/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "CDControl.h"

@interface CDNotifyControl : CDControl {
    int             activeNotifications;
    NSMutableArray  *notifications;
}

- (NSImage *) notificationIcon;
- (NSArray *) notificationIcons;

@end
