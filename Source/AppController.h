// AppController.h
// cocoadialog
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.

// Category extensions.
#import "NSArray+CocoaDialog.h"
#import "NSString+CocoaDialog.h"

// Controls.
#import "CDControl.h"
#import "CDBubbleControl.h"
#import "CDCheckboxControl.h"
#import "CDFileSelectControl.h"
#import "CDFileSaveControl.h"
#import "CDGrowlControl.h"
#import "CDInputboxControl.h"
#import "CDMsgboxControl.h"
#import "CDNotifyControl.h"
#import "CDOkMsgboxControl.h"
#import "CDPopUpButtonControl.h"
#import "CDProgressbarControl.h"
#import "CDRadioControl.h"
#import "CDSecureInputboxControl.h"
#import "CDSecureStandardInputboxControl.h"
#import "CDSlider.h"
#import "CDStandardInputboxControl.h"
#import "CDStandardPopUpButtonControl.h"
#import "CDTextboxControl.h"
#import "CDYesNoMsgboxControl.h"

#pragma mark - Constants
#define CDSite "https://mstratman.github.io/cocoadialog/"

#pragma mark -
@interface AppController : NSObject

#pragma mark - Properties
@property (nonatomic, retain) IBOutlet  NSTextField *aboutAppLink;
@property (nonatomic, retain) IBOutlet  NSPanel     *aboutPanel;
@property (nonatomic, retain) IBOutlet  NSTextField *aboutText;
@property (nonatomic, readonly, copy)   NSString    *appVersion;

#pragma mark - Public static methods
+ (NSString *) appVersion;
+ (NSArray<NSString *> *) availableControls;

#pragma mark - Public instance methods
- (CDControl *) getControl;
- (void)setHyperlinkForTextField:(NSTextField*)aTextField replaceString:(NSString *)aString withURL:(NSString *)aURL;
@end

#pragma mark -
@interface NSAttributedString (Hyperlink)
    +(id)hyperlinkFromString:(NSString*)inString withURL:(NSURL*)aURL withFont:(NSFont *)aFont;
@end
