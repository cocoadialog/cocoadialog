
#import "CDThreeButtonControl.h"

@implementation CDYesNoMsgboxControl

- (NSDictionary*) availableKeys
{
	NSNumber *vOne = @CDOptionsOneValue;
	NSNumber *vNone = @CDOptionsNoValues;

	return @{@"alert": vOne,
            @"label": vOne,
		@"no-cancel": vNone};
}

- (void) setButtons {
	[button1 setTitle:@"Yes"];
	[button2 setEnabled:YES];
	[button2 setHidden:NO];
	[button2 setTitle:@"No"];
	if ([self.options hasOpt:@"no-cancel"]) {
		[button3 setEnabled:NO];
		[button3 setHidden:YES];
	} else {
		[button3 setTitle:@"Cancel"];
		[button3 setKeyEquivalent:@"\e"];
		[button3 setEnabled:YES];
		[button3 setHidden:NO];
	}
}

@end
