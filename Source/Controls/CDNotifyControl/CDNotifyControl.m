// CDNotifyControl.m
// cocoadialog
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.

#import "CDNotifyControl.h"

@implementation CDNotifyControl

- (CDOptions *) availableOptions {
    // @todo Add a way to "hide" certain global options since they don't all apply here.
    CDOptions *options = [super availableOptions];

    // Text.
    [options addOption:[CDOptionSingleString            name:@"subtitle"]];
    [options addOption:[CDOptionSingleString            name:@"text"]];

    // Clicks handler(s).
    [options addOption:[CDOptionSingleString            name:@"click-arg"]];
    [options addOption:[CDOptionSingleString            name:@"click-path"]];

    // Required options.
    options[@"title"].required = YES;
    options[@"title"].defaultValue = nil;

    return options;
}

- (void) notificationActivated:(NSUserNotification *)notification {

    id app = [SBApplication applicationWithBundleIdentifier:notification.userInfo[@"bundleIdentifier"]];
    if (app) {
        [app activate];
    }

    NSString *command = notification.userInfo[@"command"];
    if (command) {
        NSPipe *pipe = [NSPipe pipe];
        NSFileHandle *fileHandle = [pipe fileHandleForReading];

        NSTask *task = [NSTask new];
        task.launchPath = @"/bin/sh";
        task.arguments = @[@"-c", command];
        task.standardOutput = pipe;
        task.standardError = pipe;
        [task launch];

        NSData *data = nil;
        NSMutableData *accumulatedData = [NSMutableData data];
        while ((data = [fileHandle availableData]) && [data length]) {
            [accumulatedData appendData:data];
        }

        [task waitUntilExit];
        NSLog(@"command output:\n%@", [[NSString alloc] initWithData:accumulatedData encoding:NSUTF8StringEncoding]);
    }

    [[NSUserNotificationCenter defaultUserNotificationCenter] removeDeliveredNotification:notification];
}


- (void) runControl {
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];

    NSBundle *appBundle = [self appBundle];
    if (appBundle) {
        userInfo[@"bundleIdentifier"] = appBundle.bundleIdentifier;
    }

    NSUserNotification *notification = [NSUserNotification new];

    notification.title = option[@"title"].stringValue;
    notification.subtitle = option[@"subtitle"].stringValue;
    notification.informativeText = option[@"description"].stringValue;

    NSImage *icon = [self icon] ?: [[NSWorkspace sharedWorkspace] iconForFile:[appBundle bundlePath]];
    if (icon) {
        [notification setValue:icon forKey:@"_identityImage"];
        [notification setValue:@NO forKey:@"_identityImageHasBorder"];
    }

    notification.soundName = NSUserNotificationDefaultSoundName;


    // Todo replace with actual option supplied command.
    NSMutableString *command = [NSMutableString stringWithString:[NSBundle mainBundle].bundlePath];
    [command appendString:@"/Contents/MacOS/cocoadialog msgbox --title 'Notification Action' --label 'This opened when you clicked the notification.' --button1 Okay --button2 Cancel"];

    userInfo[@"command"] = command;

    notification.userInfo = userInfo;

    [NSUserNotificationCenter.defaultUserNotificationCenter deliverNotification:notification];

    [NSApp run];
}


@end
