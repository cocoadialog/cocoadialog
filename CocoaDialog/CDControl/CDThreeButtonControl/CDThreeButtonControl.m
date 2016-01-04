
#import "CDThreeButtonControl.h"

@implementation CDThreeButtonControl

- (NSString*) controlNib {
    return  @"tbc";
}

- (NSDictionary*) globalAvailableKeys
{
	NSNumber *vOne = @CDOptionsOneValue;
	NSNumber *vNone = @CDOptionsNoValues;
	return @{@"help": vNone,
            @"debug": vNone,
            @"quiet": vNone,
            @"timeout": vOne,
            @"timeout-format": vOne,
            @"string-output": vNone,
            @"no-newline": vNone,
            // Panel
            @"title": vOne,
            @"width": vOne,
            @"height": vOne,
            @"posX": vOne,
            @"posY": vOne,
            @"no-float": vNone,
            @"minimize": vNone,
            @"resize": vNone,
            // Icon
            @"icon": vOne,
            @"icon-bundle": vOne,
            @"icon-type": vOne,
            @"icon-file": vOne,
            @"icon-size": vOne,
            @"icon-width": vOne,
            @"icon-height": vOne,
            // CDThreeButtonControl
            @"label": vOne,
            @"button1": vOne,
            @"button2": vOne,
            @"button3": vOne,
            @"cancel": vOne,
            @"value-required": vNone,
            @"empty-text": vOne};
}


// Needs to be overriden in control
- (void) setControl:(id)sender { }

- (void) setControl: (id)sender matrixRows:(NSInteger)rows matrixColumns:(NSInteger)columns items:(NSArray*)items precedence:(int)precedence
{
    if (controlMatrix != nil) {
        // Default exact columns/rows
        unsigned long exactColumns = [items count] / rows;
        float exactColumnsFloat = (float) [items count] / (float)rows;
        
        unsigned long exactRows = [items count] / columns;
        float exactRowsFloat = (float)[items count] / (float)columns;
        
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
                    columns = [items count] / rows;
                    exactColumnsFloat = (float)[items count] / (float)rows;
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
                    rows = [items count] / columns;
                    exactRowsFloat = (float)[items count] / (float)columns;
                    if (exactRowsFloat > (float) rows) {
                        rows++;
                    }
                    exactColumnsFloat = (float) [items count] / (float)rows;
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
		[aButton setTitle:aTitle];
		float maxX = NSMaxX([aButton frame]);
		[aButton sizeToFit];
		NSRect r = [aButton frame];
		r.size.width += 12.0f;
		if (maxX > 100.0f) { // button is in the right side
			r.origin.x = maxX - NSWidth(r);
		}
		[aButton setFrame:r];
		[aButton setEnabled:YES];
		[aButton setHidden:NO];
	} else {
		[aButton setEnabled:NO];
		[aButton setHidden:YES];
	}
}

// This resizes
- (void) setTitleButtonsLabel:(NSString*)labelText {

	[self.panel setTitle];

    // Add default controls
    if (expandingLabel != nil && ![self.icon.controls containsObject:expandingLabel]) {
        [self.icon addControl:expandingLabel];
    }
    if (controlMatrix != nil && ![self.icon.controls containsObject:controlMatrix]) {
        [self.icon addControl:controlMatrix];
    }
    if (self.timeoutLabel != nil && ![self.icon.controls containsObject:self.timeoutLabel]) {
        [self.icon addControl:self.timeoutLabel];
    }

    [self.icon setIconFromOptions];
    
	[self setButtons];
    [self.panel resize];
    
    [self setLabel:labelText];
    
    [self.panel resize];
    
    if (controlMatrix != nil) {
        // Remember old controlMatrix size
        NSRect m = [controlMatrix frame];
        float oldHeight = m.size.height;
        float oldWidth = m.size.width;
        
        // Call the control
        [self setControl:self];

        // Resize
        [controlMatrix sizeToCells];
        [[controlMatrix superview] setNeedsDisplay:YES];
        m = [controlMatrix frame];

        // Set panel's new width and height
        NSSize panelSize = [self.panel.panel.contentView frame].size;
        panelSize.height += m.size.height - oldHeight;
        panelSize.width += m.size.width - oldWidth;
        [self.panel.panel setContentSize:panelSize];

        [self.panel resize];
    }

}

- (void) setButtons {
    cancelButton = 0;
	unsigned i;
	struct { __unsafe_unretained NSString *key; __unsafe_unretained NSButton *button; } const buttons[] = {
		{ @"button1", button1 },
		{ @"button2", button2 },
		{ @"button3", button3 }
	};

	float minWidth = 2 * 20.0f; // margin
	for (i = 0; i != sizeof(buttons)/sizeof(buttons[0]); i++) {
		[self setTitle:[self.options optValue:buttons[i].key] forButton:buttons[i].button];
        if ([[self options] hasOpt:@"cancel"] && [[self.options optValue:@"cancel"] isEqualToString:buttons[i].key]) {
            [buttons[i].button setKeyEquivalent:@"\e"];
            cancelButton = i+1;
        }
        else if ([[self.options optValue:buttons[i].key] isEqualToString:@"Cancel"]) {
            [buttons[i].button setKeyEquivalent:@"\e"];
            cancelButton = i+1;
        }
		if ([buttons[i].button isHidden] == NO) {
			minWidth += NSWidth([buttons[i].button frame]);
		}
	}

	// move button2 so that it aligns with button1
	NSRect r = [button2 frame];
	r.origin.x = NSMinX([button1 frame]) - NSWidth(r);
	[button2 setFrame:r];

	// move button3 to the left
	r = [button3 frame];
	r.origin.x = 12.0f;
	[button3 setFrame:r];

	// ensure that the buttons never gets clipped
    [self.panel addMinHeight:40.0f]; // 20 * 2 for margin + 20 for height
    [self.panel addMinWidth:minWidth];
}

// Should be called after setButtons, and before resize
- (void) setLabel:(NSString*)labelText {
    if (expandingLabel != nil) {
        if (labelText == nil) {
            labelText = [NSString stringWithString:@""];
        }
        float labelNewHeight = -10.0f;
        NSRect labelRect = [expandingLabel frame];
        float labelHeightDiff = labelNewHeight - labelRect.size.height;
        if (![labelText isEqualToString:@""]) {
            [expandingLabel setStringValue:labelText];
            NSTextStorage *textStorage = [NSTextStorage.alloc initWithString: labelText];
            NSTextContainer *textContainer = [NSTextContainer.alloc initWithContainerSize:NSMakeSize(labelRect.size.width, FLT_MAX)];
            NSLayoutManager *layoutManager = NSLayoutManager.new;
            [layoutManager addTextContainer: textContainer];
            [textStorage addLayoutManager: layoutManager];
            [layoutManager glyphRangeForTextContainer:textContainer];
            labelNewHeight = [layoutManager usedRectForTextContainer:textContainer].size.height;
            labelHeightDiff = labelNewHeight - labelRect.size.height;
            // Set label's new height
            NSRect l = NSMakeRect(labelRect.origin.x, labelRect.origin.y - labelHeightDiff, labelRect.size.width, labelNewHeight);
            [expandingLabel setFrame: l];
        }
        else {
            [expandingLabel setHidden:YES];
        }
        // Set panel's new width and height
        NSSize p = [self.panel.panel.contentView frame].size;
        p.height += labelHeightDiff;
        [self.panel.panel setContentSize:p];
    }
}

- (void) setTimeoutLabel {
    if (self.timeoutLabel != nil) {
        float labelNewHeight = -4.0f;
        NSRect labelRect = [self.timeoutLabel frame];
        float labelHeightDiff = labelNewHeight - labelRect.size.height;
        [self.timeoutLabel setStringValue:[self formatSecondsForString:(int)self.timeout]];
        if (![[self.timeoutLabel stringValue] isEqualToString:@""] && self.timeout != 0.0f) {
            NSTextStorage *textStorage    = [NSTextStorage.alloc initWithString: self.timeoutLabel.stringValue];
            NSTextContainer *textContainer = [NSTextContainer.alloc initWithContainerSize:NSMakeSize(labelRect.size.width, FLT_MAX)];
            NSLayoutManager *layoutManager = NSLayoutManager.new;
            [layoutManager addTextContainer: textContainer];
            [textStorage addLayoutManager: layoutManager];
            [layoutManager glyphRangeForTextContainer:textContainer];
            labelNewHeight = [layoutManager usedRectForTextContainer:textContainer].size.height;
            labelHeightDiff = labelNewHeight - labelRect.size.height;
            // Set label's new height
            NSRect l = NSMakeRect(labelRect.origin.x, labelRect.origin.y - labelHeightDiff, labelRect.size.width, labelNewHeight);
            [self.timeoutLabel setFrame: l];
        }
        else {
            [self.timeoutLabel setHidden:YES];
        }
        // Set panel's new width and height
        NSSize p = [self.panel.panel.contentView frame].size;
        p.height += labelHeightDiff;
        [self.panel.panel setContentSize:p];
        
        if (controlMatrix != nil) {
            // Set controlMatrix's new Y
            NSPoint m = [controlMatrix frame].origin;
            m.y += labelHeightDiff;
            [controlMatrix setFrameOrigin:m];
        }
    }
}

- (BOOL)allowEmptyReturn {
    return ![self.options hasOpt:@"value-required"];
}

// This must be subclassed for each control. Each control must provide additional logic pertaining to their specific return values
- (BOOL) isReturnValueEmpty {
    return NO;
}

- (NSString*) returnValueEmptyText {
    return @"An input is required, please try again.";
}

- (void) returnValueEmptySheet {
    NSString *message = [self returnValueEmptyText];
    if ([self.options hasOpt:@"empty-text"]) {
        message = [self.options optValue:@"empty-text"];
    }
    NSAlert *alertSheet = NSAlert.new;
    [alertSheet addButtonWithTitle:@"Okay"];
    [alertSheet setIcon:[self.icon iconFromName:@"caution"]];
    [alertSheet setMessageText:message];
    [alertSheet beginSheetModalForWindow:self.panel.panel modalDelegate:self didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) contextInfo:nil];
}

- (void) controlHasFinished:(int)button {

    [self setValue:@(button) forKey:@"controlExitStatus"];

    id theButton = button == 1 ? button1 : button == 2 ? button2 : button3;
    [self setValue:[theButton title] forKey:@"controlExitStatusString"];

    if (button == cancelButton) [self.controlReturnValues removeAllObjects];
    else {
        if (!self.allowEmptyReturn && self.isReturnValueEmpty) return [self returnValueEmptySheet];
    }
    [self stopControl];
}

- (void) alertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void*)contextInfo {
    if (controlMatrix != nil && [[controlMatrix cells] count]) {
        if ([controlMatrix selectedCell]) {
            [controlMatrix selectCellAtRow:[controlMatrix selectedRow] column:[controlMatrix selectedColumn]];
        }
    }
    else if (self.controlItems && self.controlItems.count)
        [self.panel.panel makeFirstResponder:self.controlItems[0]];
}

- (IBAction) button1Pressed:(id)sender {
    [self.controlReturnValues removeAllObjects];
    [self controlHasFinished:1];
}

- (IBAction) button2Pressed:(id)sender {
    [self.controlReturnValues removeAllObjects];
    [self controlHasFinished:2];
}

- (IBAction) button3Pressed:(id)sender {
    [self.controlReturnValues removeAllObjects];
    [self controlHasFinished:3];
}

@end
