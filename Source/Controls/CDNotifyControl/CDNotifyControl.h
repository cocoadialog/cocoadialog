// CDNotifyControl.h
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.

#import "CDControl.h"

@interface CDNotifyControl : CDControl {
    int             activeNotifications;
    NSMutableArray  *notifications;
}

- (void) addNotificationWithTitle:(NSString *)title
                      description:(NSString *)description
                             icon:(NSImage *)_icon
                         priority:(NSNumber *)priority
                           sticky:(BOOL)sticky
                        clickPath:(NSString *)clickPath
                         clickArg:(NSString *)clickArg;

@property (nonatomic, readonly, copy) NSArray *notificationIcons;

- (void) notificationWasClicked:(id)clickContext;
- (NSArray *) parseTextForArguments:(NSString *)string;

@end
