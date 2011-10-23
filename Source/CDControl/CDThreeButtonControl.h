/*
	CDThreeButtonControl.h
	CocoaDialog
	Copyright (C) 2004-2006 Mark A. Stratman <mark@sporkstorms.org>
 
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
#import "CDControl.h"

@interface CDThreeButtonControl : CDControl {
	IBOutlet NSTextField    *expandingLabel;
    IBOutlet NSMatrix       *controlMatrix;
	IBOutlet NSButton       *button1;
	IBOutlet NSButton       *button2;
	IBOutlet NSButton       *button3;
    int rv;
}

- (IBAction) timeout:(id)sender;
- (IBAction) button1Pressed:(id)sender;
- (IBAction) button2Pressed:(id)sender;
- (IBAction) button3Pressed:(id)sender;

- (void) runAndSetRv;

- (void) setTimeout;

- (IBAction)setControl:(id)sender;
- (void) setControl: (id)sender matrixRows:(NSInteger)rows matrixColumns:(NSInteger)columns items:(NSArray *)items precedence:(int)precedence;

// This resizes too. Use it instead of the 3 contained method calls
- (void) setTitleButtonsLabel:(NSString *)labelText;

- (void) setTitle;
- (void) setButtons;
- (void) setLabel:(NSString *)labelText;

- (void) setTitle:(NSString*)aTitle forButton:(NSButton*)aButton;

- (BOOL) allowEmptyReturn;
- (BOOL) isReturnValueEmpty;
- (NSString *) returnValueEmptyText;

- (void) returnValueEmptySheet;
- (void) alertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo;

@end
