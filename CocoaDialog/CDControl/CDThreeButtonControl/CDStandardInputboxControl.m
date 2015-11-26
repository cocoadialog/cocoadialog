/*
	CDStandardInputboxControl.m
	cocoaDialog
*/

#import "CDThreeButtonControl.h"


@implementation CDStandardInputboxControl

- (NSDictionary*) availableKeys
{
	NSNumber *vOne = @CDOptionsOneValue;
	NSNumber *vNone = @CDOptionsNoValues;
	
	return @{@"value": vOne,
            @"selected": vNone,
            @"no-cancel": vNone,
            @"no-show": vNone};
}

- (void) setButtons {
	[button1 setTitle:@"Okay"];
	if ([self.options hasOpt:@"no-cancel"]) {
		[button2 setEnabled:NO];
		[button2 setHidden:YES];
	} else {
		[button2 setTitle:@"Cancel"];
		[button2 setKeyEquivalent:@"\e"];
        cancelButton = 2;
	}
	[button3 setEnabled:NO];
	[button3 setHidden:YES];
}

@end
