// CDPanel.m
// cocoadialog
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.

#import "NSPanel+CDPanel.h"

@implementation NSPanel (CDPanel)

#pragma mark - Storage
- (void) setVibrancy:(BOOL)vibrancy {
    // Explicitly override value if OS doesn't support visual effect views (< 10.10).
    if (NSClassFromString(@"NSVisualEffectView") == nil) {
        vibrancy = NO;
    }

    // Remove any existing effect subviews.
    for (NSView *view in self.contentView.subviews) {
        if ([view isKindOfClass:[NSVisualEffectView class]]) {
            [view removeFromSuperview];
        }
    }

    self.titlebarAppearsTransparent = vibrancy;
    self.movableByWindowBackground = vibrancy;

    if (vibrancy) {
        self.styleMask = self.styleMask | NSFullSizeContentViewWindowMask;
        NSVisualEffectView *view = [[NSVisualEffectView alloc] initWithFrame:[self.contentView bounds]];
        [view setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
        [view setBlendingMode:NSVisualEffectBlendingModeBehindWindow];
        [view setState:NSVisualEffectStateActive];
        [view setMaterial:NSVisualEffectMaterialLight];
        [self.contentView addSubview:view positioned:NSWindowBelow relativeTo:nil];
        self.effectView = view;
    }
    else {
        self.styleMask = self.styleMask ^ NSFullSizeContentViewWindowMask;
        self.effectView = nil;
    }

    objc_setAssociatedObject(self, @selector(vibrancy), [NSNumber numberWithBool:vibrancy], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL) vibrancy {
    NSNumber *number = objc_getAssociatedObject(self, @selector(vibrancy));
    return number.boolValue;
}

- (void) setEffectView:(NSView *)effectView {
    objc_setAssociatedObject(self, @selector(effectView), effectView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSView *) effectView {
    return objc_getAssociatedObject(self, @selector(effectView));
}

- (NSArray <NSTextField *> *) getLabels {
    NSMutableArray *labels = [NSMutableArray array];
    NSArray <NSTextField *> *textFields = [self getObjects:[NSTextField class]];
    for (NSTextField *textField in textFields) {
        if (!textField.bezeled && !textField.drawsBackground && !textField.editable) {
            [labels addObject:textField];
        }
    }
    return labels;
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

- (void) makeLabelsSelectable:(BOOL)selectable {
    NSArray<NSTextField *> *labels = [self getLabels];
    NSEnumerator *en = [labels objectEnumerator];
    NSTextField *label;
    while (label = [en nextObject]) {
        label.selectable = selectable;
    }
}

- (NSArray <NSLayoutConstraint *> *) getConstraintsForView:(NSView *)view {
    NSMutableArray <NSLayoutConstraint *> *constraints = [NSMutableArray arrayWithArray:view.constraints];
    for (NSLayoutConstraint *constraint in self.contentView.constraints) {
        if (constraint.firstItem == view && (constraint.firstAttribute == NSLayoutAttributeLeading || constraint.firstAttribute == NSLayoutAttributeLeft || constraint.firstAttribute == NSLayoutAttributeTop)) {
            [constraints addObject:constraint];
        }
        else if (constraint.secondItem == view && (constraint.secondAttribute == NSLayoutAttributeTrailing || constraint.secondAttribute == NSLayoutAttributeRight || constraint.secondAttribute == NSLayoutAttributeBottom)) {
            [constraints addObject:constraint];
        }
    }
    return constraints;
}

- (NSArray <NSLayoutConstraint *> *) getConstraintsForView:(NSView *)view withAttribute:(NSLayoutAttribute)attribute {
    NSMutableArray <NSLayoutConstraint *> *constraints = [NSMutableArray array];
    NSArray <NSLayoutConstraint *> *viewConstraints = [self getConstraintsForView:view];
    for (NSLayoutConstraint *constraint in viewConstraints) {
        if ((constraint.firstItem == view && constraint.firstAttribute == attribute) || (constraint.secondItem == view && constraint.secondAttribute == attribute)) {
            [constraints addObject:constraint];
        }
    }
    return constraints;
}

- (void) moveContraintAttribute:(NSLayoutAttribute)attribute toVisibleView:(NSArray <NSView *> *)views {
    NSView *currentView, *nextView;
    for (NSUInteger i = 0; i < views.count; i++) {
        currentView = views[i];
        nextView = i + 1 < views.count ? views[i + 1] : nil;
        // Stop if the current view is visible or there is no next view.
        if (!currentView.hidden || nextView == nil) {
            break;
        }
        [self moveContraintAttribute:attribute from:currentView to:nextView];
    }
    // Recurse down the array of views.
    if (views.count > 1) {
        [self moveContraintAttribute:attribute toVisibleView:[views subarrayWithRange:NSMakeRange(1, views.count - 1)]];
    }
}

- (void) moveContraintAttribute:(NSLayoutAttribute)attribute from:(NSView *)firstView to:(NSView *)secondView {
    NSArray <NSLayoutConstraint *> *firstViewConstraints = [self getConstraintsForView:firstView withAttribute:attribute];
    NSArray <NSLayoutConstraint *> *secondViewConstraints = [self getConstraintsForView:secondView withAttribute:attribute];

    // Do nothing if the original constraint was not found.
    if (!firstViewConstraints.count || !secondViewConstraints.count) {
        return;
    }

    NSMutableArray <NSLayoutConstraint *> *existingConstraints = [NSMutableArray array];
    [existingConstraints addObjectsFromArray: firstViewConstraints];
    [existingConstraints addObjectsFromArray: secondViewConstraints];

    // Remove all existing layout constraints for both views matching the attribute.
    if (existingConstraints.count) {
        [self.contentView removeConstraints:existingConstraints];
    }

    // Add the first item's original constraints to the secondView.
    for (NSLayoutConstraint *constraint in firstViewConstraints) {
        [self.contentView addConstraint:[NSLayoutConstraint
                                         constraintWithItem:secondView
                                         attribute:constraint.firstAttribute
                                         relatedBy:constraint.relation
                                         toItem:constraint.secondItem
                                         attribute:constraint.secondAttribute
                                         multiplier:constraint.multiplier
                                         constant:constraint.constant]];
    }
}

- (void) removeConstraintsFrom:(NSView *)view {
    [self.contentView removeConstraints:[self getConstraintsForView:view]];
}

- (void) removeConstraintsFrom:(NSView *)view withAttribute:(NSLayoutAttribute)attribute {
    [self.contentView removeConstraints:[self getConstraintsForView:view withAttribute:attribute]];
}

- (void) removeSubview:(NSView *)view {
    if (![self.contentView.subviews containsObject:view]) {
        return;
    }
    view.hidden = YES;
    [self.contentView removeConstraints:[self getConstraintsForView:view]];
    [view removeFromSuperview];
}

- (void) removeSubview:(NSView *)from movingAttribute:(NSLayoutAttribute)attribute to:(NSView *)to {
    [self moveContraintAttribute:attribute from:from to:to];
    [self removeSubview:from];
}

@end
