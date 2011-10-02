/*
	CDThreeButtonControl.m
	CocoaDialog
	Copyright (C) 2004-2006 Mark A. Stratman <mark@sporkstorms.org>
 
	This program is free software; you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation; either version 2 of the License, or
	(at your option) any later version.
 
	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.
 
	You should have received a copy of the GNU General Public License
	along with this program; if not, write to the Free Software
	Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
*/

#import "CDThreeButtonControl.h"

@implementation CDThreeButtonControl


- (void) runAndSetRv
{
	// Run modal
	[panel center];
	if ([[self options] hasOpt:@"float"]) {
		[panel setFloatingPanel: YES];
		[panel setLevel:NSScreenSaverWindowLevel];
	}		
	
	[panel makeKeyAndOrderFront:nil];
	[NSApp run];
}

- (NSDictionary *) globalAvailableKeys
{
	NSNumber *vOne = [NSNumber numberWithInt:CDOptionsOneValue];
	NSNumber *vNone = [NSNumber numberWithInt:CDOptionsNoValues];
	return [NSDictionary dictionaryWithObjectsAndKeys:
            vNone, @"help",
            vNone, @"debug",
            vOne,  @"title",
            vOne,  @"width",
            vOne,  @"height",
            vOne,  @"icon",
            vOne,  @"icon-bundle",
            vOne,  @"icon-file",
            vOne,  @"icon-size",
            vOne,  @"icon-width",
            vOne,  @"icon-height",
            vNone, @"string-output",
            vNone, @"no-newline",
            vOne,  @"label",
            vOne,  @"button1",
            vOne,  @"button2",
            vOne,  @"button3",
            vOne,  @"cancel",
            vNone, @"float",
            vOne,  @"timeout",
            nil];
}


// Needs to be overriden in control
- (void) setControl:(id)sender { }

- (void) setControl: (id)sender matrixRows:(NSInteger)rows matrixColumns:(NSInteger)columns items:(NSArray *)items precedence:(int)precedence
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
- (void) setTitleButtonsLabel:(NSString *)labelText
{

	[self setTitle];

    // Add default controls
    if (expandingLabel != nil && ![controlItems containsObject:expandingLabel]) {
        [controlItems addObject:expandingLabel];
    }
    if (controlMatrix != nil && ![controlItems containsObject:controlMatrix]) {
        [controlItems addObject:controlMatrix];
    }

    [self setIconForWindow:panel];
    
	[self setButtons];
	if ([self windowNeedsResize:panel]) {
		[panel setContentSize:[self findNewSizeForWindow:panel]];
	}
    
    [self setLabel:labelText];
    
	if ([self windowNeedsResize:panel]) {
		[panel setContentSize:[self findNewSizeForWindow:panel]];
	}
    
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
        NSSize panelSize = [[panel contentView] frame].size;
        panelSize.height += m.size.height - oldHeight;
        panelSize.width += m.size.width - oldWidth;
        [panel setContentSize:panelSize];
        [panel center];
        
        if ([self windowNeedsResize:panel]) {
            [panel setContentSize:[self findNewSizeForWindow:panel]];
        }
    }

}

- (void) setButtons
{
	unsigned i;
	struct { NSString *key; NSButton *button; } const buttons[] = {
		{ @"button1", button1 },
		{ @"button2", button2 },
		{ @"button3", button3 }
	};

	CDOptions *options = [self options];

	float minWidth = 2 * 20.0f; // margin
	for (i = 0; i != sizeof(buttons)/sizeof(buttons[0]); i++) {
		[self setTitle:[options optValue:buttons[i].key] forButton:buttons[i].button];
        if ([[self options] hasOpt:@"cancel"]) {
            if ([[options optValue:@"cancel"] isEqualToString:buttons[i].key]) {
                [buttons[i].button setKeyEquivalent:@"\e"];
            }
        }
        else {
            if ([[options optValue:buttons[i].key] isEqualToString:@"Cancel"]) {
                [buttons[i].button setKeyEquivalent:@"\e"];
            }
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
	NSSize s = [panel contentMinSize];
    s.height += 40.0f; // 20 * 2 for margin + 20 for height
	s.width += minWidth;
	[panel setContentMinSize:s];
}

// Should be called after setButtons, and before resize
- (void) setLabel:(NSString *)labelText
{
    if (expandingLabel != nil) {
        if (labelText == nil) {
            labelText = @"";
        }
        float labelNewHeight = -10.0f;
        NSRect labelRect = [expandingLabel frame];
        float labelHeightDiff = labelNewHeight - labelRect.size.height;
        if (![labelText isEqualToString:@""]) {
            [expandingLabel setStringValue:labelText];
            NSTextStorage *textStorage = [[[NSTextStorage alloc] initWithString: labelText]autorelease];
            NSTextContainer *textContainer = [[[NSTextContainer alloc] initWithContainerSize:NSMakeSize(labelRect.size.width, FLT_MAX)] autorelease];
            NSLayoutManager *layoutManager = [[[NSLayoutManager alloc]init] autorelease];
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
        NSSize p = [[panel contentView] frame].size;
        p.height += labelHeightDiff;
        [panel setContentSize:p];
    }
}

- (void) setTitle
{
	CDOptions *options = [self options];
	// set title
	if ([options optValue:@"title"] != nil) {
		[panel setTitle:[options optValue:@"title"]];
	}
}

- (void) setTimeout
{
	CDOptions *options = [self options];
	if ([options hasOpt:@"timeout"]) {
		NSTimeInterval t;
		if ([[NSScanner scannerWithString:[options optValue:@"timeout"]] scanDouble:&t]) {
			[self performSelector:@selector(timeout:) withObject:panel afterDelay:t];
		} else {
			if ([options hasOpt:@"debug"]) {
				[self debug:@"Could not parse the timeout option"];
			}
		}
	}
}

// TODO - this needs to return a value properly
- (IBAction) timeout:(id)sender
{
	rv = 0;
	// For some reason, this doesn't return the run loop until the mouse is moved over the window or something. I think it has something to do with threading.
	[NSApp stop:self];
	// So termination is needed or it won't return
	// But since that doesn't return, we have to put the exit stuff here.
	// Bah.
	NSFileHandle *fh = [NSFileHandle fileHandleWithStandardOutput];
	if ([[self options] hasOpt:@"string-output"]) {
		if (fh) {
			[fh writeData:[@"timeout" dataUsingEncoding:NSUTF8StringEncoding]];
		}
	} else {
		if (fh) {
			[fh writeData:[@"0" dataUsingEncoding:NSUTF8StringEncoding]];
		}
	}
	if (![[self options] hasOpt:@"no-newline"]) {
		[fh writeData:[@"\n" dataUsingEncoding:NSUTF8StringEncoding]];
	}
	[NSApp terminate:nil];
}

- (IBAction) button1Pressed:(id)sender
{
	rv = 1;
	[NSApp stop:nil];
	return;
}

- (IBAction) button2Pressed:(id)sender
{
	rv = 2;
	[NSApp stop:nil];
	return;
}

- (IBAction) button3Pressed:(id)sender
{
	rv = 3;
	[NSApp stop:nil];
	return;
}

@end
