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

- (NSDictionary *) availableKeys
{
	NSNumber *vOne = [NSNumber numberWithInt:CDOptionsOneValue];
	NSNumber *vNone = [NSNumber numberWithInt:CDOptionsNoValues];
	
	return [NSDictionary dictionaryWithObjectsAndKeys:
            vOne,  @"value",
            vNone, @"fullscreen",
            vOne,  @"text-from-file",
            vNone, @"editable",
            vNone, @"no-editable",
            vNone, @"selected",
            vNone, @"focus-textbox",
            vOne,  @"scroll-to",
            nil];
}

- (NSDictionary *) depreciatedKeys
{
	return [NSDictionary dictionaryWithObjectsAndKeys:
            @"label", @"informative-text",
            @"value", @"text",
            nil];
}

- (BOOL)isReturnValueEmpty
{
    return [[[textView textStorage] string] isEqualToString:@""];
}

- (NSString *) returnValueEmptyText
{
    return @"The text box can cannot be empty, please enter some text.";
}

- (BOOL)validateOptions {
	// check that they specified at least a button1
	if (![options optValue:@"button1"]) {
		if ([options hasOpt:@"debug"]) {
			[self debug:@"Must supply at least a --button1"];
		}
		return NO;
	}
    return YES;
}


- (void) createControl {
    controlMatrix = nil;
    [self setTitleButtonsLabel:[options optValue:@"label"]];
    
    scrollView = [[[NSScrollView alloc] initWithFrame:NSMakeRect(0.0f, 0.0f, 300.0f, 450.0f)] autorelease];
    [scrollView setHasVerticalScroller:YES];
    [scrollView setHasHorizontalScroller:YES];
    [scrollView setBorderType:NSBezelBorder];
    [scrollView setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
    
    textView = [[[NSTextView alloc] initWithFrame:[scrollView bounds]] autorelease];
    [textView setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
    
    NSAttributedString *text;
	// set editable
	if ([options hasOpt:@"editable"]) {
		[textView setEditable:YES];
	} else {
		[textView setEditable:NO];
	}
    
	// Set initial text in textview
	if ([options hasOpt:@"value"]) {
		text = [[NSAttributedString alloc] initWithString:
                [options optValue:@"value"]];
		[[textView textStorage] setAttributedString:text];
		[textView scrollRangeToVisible:NSMakeRange([text length], 0)];
		[text release];
	} else if ([options hasOpt:@"text-from-file"]) {
		NSString *contents = [NSString stringWithContentsOfFile:
                              [options optValue:@"text-from-file"] encoding:NSUTF8StringEncoding error:nil];
		if (contents == nil) {
			if ([options hasOpt:@"debug"]) {
				[self debug:@"Could not read file"];
			}
			return;
		} else {
			text = [[NSAttributedString alloc] initWithString:contents];
		}
		[[textView textStorage] setAttributedString:text];
		[text release];
	} else {
		[[textView textStorage] setAttributedString:[[[NSAttributedString alloc] initWithString:@""] autorelease]];
	}
    
	
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
		[[panel panel] makeFirstResponder:textView];
	} else {
		[[panel panel] makeFirstResponder:button1];
	}
    
    [scrollView setDocumentView:textView];
    [panel addControlView:scrollView];
    
    [panel setMaxHeight:[self screen].size.height];
    [panel setMaxWidth:[self screen].size.width];
//    [icon addControl:textView];

}


- (void) controlHasFinished:(int)button {
	if ([[self options] hasOpt:@"editable"]) {
        [controlReturnValues addObject:[[textView textStorage] string]];
	}
    [super controlHasFinished:button];
}


@end
