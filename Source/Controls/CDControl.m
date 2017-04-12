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
        _option = arguments.options;
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
    NSString *timerFormat = option[@"timeout-format"].wasProvided ? option[@"timeout-format"].stringValue : @"Time remaining: %r...";
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
            [self fatalError:@"Could not load control interface: \"%@.nib\"", nib, nil];
        }
    }
    else {
        [self fatalError:@"Control did not specify a NIB interface file to load.", nil];
    }
    panel = [[[CDPanel alloc] initWithArguments:self.arguments] retain];
    icon = [[[CDIcon alloc] initWithArguments:self.arguments] retain];
    if (controlPanel != nil) {

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowWillClose:) name:NSWindowWillCloseNotification object:controlPanel];


        BOOL close = option[@"titlebar-close"].boolValue;
        [controlPanel standardWindowButton:NSWindowCloseButton].enabled = close;
        if (!close) {
            controlPanel.styleMask = controlPanel.styleMask^NSClosableWindowMask;
        }

        BOOL minimize = option[@"titlebar-minimize"].boolValue;
        [controlPanel standardWindowButton:NSWindowMiniaturizeButton].enabled = minimize;
        if (!minimize) {
            controlPanel.styleMask = controlPanel.styleMask^NSMiniaturizableWindowMask;
        }

        // Handle --resize option.
        BOOL resize = option[@"resize"].boolValue;
        [controlPanel standardWindowButton:NSWindowZoomButton].enabled = resize && option[@"titlebar-resize"];
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

    // If (for whatever reason) there is no terminal width, default to 80.
    int tputColumns = [CDTput colsWithMinimum:80] - margin;

    [self writeNewLine];
    [self writeLn:[NSString stringWithFormat:NSLocalizedString(@"USAGE", nil), controlName].bold.stop];

    // Show avilable controls if it's the CDControl class printing this.
    NSMutableDictionary *usageCategories = [[[NSMutableDictionary alloc] init] autorelease];
    if ([self class] == [CDControl class]) {
        [self writeNewLine];
        [self writeLn:NSLocalizedString(@"USAGE_CATEGORY_CONTROLS", nil).uppercaseString.white.bold.underline.stop];
        NSArray *sortedControls = [NSArray arrayWithArray:[[AppController availableControls].allKeys sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];
        [self writeNewLine];

        NSEnumerator *controls = [sortedControls objectEnumerator];
        unsigned currKey = 0;
        unsigned i = 0;
        while (key = [controls nextObject]) {
            if (i == 0) {
                [self write:@"    "];
            }
            [self write:key];
            if (i <= 6 && currKey != sortedControls.count - 1) {
                [self write:@", "];
                i++;
            }
            if (i == 6) {
                [self writeNewLine];
                i = 0;
            }
            currKey++;
        }
        [self writeNewLine];
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
    NSMutableArray *realColumnWidths = [[[NSMutableArray alloc] init] autorelease];
    NSMutableArray *colorColumnWidths = [[[NSMutableArray alloc] init] autorelease];
    for (id category in usageCategories) {
        NSDictionary *opts = [self parseOptionsIntoColumns:[usageCategories objectForKey:category]];
        for (id name in opts) {
            NSArray *optColumns = [opts objectForKey:name];
            if (optColumns.count > columns) {
                columns = optColumns.count;
            }
            __block int realPreviousWidth = 0;
            __block int colorPreviousWidth = 0;
            [optColumns enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger i, BOOL * _Nonnull stop) {
                int realMaxWidth = (tputColumns - realPreviousWidth);
                int colorMaxWidth = (tputColumns - colorPreviousWidth);

                NSString *string = [optColumns objectAtIndex:i];
                if (i >= realColumnWidths.count || [realColumnWidths objectAtIndex:i] == nil) {
                    [realColumnWidths insertObject:@0 atIndex:i];
                }
                if (i >= colorColumnWidths.count || [colorColumnWidths objectAtIndex:i] == nil) {
                    [colorColumnWidths insertObject:@0 atIndex:i];
                }

                NSNumber *realStringLength = [NSNumber numberWithInt:(int) string.length + 5];
                if ([realStringLength intValue] > [[realColumnWidths objectAtIndex:i] intValue]) {
                    if ([realStringLength intValue] > realMaxWidth) {
                        realStringLength = [NSNumber numberWithInt:realMaxWidth];
                    }
                    realPreviousWidth += [realStringLength intValue];
                    [realColumnWidths replaceObjectAtIndex:i withObject:realStringLength];
                }

                NSNumber *colorStringLength = [NSNumber numberWithInt:(int) string.removeColor.length + 5];
                if ([colorStringLength intValue] > [[colorColumnWidths objectAtIndex:i] intValue]) {
                    if ([colorStringLength intValue] > colorMaxWidth) {
                        colorStringLength = [NSNumber numberWithInt:colorMaxWidth];
                    }
                    colorPreviousWidth += [colorStringLength intValue];
                    [colorColumnWidths replaceObjectAtIndex:i withObject:colorStringLength];
                }
            }];
        }
    }

    // Print options for each category.
    NSEnumerator *sortedCategories = [[NSArray arrayWithArray:[usageCategories.allKeys sortedArrayUsingComparator:^NSComparisonResult(NSString *a, NSString *b) {
        // Ensure global options are always at the bottom.
        if ([a isEqualToString:NSLocalizedString(@"GLOBAL_OPTION", nil)]) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        else if ([b isEqualToString:NSLocalizedString(@"GLOBAL_OPTION", nil)]) {
            return (NSComparisonResult)NSOrderedAscending;
        }
        return [a localizedCaseInsensitiveCompare:b];
    }]] objectEnumerator];
    NSString *category;
    while (category = [sortedCategories nextObject]) {
        [self writeNewLine];
        [self writeLn:category.uppercaseString.white.bold.underline.stop];
        [self writeNewLine];

        NSDictionary *opts = [self parseOptionsIntoColumns:[usageCategories objectForKey:category]];
        NSArray *sorted = opts.allKeys.sortedAlphabetically;
        NSEnumerator *enumerator = [sorted objectEnumerator];
        id name;
        while (name = [enumerator nextObject]) {
            NSMutableString *line = [[[NSMutableString alloc] initWithString:@"    "] autorelease];
            NSArray *optColumns = [opts objectForKey:name];

            int realPreviousWidth = 0;
            int colorPreviousWidth = 0;
            for (int i = 0, l = (int) optColumns.count; i < l; i++) {
                int colorMaxWidth = (tputColumns - colorPreviousWidth);
                int realColumnWidth = [[realColumnWidths objectAtIndex:i] intValue];
                int colorColumnWidth = [[colorColumnWidths objectAtIndex:i] intValue];

                NSMutableString *column = [NSMutableString string];

                [column appendString:[optColumns objectAtIndex:i]];

                // Wrap the column to fit available space.
                if (i != 0 && colorColumnWidth >= colorMaxWidth) {
                    column = [[NSMutableString stringWithString:[column wrapToLength: colorMaxWidth - margin]] autorelease];
                }

                // Replace new lines so they're intented properly.
                column = [[NSMutableString stringWithString:[column indentNewlinesWith:(colorPreviousWidth + margin)]] autorelease];

                // Pad the column with spaces.
                if (i == 0) {
                    column = [NSMutableString stringWithString:[column stringByPaddingToLength:colorColumnWidth withString:@" " startingAtIndex:0 ignoreColor:YES]];
                }

                realPreviousWidth += realColumnWidth;
                colorPreviousWidth += colorColumnWidth;

                [line appendString:column];
            }

            [self writeLn:line.stop];
        }
    }

    [self writeNewLine];
    [self writeNewLine];

    [self writeLn:[NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"USAGE_VERSION", nil).uppercaseString.underline.white.bold.stop, [AppController appVersion].cyan]];

    [self writeNewLine];

    [self writeLn:[NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"USAGE_WEBSITE", nil).uppercaseString.underline.white.bold.stop, @CDSite.cyan.stop]];
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

        if ([option isKindOfClass:[CDOptionBoolean class]]) {
            [type appendString:NSLocalizedString(@"OPTION_TYPE_BOOLEAN", nil)];
            type.color.fg = CDColorFgMagenta;
        }
        else {
            if (
                [option isKindOfClass:[CDOptionSingleString class]] ||
                [option isKindOfClass:[CDOptionSingleStringOrNumber class]] ||
                [option isKindOfClass:[CDOptionMultipleStrings class]] ||
                [option isKindOfClass:[CDOptionMultipleStringsOrNumbers class]]
                ) {
                [type appendString:NSLocalizedString(@"OPTION_TYPE_STRING", nil)];
                type.color.fg = CDColorFgGreen;
            }
            if (
                [option isKindOfClass:[CDOptionSingleNumber class]] ||
                [option isKindOfClass:[CDOptionSingleStringOrNumber class]] ||
                [option isKindOfClass:[CDOptionMultipleNumbers class]] ||
                [option isKindOfClass:[CDOptionMultipleStringsOrNumbers class]]
                ) {
                if (![type isEqualToString:@""]) {
                    [type appendString:@"|"];
                    type.color.fg = CDColorFgYellow;
                }
                else {
                    type.color.fg = CDColorFgCyan;
                }
                [type appendString:NSLocalizedString(@"OPTION_TYPE_NUMBER", nil)];
            }
        }

        // Add option "name <type>".
        BOOL useBreak = NO;
        if (![type isEqualToString:@""]) {
            [type insertString:@"<" atIndex:0];
            [type appendString:@">"];
            if ([option isKindOfClass:[CDOptionMultipleNumbers class]] || [option isKindOfClass:[CDOptionMultipleStrings class]] || [option isKindOfClass:[CDOptionMultipleStringsOrNumbers class]]) {
                [type appendString:@" [...] --"];
                useBreak = YES;
            }
            [columns addObject:[NSString stringWithFormat:@"--%@ %@", option.name, type.dim.stop].white.bold.stop];
        }
        // Otherwise, just add the option "name".
        else {
            [columns addObject:[NSString stringWithFormat:@"--%@", option.name].white.bold.stop];
        }

        // Add the option help text (description).
        if (option.helpText != nil) {
            if (useBreak) {
                [columns addObject:[NSString stringWithFormat:@"%@ %@", option.helpText, NSLocalizedString(@"OPTION_DOUBLE_DASH", nil)]];
            }
            else {
                [columns addObject:option.helpText];
            }
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
        [self fatalError:@"The control has not specified the panel it is to use and cocoaDialog cannot continue.", nil];
    }
}
- (void) setTimeout {
    timeout = 0.0f;
    timer = nil;
    // Only initialize timeout if the option is provided
    NSNumber *time = option[@"timeout"].numberValue;
    if (timeout) {
        if ([[NSScanner scannerWithString:[NSString stringWithFormat:@"%@", time]] scanFloat:&timeout]) {
            mainThread = [NSThread currentThread];
            [NSThread detachNewThreadSelector:@selector(createTimer) toTarget:self withObject:nil];
        }
        else {
            [self warning:@"Unable to parse the --timeout option.", nil];
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
    if (!option[@"quiet"].wasProvided && controlExitStatus != -1 && controlExitStatus != -2) {
        if (option[@"string-output"].wasProvided) {
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
            if (!option[@"no-newline"].wasProvided || i+1 < controlReturnValues.count) {
                if (fh) {
                    [fh writeData:[@"\n" dataUsingEncoding:NSUTF8StringEncoding]];
                }
            }
        }
    }
    else {
        [self fatalError:@"Control returned nil.", nil];
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

    // Global.
    [options addOption:[CDOptionBoolean                 name:@"color"               category:@"GLOBAL_OPTION"]];
    [options addOption:[CDOptionFlag                    name:@"debug"               category:@"GLOBAL_OPTION"]];
    [options addOption:[CDOptionFlag                    name:@"help"                category:@"GLOBAL_OPTION"]];
    [options addOption:[CDOptionFlag                    name:@"no-newline"          category:@"GLOBAL_OPTION"]];
    [options addOption:[CDOptionFlag                    name:@"no-warnings"         category:@"GLOBAL_OPTION"]];
    [options addOption:[CDOptionFlag                    name:@"quiet"               category:@"GLOBAL_OPTION"]];
    [options addOption:[CDOptionSingleNumber            name:@"screen"              category:@"GLOBAL_OPTION"]];
    [options addOption:[CDOptionFlag                    name:@"string-output"       category:@"GLOBAL_OPTION"]];
    [options addOption:[CDOptionSingleNumber            name:@"timeout"             category:@"GLOBAL_OPTION"]];
    [options addOption:[CDOptionSingleString            name:@"timeout-format"      category:@"GLOBAL_OPTION"]];
    [options addOption:[CDOptionFlag                    name:@"verbose"             category:@"GLOBAL_OPTION"]];
    [options addOption:[CDOptionFlag                    name:@"version"             category:@"GLOBAL_OPTION"]];

    // Panel.
    [options addOption:[CDOptionSingleNumber            name:@"height"              category:@"WINDOW_OPTION"]];
    [options addOption:[CDOptionFlag                    name:@"no-float"            category:@"WINDOW_OPTION"]];
//    @todo Add max/min height/width options back once there is logic in place to support them.
//    [options addOption:[CDOptionSingleNumber            name:@"max-height"          category:@"WINDOW_OPTION"]];
//    [options addOption:[CDOptionSingleNumber            name:@"max-width"           category:@"WINDOW_OPTION"]];
//    [options addOption:[CDOptionSingleNumber            name:@"min-height"          category:@"WINDOW_OPTION"]];
//    [options addOption:[CDOptionSingleNumber            name:@"min-width"           category:@"WINDOW_OPTION"]];
    [options addOption:[CDOptionSingleStringOrNumber    name:@"posX"                category:@"WINDOW_OPTION"]];
    [options addOption:[CDOptionSingleStringOrNumber    name:@"posY"                category:@"WINDOW_OPTION"]];
    [options addOption:[CDOptionFlag                    name:@"resize"              category:@"WINDOW_OPTION"]];
    [options addOption:[CDOptionSingleString            name:@"title"               category:@"WINDOW_OPTION"]];
    [options addOption:[CDOptionFlag                    name:@"titlebar-close"      category:@"WINDOW_OPTION"]];
    [options addOption:[CDOptionFlag                    name:@"titlebar-minimize"   category:@"WINDOW_OPTION"]];
    [options addOption:[CDOptionFlag                    name:@"titlebar-zoom"       category:@"WINDOW_OPTION"]];
    [options addOption:[CDOptionSingleNumber            name:@"width"               category:@"WINDOW_OPTION"]];

    // Icon.
    [options addOption:[CDOptionSingleString            name:@"icon"                category:@"ICON_OPTION"]];
    [options addOption:[CDOptionSingleString            name:@"icon-bundle"         category:@"ICON_OPTION"]];
    [options addOption:[CDOptionSingleString            name:@"icon-file"           category:@"ICON_OPTION"]];
    [options addOption:[CDOptionSingleNumber            name:@"icon-height"         category:@"ICON_OPTION"]];
    [options addOption:[CDOptionSingleNumber            name:@"icon-size"           category:@"ICON_OPTION"]];
    [options addOption:[CDOptionSingleNumber            name:@"icon-width"          category:@"ICON_OPTION"]];
    [options addOption:[CDOptionSingleString            name:@"icon-type"           category:@"ICON_OPTION"]];

    return options;
}

- (void) createControl {};

- (NSMutableDictionary *) depreciatedOptions {return nil;}

- (BOOL) validateControl { return YES; }

- (BOOL) validateOptions { return YES; }

@end
