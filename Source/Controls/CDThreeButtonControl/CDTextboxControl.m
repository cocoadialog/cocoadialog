/*
	CDTextboxControl.m
	cocoaDialog
	Copyright (C) 2004 Mark A. Stratman <mark@sporkstorms.org>
 
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

#import "CDTextboxControl.h"


@implementation CDTextboxControl

- (NSString *)controlNib {
    return @"Textbox";
}

- (CDOptions *) availableOptions {
    CDOptions *options = [super availableOptions];

    [options addOption:[CDOptionFlag                name:@"editable"]];
    [options addOption:[CDOptionFlag                name:@"focus-textbox"]];
    [options addOption:[CDOptionSingleString        name:@"label"]];
    [options addOption:[CDOptionFlag                name:@"no-editable"]];
    [options addOption:[CDOptionSingleString        name:@"scroll-to"]];
    [options addOption:[CDOptionFlag                name:@"selected"]];
    [options addOption:[CDOptionSingleString        name:@"text"]];
    [options addOption:[CDOptionSingleString        name:@"text-from-file"]];

    // Deprecated options.
    [options addOption:[CDOptionDeprecated          from:@"informative-text" to:@"label"]];

    // Require options.
    options[@"button1"].required = YES;

    return options;
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
            expandingLabel.frame = l;
        }
        else {
            [expandingLabel setHidden:YES];
        }
        // Set panel's new width and height
        NSSize p = panel.panel.contentView.frame.size;
        p.height += labelHeightDiff;
        [panel.panel setContentSize:p];

        // Set scrollView's new height
        NSSize s = scrollView.frame.size;
        s.height -= labelHeightDiff;
        [scrollView setFrameSize:s];

    }
}

- (BOOL) isReturnValueEmpty {
    return [textView.textStorage.string isEqualToString:@""];
}

- (NSString *) returnValueEmptyText {
    return @"The text box can cannot be empty, please enter some text.";
}

- (void) createControl {
	NSAttributedString *text;
    
    [icon addControl:scrollView];
	
	// Editable.
    [textView setEditable:option[@"editable"].wasProvided];

	// Set initial text in textview
	if (option[@"text"].wasProvided) {
		text = [[NSAttributedString alloc] initWithString:option[@"text"].stringValue];
		[textView.textStorage setAttributedString:text];
		[textView scrollRangeToVisible:NSMakeRange(text.length, 0)];
		[text release];
	} else if (option[@"text-from-file"].wasProvided) {
        NSString *file = option[@"text-from-file"].stringValue;
		NSString *contents = [NSString stringWithContentsOfFile: file encoding:NSUTF8StringEncoding error:nil];
		if (contents == nil) {
            [self warning:@"Could not read file: %@", file, nil];
			return;
		} else {
			text = [[NSAttributedString alloc] initWithString:contents];
		}
		[textView.textStorage setAttributedString:text];
		[text release];
	} else {
		[textView.textStorage setAttributedString:[[[NSAttributedString alloc] initWithString:@""] autorelease]];
	}
    
	[self setTitleButtonsLabel:option[@"label"].stringValue];
	
	// scroll to top or bottom (do this AFTER resizing, setting the text, 
	// etc). Default is top
	if (option[@"scroll-to"].wasProvided && [option[@"scroll-to"].stringValue isEqualToStringCaseInsensitive:@"bottom"]) {
		[textView scrollRangeToVisible:
			NSMakeRange(textView.textStorage.length-1, 0)];
	} else {
		[textView scrollRangeToVisible:NSMakeRange(0, 0)];
	}
	
	// select all the text
	if (option[@"selected"].wasProvided) {
		[textView setSelectedRange:NSMakeRange(0, textView.textStorage.length)];
	}
	
	// Set first responder
	// Why doesn't this work for the button?
	if (option[@"focus-textbox"].wasProvided) {
		[panel.panel makeFirstResponder:textView];
	} else {
		[panel.panel makeFirstResponder:button1];
	}
}

- (void) controlHasFinished:(int)button {
	if (option[@"editable"].wasProvided) {
        [controlReturnValues addObject:textView.textStorage.string];
	}
    [super controlHasFinished:button];
}


@end
