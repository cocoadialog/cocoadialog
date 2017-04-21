// CDProgressbarControl.m
// cocoadialog
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.

#import "CDProgressbarControl.h"
#import "CDProgressbarInputHandler.h"
#import <sys/select.h>

@implementation CDProgressbarControl

- (NSString *) controlNib {
	return @"Progressbar";
}

- (CDOptions *) availableOptions {
    CDOptions *options = [super availableOptions];

    [options addOption:[CDOptionSingleString    name:@"text"]];
    [options addOption:[CDOptionSingleString    name:@"percent"]];
    [options addOption:[CDOptionFlag            name:@"indeterminate"]];
    [options addOption:[CDOptionFlag            name:@"float"]];
    [options addOption:[CDOptionFlag            name:@"stoppable"]];

    return options;
}

-(void) updateProgress:(NSNumber*)newProgress {
	progressBar.doubleValue = newProgress.doubleValue;
}

-(void) updateLabel:(NSString*)newLabel {
	expandingLabel.stringValue = newLabel;
}

-(void) finish {
	if (confirmationSheet) {
		[NSApp endSheet:confirmationSheet.window];
		[confirmationSheet release];
		confirmationSheet = nil;
	}

	if (stopped) {
        // @todo write to stderr instead.
        [self.terminal writeLine:@"stopped"];
	}

	[NSApp terminate:nil];
}

-(void) confirmStop {
	confirmationSheet = [[NSAlert alloc] init];
    [confirmationSheet setIcon:[self iconFromName:@"caution"]];
	[confirmationSheet addButtonWithTitle:NSLocalizedString(@"Stop", nil)];
	[confirmationSheet addButtonWithTitle:NSLocalizedString(@"Cancel", nil)];
	confirmationSheet.messageText = NSLocalizedString(@"Are you sure you want to stop?", nil);
	[confirmationSheet beginSheetModalForWindow:self.panel modalDelegate:self didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) contextInfo:nil];
}

- (void) alertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
	if (confirmationSheet == alert) {
		[confirmationSheet release];
		confirmationSheet = nil;
	}
	if (returnCode == NSAlertFirstButtonReturn && stopEnabled) {
		stopped = YES;
		[self finish];
	}
}

-(IBAction)stop:(id)sender {
	[self confirmStop];
}

-(void) setStopEnabled:(NSNumber*)enabled {
	stopEnabled = enabled.boolValue;
	stopButton.enabled = stopEnabled;
}

- (void) createControl {
	stopEnabled = YES;
	
	[self addMinWidth:progressBar.frame.size.width + 30.0f];
	[self iconAffectedByControl:expandingLabel];
	[self iconAffectedByControl:progressBar];

	// Set text label.
    expandingLabel.stringValue = option[@"text"].wasProvided ? option[@"text"].stringValue : @"";

	// Hide stop button if not stoppable and resize window/controls.
	if (!option[@"stoppable"].wasProvided) {
		NSRect progressBarFrame = progressBar.frame;

		NSRect currentWindowFrame = self.panel.frame;
		CGFloat stopButtonWidth = stopButton.frame.size.width;
		NSRect newWindowFrame = {
			.origin = currentWindowFrame.origin,
			.size = NSMakeSize(currentWindowFrame.size.width - stopButtonWidth + 2, currentWindowFrame.size.height)
		};
		[self.panel setFrame:newWindowFrame display:NO];

		progressBar.frame = progressBarFrame;
		[stopButton setHidden:YES];
	}

	[self resize];
	
	CDProgressbarInputHandler *inputHandler = [[CDProgressbarInputHandler alloc] init];
	[inputHandler setDelegate:self];

	[progressBar setMinValue:CDProgressbarMIN];
	[progressBar setMaxValue:CDProgressbarMAX];
	
	// Set initial percent.
	if (option[@"percent"].wasProvided) {
		double initialPercent;
		if ([inputHandler parseString:option[@"percent"].stringValue intoProgress:&initialPercent]) {
			progressBar.doubleValue = initialPercent;
		}
	}
		
	// Set window title.
	if (option[@"title"].wasProvided) {
		self.panel.title = option[@"title"].stringValue;
	}

	// set indeterminate
	if (option[@"indeterminate"].wasProvided) {
		[progressBar setIndeterminate:YES];
		[progressBar startAnimation:self];
	} else {
		[progressBar setIndeterminate:NO];
	}

	NSOperationQueue* queue = [[NSOperationQueue new] autorelease];
	[queue addOperation:inputHandler];
	[inputHandler release];
}

@end
