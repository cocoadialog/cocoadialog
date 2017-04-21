// CDThreeButtonControl.m
// cocoadialog
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.

#import "CDThreeButtonControl.h"

@implementation CDThreeButtonControl

- (NSString *) controlNib {
    return  @"tbc";
}

- (CDOptions *) availableOptions {
    CDOptions *options = [super availableOptions];

    [options addOption:[CDOptionSingleString            name:@"button1"             category:@"WINDOW_OPTION"]];
    [options addOption:[CDOptionSingleString            name:@"button2"             category:@"WINDOW_OPTION"]];
    [options addOption:[CDOptionSingleString            name:@"button3"             category:@"WINDOW_OPTION"]];

    [options addOption:[CDOptionSingleStringOrNumber    name:@"cancel"              category:@"WINDOW_OPTION"]];
    options[@"cancel"].defaultValue = ^ {
        return @"Cancel";
    };

    [options addOption:[CDOptionSingleString            name:@"empty-text"          category:@"WINDOW_OPTION"]];
    [options addOption:[CDOptionFlag                    name:@"no-default-button"   category:@"WINDOW_OPTION"]];
    [options addOption:[CDOptionSingleString            name:@"label"               category:@"WINDOW_OPTION"]];
    [options addOption:[CDOptionFlag                    name:@"value-required"      category:@"WINDOW_OPTION"]];

    return options;
}

// Needs to be overriden in control
- (void) setControl:(id)sender { }

- (void) setControl: (id)sender matrixRows:(NSInteger)rows matrixColumns:(NSInteger)columns items:(NSArray *)items precedence:(int)precedence
{
    if (controlMatrix != nil) {
        // Default exact columns/rows
        unsigned long exactColumns = items.count / rows;
        float exactColumnsFloat = (float) items.count / (float)rows;
        
        unsigned long exactRows = items.count / columns;
        float exactRowsFloat = (float)items.count / (float)columns;
        
        switch (precedence) {
                // Rows have precedence over columns, if items extend past number of rows
                // columns will be increased to account for the additional items.
            case 1:
                // Items do not fill rows, reduce the rows to fit
                if (exactRowsFloat < (float)rows) {
                    rows = exactRows;
                }
                // Items exceed rows, expand columns
                else if (exactRowsFloat > (float)rows) {
                    columns = items.count / rows;
                    exactColumnsFloat = (float)items.count / (float)rows;
                    if (exactColumnsFloat > (float) columns) {
                        columns++;
                    }
                }
                // Extend rows once more if the division is greater than a whole number
                if (exactColumnsFloat > (float) columns) {
                    columns++;
                }
                break;
                
                // Columns have precedence over rows, if items extend past number of columns
                // rows will be increased to account for the additional items.
            default:
                // Items do not fill columns, reduce the columns to fit
                if (exactColumnsFloat < (float)columns) {
                    columns = (int) exactColumns;
                }
                // Items exceed columns, expand rows
                else if (exactColumnsFloat > (float)columns) {
                    rows = items.count / columns;
                    exactRowsFloat = (float)items.count / (float)columns;
                    if (exactRowsFloat > (float) rows) {
                        rows++;
                    }
                    exactColumnsFloat = (float) items.count / (float)rows;
                    if (exactColumnsFloat <= (float)columns) {
                        columns = (int) exactColumnsFloat;
                    }
                }
                // Extend rows once more if the division is greater than a whole number
                if (exactRowsFloat > (float) rows) {
                    rows++;
                }
                break;
        }
        // Tell the matrix how many rows and columns it has
        [controlMatrix renewRows:rows columns:columns];
    }
}

- (void) setTitle:(NSString*)aTitle forButton:(NSButton*)aButton
{
	if (aTitle && ![aTitle isEqualToString:@""]) {
		aButton.title = aTitle;
		float maxX = NSMaxX(aButton.frame);
		[aButton sizeToFit];
		NSRect r = aButton.frame;
		r.size.width += 12.0f;
		if (maxX > 100.0f) { // button is in the right side
			r.origin.x = maxX - NSWidth(r);
		}
		aButton.frame = r;
		[aButton setEnabled:YES];
		[aButton setHidden:NO];
	} else {
		[aButton setEnabled:NO];
		[aButton setHidden:YES];
	}
}

// This resizes
- (void) setTitleButtonsLabel:(NSString *)labelText {

	[self setTitle];

    // Add default controls
    if (expandingLabel != nil && ![[self iconControls] containsObject:expandingLabel]) {
        [self iconAffectedByControl:expandingLabel];
    }
    if (controlMatrix != nil && ![[self iconControls] containsObject:controlMatrix]) {
        [self iconAffectedByControl:controlMatrix];
    }
    if (self.timeoutLabel != nil && ![[self iconControls] containsObject:self.timeoutLabel]) {
        [self iconAffectedByControl:self.timeoutLabel];
    }

    [self setIconFromOptions];
    
	[self setButtons];
    [self resize];
    
    [self setLabel:labelText];
    
    [self resize];
    
    if (controlMatrix != nil) {
        // Remember old controlMatrix size
        NSRect m = controlMatrix.frame;
        float oldHeight = m.size.height;
        float oldWidth = m.size.width;
        
        // Call the control
        [self setControl:self];

        // Resize
        [controlMatrix sizeToCells];
        [controlMatrix.superview setNeedsDisplay:YES];
        m = controlMatrix.frame;

        // Set panel's new width and height
        NSSize panelSize = self.panel.contentView.frame.size;
        panelSize.height += m.size.height - oldHeight;
        panelSize.width += m.size.width - oldWidth;
        [self.panel setContentSize:panelSize];

        [self resize];
    }

}

- (void) setButtons {
    cancelButton = 0;

    NSArray *buttons = @[
                         @{@"name": @"button1", @"button": button1},
                         @{@"name": @"button2", @"button": button2},
                         @{@"name": @"button3", @"button": button3},
                         ];

    BOOL noDefault = option[@"no-default-button"].boolValue;
	float minWidth = 2 * 20.0f; // margin
	for (NSUInteger i = 0; i < buttons.count; i++) {
        NSString *name = [buttons[i] objectForKey:@"name"];
        NSButton *button = [buttons[i] objectForKey:@"button"];
		[self setTitle:option[name].stringValue forButton:button];

        if (option[@"cancel"].wasProvided && ([option[@"cancel"].stringValue isEqualToString:name] || option[@"cancel"].unsignedIntegerValue == i)) {
            if (!noDefault) {
                button.keyEquivalent = @"\e";
            }
            cancelButton = i + 1;
        }
        else if ([option[name].stringValue isEqualToStringCaseInsensitive:@"cancel"]) {
            if (!noDefault) {
                button.keyEquivalent = @"\e";
            }
            cancelButton = i + 1;
        }
		if (button.hidden == NO) {
			minWidth += NSWidth(button.frame);
		}
        
        // Remove default button key mappings.
        if (noDefault && ![button.keyEquivalent  isEqual: @""]) {
            button.keyEquivalent = @"";
            button.needsDisplay = YES;
        }
	}

	// move button2 so that it aligns with button1
	NSRect r = button2.frame;
	r.origin.x = NSMinX(button1.frame) - NSWidth(r);
	button2.frame = r;

	// move button3 to the left
	r = button3.frame;
	r.origin.x = 12.0f;
	button3.frame = r;

	// ensure that the buttons never gets clipped
    [self addMinHeight:60.0f]; // 20 * 2 for margin + 20 for height
    [self addMinWidth:minWidth];
    
    // Ensure the panel itself doesn't have a set default button.
    if (noDefault) {
        [self.panel setDefaultButtonCell:nil];
    }

}

// Should be called after setButtons, and before resize
- (void) setLabel:(NSString *)labelText {
    if (expandingLabel != nil) {
        if (labelText == nil) {
            labelText = @"";
        }
        float labelNewHeight = -10.0f;
        NSRect labelRect = expandingLabel.frame;
        float labelHeightDiff = labelNewHeight - labelRect.size.height;
        if (![labelText isEqualToString:@""]) {
            expandingLabel.stringValue = labelText;
            NSTextStorage *textStorage = [[NSTextStorage alloc] initWithString: labelText];
            NSTextContainer *textContainer = [[NSTextContainer alloc] initWithContainerSize:NSMakeSize(labelRect.size.width, FLT_MAX)];
            NSLayoutManager *layoutManager = [[NSLayoutManager alloc]init];
            [layoutManager addTextContainer: textContainer];
            [textStorage addLayoutManager: layoutManager];
            [layoutManager glyphRangeForTextContainer:textContainer];
            labelNewHeight = [layoutManager usedRectForTextContainer:textContainer].size.height;
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
    }
}

- (void) setTimeoutLabel {
    if (self.timeoutLabel != nil) {
        float labelNewHeight = -4.0f;
        NSRect labelRect = self.timeoutLabel.frame;
        float labelHeightDiff = labelNewHeight - labelRect.size.height;
        self.timeoutLabel.stringValue = [self formatSecondsForString:(int)timeout];
        if (![self.timeoutLabel.stringValue isEqualToString:@""] && timeout != 0.0f) {
            NSTextStorage *textStorage = [[NSTextStorage alloc] initWithString: self.timeoutLabel.stringValue];
            NSTextContainer *textContainer = [[NSTextContainer alloc] initWithContainerSize:NSMakeSize(labelRect.size.width, FLT_MAX)];
            NSLayoutManager *layoutManager = [[NSLayoutManager alloc]init];
            [layoutManager addTextContainer: textContainer];
            [textStorage addLayoutManager: layoutManager];
            [layoutManager glyphRangeForTextContainer:textContainer];
            labelNewHeight = [layoutManager usedRectForTextContainer:textContainer].size.height;
            labelHeightDiff = labelNewHeight - labelRect.size.height;
            // Set label's new height
            NSRect l = NSMakeRect(labelRect.origin.x, labelRect.origin.y - labelHeightDiff, labelRect.size.width, labelNewHeight);
            self.timeoutLabel.frame = l;
        }
        else {
            self.timeoutLabel.hidden = YES;
        }
        // Set panel's new width and height
        NSSize p = self.panel.contentView.frame.size;
        p.height += labelHeightDiff;
        [self.panel setContentSize:p];
        
        if (controlMatrix != nil) {
            // Set controlMatrix's new Y
            NSPoint m = controlMatrix.frame.origin;
            m.y += labelHeightDiff;
            [controlMatrix setFrameOrigin:m];
        }
    }
}

- (BOOL) allowEmptyReturn {
    return !option[@"value-required"];
}

// This must be subclassed for each control. Each control must provide additional logic pertaining to their specific return values
- (BOOL) isReturnValueEmpty {
    return NO;
}

- (NSString *) returnValueEmptyText {
    return NSLocalizedString(@"An input is required, please try again.", nil);
}

- (void) returnValueEmptySheet {
    NSString *message = option[@"empty-text"].wasProvided ? option[@"empty-text"].stringValue : [self returnValueEmptyText];
    NSAlert *alertSheet = [[NSAlert alloc] init];
    [alertSheet addButtonWithTitle:NSLocalizedString(@"Okay", nil)];
    alertSheet.icon = [self iconFromName:@"caution"];
    alertSheet.messageText = message;
    [alertSheet beginSheetModalForWindow:self.panel modalDelegate:self didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) contextInfo:nil];
}

- (void) controlHasFinished:(NSUInteger)button {
    controlExitStatus = (int) button;
    switch (button) {
        case 1: controlExitStatusString = button1.title; break;
        case 2: controlExitStatusString = button2.title; break;
        case 3: controlExitStatusString = button3.title; break;
    }
    if (button == cancelButton) {
        controlReturnValues = [NSMutableArray array];
    }
    else {
        if (![self allowEmptyReturn] && [self isReturnValueEmpty]) {
            [self returnValueEmptySheet];
            return;
        }
    }
    [self stopControl];
}

- (void) alertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
    if (controlMatrix != nil && controlMatrix.cells.count) {
        if (controlMatrix.selectedCell) {
            [controlMatrix selectCellAtRow:controlMatrix.selectedRow column:controlMatrix.selectedColumn];
        }
    }
    else if (controlItems != nil && controlItems.count) {
        [self.panel makeFirstResponder:controlItems[0]];
    }
}

- (IBAction) button1Pressed:(id)sender {
    [controlReturnValues removeAllObjects];
    [self controlHasFinished:1];
}

- (IBAction) button2Pressed:(id)sender {
    [controlReturnValues removeAllObjects];
    [self controlHasFinished:2];
}

- (IBAction) button3Pressed:(id)sender {
    [controlReturnValues removeAllObjects];
    [self controlHasFinished:3];
}

@end
