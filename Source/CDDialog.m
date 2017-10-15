// CDDialog.m
// cocoadialog
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.

#import "CDApplication.h"
#import "CDDialog.h"
#import "CDIcon.h"

// Frameworks.
#import <Masonry/Masonry.h>

@implementation CDDialog

- (instancetype) init {
    self = [super init];
    if (self) {
        self.panel = [[NSPanel alloc] init];
        self.buttons = [NSMutableArray array];
        self.controlView = [[NSView alloc] init];
    }
    return self;
}

#pragma mark - Properties
- (BOOL) allowEmptyReturn {
    return !self.options[@"value-required"].boolValue;
}

- (BOOL) isReturnValueEmpty {
    return NO;
}

- (NSString *) returnValueEmptyText {
    return @"An input is required, please try again.".localized;
}

+ (NSString *) scope {
    return @"dialog";
}

- (NSString *) nib {
    return [CDDialog className];
}

#pragma mark - Public instance methods
+ (CDOptions *) availableOptions {
    return super.availableOptions.addOptionsToScope([self class].scope,
  @[
    CDOption.create(CDString,           @"buttons").min(1).max(3).deprecates(@[
                                                                    CDOption.create(CDString, @"button1").toValueIndex(0),
                                                                    CDOption.create(CDString, @"button2").toValueIndex(1),
                                                                    CDOption.create(CDString, @"button3").toValueIndex(2)
                                                                    ]),
    CDOption.create(CDStringOrNumber,   @"cancel-button").setDefaultValue(@"Cancel").deprecates(@[CDOption.create(CDStringOrNumber, @"cancel")]),
    CDOption.create(CDStringOrNumber,   @"default-button"),
    CDOption.create(CDBoolean,          @"float").setDefaultValue(@YES).deprecates(@[CDOption.create(CDBoolean, @"no-float")]).addWarning(@"USAGE_OPTION_DIALOG_FLOAT_WARNING".localized),
    CDOption.create(CDString,           @"header").deprecates(@[CDOption.create(CDString, @"alert"), CDOption.create(CDString, @"text")]),
    CDOption.create(CDNumber,           @"height"),
    CDOption.create(CDString,           @"icon"),
    CDOption.create(CDString,           @"icon-bundle"),
    CDOption.create(CDString,           @"icon-file"),
    CDOption.create(CDNumber,           @"icon-height").allow(@[@16, @32, @48, @96, @128, @256]),
    CDOption.create(CDNumber,           @"icon-size").allow(@[@16, @32, @48, @96, @128, @256]).setDefaultValue(@48),
    CDOption.create(CDString,           @"icon-type").allow(@[@"gif", @"icns", @"ico", @"jpg", @"png", @"tiff"]).setDefaultValue(@"icns"),
    CDOption.create(CDNumber,           @"icon-width").allow(@[@16, @32, @48, @96, @128, @256]),
    CDOption.create(CDBoolean,          @"markdown").setDefaultValue(@YES),
    CDOption.create(CDNumber,           @"max-height").setDefaultValue(@YES),
    CDOption.create(CDNumber,           @"max-width").setDefaultValue(@YES),
    CDOption.create(CDNumber,           @"min-height").setDefaultValue(@YES),
    CDOption.create(CDNumber,           @"min-width").setDefaultValue(@YES),
    CDOption.create(CDString,           @"message").deprecates(@[CDOption.create(CDString, @"informative-text")]),
    CDOption.create(CDStringOrNumber,   @"posX").setDefaultValue(@"center"),
    CDOption.create(CDStringOrNumber,   @"posY").setDefaultValue(@"center"),
    CDOption.create(CDBoolean,          @"resize").setDefaultValue(@NO),
    CDOption.create(CDBoolean,          @"selectable-labels").setDefaultValue(@NO).addNote(@"USAGE_OPTION_DIALOG_SELECTABLE_LABELS_NOTE_MARKDOWN".localized),
    CDOption.create(CDNumber,           @"timeout"),
    CDOption.create(CDString,           @"timeout-format").setDefaultValue(@"_Time remaining: %r..._").dependsOn(@"timeout"),
    CDOption.create(CDString,           @"title"),
    CDOption.create(CDBoolean,          @"titlebar-close").setDefaultValue(@NO),
    CDOption.create(CDBoolean,          @"titlebar-minimize").setDefaultValue(@NO),
    CDOption.create(CDBoolean,          @"titlebar-zoom").setDefaultValue(@NO),
    CDOption.create(CDBoolean,          @"vibrancy").setDefaultValue((CDOptionAutomaticValueBlock) ^() {
        return [NSNumber numberWithBool:NSClassFromString(@"NSVisualEffectView") != nil];
    }).addNote(@"USAGE_OPTION_DIALOG_VIBRANCY_NOTE_OS".localized),
    CDOption.create(CDNumber,           @"width"),
    CDOption.create(CDString,           @"empty-text"),
    CDOption.create(CDBoolean,          @"newline").setDefaultValue(@YES).deprecates(@[CDOption.create(CDBoolean, @"no-newline")]),
    CDOption.create(CDBoolean,          @"return-labels").setDefaultValue(@NO).deprecates(@[CDOption.create(CDBoolean, @"string-output")]),
    CDOption.create(CDBoolean,          @"value-required").setDefaultValue(@NO),
    CDOption.create(CDBoolean,          @"no-cancel").hide(YES)
    ]);
}

- (void) dealloc {
    if (self.timer != nil) {
        [self.timer invalidate];
    }
}

- (void) createControl {
    [super createControl];

    [self createTitle];
    [self createIcon];
    [self createHeader];
    [self createMessage];
    [self createControlView];
    [self createTimeout];
    [self createButtons];
}

- (void) createControlView {
}

- (void) runControl {
    // Add borders around all views when in development mode.
    if (self.options[@"dev"].boolValue) {
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
    [self createPanel];

    if (self.options[@"dev"].boolValue) {
        for (NSLayoutConstraint *constraint in self.panel.contentView.constraints) {
            if ([NSStringFromClass([constraint class]) isEqualTo:@"NSAutoresizingMaskLayoutConstraint"]) {
                continue;
            }
            self.terminal.dev(@"%@", [self debugConstraint:constraint], nil);
        }
    }

    // Start timeout, if necessary.
    if (self.timeout) {
        self.mainThread = [NSThread currentThread];
        [NSThread detachNewThreadSelector:@selector(createTimer) toTarget:self withObject:nil];
    }

    // Continue up the chain.
    [super runControl];
}

- (NSString *) debugConstraint:(NSLayoutConstraint *)constraint {
    NSView *firstItem = constraint.firstItem;
    NSView *secondItem = constraint.secondItem;

    NSString *relation = @"=";
    if (constraint.relation == NSLayoutRelationLessThanOrEqual) {
        relation = @"≤";
    }
    if (constraint.relation == NSLayoutRelationGreaterThanOrEqual) {
        relation = @"≥";
    }

    NSString *multiplier = @"";
    if (constraint.multiplier > 1) {
        multiplier = [NSString stringWithFormat:@" %.2f x", constraint.multiplier];
    }

    NSString *constant = @"";
    if (constraint.constant > 0) {
        constant = [NSString stringWithFormat:@" + %.2f", constraint.constant];
    }
    else if (constraint.constant < 0) {
        constant = [NSString stringWithFormat:@" - %.2f", constraint.constant];
    }

    NSString *priority = @"";
    if (constraint.priority != NSLayoutPriorityRequired) {
        priority = [NSString stringWithFormat:@" @%.0f", constraint.priority];
    }

    return [NSString stringWithFormat:@"%@.%@ %@%@ %@.%@%@%@", firstItem.identifier, [self layoutAtttributeToString:constraint.firstAttribute], relation, multiplier, secondItem.identifier, [self layoutAtttributeToString:constraint.secondAttribute], constant, priority];
}

- (NSString *) layoutAtttributeToString:(NSLayoutAttribute)attribute {
    switch (attribute) {
        case NSLayoutAttributeLeft: return @"left";
        case NSLayoutAttributeRight: return @"right";
        case NSLayoutAttributeTop: return @"top";;
        case NSLayoutAttributeBottom: return @"bottom";
        case NSLayoutAttributeLeading: return @"leading";
        case NSLayoutAttributeTrailing: return @"trailing";
        case NSLayoutAttributeWidth: return @"width";
        case NSLayoutAttributeHeight: return @"height";
        case NSLayoutAttributeCenterX: return @"centerX";
        case NSLayoutAttributeCenterY: return @"centerY";
        case NSLayoutAttributeBaseline: return @"baseline";
        default:
        case NSLayoutAttributeNotAnAttribute: return @"unknown";
    }
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

    NSString *message = self.options[@"empty-text"].wasProvided ? self.options[@"empty-text"].stringValue : [self returnValueEmptyText];
    NSAlert *alertSheet = [[NSAlert alloc] init];
    [alertSheet addButtonWithTitle:@"OKAY".localized];
    alertSheet.icon = [CDIcon.sharedInstance iconFromName:@"caution"];
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

    NSNumber *width = [NSNumber numberWithFloat:self.panel.frame.size.width];
    NSNumber *height = [NSNumber numberWithFloat:self.panel.frame.size.height];
    NSNumber *minWidth = [NSNumber numberWithFloat:self.panel.contentMinSize.width];
    NSNumber *minHeight = [NSNumber numberWithFloat:self.panel.contentMinSize.height];
    self.terminal.dev(@"width: %@, height: %@, minWidth: %@, minHeight: %@", width, height, minWidth, minHeight, nil);
}

- (void) windowWillClose:(NSNotification *)notification {
    self.exitStatus = CDTerminalExitCodeCancel;
    [self stopControl];
}

#pragma mark - Buttons

- (void) createButtons {
    self.cancelButton = self.options[@"cancel-button"].numberValue;
    NSString *cancelButton = self.options[@"cancel-button"].stringValue;

    NSArray *buttons = self.options[@"buttons"].arrayOfStrings;
//    NSNumber *defaultButtonNumber = self.options[@"default-button"].numberValue;
//    NSString *defaultButtonString = defaultButtonNumber == nil ? self.options[@"default-button"].stringValue : nil;
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
        self.returnValues = [NSMutableDictionary dictionary];
        self.exitStatus = CDTerminalExitCodeCancel;
    }
    else {
        if (![self allowEmptyReturn] && [self isReturnValueEmpty]) {
            [self returnValueEmptySheet];
            return;
        }
    }

    id buttonValue = [NSNumber numberWithUnsignedInteger:button];

    if (self.options[@"return-labels"].wasProvided) {
        switch (button) {
            case 0: buttonValue = self.button0.title; break;
            case 1: buttonValue = self.button1.title; break;
            case 2: buttonValue = self.button2.title; break;
        }
    }

    // Add the button return value.
    if (buttonValue != nil) {
        self.returnValues[@"button"] = buttonValue;
    }

    [self stopControl];
}

- (IBAction) buttonPressed:(NSButton *)button {
    [self.returnValues removeAllObjects];
    [self controlHasFinished:button.tag];
}

#pragma mark - Header

- (void) createHeader {
    [self setLabel:self.header withText:self.options[@"header"].stringValue];
    if (self.header.hidden) {
        [self.panel removeSubview:self.header movingAttribute:NSLayoutAttributeTop to:self.message];
    }
}

#pragma mark - Icon
- (void) createIcon {
    NSImage *image = nil;
    if (self.options[@"icon-file"].wasProvided) {
        image = [CDIcon.sharedInstance iconFromFile:self.options[@"icon-file"].stringValue];
    }
    else if (self.options[@"icon"].wasProvided) {
        image = [CDIcon.sharedInstance iconFromName:self.options[@"icon"].stringValue];
    }

    // Default icon size.
    float w = 48.0f;
    float h = 48.0f;

    // Retrive sizes from options.
    if (self.options[@"icon-size"].wasProvided) {
        w = self.options[@"icon-size"].floatValue;
        h = self.options[@"icon-size"].floatValue;
    }
    else {
        if (self.options[@"icon-width"].wasProvided) {
            w = self.options[@"icon-width"].floatValue;
        }
        if (self.options[@"icon-height"].wasProvided) {
            h = self.options[@"icon-height"].floatValue;
        }
    }

    // Set the icon.
    [self setIconFromImage:image withSize:NSMakeSize(w, h)];
}

- (void) setIconFromImage:(NSImage *)anImage withSize:(NSSize)aSize {
    // Immediately remove image if not set and then return.
    if (anImage == nil) {
        self.iconView.hidden = YES;
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
    [self.panel updateConstraintsIfNeeded];
}

#pragma mark - Message

- (void) createMessage {
    [self setLabel:self.message withText:self.options[@"message"].stringValue];
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

    if (self.options[@"buttons"].wasProvided) {
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

- (void) createPanel {
    if (self.panel == nil) {
        self.terminal.error(@"Control panel failed to bind.", nil).exit(CDTerminalExitCodeControlFailure);
    }

    // Update panel's constraints.
    [self.panel setContentSize:NSMakeSize(self.panel.contentView.frame.size.width, self.panel.contentView.frame.size.height)];
    self.panel.viewsNeedDisplay = YES;
    [self.panel updateConstraintsIfNeeded];

    [self.panel makeLabelsSelectable:self.options[@"selectable-labels"].boolValue];
    self.panel.vibrancy = self.options[@"vibrancy"].boolValue;

    [self updateMinSize];

    // Resize.
    NSScreen *screen = self.getScreen;
    NSSize size = self.panel.contentView.frame.size;

    float width, height;
    if (self.options[@"width"].wasProvided) {
        width = self.options[@"width"].isPercent ? [self.options[@"width"] percentageOf:screen.frame.size.width] : self.options[@"width"].floatValue;
        if (width != 0.0) {
            size.width = width;
        }
    }
    if (self.options[@"height"].wasProvided) {
        height = self.options[@"height"].isPercent ? [self.options[@"height"] percentageOf:screen.frame.size.height] : self.options[@"height"].floatValue;
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
    self.panel.floatingPanel = self.options[@"float"].boolValue;
    self.panel.level = self.options[@"float"].boolValue ? NSFloatingWindowLevel : NSNormalWindowLevel;

    // Retrieve information about the screen.
    float x = NSMinX(screen.visibleFrame);
    float y = NSMinY(screen.visibleFrame);
    float padding = 20.0f;
    float screenHeight = NSHeight(screen.visibleFrame);
    float screenWidth = NSWidth(screen.visibleFrame);

    // Retrieve any position options.
    NSString *posX = self.options[@"posX"].stringValue;
    NSString *posY = self.options[@"posY"].stringValue;

    // Default to center positions.
    float left = x + ((screenWidth - NSWidth(self.panel.frame)) / 2.0f - padding);
    float top = (y + screenHeight) - (screenHeight / 1.8f) - (NSHeight(self.panel.frame) / 1.8f);

    float posXNumber = self.options[@"posX"].isPercent ? [self.options[@"posX"] percentageOf:screenWidth - NSWidth(self.panel.frame)] : self.options[@"posX"].floatValue;
    float posYNumber = self.options[@"posY"].isPercent ? [self.options[@"posY"] percentageOf:screenHeight - NSHeight(self.panel.frame)] : self.options[@"posY"].floatValue;


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

- (void) createTitle {
    self.panel.title = self.options[@"title"].stringValue ?: @"";

    // Handle --titlebar-close option.
    BOOL close = self.options[@"titlebar-close"].boolValue;
    [self.panel standardWindowButton:NSWindowCloseButton].enabled = close;
    if (close) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowWillClose:) name:NSWindowWillCloseNotification object:self.panel];
    }
    else {
        self.panel.styleMask = self.panel.styleMask^NSClosableWindowMask;
    }

    // Handle --titlebar-minimize option.
    BOOL minimize = self.options[@"titlebar-minimize"].boolValue;
    [self.panel standardWindowButton:NSWindowMiniaturizeButton].enabled = minimize;
    if (!minimize) {
        self.panel.styleMask = self.panel.styleMask^NSMiniaturizableWindowMask;
    }

    // Handle --resize and && --titlebar-zoom options.
    BOOL resize = self.options[@"resize"].boolValue;
    [self.panel standardWindowButton:NSWindowZoomButton].enabled = resize && self.options[@"titlebar-zoom"].wasProvided;
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
            self.timeoutLabel.stringValue = [self format:self.options[@"timeout-format"].stringValue withSeconds:ceil(self.timeout)];
        }
    }
    else {
        self.exitStatus = CDTerminalExitCodeTimeout;
        self.returnValues = [NSMutableDictionary dictionary];
        [self performSelector:@selector(stopControl) onThread:self.mainThread withObject:nil waitUntilDone:YES];
    }
}

- (void) setLabel:(CDTextField *)label withText:(NSString *)text {
    label.markdown.enabled = self.options[@"markdown"].boolValue;

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

- (void) createTimeout {
    self.timer = nil;
    self.timeout = self.options[@"timeout"].doubleValue;

    NSString *text = self.timeout ? [self format:self.options[@"timeout-format"].stringValue withSeconds:ceil(self.timeout)] : nil;

    // Set the timeout label.
    [self setLabel:self.timeoutLabel withText:text];
}

@end
