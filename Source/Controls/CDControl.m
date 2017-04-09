/*
	CDControl.m
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

#import "AppController.h"
#import "CDControl.h"

@implementation CDControl

@synthesize controlName;

#pragma mark - Internal Control Methods -
- (NSString *) controlNib { return @""; }

- (instancetype) initWithArguments {
    self = [self init];
    if (self) {
        controlName = @"<control>";
        arguments = [CDArguments initWithAvailableOptions:[self availableOptions]];
        controlExitStatus = -1;
        controlExitStatusString = nil;
        controlReturnValues = [[[NSMutableArray alloc] init] retain];
        controlItems = [[[NSMutableArray alloc] init] retain];
    }
    return self;
}

- (void) dealloc {
    [panel release];
    [icon release];
    [controlExitStatusString release];
    [controlItems release];
    [controlReturnValues release];
    [arguments release];
    if (timer != nil) {
        [timer invalidate];
        [timer release];
    }
    [super dealloc];
}
- (NSString *) formatSecondsForString:(NSInteger)timeInSeconds {
    static NSString *timerFormat = nil;
    if (timerFormat == nil) {
        if ([arguments hasOption:@"timeout-format"]) {
            timerFormat = [arguments getOption:@"timeout-format"];
        }
        else {
            timerFormat = @"Time remaining: %r...";
        }
    }
    NSString *returnString = timerFormat;

    NSInteger seconds = timeInSeconds % 60;
    NSInteger minutes = (timeInSeconds / 60) % 60;
    NSInteger hours = timeInSeconds / 3600;
    NSInteger days = timeInSeconds / (3600 * 24);
    NSString *relative = @"unknown";
    if (days > 0) {
        if (days > 1) {
            relative = [NSString stringWithFormat:@"%id days", (int) days];
        }
        else {
            relative = [NSString stringWithFormat:@"%id day", (int) days];
        }
    }
    else {
        if (hours > 0) {
            if (hours > 1) {
                relative = [NSString stringWithFormat:@"%ld hours", (long)hours];
            }
            else {
                relative = [NSString stringWithFormat:@"%ld hour", (long)hours];
            }
        }
        else {
            if (minutes > 0) {
                if (minutes > 1) {
                    relative = [NSString stringWithFormat:@"%ld minutes", (long)minutes];
                }
                else {
                    relative = [NSString stringWithFormat:@"%ld minute", (long)minutes];
                }
            }
            else {
                if (seconds > 0) {
                    if (seconds > 1) {
                        relative = [NSString stringWithFormat:@"%ld seconds", (long)seconds];
                    }
                    else {
                        relative = [NSString stringWithFormat:@"%ld second", (long)seconds];
                    }
                }
            }
        }
    }
    returnString = [returnString stringByReplacingOccurrencesOfString:@"%s" withString:[NSString stringWithFormat:@"%ld", (long)seconds]];
    returnString = [returnString stringByReplacingOccurrencesOfString:@"%m" withString:[NSString stringWithFormat:@"%ld", (long)minutes]];
    returnString = [returnString stringByReplacingOccurrencesOfString:@"%h" withString:[NSString stringWithFormat:@"%ld", (long)hours]];
    returnString = [returnString stringByReplacingOccurrencesOfString:@"%d" withString:[NSString stringWithFormat:@"%ld", (long)days]];
    returnString = [returnString stringByReplacingOccurrencesOfString:@"%r" withString:relative];
    return returnString;
}

- (BOOL) loadControlNib:(NSString *)nib {
    // Load nib
    if (nib != nil) {
        if (![nib isEqualToString:@""] && ![[NSBundle mainBundle] loadNibNamed:nib owner:self topLevelObjects:nil]) {
            [self fatalError:@"Could not load control interface: \"%@.nib\"", nib];
        }
    }
    else {
        [self fatalError:@"Control did not specify a NIB interface file to load."];
    }
    panel = [[[CDPanel alloc] initWithArguments:self.arguments] retain];
    icon = [[[CDIcon alloc] initWithArguments:self.arguments] retain];
    if (controlPanel != nil) {

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowWillClose:) name:NSWindowWillCloseNotification object:controlPanel];


        BOOL close = [arguments hasOption:@"titlebar-close"];
        [controlPanel standardWindowButton:NSWindowCloseButton].enabled = close;
        if (!close) {
            controlPanel.styleMask = controlPanel.styleMask^NSClosableWindowMask;
        }

        BOOL minimize = [arguments hasOption:@"titlebar-minimize"];
        [controlPanel standardWindowButton:NSWindowMiniaturizeButton].enabled = minimize;
        if (!minimize) {
            controlPanel.styleMask = controlPanel.styleMask^NSMiniaturizableWindowMask;
        }

        // Handle --resize option.
        BOOL resize = [arguments hasOption:@"resize"];
        [controlPanel standardWindowButton:NSWindowZoomButton].enabled = resize && [arguments hasOption:@"titlebar-resize"];
        if (!resize) {
            controlPanel.styleMask = controlPanel.styleMask^NSResizableWindowMask;
        }

        panel.panel = controlPanel;
        icon.panel = panel;
    }
    if (controlIcon != nil) {
        icon.control = controlIcon;
    }
    return YES;
}

- (void) printHelpTo:(NSFileHandle *)fh {
    // Immediately return if there's no file handler.
    if (!fh) {
        return;
    }
    id key;

    int margin = 4;
    int terminalWidth = [AppController getTerminalWidth] - margin;

    [fh writeData:[[NSString stringWithFormat:NSLocalizedString(@"USAGE", nil), controlName] dataUsingEncoding:NSUTF8StringEncoding]];
    [fh writeData:[@"\n" dataUsingEncoding:NSUTF8StringEncoding]];

    NSMutableDictionary *usageCategories = [[[NSMutableDictionary alloc] init] autorelease];

    // Show avilable controls if it's the CDControl class printing this.
    if ([self class] == [CDControl class]) {
        [fh writeData:[@"\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [fh writeData:[NSLocalizedString(@"USAGE_CATEGORY_CONTROLS", nil) dataUsingEncoding:NSUTF8StringEncoding]];
        [fh writeData:[@":\n" dataUsingEncoding:NSUTF8StringEncoding]];
        NSArray *sortedControls = [NSArray arrayWithArray:[[AppController availableControls].allKeys sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];
        NSEnumerator *controls = [sortedControls objectEnumerator];
        unsigned currKey = 0;
        unsigned i = 0;
        while (key = [controls nextObject]) {
            if (i == 0) {
                [fh writeData:[@"    " dataUsingEncoding:NSUTF8StringEncoding]];
            }
            [fh writeData:[key dataUsingEncoding:NSUTF8StringEncoding]];
            if (i <= 6 && currKey != sortedControls.count - 1) {
                [fh writeData:[@", " dataUsingEncoding:NSUTF8StringEncoding]];
                i++;
            }
            if (i == 6) {
                [fh writeData:[@"\n" dataUsingEncoding:NSUTF8StringEncoding]];
                i = 0;
            }
            currKey++;
        }
        [fh writeData:[@"\n" dataUsingEncoding:NSUTF8StringEncoding]];
    }

    // Get all available options and put them in their necessary categories.
    CDOptions *availableOptions = [self availableOptions];
    NSEnumerator *availableOptionsEnumerator = [availableOptions.options.allValues objectEnumerator];
    CDOption *option;
    while (option = [availableOptionsEnumerator nextObject]) {
        NSString *category = option.category != nil ? option.category : NSLocalizedString(@"USAGE_CATEGORY_CONTROL", nil);
        NSMutableDictionary *categoryOptions = [usageCategories objectForKey:category];
        if (categoryOptions == nil) {
            categoryOptions = [[[NSMutableDictionary alloc] init] autorelease];
        }
        [categoryOptions setObject:option forKey:option.name];
        [usageCategories setObject:categoryOptions forKey:category];
    }

    // Determine the number of columns and how wide they should be.
    NSUInteger columns = 0;
    NSMutableArray *columnWidths = [[[NSMutableArray alloc] init] autorelease];
    for (id category in usageCategories) {
        NSDictionary *opts = [self parseOptionsIntoColumns:[usageCategories objectForKey:category]];
        for (id name in opts) {
            NSArray *optColumns = [opts objectForKey:name];
            if (optColumns.count > columns) {
                columns = optColumns.count;
            }
            __block int previousWidth = 0;
            [optColumns enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger i, BOOL * _Nonnull stop) {
                int maxWidth = (terminalWidth - previousWidth);

                NSString *string = [optColumns objectAtIndex:i];
                if (i >= columnWidths.count || [columnWidths objectAtIndex:i] == nil) {
                    [columnWidths insertObject:@0 atIndex:i];
                }

                NSNumber *currentLength = [columnWidths objectAtIndex:i];
                NSNumber *optionLength = [NSNumber numberWithInt:(int) string.length + 5];
                if ([optionLength intValue] > [currentLength intValue]) {
                    if ([optionLength intValue] > maxWidth) {
                        optionLength = [NSNumber numberWithInt:maxWidth];
                    }
                    previousWidth += [optionLength intValue];
                    [columnWidths replaceObjectAtIndex:i withObject:optionLength];
                }
            }];
        }
    }

    // Print options for each category.
    NSEnumerator *sortedCategories = [[NSArray arrayWithArray:[usageCategories.allKeys sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]] objectEnumerator];
    id category;
    while (category = [sortedCategories nextObject]) {
        [fh writeData:[@"\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [fh writeData:[category dataUsingEncoding:NSUTF8StringEncoding]];
        [fh writeData:[@":\n" dataUsingEncoding:NSUTF8StringEncoding]];

        NSDictionary *opts = [self parseOptionsIntoColumns:[usageCategories objectForKey:category]];
        NSArray *sorted = [NSArray arrayWithArray:[opts.allKeys sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];
        NSEnumerator *enumerator = [sorted objectEnumerator];
        id name;
        while (name = [enumerator nextObject]) {
            NSMutableString *line = [[[NSMutableString alloc] initWithString:@"    "] autorelease];
            NSArray *optColumns = [opts objectForKey:name];

            int previousWidth = 0;
            for (int i = 0, l = (int) optColumns.count; i < l; i++) {
                int maxWidth = (terminalWidth - previousWidth);
                int columnWidth = [[columnWidths objectAtIndex:i] intValue];

                NSMutableString *column = [NSMutableString string];

                [column appendString:[optColumns objectAtIndex:i]];

                // Wrap the column to fit available space.
                if (i != 0 && columnWidth >= maxWidth) {
                    column = [[NSMutableString stringWithString:[column wrapToLength: maxWidth - margin]] autorelease];
                }

                // Replace new lines so they're intented properly.
                column = [[NSMutableString stringWithString:[column indentNewlinesWith:(previousWidth + margin)]] autorelease];

                // Pad the column with spaces.
                if (i == 0) {
                    column = [NSMutableString stringWithString:[column stringByPaddingToLength:columnWidth withString:@" " startingAtIndex:0]];
                }

                previousWidth += columnWidth;

                [line appendString:column];
            }
            
            [line appendString:@"\n"];
            
            [fh writeData:[line dataUsingEncoding:NSUTF8StringEncoding]];
        }
    }

    [fh writeData:[@"\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [fh writeData:[@"\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [fh writeData:[[NSString stringWithFormat:NSLocalizedString(@"USAGE_VISIT_SITE", nil), [@CDSite UTF8String]] dataUsingEncoding:NSUTF8StringEncoding]];
    [fh writeData:[@"\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [fh writeData:[@"\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [fh writeData:[NSLocalizedString(@"USAGE_VERSION", nil) dataUsingEncoding:NSUTF8StringEncoding]];
    [fh writeData:[@": " dataUsingEncoding:NSUTF8StringEncoding]];
    [fh writeData:[[NSBundle mainBundle].infoDictionary[@"CFBundleVersion"] dataUsingEncoding:NSUTF8StringEncoding]];
    [fh writeData:[@"\n" dataUsingEncoding:NSUTF8StringEncoding]];
}

- (NSMutableDictionary *) parseOptionsIntoColumns:(NSDictionary *)opts {
    NSMutableDictionary *parsedOpts = [[[NSMutableDictionary alloc] init] autorelease];
    NSArray *sorted = [NSArray arrayWithArray:[opts.allValues sortedArrayUsingComparator:^NSComparisonResult(CDOption *a, CDOption *b) {
        return [a.name localizedCaseInsensitiveCompare:b.name];
    }]];
    NSEnumerator *enumerator = [sorted objectEnumerator];
    CDOption *option;
    while (option = [enumerator nextObject]) {
        NSMutableArray *columns = [[[NSMutableArray alloc] init] autorelease];

        // Determine the type of option.
        NSMutableString *type = [NSMutableString string];
        if (
            [option isKindOfClass:[CDOptionSingleString class]] ||
            [option isKindOfClass:[CDOptionSingleStringOrNumber class]] ||
            [option isKindOfClass:[CDOptionMultipleStrings class]] ||
            [option isKindOfClass:[CDOptionMultipleStringsOrNumbers class]]
        ) {
            [type appendString:NSLocalizedString(@"OPTION_TYPE_STRING", nil)];
        }
        if (
            [option isKindOfClass:[CDOptionSingleNumber class]] ||
            [option isKindOfClass:[CDOptionSingleStringOrNumber class]] ||
            [option isKindOfClass:[CDOptionMultipleNumbers class]] ||
            [option isKindOfClass:[CDOptionMultipleStringsOrNumbers class]]
        ) {
            if (![type isEqualToString:@""]) {
                [type appendString:@"|"];
            }
            [type appendString:NSLocalizedString(@"OPTION_TYPE_NUMBER", nil)];
        }

        // Add option "name <type>".
        if (![type isEqualToString:@""]) {
            [type insertString:@"<" atIndex:0];
            [type appendString:@">"];
            if ([option isKindOfClass:[CDOptionMultipleNumbers class]] || [option isKindOfClass:[CDOptionMultipleStrings class]] || [option isKindOfClass:[CDOptionMultipleStringsOrNumbers class]]) {
                [type appendString:@" [...] --"];
            }
            [columns addObject:[NSString stringWithFormat:@"--%@ %@", option.name, type]];
        }
        // Otherwise, just add the option "name".
        else {
            [columns addObject:[NSString stringWithFormat:@"--%@", option.name]];
        }

        // Add the option help text (description).
        if (option.helpText != nil) {
            [columns addObject:option.helpText];
        }

        [parsedOpts setObject:columns forKey:option.name];
    }
    return parsedOpts;
}

- (void) runControl {
    // The control must either: 1) sub-class -(NSString *) controlNib, return the name of the NIB, and then connect "controlPanel" in IB or 2) set the panel manually with [panel setPanel:(NSPanel *)]  when creating the control.
    if (panel.panel != nil) {
        // Set icon
        if (icon.control != nil) {
            [icon setIconFromOptions];
        }
        // Reposition Panel
        [panel setPosition];
        [panel setFloat];
        [NSApp run];
    }
    else {
        [self fatalError:@"The control has not specified the panel it is to use and cocoaDialog cannot continue."];
    }
}
- (void) setTimeout {
    timeout = 0.0f;
    timer = nil;
    // Only initialize timeout if the option is provided
    NSNumber *time = [arguments getOption:@"timeout"];
    if (timeout) {
        if ([[NSScanner scannerWithString:[NSString stringWithFormat:@"%@", time]] scanFloat:&timeout]) {
            mainThread = [NSThread currentThread];
            [NSThread detachNewThreadSelector:@selector(createTimer) toTarget:self withObject:nil];
        }
        else {
            [self warning:@"Unable to parse the --timeout option."];
        }
    }
    [self setTimeoutLabel];
}
- (void) setTimeoutLabel {
    if (timeoutLabel != nil) {
        float labelNewHeight = -4.0f;
        NSRect labelRect = timeoutLabel.frame;
        float labelHeightDiff = labelNewHeight - labelRect.size.height;
        timeoutLabel.stringValue = [self formatSecondsForString:(int)timeout];
        if (![timeoutLabel.stringValue isEqualToString:@""] && timeout != 0.0f) {
            NSTextStorage *textStorage = [[[NSTextStorage alloc] initWithString: timeoutLabel.stringValue]autorelease];
            NSTextContainer *textContainer = [[[NSTextContainer alloc] initWithContainerSize:NSMakeSize(labelRect.size.width, FLT_MAX)] autorelease];
            NSLayoutManager *layoutManager = [[[NSLayoutManager alloc]init] autorelease];
            [layoutManager addTextContainer: textContainer];
            [textStorage addLayoutManager: layoutManager];
            [layoutManager glyphRangeForTextContainer:textContainer];
            labelNewHeight = [layoutManager usedRectForTextContainer:textContainer].size.height;
            labelHeightDiff = labelNewHeight - labelRect.size.height;
            // Set label's new height
            NSRect l = NSMakeRect(labelRect.origin.x, labelRect.origin.y - labelHeightDiff, labelRect.size.width, labelNewHeight);
            timeoutLabel.frame = l;
        }
        else {
            [timeoutLabel setHidden:YES];
        }
        // Set panel's new width and height
        NSSize p = panel.panel.contentView.frame.size;
        p.height += labelHeightDiff;
        [panel.panel setContentSize:p];
    }
}
- (void) createTimer {
    NSAutoreleasePool *timerPool = [[NSAutoreleasePool alloc] init];
    timerThread = [NSThread currentThread];
    NSRunLoop *_runLoop = [NSRunLoop currentRunLoop];
    timer = [[NSTimer timerWithTimeInterval:1.0f target:self selector:@selector(processTimer) userInfo:nil repeats:YES] retain];
    [_runLoop addTimer:timer forMode:NSRunLoopCommonModes];
    [_runLoop run];
    [timerPool release];
}
- (void) stopTimer {
    [timer invalidate];
    [timer release];
    timer = nil;
    [self performSelector:@selector(stopControl) onThread:mainThread withObject:nil waitUntilDone:YES];
}
- (void) processTimer {
    // Decrease timeout value
    timeout = timeout - 1.0f;
    // Update and position the label if it exists
    if (timeout > 0.0f) {
        if (timeoutLabel != nil) {
            timeoutLabel.stringValue = [self formatSecondsForString:(int)timeout];
        }
    }
    else {
        controlExitStatus = 0;
        controlExitStatusString = @"timeout";
        controlReturnValues = [NSMutableArray array];
        [self stopTimer];
    }
}
- (void) stopControl {
    // Stop timer
    if (timerThread != nil) {
        [timerThread cancel];
    }
    // Stop any modal windows currently running
    [NSApp stop:self];
    if (![arguments hasOption:@"quiet"] && controlExitStatus != -1 && controlExitStatus != -2) {
        if ([arguments hasOption:@"string-output"]) {
            if (controlExitStatusString == nil) {
                controlExitStatusString = [NSString stringWithFormat:@"%d", controlExitStatus];
            }
            [controlReturnValues insertObject:controlExitStatusString atIndex:0];
        }
        else {
            [controlReturnValues insertObject: [NSString stringWithFormat:@"%d", controlExitStatus] atIndex:0];
        }
    }
    if (controlExitStatus == -1) controlExitStatus = 0;
    if (controlExitStatus == -2) controlExitStatus = 1;
    // Print all the returned lines
    if (controlReturnValues != nil) {
        unsigned i;
        NSFileHandle *fh = [NSFileHandle fileHandleWithStandardOutput];
        for (i = 0; i < controlReturnValues.count; i++) {
            if (fh) {
                [fh writeData:[controlReturnValues[i] dataUsingEncoding:NSUTF8StringEncoding]];
            }
            if (![arguments hasOption:@"no-newline"] || i+1 < controlReturnValues.count)
                {
                if (fh) {
                    [fh writeData:[@"\n" dataUsingEncoding:NSUTF8StringEncoding]];
                }
                }
        }
    }
    else {
        [self fatalError:@"Control returned nil."];
    }
    int exitStatus = controlExitStatus;
    [self dealloc];
    // Return the exit status
    exit(exitStatus);
}

- (void)windowWillClose:(NSNotification *)notification {
    [self stopControl];
}

#pragma mark - Subclassable Control Methods -
- (CDOptions *) availableOptions {
    CDOptions *options = [CDOptions options];

    NSString *global = @"GLOBAL_OPTION";

    // General.
    [options addOption:[CDOptionFlag                    name:@"debug"               value: nil category:global]];
    [options addOption:[CDOptionFlag                    name:@"help"                value: nil category:global]];
    [options addOption:[CDOptionFlag                    name:@"no-newline"          value: nil category:global]];
    [options addOption:[CDOptionFlag                    name:@"no-warnings"         value: nil category:global]];
    [options addOption:[CDOptionFlag                    name:@"quiet"               value: nil category:global]];
    [options addOption:[CDOptionFlag                    name:@"string-output"       value: nil category:global]];
    [options addOption:[CDOptionSingleNumber            name:@"timeout"             value: nil category:global]];
    [options addOption:[CDOptionSingleString            name:@"timeout-format"      value: nil category:global]];
    [options addOption:[CDOptionFlag                    name:@"verbose"             value: nil category:global]];
    [options addOption:[CDOptionFlag                    name:@"version"             value: nil category:global]];

    // Panel.
    [options addOption:[CDOptionSingleNumber            name:@"height"              value: nil category:global]];
    [options addOption:[CDOptionFlag                    name:@"no-float"            value: nil category:global]];
//    @todo Add max/min height/width options back once there is logic in place to support them.
//    [options addOption:[CDOptionSingleNumber            name:@"max-height"          value: nil category:global]];
//    [options addOption:[CDOptionSingleNumber            name:@"max-width"           value: nil category:global]];
//    [options addOption:[CDOptionSingleNumber            name:@"min-height"          value: nil category:global]];
//    [options addOption:[CDOptionSingleNumber            name:@"min-width"           value: nil category:global]];
    [options addOption:[CDOptionSingleStringOrNumber    name:@"posX"                value: nil category:global]];
    [options addOption:[CDOptionSingleStringOrNumber    name:@"posY"                value: nil category:global]];
    [options addOption:[CDOptionFlag                    name:@"resize"              value: nil category:global]];
    [options addOption:[CDOptionSingleNumber            name:@"screen"              value: nil category:global]];
    [options addOption:[CDOptionSingleString            name:@"title"               value: nil category:global]];
    [options addOption:[CDOptionFlag                    name:@"titlebar-close"      value: nil category:global]];
    [options addOption:[CDOptionFlag                    name:@"titlebar-minimize"   value: nil category:global]];
    [options addOption:[CDOptionFlag                    name:@"titlebar-zoom"       value: nil category:global]];
    [options addOption:[CDOptionSingleNumber            name:@"width"               value: nil category:global]];

    // Icon.
    [options addOption:[CDOptionSingleString            name:@"icon"                value: nil category:global]];
    [options addOption:[CDOptionSingleString            name:@"icon-bundle"         value: nil category:global]];
    [options addOption:[CDOptionSingleString            name:@"icon-file"           value: nil category:global]];
    [options addOption:[CDOptionSingleNumber            name:@"icon-height"         value: nil category:global]];
    [options addOption:[CDOptionSingleNumber            name:@"icon-size"           value: nil category:global]];
    [options addOption:[CDOptionSingleNumber            name:@"icon-width"          value: nil category:global]];
    [options addOption:[CDOptionSingleString            name:@"icon-type"           value: nil category:global]];

    return options;
}

- (void) createControl {};

- (NSMutableDictionary *) depreciatedOptions {return nil;}

- (BOOL) validateControl { return YES; }

- (BOOL) validateOptions { return YES; }

@end
