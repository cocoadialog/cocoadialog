/*
	AppController.h
	cocoaDialog
	Copyright (C) 2004 Mark A. Stratman <mark@sporkstorms.org>

	This program is free software; you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation; either version 2 of the License, or
	(at your option) any later version.
 
	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.
 
	You should have received a copy of the GNU General Public License
	along with this program; if not, write to the Free Software
	Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
*/

#import <Foundation/Foundation.h>

// Category extensions.
#import "NSArray+CDCommon.h"
#import "NSString+CDCommon.h"

// Core.
#import "CDArguments.h"
#import "CDTput.h"

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

#define CDSite "https://mstratman.github.io/cocoadialog/"

@interface AppController : NSObject {
    IBOutlet NSPanel        *aboutPanel;
    IBOutlet NSTextField    *aboutAppLink;
    IBOutlet NSTextField    *aboutText;
}

+ (NSString *) appVersion;

@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *appVersion;

+ (NSDictionary *) availableControls;
- (CDControl *) findControl;
- (void)setHyperlinkForTextField:(NSTextField*)aTextField replaceString:(NSString *)aString withURL:(NSString *)aURL;
@end

@interface NSAttributedString (Hyperlink)
    +(id)hyperlinkFromString:(NSString*)inString withURL:(NSURL*)aURL withFont:(NSFont *)aFont;
@end
