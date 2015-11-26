/*
	CDProgressbarControl.h
	cocoaDialog
*/

#import <Foundation/Foundation.h>
#import "CDControl.h"
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

-(void) alertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void*)contextInfo;

-(IBAction)stop:(id)sender;

@end
