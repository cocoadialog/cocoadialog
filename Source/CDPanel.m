// CDPanel.m
// cocoadialog
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.

#import "CDPanel.h"

@implementation CDPanel

- (void) awakeFromNib {
    if (NSClassFromString(@"NSVisualEffectView") != nil) {
        self.styleMask = self.styleMask | NSFullSizeContentViewWindowMask;

        self.titlebarAppearsTransparent = YES;
        self.movableByWindowBackground = YES;

        NSVisualEffectView* effectView = [[NSVisualEffectView alloc] initWithFrame:[self.contentView bounds]];
        [effectView setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
        [effectView setBlendingMode:NSVisualEffectBlendingModeBehindWindow];
        [effectView setState:NSVisualEffectStateActive];
        [self.contentView addSubview:effectView positioned:NSWindowBelow relativeTo:nil];
        [effectView setMaterial:NSVisualEffectMaterialLight];
    }
}

@end
