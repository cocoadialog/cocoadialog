//
//  CDCheckboxControl.m
//  CocoaDialog
//
//  Created by Mark Carver on 9/20/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "CDCheckboxControl.h"

@implementation CDCheckboxControl

- (NSDictionary *) availableKeys
{
	NSNumber *vNone = [NSNumber numberWithInt:CDOptionsNoValues];
	NSNumber *vOne = [NSNumber numberWithInt:CDOptionsOneValue];
	NSNumber *vMul = [NSNumber numberWithInt:CDOptionsMultipleValues];
    
	return [NSDictionary dictionaryWithObjectsAndKeys:
            vOne, @"text",
            vOne, @"button1",
            vOne, @"button2",
            vOne, @"button3",
            vOne, @"cancel",
            vNone,@"allow-mixed",
            vMul, @"items",
            vMul, @"checked",
            vMul, @"mixed",
            vMul, @"disabled",
            vNone, @"float",
            vOne, @"timeout",
            nil];
}

- (NSArray *) runControlFromOptions:(CDOptions *)options
{
	NSString *buttonRv = nil;
	NSString *itemRv   = nil;
    
	[self setOptions:options];
    
	// check that they specified at least a button1
	// return nil if not
	if (![options optValue:@"button1"] 
	    && [self isMemberOfClass:[CDCheckboxControl class]]) 
	{
		if ([options hasOpt:@"debug"]) {
			[CDControl debug:@"Must supply at least a --button1"];
		}
		return nil;
	}
    
	// Load Checkbox.xib or return nil
	if (![NSBundle loadNibNamed:@"tbc" owner:self]) {
		if ([options hasOpt:@"debug"]) {
			[CDControl debug:@"Could not load tbc.xib"];
		}
		return nil;
	}
    
	[self setTitleButtonsLabel:[options optValue:@"text"]];
	
	[self setTimeout];
    
	[self runAndSetRv];
    
	// set return values 
	if ([options hasOpt:@"string-output"]) {
		if (rv == 1) {
			buttonRv = [button1 title];
		} else if (rv == 2) {
			buttonRv = [button2 title];
		} else if (rv == 3) {
			buttonRv = [button3 title];
		} else if (rv == 4) {
			buttonRv = @"4";
		} else if (rv == 0) {
			buttonRv = @"timeout";
		}
        if (checkboxes != nil && [checkboxes count]) {
            NSMutableArray *itemRvArray = [[[NSMutableArray alloc] init] autorelease];
            NSEnumerator *en = [checkboxes objectEnumerator];
            id obj;
            int state;
            while (obj = [en nextObject]) {
                state = [obj state];
                switch (state) {
                    case NSOffState: [itemRvArray addObject: @"off"]; break;
                    case NSOnState: [itemRvArray addObject: @"on"]; break;
                    case NSMixedState: [itemRvArray addObject: @"mixed"]; break;
                }
            }
            itemRv = [itemRvArray componentsJoinedByString:@" "];
        }
	} else {
		buttonRv = [NSString stringWithFormat:@"%d",rv];
        if (checkboxes != nil && [checkboxes count]) {
            NSMutableArray *itemRvArray = [[[NSMutableArray alloc] init] autorelease];
            NSEnumerator *en = [checkboxes objectEnumerator];
            id obj;
            while (obj = [en nextObject]) {
                [itemRvArray addObject: [NSString stringWithFormat:@"%i", [obj state]]];
            }
            itemRv = [itemRvArray componentsJoinedByString:@" "];
        }
	}
	return [NSArray arrayWithObjects:buttonRv, itemRv, nil];
}

// Should be called after setButtons, and before resize
- (void) setLabel:(NSString *)labelText
{
	if (labelText != nil) {
		[expandingLabel setStringValue:labelText];
	} else {
		[expandingLabel setStringValue:@""];
	}
    
    NSRect labelRect = [expandingLabel frame];
    NSTextStorage *textStorage = [[[NSTextStorage alloc] initWithString: labelText]autorelease];
    NSTextContainer *textContainer = [[[NSTextContainer alloc] initWithContainerSize:NSMakeSize(labelRect.size.width, FLT_MAX)] autorelease];
    NSLayoutManager *layoutManager = [[[NSLayoutManager alloc]init] autorelease];
    [layoutManager addTextContainer: textContainer];
    [textStorage addLayoutManager: layoutManager];
    [textContainer setLineFragmentPadding:0];
    [layoutManager glyphRangeForTextContainer:textContainer];
    
    float labelNewHeight = [layoutManager usedRectForTextContainer:textContainer].size.height;
    float labelHeightDiff = labelNewHeight - labelRect.size.height;
    
    // Set label's new height
    NSRect l = NSMakeRect(labelRect.origin.x, labelRect.origin.y - labelHeightDiff, labelRect.size.width, labelNewHeight);
    [expandingLabel setFrame: l];

    // Set panel's new width and height
    NSSize p = [[panel contentView] frame].size;
	p.height += labelHeightDiff;
	[panel setContentSize:p];
    [panel center];
    
   
}

- (void) setControl
{
    CDOptions *options = [self options];

    // Setup control
    
    NSArray *items = [[[NSArray alloc] init] autorelease];
    NSArray *checked = [[[NSArray alloc] init] autorelease];
    NSArray *mixed = [[[NSArray alloc] init] autorelease];
    NSArray *disabled = [[[NSArray alloc] init] autorelease];
    
    // Setup the checkbox items
	items = [options optValues:@"items"];
    if ([options hasOpt:@"checked"]) {
        checked = [options optValues:@"checked"];
    }
    if ([options hasOpt:@"allow-mixed"] && [options hasOpt:@"mixed"]) {
        mixed = [options optValues:@"mixed"];
    }
    if ([options hasOpt:@"disabled"]) {
        disabled = [options optValues:@"disabled"];
    }
    checkboxes = [[[NSMutableArray alloc] init] autorelease];
    int count = 0;
	if (items != nil && [items count]) {
		NSEnumerator *en = [items objectEnumerator];
        NSRect viewFrame = [controlView frame];
        NSFont * checkboxFont = [expandingLabel font];
		id obj;
		while (obj = [en nextObject]) {
            NSRect frame = NSMakeRect(0, 0, viewFrame.size.width, 18);
            NSButton *checkBox = [[NSButton alloc] initWithFrame:frame];
            [checkBox setTag: count];
            [checkBox setFont:checkboxFont];
            [checkBox setButtonType:NSSwitchButton];
            [checkBox setTitle:(NSString *)obj];
            if (checked != nil && [checked count]) {
                if ([checked containsObject:[NSString stringWithFormat:@"%i", count]]) {
                    [checkBox setState: NSOnState];
                }
            }
            if (mixed != nil && [mixed count]) {
                if ([mixed containsObject:[NSString stringWithFormat:@"%i", count]]) {
                    [checkBox setAllowsMixedState: YES];
                    [checkBox setState: NSMixedState];
                }
            }
            if (disabled != nil && [disabled count]) {
                if ([disabled containsObject:[NSString stringWithFormat:@"%i", count]]) {
                    [checkBox setEnabled: NO];
                }
            }
            [controlView addSubview:checkBox];
            [checkboxes addObject:checkBox];
            count++;
		}
	} else {
		if ([options hasOpt:@"debug"]) {
			[CDControl debug:@"No items provided."];
		}
        return;
	}
    
    // Resize control
    
    NSRect controlFrame = [controlView frame];

    // Calculate the controlView height
    float controlHeight = (float)([checkboxes count] * 18);
    
    // Set panel's new width and height
    NSSize p = [[panel contentView] frame].size;
	p.height += controlHeight - controlFrame.size.height;
	[panel setContentSize:p];
    [panel center];

    // Align checkboxes
    if (checkboxes != nil && [checkboxes count]) {
		NSEnumerator *en = [checkboxes objectEnumerator];
        float count = 0;
        id obj;
		while (obj = [en nextObject]) {
            count++;
            NSRect checkboxFrame = NSMakeRect(0, controlHeight - (count * 18.0), controlFrame.size.width, 18.0);
            [obj setFrame:checkboxFrame];
		}
    }
}


- (void) dealloc
{
	[super dealloc];
}


@end
