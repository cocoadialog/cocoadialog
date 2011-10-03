//
//  CDGrowl.h
//  CocoaDialog
//
//  Created by Mark Carver on 10/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Sparkle/Sparkle.h>
#import <Growl/Growl.h>
#import "CDNotifyControl.h"

@interface CDGrowlControl : CDNotifyControl <GrowlApplicationBridgeDelegate>

- (void) addNotificationWithTitle:(NSString *)title
                      description:(NSString *)description
                             icon:(NSImage *)icon
                         priority:(NSNumber *)priority
                           sticky:(BOOL)sticky
                        clickPath:(NSString *)clickPath
                         clickArg:(NSString *)clickArg;

- (NSArray *) parseTextForArguments:(NSString *)string;

@end
