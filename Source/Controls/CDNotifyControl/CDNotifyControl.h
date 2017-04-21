// CDNotifyControl.h
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.

#import <objc/runtime.h>
#import <ScriptingBridge/ScriptingBridge.h>
#import "CDControl.h"

@interface CDNotifyControl : CDControl

- (void) notificationActivated:(NSUserNotification *)notification;

@end
