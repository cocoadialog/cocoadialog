/*
	CDMsgboxControl.m
	cocoaDialog
*/

#import "CDThreeButtonControl.h"

@implementation CDMsgboxControl

- (NSDictionary*) availableKeys
{
	NSNumber *vOne = @CDOptionsOneValue;
//	NSNumber *vNone = [NSNumber numberWithInt:CDOptionsNoValues];

	return @{@"alert": vOne,
		@"label": vOne};
}

- (NSDictionary*) depreciatedKeys
{
	return @{@"text": @"alert", @"informative-text": @"label"};
}

- (NSString*) controlNib { return @"Msgbox"; }

- (BOOL) validateOptions { return YES; }

- (void) createControl {
  // Add extra control
  [self.icon addControl:self.text];
	// add the main bold text
	if ([self.options optValue:@"alert"]) [self.text setStringValue:[self.options optValue:@"alert"]];
	[self setTitleButtonsLabel:[self.options optValue:@"label"]];
}

@end
