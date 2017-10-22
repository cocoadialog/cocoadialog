// NSPanel+CDPanel.h
// cocoadialog
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.

#import <objc/runtime.h>
#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

@interface NSPanel (CDPanel)

@property(strong) NSView *effectView;
@property BOOL vibrancy;

- (NSArray <NSLayoutConstraint *> *)getConstraintsForView:(NSView *)view;
- (NSArray <NSLayoutConstraint *> *)getConstraintsForView:(NSView *)view withAttribute:(NSLayoutAttribute)attribute;
- (NSArray <NSTextField *> *)getLabels;
- (NSArray *)getObjects:(Class)objectClass;
- (NSArray *)getObjects:(Class)objectClass fromView:(NSView *)view;
- (void)makeLabelsSelectable:(BOOL)selectable;
- (void)moveContraintAttribute:(NSLayoutAttribute)attribute from:(NSView *)firstView to:(NSView *)secondView;
- (void)moveContraintAttribute:(NSLayoutAttribute)attribute toVisibleView:(NSArray <NSView *> *)views;
- (void)removeConstraintsFrom:(NSView *)view;
- (void)removeConstraintsFrom:(NSView *)view withAttribute:(NSLayoutAttribute)attribute;
- (void)removeSubview:(NSView *)view;
- (void)removeSubview:(NSView *)from movingAttribute:(NSLayoutAttribute)attribute to:(NSView *)to;

@end
