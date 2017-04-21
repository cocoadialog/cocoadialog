// CDThreeButtonControl.h
// cocoadialog
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.

#import "CDControl.h"

@interface CDThreeButtonControl : CDControl {
	IBOutlet NSTextField    *expandingLabel;
    IBOutlet NSMatrix       *controlMatrix;
	IBOutlet NSButton       *button1;
	IBOutlet NSButton       *button2;
	IBOutlet NSButton       *button3;
    NSUInteger              cancelButton;
}

- (void) controlHasFinished:(NSUInteger)button;

- (IBAction) button1Pressed:(id)sender;
- (IBAction) button2Pressed:(id)sender;
- (IBAction) button3Pressed:(id)sender;

- (IBAction)setControl:(id)sender;
- (void) setControl: (id)sender matrixRows:(NSInteger)rows matrixColumns:(NSInteger)columns items:(NSArray *)items precedence:(int)precedence;

// This resizes too. Use it instead of the 3 contained method calls
- (void) setTitleButtonsLabel:(NSString *)labelText;

- (void) setButtons;
- (void) setLabel:(NSString *)labelText;

- (void) setTitle:(NSString*)aTitle forButton:(NSButton*)aButton;

@property (NS_NONATOMIC_IOSONLY, readonly) BOOL allowEmptyReturn;
@property (NS_NONATOMIC_IOSONLY, getter=isReturnValueEmpty, readonly) BOOL returnValueEmpty;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *returnValueEmptyText;

- (void) returnValueEmptySheet;
- (void) alertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo;

@end
