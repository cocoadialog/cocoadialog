
#import "CDThreeButtonControl.h"

@implementation CDOkMsgboxControl

- (NSDictionary*) availableKeys
{
	return @{@"alert":  @CDOptionsOneValue, @"label":@CDOptionsOneValue, @"no-cancel": @CDOptionsNoValues};
}

- (void) setButtons {

	button1.title = @"Ok";

	if ([self.options hasOpt:@"no-cancel"])

    BUTTON_SET(button2,NO,YES);

  else {
		button2.title         = @"Cancel";
		button2.keyEquivalent = @"\e";
		BUTTON_SET(button2,YES,NO);
	}

	BUTTON_SET(button3, NO, YES);
}

@end
