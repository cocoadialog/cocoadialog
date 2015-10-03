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

#import "CDThreeButtonControl.h"

@implementation CDTextboxControl

- (NSString *)controlNib {
    return @"Textbox";
}

- (NSDictionary *) availableKeys
{
	NSNumber *vOne = @CDOptionsOneValue;
	NSNumber *vNone = @CDOptionsNoValues;
	
	return @{@"label": vOne,
            @"text": vOne,
            @"text-from-file": vOne,
            @"editable": vNone,
            @"no-editable": vNone,
            @"selected": vNone,
            @"focus-textbox": vNone,
            @"scroll-to": vOne};
}

- (NSDictionary *) depreciatedKeys
{
	return @{@"informative-text": @"label"};
}

// Should be called after setButtons, and before resize
- (void) setLabel:(NSString *)labelText {
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

        // Set scrollView's new height
        NSSize s = self.scrollView.frame.size;
        s.height -= labelHeightDiff;
        [self.scrollView setFrameSize:s];

    }
}

- (BOOL)isReturnValueEmpty
{
    return [self.textView.textStorage.string isEqualToString:@""];
}

- (NSString *) returnValueEmptyText
{
    return @"The text box can cannot be empty, please enter some text.";
}

- (BOOL)validateOptions {
	// check that they specified at least a button1
	if (![self.options optValue:@"button1"]) {
		if ([self.options hasOpt:@"debug"]) {
			[self debug:@"Must supply at least a --button1"];
		}
		return NO;
	}
    return YES;
}


- (void) createControl {

	NSAttributedString *text;
    
    [self.icon addControl:self.scrollView];
	
	// set editable
	if ([self.options hasOpt:@"editable"]) {
		[self.textView setEditable:YES];
	} else {
		[self.textView setEditable:NO];
	}
    
	// Set initial text in textview
	if ([self.options hasOpt:@"text"]) {
		text = [NSAttributedString.alloc initWithString:
			[self.options optValue:@"text"]];
		[self.textView.textStorage setAttributedString:text];
		[self.textView scrollRangeToVisible:NSMakeRange([text length], 0)];
	} else if ([self.options hasOpt:@"text-from-file"]) {

		NSString *contents = [NSString stringWithContentsOfFile:[self.options optValue:@"text-from-file"]
                                                   encoding:NSUTF8StringEncoding error:nil];
		if (!contents) {
			if ([self.options hasOpt:@"debug"]) [self debug:@"Could not read file"];
			return;
		} else text = [NSAttributedString.alloc initWithString:contents];

		[self.textView.textStorage setAttributedString:text];
	} else {
		[self.textView.textStorage setAttributedString:[NSAttributedString.alloc initWithString:@""]];
	}
    
	[self setTitleButtonsLabel:[self.options optValue:@"label"]];
	
	// scroll to top or bottom (do this AFTER resizing, setting the text, 
	// etc). Default is top
   [self.options optValue:@"scroll-to"] &&
  [[self.options optValue:@"scroll-to"] isCaseInsensitiveLike:@"bottom"] ?
    [self.textView scrollRangeToVisible:NSMakeRange(self.textView.textStorage.length-1, 0)] :
    [self.textView scrollRangeToVisible:NSMakeRange(0, 0)];
	
	// select all the text
	if ([self.options hasOpt:@"selected"])
		[self.textView setSelectedRange:NSMakeRange(0, self.textView.textStorage.length)];
	
	// Set first responder
	// Why doesn't this work for the button?
  [self.options hasOpt:@"focus-textbox"] ? [self.panel.panel makeFirstResponder:self.textView]
                                         : [self.panel.panel makeFirstResponder:button1];
}

- (void) controlHasFinished:(int)button {

	![self.options hasOpt:@"editable"] ?: [controlReturnValues addObject:self.textView.textStorage.string];

  [super controlHasFinished:button];
}


@end
