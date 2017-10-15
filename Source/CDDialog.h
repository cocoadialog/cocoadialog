// CDDialog.h
// cocoadialog
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.

@class CDDialog;

#import "CDControl.h"
#import "CDTextField.h"

@interface CDDialog : CDControl;

#pragma mark - Properties
@property (readonly)                 BOOL                   allowEmptyReturn;
@property (readonly)                 BOOL                   returnValueEmpty;
@property (readonly, copy)           NSString               *returnValueEmptyText;
@property (strong)                   NSResponder            *firstResponder;

#pragma mark - Public static methods

#pragma mark - Public instance methods
- (void) alertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo;
- (void) returnValueEmptySheet;

#pragma mark - Buttons
@property (strong)       IBOutlet       NSButton                            *button0;
@property (strong)       IBOutlet       NSButton                            *button1;
@property (strong)       IBOutlet       NSButton                            *button2;
@property (strong)                      NSMutableArray <NSButton *>         *buttons;
@property (strong)                      NSNumber                            *cancelButton;
- (void) controlHasFinished:(NSUInteger)button;
- (void) createButtons;

#pragma mark - Control view.
@property (strong)       IBOutlet    NSView                  *controlView;
- (void) createControlView;

#pragma mark - Header
@property (strong)       IBOutlet    CDTextField             *header;
- (void) createHeader;

#pragma mark - Icon
@property (readonly)                 NSImage                 *icon;
@property (readonly)                 NSImage                 *iconImage;
@property (retain)       IBOutlet    NSImageView             *iconView;
- (void) createIcon;
- (void) setIconFromImage:(NSImage *)anImage withSize:(NSSize)aSize;

#pragma mark - Message
@property (strong)       IBOutlet    CDTextField             *message;
- (void) createMessage;

#pragma mark - Panel
@property (readonly)                 NSSize                  findNewSize;
@property (retain)       IBOutlet    NSPanel                 *panel;
- (void) createPanel;
- (void) createTitle;

#pragma mark - Timeout
@property (retain)                   NSThread                *mainThread;
@property (retain)                   NSTimer                 *timer;
@property (retain)                   NSThread                *timerThread;
@property (nonatomic)                double                  timeout;
@property (retain)       IBOutlet    CDTextField             *timeoutLabel;
- (void) createTimeout;
- (void) createTimer;
- (NSString *) format:(NSString *)format withSeconds:(NSUInteger)timeInSeconds;
- (void) processTimer;

@end
