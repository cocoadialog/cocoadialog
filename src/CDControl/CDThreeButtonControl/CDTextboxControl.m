/*
	CDTextboxControl.m
	CocoaDialog
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

- (NSDictionary *) availableKeys
{
	NSNumber *vOne = [NSNumber numberWithInt:CDOptionsOneValue];
	NSNumber *vNone = [NSNumber numberWithInt:CDOptionsNoValues];
	
	return [NSDictionary dictionaryWithObjectsAndKeys:
            vOne, @"text",
            vOne, @"text-from-file",
            vOne, @"informative-text",
            vNone, @"editable",
            vNone, @"no-editable",
            vNone, @"selected",
            vNone, @"focus-textbox",
            vOne, @"scroll-to",
            nil];
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
    
    float newHeight = [layoutManager usedRectForTextContainer:textContainer].size.height;
    float heightDiff = newHeight - labelRect.size.height;
    
    // Set label's new width and height
    NSRect l = NSMakeRect(labelRect.origin.x, labelRect.origin.y - heightDiff, labelRect.size.width, newHeight);
    [expandingLabel setFrame: l];
    
    // Set panel's new width and height
    NSSize p = [[panel contentView] frame].size;
	p.height += heightDiff;
	[panel setContentSize:p];
    [panel center];

    // Set scrollView's new height
	NSSize s = [scrollView frame].size;
    s.height -= heightDiff;
	[scrollView setFrameSize:s];

}

- (NSArray *) runControlFromOptions:(CDOptions *)options
{
	NSAttributedString *text;
	NSString *returnString = nil;

	[self setOptions:options];

	// check that they specified at least a button1
	// return nil if not
	if (![options optValue:@"button1"]) {
		if ([options hasOpt:@"debug"]) {
			[CDControl debug:@"Must supply at least a --button1"];
		}
		return nil;
	}	
	
	// Load Textbox.nib or return nil
	if (![NSBundle loadNibNamed:@"Textbox" owner:self]) {
		if ([options hasOpt:@"debug"]) {
			[CDControl debug:@"Could not load Textbox.nib"];
		}
		return nil;
	}
	
	// set editable
	if ([options hasOpt:@"editable"]) {
		[textView setEditable:YES];
	} else {
		[textView setEditable:NO];
	}
	
	// Set initial text in textview
	if ([options optValue:@"text"]) {
		text = [[NSAttributedString alloc] initWithString:
			[options optValue:@"text"]];
		[[textView textStorage] setAttributedString:text];
		[textView scrollRangeToVisible:NSMakeRange([text length], 0)];
		[text release];
	} else if ([options optValue:@"text-from-file"]) {
		NSString *contents = [NSString stringWithContentsOfFile:
			[options optValue:@"text-from-file"] encoding:NSUTF8StringEncoding error:nil];
		if (contents == nil) {
			if ([options hasOpt:@"debug"]) {
				[CDControl debug:@"Could not read file"];
			}
			return nil;
		} else {
			text = [[NSAttributedString alloc] initWithString:contents];
		}
		[[textView textStorage] setAttributedString:text];
		[text release];
	} else {
		[[textView textStorage] setAttributedString:
			[[[NSAttributedString alloc] initWithString:@""] autorelease]];
	}
		
	[self setTitleButtonsLabel:[options optValue:@"informative-text"]];
	
	// scroll to top or bottom (do this AFTER resizing, setting the text, 
	// etc). Default is top
	if ([options optValue:@"scroll-to"] 
	    && [[options optValue:@"scroll-to"] isCaseInsensitiveLike:@"bottom"]) 
	{
		[textView scrollRangeToVisible:
			NSMakeRange([[textView textStorage] length]-1, 0)];
	} else {
		[textView scrollRangeToVisible:NSMakeRange(0, 0)];
	}
	
	// select all the text
	if ([options hasOpt:@"selected"]) {
		[textView setSelectedRange:
			NSMakeRange(0, [[textView textStorage] length])];
	}
	
	// Set first responder
	// Why doesn't this work for the button?
	if ([options hasOpt:@"focus-textbox"]) {
		[panel makeFirstResponder:textView];
	} else {
		[panel makeFirstResponder:button1];
	}
	
	[self setTimeout];

	[self runAndSetRv];

	// set returnString
	if ([options hasOpt:@"string-output"]) {
		if (rv == 1) {
			returnString = [button1 title];
		} else if (rv == 2) {
			returnString = [button2 title];
		} else if (rv == 3) {
			returnString = [button3 title];
		} else if (rv == 0) {
			returnString = @"timeout";
		}
	} else {
		returnString = [NSString stringWithFormat:@"%d",rv];
	}
		
	if ([options hasOpt:@"editable"]) {
		return [NSArray arrayWithObjects:returnString, 
				[[textView textStorage] string], nil];
	} else {
		return returnString == nil ? nil :
			[NSArray arrayWithObject:returnString];
	}
}


@end
