
#import "CDThreeButtonControl.h"

@implementation CDStandardPopUpButtonControl

- (NSDictionary*) availableKeys
{
    NSNumber *vOne = @CDOptionsOneValue;
	NSNumber *vNone = @CDOptionsNoValues;
	NSNumber *vMul = @CDOptionsMultipleValues;
    
	return @{@"items": vMul,
            @"selected": vOne,
            @"exit-onchange": vNone,
            @"pulldown": vNone,
            @"no-cancel": vNone};
}

- (void) setButtons {
	[button1 setTitle:@"Okay"];
	if ([self.options hasOpt:@"no-cancel"]) {
		[button2 setEnabled:NO];
		[button2 setHidden:YES];
	} else {
		[button2 setTitle:@"Cancel"];
		[button2 setKeyEquivalent:@"\e"];
	}
	[button3 setEnabled:NO];
	[button3 setHidden:YES];
}

@end
