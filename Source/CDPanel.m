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

- (NSArray *) getObjects:(Class)objectClass {
    return [self getObjects:objectClass fromView:self.contentView];
}

- (NSArray *) getObjects:(Class)objectClass fromView:(NSView *)view {
    NSMutableArray *array = [NSMutableArray array];
    if([view isKindOfClass:objectClass]) {
        [array addObject:view];
    }
    // Traverse any subviews.
    for (NSView *subview in [view subviews]) {
        [array addObjectsFromArray:[self getObjects:objectClass fromView:subview]];
    }
    return array;
}

- (void) makeLargerFontsThinner {
    BOOL isUltraLightFontWeightAvailable = (&NSFontWeightUltraLight != NULL);
    if (isUltraLightFontWeightAvailable) {
        NSArray<NSTextField *> *textFields = [self getObjects:[NSTextField class]];
        for (NSUInteger i = 0; i < textFields.count; i++) {
            if (textFields[i].font.pointSize > 28) {
                textFields[i].font = [NSFont systemFontOfSize:textFields[i].font.pointSize weight:NSFontWeightUltraLight];
            }
        }
    }
}


@end
