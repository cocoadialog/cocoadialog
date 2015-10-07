//
//  CDUpdate.m
//  cocoaDialog
//
//  Created by Mark Whitaker on 10/31/11.
//  Copyright (c) 2011 Mark Whitaker. All rights reserved.
//

#import "CDUpdate.h"
#import <Sparkle/Sparkle.h>

@implementation CDUpdate

- (BOOL) updaterShouldPromptInstall:(SUUpdater*)upd { return NO; }

- (BOOL) updaterShouldRelaunchApplication:(SUUpdater*)upd { return NO; }

- (void) updaterDidNotFindUpdate:(SUUpdater*)upd { exit(2); }

- (void) updater:(SUUpdater*)upd didAbortWithError:(NSError*)error {

  ![self.options hasOpt:@"debug"] ?: [self debug:error ? error.localizedDescription : @"An unknown error occurred while trying to update."];
  exit(1);
}

- (void) update {

    SUUpdater * updater = SUUpdater.sharedUpdater;
    [updater setDelegate:self];
    NSURL *appcastURL = [NSURL URLWithString:NSBundle.mainBundle.infoDictionary[@"SUFeedURL"]];

    appcastURL ? [updater setFeedURL:appcastURL]
               : [updater setFeedURL:[NSURL URLWithString:@"https://raw.github.com/mstratman/cocoadialog/master/sparkle-release/appcast.xml"]];

    [updater setSendsSystemProfile:YES];
    [updater resetUpdateCycle];
    [updater setAutomaticallyChecksForUpdates:YES];
    if ([self.options hasOpt:@"quiet"]) {
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
