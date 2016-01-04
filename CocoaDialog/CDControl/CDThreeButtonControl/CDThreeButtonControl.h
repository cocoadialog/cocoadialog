
#import "CDControl.h"

#define BUTTON_SET(BUTTON,ENABLED,HIDDEN) ({ BUTTON.enabled = ENABLED; BUTTON.hidden  = HIDDEN; })

@interface CDThreeButtonControl : CDControl {

  IBOutlet NSTextField    *expandingLabel;
  IBOutlet NSMatrix       *controlMatrix;
	IBOutlet NSButton       *button1, *button2, *button3;

  int cancelButton;
}

@property (readonly) BOOL allowEmptyReturn;
@property (getter=isReturnValueEmpty, readonly) BOOL returnValueEmpty;
@property (readonly, copy) NSString *returnValueEmptyText;


- (void) controlHasFinished:(int)button;

- (IBAction) button1Pressed:b1;
- (IBAction) button2Pressed:b2;
- (IBAction) button3Pressed:b3;

- (IBAction)setControl:sender;
- (void) setControl:sender matrixRows:(NSInteger)rows matrixColumns:(NSInteger)columns items:(NSArray*)items precedence:(int)precedence;

// This resizes too. Use it instead of the 3 contained method calls
- (void) setTitleButtonsLabel:(NSString*)labelText;

- (void) setButtons;
- (void) setLabel:(NSString*)labelText;

- (void) setTitle:(NSString*)aTitle forButton:(NSButton*)aButton;

- (void) returnValueEmptySheet;
- (void) alertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void*)contextInfo;

@end


#pragma mark - Variations

@interface     CDInputboxControl : CDThreeButtonControl
@end
@interface CDStandardInputboxControl : CDInputboxControl
@end


@interface        CDRadioControl : CDThreeButtonControl
@end
@interface     CDCheckboxControl : CDThreeButtonControl
@property         NSMutableArray * checkboxes;
@end

@interface       CDMsgboxControl : CDThreeButtonControl
@property IBOutlet   NSTextField * text;
@end
@interface     CDOkMsgboxControl : CDMsgboxControl
@end
@interface  CDYesNoMsgboxControl : CDMsgboxControl
@end

@interface      CDTextboxControl : CDThreeButtonControl
@property IBOutlet    NSTextView * textView;
@property	IBOutlet NSScrollView  * scrollView;

- (void) setLabel:(NSString*)labelText;


@end


@interface  CDPopUpButtonControl : CDThreeButtonControl
@property IBOutlet NSPopUpButton * popupControl;

- (void) selectionChanged:x;

@end
@interface CDStandardPopUpButtonControl : CDPopUpButtonControl
@end



