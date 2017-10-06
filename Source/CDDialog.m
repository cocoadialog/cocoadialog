// CDDialog.m
// cocoadialog
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.

#import "CDApplication.h"
#import "CDDialog.h"

@implementation CDDialog

#pragma mark - Properties
- (BOOL) allowEmptyReturn {
    return !option[@"value-required"].boolValue;
}

- (BOOL) isReturnValueEmpty {
    return NO;
}

- (NSString *) returnValueEmptyText {
    return NSLocalizedString(@"An input is required, please try again.", nil);
}

- (NSString *) xib {
    return [CDDialog className];
}

#pragma mark - Public instance methods
- (CDOptions *) availableOptions {
    CDOptions *options = [super availableOptions];

    // --buttons
    [options add:[CDOptionMultipleStrings         name:@"buttons"             category:@"DIALOG_OPTION"]];
    [options add:[CDOptionSingleString            name:@"button1"             replacedBy:@"buttons"     valueIndex:0]];
    [options add:[CDOptionSingleString            name:@"button2"             replacedBy:@"buttons"     valueIndex:1]];
    [options add:[CDOptionSingleString            name:@"button3"             replacedBy:@"buttons"     valueIndex:2]];
    options[@"buttons"].maximumValues = @3;

    // --cancel-button
    [options add:[CDOptionSingleStringOrNumber    name:@"cancel-button"       category:@"DIALOG_OPTION"]];
    [options add:[CDOptionSingleStringOrNumber    name:@"cancel"              replacedBy:@"cancel-button"]];
    options[@"cancel-button"].defaultValue = @"Cancel";

    // --default-button
    [options add:[CDOptionSingleStringOrNumber    name:@"default-button"      category:@"DIALOG_OPTION"]];

    // --float
    [options add:[CDOptionBoolean                 name:@"float"               category:@"DIALOG_OPTION"]];
    [options add:[CDOptionBoolean                 name:@"no-float"            replacedBy:@"float"]];
    options[@"float"].defaultValue = @YES;

    // --header
    [options add:[CDOptionSingleString            name:@"header"              category:@"DIALOG_OPTION"]];
    [options add:[CDOptionSingleString            name:@"alert"               replacedBy:@"header"]];
    [options add:[CDOptionSingleString            name:@"text"                replacedBy:@"header"]];

    // --height
    [options add:[CDOptionSingleNumber            name:@"height"              category:@"DIALOG_OPTION"]];

    // --icon
    [options add:[CDOptionSingleString            name:@"icon"                category:@"DIALOG_OPTION"]];

    // --icon-bundle
    [options add:[CDOptionSingleString            name:@"icon-bundle"         category:@"DIALOG_OPTION"]];

    // --icon-file
    [options add:[CDOptionSingleString            name:@"icon-file"           category:@"DIALOG_OPTION"]];

    // --icon-height
    [options add:[CDOptionSingleNumber            name:@"icon-height"         category:@"DIALOG_OPTION"]];
    [options[@"icon-height"].allowedValues addObjectsFromArray:@[@16, @32, @48, @96, @128, @256]];

    // --icon-size
    [options add:[CDOptionSingleNumber            name:@"icon-size"           category:@"DIALOG_OPTION"]];
    [options[@"icon-size"].allowedValues addObjectsFromArray:@[@16, @32, @48, @96, @128, @256]];
    options[@"icon-size"].defaultValue = @48;

    // --icon-type
    [options add:[CDOptionSingleString            name:@"icon-type"           category:@"DIALOG_OPTION"]];
    [options[@"icon-type"].allowedValues addObjectsFromArray:@[@"gif", @"icns", @"ico", @"jpg", @"png", @"tiff"]];
    options[@"icon-type"].defaultValue = @"icns";

    // --icon-width
    [options add:[CDOptionSingleNumber            name:@"icon-width"          category:@"DIALOG_OPTION"]];
    [options[@"icon-width"].allowedValues addObjectsFromArray:@[@16, @32, @48, @96, @128, @256]];

    // --markdown
    [options add:[CDOptionBoolean                 name:@"markdown"            category:@"DIALOG_OPTION"]];

    // --max-height
    [options add:[CDOptionSingleNumber            name:@"max-height"          category:@"DIALOG_OPTION"]];

    // --max-width
    [options add:[CDOptionSingleNumber            name:@"max-width"           category:@"DIALOG_OPTION"]];

    // --min-height
    [options add:[CDOptionSingleNumber            name:@"min-height"          category:@"DIALOG_OPTION"]];

    // --min-width
    [options add:[CDOptionSingleNumber            name:@"min-width"           category:@"DIALOG_OPTION"]];

    // --message
    [options add:[CDOptionSingleString            name:@"message"             category:@"DIALOG_OPTION"]];
    [options add:[CDOptionSingleString            name:@"informative-text"    replacedBy:@"message"]];

    // --posX
    [options add:[CDOptionSingleStringOrNumber    name:@"posX"                category:@"DIALOG_OPTION"]];
    options[@"posX"].defaultValue = @"center";

    // --posY
    [options add:[CDOptionSingleStringOrNumber    name:@"posY"                category:@"DIALOG_OPTION"]];
    options[@"posY"].defaultValue = @"center";

    // --resize
    [options add:[CDOptionBoolean                 name:@"resize"              category:@"DIALOG_OPTION"]];

    // --selectable-labels
    [options add:[CDOptionBoolean                 name:@"selectable-labels"   category:@"DIALOG_OPTION"]];

    // --timeout
    [options add:[CDOptionSingleNumber            name:@"timeout"             category:@"DIALOG_OPTION"]];

    // --timeout-format
    [options add:[CDOptionSingleString            name:@"timeout-format"      category:@"DIALOG_OPTION"]];
    options[@"timeout-format"].defaultValue = @"_Time remaining: %r..._";
    options[@"timeout-format"].parentOption = options[@"timeout"];

    // --title
    [options add:[CDOptionSingleString            name:@"title"               category:@"DIALOG_OPTION"]];
    options[@"title"].defaultValue = (CDOptionAutomaticDefaultValue) ^() {
        return [CDApplication appTitle];
        //return option[@"app-title"].stringValue;
    };

    // --titlebar-close
    [options add:[CDOptionBoolean                 name:@"titlebar-close"      category:@"DIALOG_OPTION"]];

    // --titlebar-minimize
    [options add:[CDOptionBoolean                 name:@"titlebar-minimize"   category:@"DIALOG_OPTION"]];

    // --titlebar-zoom
    [options add:[CDOptionBoolean                 name:@"titlebar-zoom"       category:@"DIALOG_OPTION"]];

    // --vibrancy
    [options add:[CDOptionBoolean                 name:@"vibrancy"            category:@"DIALOG_OPTION"]];
    options[@"vibrancy"].defaultValue = (CDOptionAutomaticDefaultValue) ^() {
        return [NSNumber numberWithBool:NSClassFromString(@"NSVisualEffectView") != nil];
    };

    // --width
    [options add:[CDOptionSingleNumber            name:@"width"               category:@"DIALOG_OPTION"]];

    // --------------------
    // Input options.
    // --------------------

    // --empty-text
    [options add:[CDOptionSingleString            name:@"empty-text"            category:@"INPUT_OPTIONS"]];

    // --no-newline
    [options add:[CDOptionBoolean                 name:@"no-newline"            category:@"INPUT_OPTIONS"]];

    // --return-labels
    [options add:[CDOptionBoolean                 name:@"return-labels"         category:@"INPUT_OPTIONS"]];
    [options add:[CDOptionBoolean                 name:@"string-output"         replacedBy:@"return-labels"]];

    // --value-required
    [options add:[CDOptionBoolean                 name:@"value-required"        category:@"INPUT_OPTIONS"]];

    // --------------------
    // Hidden options (deprecated aliased control options).
    // @todo Remove in 4.0.0
    // --------------------

    // --no-cancel
    [options add:[CDOptionBoolean                 name:@"no-cancel"]]; // yesno-msgbox
    options[@"no-cancel"].hidden = YES;

    return options;
}

- (void) dealloc {
    if (self.timer != nil) {
        [self.timer invalidate];
    }
}

- (void) initControl {
    [super initControl];
    [self initTitle];
    [self initIcon];
    [self initHeader];
    [self initMessage];
    [self initControlView];
    [self initTimeout];
    [self initButtons];
}

- (void) initControlView {
}

- (void) runControl {
    // Add borders around all views when in development mode.
    if (option[@"dev"].boolValue) {
        for (NSView *view in self.panel.contentView.subviews) {
            view.wantsLayer = YES;
            view.layer.borderWidth = 1;
            view.layer.borderColor = [[NSColor blueColor] CGColor];
        }
    }

    // Remove the control view if there are no subviews.
    if (!self.controlView.subviews.count) {
        [self.panel removeSubview:self.controlView movingAttribute:NSLayoutAttributeTop to:self.timeoutLabel];
    }
    

    if (self.button0.hidden && self.button1.hidden && self.button2.hidden) {
//        [self.panel.contentView removeConstraints:[self.panel getConstraintsForView:self.timeoutLabel withAttribute:NSLayoutAttributeBottom]];
//        [self.panel.contentView addConstraints:[self.panel getConstraintsForView:self.button1 withAttribute:NSLayoutAttributeBottom]];
        [self.panel moveContraintAttribute:NSLayoutAttributeBottom from:self.button1 to:self.timeoutLabel];
        [self.panel removeSubview:self.button0];
        [self.panel removeSubview:self.button1];
        [self.panel removeSubview:self.button2];

//        float height = self.button1.frame.size.height;
//        NSArray <NSLayoutConstraint *> *button1Constraints = [self.panel getConstraintsForView:self.button1 withAttribute:NSLayoutAttributeTop];
//        for (NSLayoutConstraint *constraint in button1Constraints) {
//            height += constraint.constant;
//        }
//        NSArray <NSLayoutConstraint *> *timeoutLabelConstraints = [self.panel getConstraintsForView:self.timeoutLabel withAttribute:NSLayoutAttributeBottom];
//        for (NSLayoutConstraint *constraint in timeoutLabelConstraints) {
//            constraint.constant -= height;
//        }
    }

    [self.panel moveContraintAttribute:NSLayoutAttributeBottom toVisibleView:@[self.button1, self.timeoutLabel, self.controlView, self.message, self.header]];
    [self.panel moveContraintAttribute:NSLayoutAttributeTop toVisibleView:@[self.header, self.message, self.controlView, self.timeoutLabel]];

    // Initialize the panel.
    [self initPanel];

    // Start timeout, if necessary.
    if (self.timeout) {
        self.mainThread = [NSThread currentThread];
        [NSThread detachNewThreadSelector:@selector(createTimer) toTarget:self withObject:nil];
    }

    // Continue up the chain.
    [super runControl];
}

- (void) stopControl {
    // Stop timer.
    if (self.timer != nil) {
        [self.timer invalidate];
        self.timer = nil;
    }
    if (self.timerThread != nil) {
        [self.timerThread cancel];
    }

    [super stopControl];
}

- (void) alertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
    if (self.firstResponder != nil) {
        [self.panel makeFirstResponder:self.firstResponder];
    }
}

- (void) returnValueEmptySheet {
    // Save the currently focused view.
    self.firstResponder = self.panel.firstResponder ?: nil;

    NSString *message = option[@"empty-text"].wasProvided ? option[@"empty-text"].stringValue : [self returnValueEmptyText];
    NSAlert *alertSheet = [[NSAlert alloc] init];
    [alertSheet addButtonWithTitle:NSLocalizedString(@"OKAY", nil)];
    alertSheet.icon = [self iconFromName:@"caution"];
    alertSheet.messageText = message;
    [alertSheet beginSheetModalForWindow:self.panel completionHandler:^(NSModalResponse returnCode) {
        [self alertDidEnd:alertSheet returnCode:returnCode contextInfo:nil];
    }];
//    [alertSheet beginSheetModalForWindow:self.panel modalDelegate:self didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) contextInfo:nil];
}

#pragma mark - Window Delegated Methods

- (void) windowDidResize:(NSNotification *)notification {
    [self setLabel:self.header withText:self.header.stringValue];
    [self setLabel:self.message withText:self.message.stringValue];
    [self setLabel:self.timeoutLabel withText:self.timeoutLabel.stringValue];
    [self updateMinSize];
    if (option[@"dev"].boolValue) {
        [self verbose:@"Resized panel width: %@, height: %@, minimum width: %@, minimum height: %@", [NSNumber numberWithFloat:self.panel.frame.size.width], [NSNumber numberWithFloat:self.panel.frame.size.height], [NSNumber numberWithFloat:self.panel.contentMinSize.width], [NSNumber numberWithFloat:self.panel.contentMinSize.height], nil];
    }
}

- (void) windowWillClose:(NSNotification *)notification {
    exitStatus = CDExitCodeCancel;
    [self stopControl];
}

#pragma mark - Buttons

- (void) initButtons {
    self.cancelButton = option[@"cancel-button"].numberValue;
    NSString *cancelButton = option[@"cancel-button"].stringValue;

    NSArray *buttons = option[@"buttons"].arrayValue;
//    NSNumber *defaultButtonNumber = option[@"default-button"].numberValue;
//    NSString *defaultButtonString = defaultButtonNumber == nil ? option[@"default-button"].stringValue : nil;
    for (NSUInteger i = 0; i < buttons.count; i++) {
        NSButton *button = [self valueForKey:[NSString stringWithFormat:@"button%lu", i]];
        NSString *title = buttons[i];

        // Skip buttons that are empty.
        if (title == nil || title.isBlank) {
            button.hidden = YES;
            continue;
        }

        button.title = title;
        [button sizeToFit];

        if ((self.cancelButton && self.cancelButton.unsignedIntegerValue == i) || (!self.cancelButton && ([cancelButton isEqualToStringCaseInsensitive:title]))) {
            button.keyEquivalent = @"\e";
            self.cancelButton = [NSNumber numberWithUnsignedInteger:i];
        }

        // Remove default button key mappings.
//        if (noDefault && ![button.keyEquivalent isEqual: @""]) {
//            button.keyEquivalent = @"";
//            button.needsDisplay = YES;
//        }
    }

    // Ensure the panel itself doesn't have a set default button.
//    if (noDefault) {
//        [self.panel setDefaultButtonCell:nil];
//    }

}

- (void) controlHasFinished:(NSUInteger)button {
    if (self.cancelButton && button == self.cancelButton.unsignedIntegerValue) {
        returnValues = [NSMutableDictionary dictionary];
        exitStatus = CDExitCodeCancel;
    }
    else {
        if (![self allowEmptyReturn] && [self isReturnValueEmpty]) {
            [self returnValueEmptySheet];
            return;
        }
    }

    id buttonValue = [NSNumber numberWithUnsignedInteger:button];

    if (option[@"return-labels"].wasProvided) {
        switch (button) {
            case 0: buttonValue = self.button0.title; break;
            case 1: buttonValue = self.button1.title; break;
            case 2: buttonValue = self.button2.title; break;
        }
    }

    // Add the button return value.
    if (buttonValue != nil) {
        returnValues[@"button"] = buttonValue;
    }

    [self stopControl];
}

- (IBAction) buttonPressed:(NSButton *)button {
    [returnValues removeAllObjects];
    [self controlHasFinished:button.tag];
}

#pragma mark - Header

- (void) initHeader {
    [self setLabel:self.header withText:option[@"header"].stringValue];
    if (self.header.hidden) {
        [self.panel removeSubview:self.header movingAttribute:NSLayoutAttributeTop to:self.message];
    }
}

#pragma mark - Icon
- (void) initIcon {
    NSImage *image = nil;
    if (option[@"icon-file"].wasProvided) {
        image = [self iconFromFile:option[@"icon-file"].stringValue];
    }
    else if (option[@"icon"].wasProvided) {
        image = [self iconFromName:option[@"icon"].stringValue];
    }

    // Default icon size.
    float w = 48.0f;
    float h = 48.0f;

    // Retrive sizes from options.
    if (option[@"icon-size"].wasProvided) {
        w = option[@"icon-size"].floatValue;
        h = option[@"icon-size"].floatValue;
    }
    else {
        if (option[@"icon-width"].wasProvided) {
            w = option[@"icon-width"].floatValue;
        }
        if (option[@"icon-height"].wasProvided) {
            h = option[@"icon-height"].floatValue;
        }
    }

    // Set the icon.
    [self setIconFromImage:image withSize:NSMakeSize(w, h)];
}

- (void) setIconFromImage:(NSImage *)anImage withSize:(NSSize)aSize {
    // Immediately remove image if not set and then return.
    if (anImage == nil) {
        self.iconView.image = nil;
        self.iconLeadingConstraint.constant = 0;
        self.iconHeightConstraint.constant = 0;
        self.iconWidthConstraint.constant = 0;
        [self.panel updateConstraintsIfNeeded];
        return;
    }

    NSSize originalSize = anImage.size;

    // Resize Icon
    if (originalSize.width != aSize.width || originalSize.height != aSize.height) {
        NSImage *resizedImage = [[NSImage alloc] initWithSize: aSize];
        [resizedImage lockFocus];
        [anImage drawInRect:NSMakeRect(0, 0, aSize.width, aSize.height) fromRect:NSMakeRect(0, 0, originalSize.width, originalSize.height) operation:NSCompositeSourceOver fraction:1.0];
        [resizedImage unlockFocus];
        anImage = resizedImage;
    }

    // Replace the image.
    self.iconView.image = anImage;

    // Update constraints.
    self.iconLeadingConstraint.constant = 20;
    self.iconHeightConstraint.constant = aSize.height;
    self.iconWidthConstraint.constant = aSize.width;
    [self.panel updateConstraintsIfNeeded];
}

#pragma mark - Message

- (void) initMessage {
    [self setLabel:self.message withText:option[@"message"].stringValue];
    if (self.message.hidden) {
        [self.panel removeSubview:self.message movingAttribute:NSLayoutAttributeTop to:self.controlView];
    }
}

#pragma mark - Panel

- (float) getViewHeight:(NSView *)view {
    if (view.hidden) {
        return 0.0f;
    }

    // Return a height constraint.
    for (NSLayoutConstraint *constraint in view.constraints) {
        if (constraint.firstAttribute == NSLayoutAttributeHeight) {
            return constraint.constant;
        }
    }

    // Otherwise, return the frame height.
    return view.frame.size.height;
}

- (float) getMinHeight {
    float minHeight = 0.0f;

    minHeight += [self getViewHeight:self.header];
    minHeight += [self getViewHeight:self.message];
    minHeight += [self getViewHeight:self.controlView];
    minHeight += [self getViewHeight:self.timeoutLabel];

    if (option[@"buttons"].wasProvided) {
        minHeight += [self getViewHeight:self.button0] + 10.0f;
    }

    // Add in top constraints.
    for (NSView *view in self.panel.contentView.subviews) {
        // Skip hidden views.
        if (view.hidden) {
            continue;
        }
        NSArray <NSLayoutConstraint *> *constraints = [self.panel getConstraintsForView:view withAttribute:NSLayoutAttributeTop];
        for (NSLayoutConstraint *constraint in constraints) {
            minHeight += constraint.constant;
        }
    }

    return minHeight;
}

- (void) updateMinSize {
    NSSize minSize = self.panel.contentMinSize;
    minSize.height = [self getMinHeight];
    self.panel.contentMinSize = minSize;
}

- (void) initPanel {
    if (self.panel == nil) {
        [self fatal: CDExitCodeControlFailure error:@"Control panel failed to bind.", nil];
    }

    // Update panel's constraints.
    [self.panel setContentSize:NSMakeSize(self.panel.contentView.frame.size.width, self.panel.contentView.frame.size.height)];
    self.panel.viewsNeedDisplay = YES;
    [self.panel updateConstraintsIfNeeded];

    [self.panel makeLabelsSelectable:option[@"selectable-labels"].boolValue];
    self.panel.vibrancy = option[@"vibrancy"].boolValue;

    [self updateMinSize];

    // Resize.
    NSScreen *screen = self.getScreen;
    NSSize size = self.panel.contentView.frame.size;

    float width, height;
    if (option[@"width"].wasProvided) {
        width = option[@"width"].isPercent ? [option[@"width"] percentageOf:screen.frame.size.width] : option[@"width"].floatValue;
        if (width != 0.0) {
            size.width = width;
        }
    }
    if (option[@"height"].wasProvided) {
        height = option[@"height"].isPercent ? [option[@"height"] percentageOf:screen.frame.size.height] : option[@"height"].floatValue;
        if (height != 0.0) {
            size.height = height;
        }
    }
    NSSize minSize = self.panel.contentMinSize;
    if (size.height < minSize.height) {
        size.height = minSize.height;
    }
    if (size.width < minSize.width) {
        size.width = minSize.width;
    }

    // Set the new panel size.
    [self.panel setContentSize:size];

    // Determine whether or not panel should float.
    self.panel.floatingPanel = option[@"float"].boolValue;
    self.panel.level = option[@"float"].boolValue ? NSFloatingWindowLevel : NSNormalWindowLevel;

    // Retrieve information about the screen.
    float x = NSMinX(screen.visibleFrame);
    float y = NSMinY(screen.visibleFrame);
    float padding = 20.0f;
    float screenHeight = NSHeight(screen.visibleFrame);
    float screenWidth = NSWidth(screen.visibleFrame);

    // Retrieve any position options.
    NSString *posX = option[@"posX"].stringValue;
    NSString *posY = option[@"posY"].stringValue;

    // Default to center positions.
    float left = x + ((screenWidth - NSWidth(self.panel.frame)) / 2.0f - padding);
    float top = (y + screenHeight) - (screenHeight / 1.8f) - (NSHeight(self.panel.frame) / 1.8f);

    float posXNumber = option[@"posX"].isPercent ? [option[@"posX"] percentageOf:screenWidth - NSWidth(self.panel.frame)] : option[@"posX"].floatValue;
    float posYNumber = option[@"posY"].isPercent ? [option[@"posY"] percentageOf:screenHeight - NSHeight(self.panel.frame)] : option[@"posY"].floatValue;


    // Left
    if ([posX isEqualToStringCaseInsensitive:@"left"]) {
        left = x + padding;
    }
    // Right
    else if ([posX isEqualToStringCaseInsensitive:@"right"]) {
        left = x + (screenWidth - NSWidth(self.panel.frame)) - padding;
    }
    // Manual posX coords
    else if (posXNumber) {
        left = x + posXNumber;
    }

    // Bottom
    if ([posY isEqualToStringCaseInsensitive:@"bottom"]) {
        top = y + padding;
    }
    // Top
    else if ([posY isEqualToStringCaseInsensitive:@"top"]) {
        top = (y + screenHeight) - NSHeight(self.panel.frame) - padding;
    }
    // Manual posY coords
    else if (posYNumber) {
        top = (y + screenHeight) - NSHeight(self.panel.frame) - posYNumber;
    }

    // Set the panel's new frame origins.
    [self.panel setFrameOrigin:NSMakePoint(left, top)];
    [self.panel makeKeyAndOrderFront:nil];
}

- (void) initTitle {
    self.panel.title = option[@"title"].stringValue;

    // Handle --titlebar-close option.
    BOOL close = option[@"titlebar-close"].boolValue;
    [self.panel standardWindowButton:NSWindowCloseButton].enabled = close;
    if (close) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowWillClose:) name:NSWindowWillCloseNotification object:self.panel];
    }
    else {
        self.panel.styleMask = self.panel.styleMask^NSClosableWindowMask;
    }

    // Handle --titlebar-minimize option.
    BOOL minimize = option[@"titlebar-minimize"].boolValue;
    [self.panel standardWindowButton:NSWindowMiniaturizeButton].enabled = minimize;
    if (!minimize) {
        self.panel.styleMask = self.panel.styleMask^NSMiniaturizableWindowMask;
    }

    // Handle --resize and && --titlebar-zoom options.
    BOOL resize = option[@"resize"].boolValue;
    [self.panel standardWindowButton:NSWindowZoomButton].enabled = resize && option[@"titlebar-zoom"].wasProvided;
    if (!resize) {
        self.panel.styleMask = self.panel.styleMask^NSResizableWindowMask;
    }
}

#pragma mark - Timer
- (void) createTimer {
    @autoreleasepool {
        self.timerThread = [NSThread currentThread];
        NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
        self.timer = [NSTimer timerWithTimeInterval:1.0f target:self selector:@selector(processTimer) userInfo:nil repeats:YES];
        [runLoop addTimer:self.timer forMode:NSRunLoopCommonModes];
        [runLoop run];
    }
}

- (NSString *) format:(NSString *)format withSeconds:(NSUInteger)timeInSeconds {
    NSUInteger seconds = timeInSeconds % 60;
    NSUInteger minutes = (timeInSeconds / 60) % 60;
    NSUInteger hours = timeInSeconds / 3600;
    NSUInteger days = timeInSeconds / (3600 * 24);
    NSString *relative = @"N/A";
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
    format = [format stringByReplacingOccurrencesOfString:@"%s" withString:[NSString stringWithFormat:@"%ld", (long) seconds]];
    format = [format stringByReplacingOccurrencesOfString:@"%m" withString:[NSString stringWithFormat:@"%ld", (long) minutes]];
    format = [format stringByReplacingOccurrencesOfString:@"%h" withString:[NSString stringWithFormat:@"%ld", (long) hours]];
    format = [format stringByReplacingOccurrencesOfString:@"%d" withString:[NSString stringWithFormat:@"%ld", (long) days]];
    format = [format stringByReplacingOccurrencesOfString:@"%r" withString:relative];
    return format;
}

- (void) processTimer {
    // Decrease timeout value.
    self.timeout = self.timeout - 1.0f;

    // Update and position the label if it exists.
    if (self.timeout > 0.0f) {
        if (self.timeoutLabel != nil) {
            self.timeoutLabel.stringValue = [self format:option[@"timeout-format"].stringValue withSeconds:ceil(self.timeout)];
        }
    }
    else {
        exitStatus = CDExitCodeTimeout;
        returnValues = [NSMutableDictionary dictionary];
        [self performSelector:@selector(stopControl) onThread:self.mainThread withObject:nil waitUntilDone:YES];
    }
}

- (void) setLabel:(CDTextField *)label withText:(NSString *)text {
    label.markdown.enabled = option[@"markdown"].boolValue;

    // Immediately hide label if there's nothing there.
    if (text == nil || text.isBlank) {
        label.hidden = YES;
        return;
    }

    // Determine the maximum height for the text based on current available width.
    // @see https://stackoverflow.com/a/32171028/1226717
    float width = label.frame.size.width;
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:label];
    NSTextField *clone = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    NSRect rect = {NSZeroPoint, NSMakeSize(width, 0)};
    rect = [clone alignmentRectForFrame:rect];
    clone.preferredMaxLayoutWidth = NSWidth(rect);
    rect.size = clone.intrinsicContentSize;

    float height = [clone frameForAlignmentRect:rect].size.height;

    // Update any height constraint on the label.
    for (NSLayoutConstraint *constraint in label.constraints) {
        if (constraint.firstAttribute == NSLayoutAttributeHeight) {
            if (constraint.constant != height) {
                constraint.constant = height;
                [label updateConstraints];
            }
            break;
        }
    }

    // Set label's new height.
    if (label.frame.size.height != height) {
        [label setFrameSize:NSMakeSize(label.frame.size.width, height)];
    }

    // Set the text.
    if (![label.stringValue isEqualToString:text]) {
        label.stringValue = text;
    }

    [label displayIfNeeded];
}

- (void) initTimeout {
    self.timer = nil;
    self.timeout = option[@"timeout"].doubleValue;

    NSString *text = self.timeout ? [self format:option[@"timeout-format"].stringValue withSeconds:ceil(self.timeout)] : nil;

    // Set the timeout label.
    [self setLabel:self.timeoutLabel withText:text];
}

@end
