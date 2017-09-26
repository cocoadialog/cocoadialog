// CDDropdownControl.m
// cocoadialog
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.

#import "CDDropdownControl.h"

@implementation CDDropdownControl

@synthesize dropdownControl;

- (CDOptions *) availableOptions {
    CDOptions *options = [super availableOptions];

    [options addOption:[CDOptionFlag                name:@"exit-onchange"]];
    [options addOption:[CDOptionMultipleStrings     name:@"items"]];
    [options addOption:[CDOptionFlag                name:@"pulldown"]];
    [options addOption:[CDOptionSingleNumber        name:@"selected"]];

    // Deprecated options.
    [options addOption:[CDOptionDeprecated          from:@"text" to:@"label"]];

    // Minimum values.
    options[@"items"].minimumValues = @2;

    // Required options.
    [options[@"button1"] addConditionalRequirement:^BOOL{
        return !option[@"pulldown"].wasProvided;
    }];
    options[@"items"].required = YES;

    return options;
}

- (NSString *)controlNib {
    return @"Dropdown";
}

- (void) createControl {
    [self addMinWidth:dropdownControl.frame.size.width];
    [controlItems addObject:dropdownControl];
    [self iconAffectedByControl:dropdownControl];
    // Setup the control
    dropdownControl.keyEquivalent = @" ";
    dropdownControl.target = self;
    dropdownControl.action = @selector(selectionChanged:);
	[dropdownControl removeAllItems];

    // Set pulldown style.
    dropdownControl.pullsDown = option[@"pulldown"].wasProvided;

    // Populate menu
    NSArray *items = option[@"items"].arrayValue;
	if (items != nil && items.count) {
		NSEnumerator *en = [items objectEnumerator];
		id obj;
		while (obj = [en nextObject]) {
			[dropdownControl addItemWithTitle:(NSString *)obj];
		}
        NSUInteger selected = option[@"selected"].wasProvided ? option[@"selected"].unsignedIntegerValue : 0;
        [dropdownControl selectItemAtIndex:selected];
	}
	[self setTitleButtonsLabel:option[@"label"].stringValue];
}

- (void) controlHasFinished:(NSUInteger)button {
	if (option[@"return-labels"].wasProvided) {
        returnValues[@"value"] = dropdownControl.titleOfSelectedItem;
	} else {
        returnValues[@"value"] = [NSNumber numberWithInteger:dropdownControl.indexOfSelectedItem];
	}
    [super controlHasFinished:button];
}

- (void) selectionChanged:(id)sender {
    [dropdownControl synchronizeTitleAndSelectedItem];
	if (option[@"exit-onchange"].wasProvided) {
        if (option[@"return-labels"].wasProvided) {
            returnValues[@"value"] = dropdownControl.titleOfSelectedItem;
        } else {
            returnValues[@"value"] = [NSNumber numberWithInteger:dropdownControl.indexOfSelectedItem];
        }
        [self stopControl];
	}
}

// Should be called after setButtons, and before resize
- (void) setLabel:(NSString *)labelText {
    if (expandingLabel != nil) {
        if (labelText == nil) {
            labelText = @"";
        }
        float labelLineHeight = 14.0f;
        float labelNewHeight = -labelLineHeight;
        NSRect labelRect = expandingLabel.frame;
        float labelHeightDiff = labelNewHeight - labelRect.size.height;
        if (![labelText isBlank]) {
            expandingLabel.stringValue = labelText;
            NSTextStorage *textStorage = [[NSTextStorage alloc] initWithString: labelText];
            NSTextContainer *textContainer = [[NSTextContainer alloc] initWithContainerSize:NSMakeSize(labelRect.size.width, FLT_MAX)];
            NSLayoutManager *layoutManager = [[NSLayoutManager alloc]init];
            [layoutManager addTextContainer: textContainer];
            [textStorage addLayoutManager: layoutManager];
            [layoutManager glyphRangeForTextContainer:textContainer];
            labelNewHeight = [layoutManager usedRectForTextContainer:textContainer].size.height + labelLineHeight;
            labelHeightDiff = labelNewHeight - labelRect.size.height;
            // Set label's new height
            NSRect l = NSMakeRect(labelRect.origin.x, labelRect.origin.y - labelHeightDiff, labelRect.size.width, labelNewHeight);
            expandingLabel.frame = l;
        }
        else {
            [expandingLabel setHidden:YES];
        }
        // Set panel's new width and height
        NSSize p = self.panel.contentView.frame.size;
        p.height += labelHeightDiff;
        [self.panel setContentSize:p];

        // Set dropdownControl's new Y.
        // @todo this should be done automatically in TBC using the controlItems.
        if (dropdownControl != nil) {
            NSPoint d = dropdownControl.frame.origin;
            d.y -= labelHeightDiff;
            [dropdownControl setFrameOrigin:d];
        }

        // Set controlMatrix's new Y.
        if (controlMatrix != nil) {
            NSPoint m = controlMatrix.frame.origin;
            m.y -= labelHeightDiff;
            [controlMatrix setFrameOrigin:m];
        }
    }
}


@end
