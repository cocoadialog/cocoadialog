//
//  CDUpdate.m
//  cocoaDialog
//
//  Created by Mark Whitaker on 10/31/11.
//  Copyright (c) 2011 Mark Whitaker. All rights reserved.
//

#import "CDUpdate.h"

@implementation CDUpdate

- (BOOL) updaterShouldPromptInstall:(SUUpdater *)updater {
    return NO;
}

- (BOOL) updaterShouldRelaunchApplication:(SUUpdater *)updater {
    return NO;
}

- (void) updater:(SUUpdater *)updater didAbortWithError:(NSError *)error {
    if ([options hasOpt:@"debug"]) {
        NSString *output = @"An unknown error occurred while trying to update.";
        if (error) {
            output = [error localizedDescription];
        }
        [self debug:output];
    }
    exit(1);
}

- (void) updaterDidNotFindUpdate:(SUUpdater *)update {
    exit(2);
}

- (void) update {
    SUUpdater * updater = [SUUpdater sharedUpdater];
    [updater setDelegate:self];
    NSURL *appcastURL = [NSURL URLWithString:[[NSBundle mainBundle] infoDictionary][@"SUFeedURL"]];
    if (appcastURL) {
        [updater setFeedURL:appcastURL];
    }
    else {
        [updater setFeedURL:[NSURL URLWithString:@"https://raw.github.com/mstratman/cocoadialog/master/sparkle-release/appcast.xml"]];
    }
    [updater setSendsSystemProfile:YES];
    [updater resetUpdateCycle];
    [updater setAutomaticallyChecksForUpdates:YES];
    if ([options hasOpt:@"quiet"]) {
        [updater setAutomaticallyDownloadsUpdates:YES];
        [updater checkForUpdatesInBackground];
    }
    else {
        [updater setAutomaticallyDownloadsUpdates:NO];
        [updater checkForUpdates:nil];
    }
    [NSApp run];
}

@end
