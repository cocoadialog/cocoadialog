// CDDialog.h
// cocoadialog
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.

@class CDDialog;

#import <Foundation/Foundation.h>

#import "CDControl.h"
#import "CDTextField.h"

@interface CDDialog : CDControl;

@property(readonly) BOOL allowEmptyReturn;
@property(strong) IBOutlet NSButton *button0;
@property(strong) IBOutlet NSButton *button1;
@property(strong) IBOutlet NSButton *button2;
@property(strong) NSMutableArray <NSButton *> *buttons;
@property(strong) NSNumber *cancelButton;
@property(strong) IBOutlet NSView *controlView;
@property(readonly) NSSize findNewSize;
@property(strong) NSResponder *firstResponder;
@property(strong) IBOutlet CDTextField *header;
@property(readonly) NSImage *icon;
@property(readonly) NSImage *iconImage;
@property(retain) IBOutlet NSImageView *iconView;
@property(retain) NSThread *mainThread;
@property(strong) IBOutlet CDTextField *message;
@property(retain) IBOutlet NSPanel *panel;
@property(readonly) BOOL returnValueEmpty;
@property(readonly, copy) NSString *returnValueEmptyText;
@property(nonatomic) double timeout;
@property(retain) IBOutlet CDTextField *timeoutLabel;
@property(retain) NSTimer *timer;
@property(retain) NSThread *timerThread;

- (void)alertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo;
- (void)controlHasFinished:(NSInteger)button;
- (void)createButtons;
- (void)createControlView;
- (void)createHeader;
- (void)createIcon;
- (void)createMessage;
- (void)createPanel;
- (void)createTitle;
- (void)createTimeout;
- (void)createTimer;
- (NSString *)format:(NSString *)format withSeconds:(NSUInteger)timeInSeconds;
- (void)processTimer;
- (void)returnValueEmptySheet;
- (void)setIconFromImage:(NSImage *)anImage withSize:(NSSize)aSize;

@end
