// CDProgressbarControl.h
// cocoadialog
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.

#import <sys/select.h>
#import "CDControl.h"
#import "CDProgressbarInputHandler.h"
#import "CDProgressbarInputHandlerDelegate.h"

@interface CDProgressbarControl : CDControl <NSWindowDelegate, CDProgressbarInputHandlerDelegate> {
	IBOutlet NSTextField			*expandingLabel;
	IBOutlet NSProgressIndicator	*progressBar;
	IBOutlet NSButton				*stopButton;

	@private
	NSAlert	*confirmationSheet;

	@private
	BOOL	stopped;

	@private
	BOOL	stopEnabled;
}

-(void) alertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo;
-(void) finish;

-(IBAction)stop:(id)sender;

@end
