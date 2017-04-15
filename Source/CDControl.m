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
@synthesize option; // For DX/readability use "option" opposed to "options".
@synthesize panel;
@synthesize terminal;

#pragma mark - Internal Control Methods -
- (NSString *) controlNib { return @""; }

- (instancetype) init {
    self = [super init];
    if (self) {
        terminal = [CDTerminal terminal];

        controlExitStatus = -1;
        controlReturnValues = [NSMutableArray array];
        controlItems = [NSMutableArray array];
        option = [[self availableOptions] processArguments];

        // Provide some useful debugging information for default/automatic values.
        // Note: this must be added here, after avaialble options have populated in
        // case they access the options themselves to add additional properties like
        // "required" or "defaultValue".
        option.getOptionOnceCallback = ^(CDOption *opt) {
            // Don't run this twice if it's the base control class.
            // @todo Remove once notify no longer instantiates a base control class.
            if (self.isBaseControl) {
                return;
            }

            if (!opt.wasProvided) {
                if (opt.defaultValue != nil) {
                    NSMutableString *value = [NSMutableString stringWithString:opt.stringValue];
                    if (opt.hasAutomaticDefaultValue) {
                        [value appendString:[NSString stringWithFormat:@" (%@)", NSLocalizedString(@"OPTION_AUTOMATIC_DEFAULT_VALUE", nil).lowercaseString]];
                    }
                    [self debug:@"The %@ option was not provided. Using default value: %@", opt.name.optionFormat, value, nil];
                }
            }
            else if ([opt isKindOfClass:[CDOptionFlag class]]) {
                [self debug:@"The %@ option was provided.", opt.name.optionFormat, nil];
            }
            else {
                [self debug:@"The %@ option was provided with the value: %@", opt.name.optionFormat, opt.stringValue, nil];
            }
        };

        // Indicate whether color should be used.
        NSStringCDColor = option[@"color"].boolValue;
    }
    return self;
}

+ (instancetype) control {
    return [[[self alloc] init] autorelease];
}

- (BOOL) isBaseControl {
    return [self class] == [CDControl class];
}

- (void) dealloc {
    if (timer != nil) {
        [timer invalidate];
        [timer release];
    }
    [super dealloc];
}

// Logging.

- (NSString *) argumentToString:(NSString *)arg lineColor:(CDColor *)lineColor argumentColor:(CDColor *)argumentColor {
    NSMutableString *string = [NSMutableString stringWithString:[arg applyColor:argumentColor]];
    [string appendString:[@"" applyColor:lineColor]];
    return string;
}

- (NSMutableArray *) argumentsToArray:(va_list)args lineColor:(CDColor *)lineColor argumentColor:(CDColor *)argumentColor {
    NSMutableArray *array = [NSMutableArray array];
    id arg;
    while ((arg = va_arg(args, id))) {
        if ([arg isKindOfClass:[NSString class]]) {
            [array addObject:[self argumentToString:arg lineColor:lineColor argumentColor:argumentColor]];
        }
        else {
            [array addObject:arg];
        }
    }
    va_end(args);
    return array;
}

- (void) debug:(NSString *)format, ... {
    if (option[@"debug"].wasProvided) {
        CDColor *lineColor = [CDColor fg:CDColorFgMagenta];
        CDColor *argumentColor = [CDColor fg:CDColorFgWhite bg:CDColorBgNone style:CDColorStyleBold];

        // Get arguments.
        va_list va_args;
        va_start(va_args, format);
        NSMutableArray *args = [self argumentsToArray:va_args lineColor:lineColor argumentColor:argumentColor];

        format = [[NSMutableString prepend:NSLocalizedString(@"LOG_DEBUG", nil) toString:format] applyColor:lineColor].stop;
        [terminal writeErrorLine:[NSString stringWithFormat:format array:args]];
    }
}

- (void) error:(NSString *)format, ... {
    CDColor *lineColor = [CDColor fg:CDColorFgRed bg:CDColorBgNone style:CDColorStyleBold];
    CDColor *argumentColor = [CDColor fg:CDColorFgWhite bg:CDColorBgNone style:CDColorStyleBold];

    // Get arguments.
    va_list va_args;
    va_start(va_args, format);
    NSMutableArray *args = [self argumentsToArray:va_args lineColor:lineColor argumentColor:argumentColor];

    format = [[NSMutableString prepend:NSLocalizedString(@"LOG_ERROR", nil) toString:format] applyColor:lineColor].stop;
    [terminal writeErrorLine:[NSString stringWithFormat:format array:args]];
}


- (void) fatalError:(NSString *)format, ... {
    CDColor *lineColor = [CDColor fg:CDColorFgRed bg:CDColorBgNone style:CDColorStyleBold];
    CDColor *argumentColor = [CDColor fg:CDColorFgWhite bg:CDColorBgNone style:CDColorStyleBold];

    // Get arguments.
    va_list va_args;
    va_start(va_args, format);
    NSMutableArray *args = [self argumentsToArray:va_args lineColor:lineColor argumentColor:argumentColor];

    format = [[NSMutableString prepend:NSLocalizedString(@"LOG_ERROR", nil) toString:format] applyColor:lineColor].stop;
    [terminal writeErrorLine:[NSString stringWithFormat:format array:args]];
    exit(255);
}

- (void) verbose:(NSString *)format, ... {
    if (option[@"verbose"].wasProvided) {
        CDColor *lineColor = [CDColor fg:CDColorFgCyan];
        CDColor *argumentColor = [CDColor fg:CDColorFgWhite bg:CDColorBgNone style:CDColorStyleBold];

        // Get arguments.
        va_list va_args;
        va_start(va_args, format);
        NSMutableArray *args = [self argumentsToArray:va_args lineColor:lineColor argumentColor:argumentColor];

        format = [[NSMutableString prepend:NSLocalizedString(@"LOG_VERBOSE", nil) toString:format] applyColor:lineColor].stop;
        [terminal writeErrorLine:[NSString stringWithFormat:format array:args]];
    }
}

- (void) warning:(NSString *)format, ... {
    if (!option[@"no-warnings"].wasProvided) {
        CDColor *lineColor = [CDColor fg:CDColorFgYellow];
        CDColor *argumentColor = [CDColor fg:CDColorFgWhite bg:CDColorBgNone style:CDColorStyleBold];

        // Get arguments.
        va_list va_args;
        va_start(va_args, format);
        NSMutableArray *args = [self argumentsToArray:va_args lineColor:lineColor argumentColor:argumentColor];

        format = [[NSMutableString prepend:NSLocalizedString(@"LOG_WARNING", nil) toString:format] applyColor:lineColor].stop;
        [terminal writeErrorLine:[NSString stringWithFormat:format array:args]];
    }
}

// Icon.

- (void) iconAffectedByControl:(id)obj {
    if (obj != nil) {
        [_iconControls addObject:obj];
    }
}

- (NSImage *)icon {
    if (option[@"icon-file"].wasProvided) {
        _iconImage = [self iconFromFile:option[@"icon-file"].stringValue];
    }
    else if (option[@"icon"].wasProvided) {
        _iconImage = [self iconFromName:option[@"icon"].stringValue];
    }
    return _iconImage;
}
- (NSData *)iconData {
    return [self icon].TIFFRepresentation;
}
- (NSImage *)iconWithDefault {
    if ([self icon] == nil) {
        _iconImage = NSApp.applicationIconImage;
    }
    return _iconImage;
}
- (NSData *)iconDataWithDefault {
    return [self iconWithDefault].TIFFRepresentation;
}


- (NSImage *)iconFromFile:(NSString *)file {
    NSImage *image = [[[NSImage alloc] initWithContentsOfFile:file] autorelease];
    if (image == nil) {
        [self warning:@"Could not return icon from specified file: %@.", file.doubleQuote, nil];
    }
    return image;
}

- (NSImage *)iconFromName:(NSString *)name {
    BOOL hasImage = NO;
    NSImage *image = [[[NSImage alloc] init] autorelease];
    NSString *bundle = nil;
    NSString *path = nil;
    NSString *iconType = @"icns";
    if (option[@"icon-type"].wasProvided) {
        iconType = option[@"icon-type"].stringValue;
    }
    // Use bundle identifier
    if (option[@"icon-bundle"].wasProvided) {
        bundle = option[@"icon-bundle"].stringValue;
    }
    // Set default bundle identifier
    if (bundle == nil) {
        // Application icon
        if ([name isEqualToStringCaseInsensitive:@"cocoadialog"]) {
            image = NSApp.applicationIconImage;
            hasImage = YES;
        }
        // User specific computer image
        else if ([name isEqualToStringCaseInsensitive:@"computer"]) {
            image = [NSImage imageNamed: NSImageNameComputer];
            hasImage = YES;
        }
        // Bundle Identifications
        else if ([name isEqualToStringCaseInsensitive:@"addressbook"]) {
            name = @"AppIcon";
            bundle = @"com.apple.AddressBook";
        }
        else if ([name isEqualToStringCaseInsensitive:@"airport"]) {
            name = @"AirPort";
            bundle = @"com.apple.AirPortBaseStationAgent";
        }
        else if ([name isEqualToStringCaseInsensitive:@"airport2"]) {
            name = @"AirPort";
            bundle = @"com.apple.wifi.diagnostics";
        }
        else if ([name isEqualToStringCaseInsensitive:@"archive"]) {
            name = @"bah";
            bundle = @"com.apple.archiveutility";
        }
        else if ([name isEqualToStringCaseInsensitive:@"bluetooth"]) {
            name = @"AppIcon";
            bundle = @"com.apple.BluetoothAudioAgent";
        }
        else if ([name isEqualToStringCaseInsensitive:@"application"]) {
            name = @"GenericApplicationIcon";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";
        }
        else if ([name isEqualToStringCaseInsensitive:@"bonjour"] || [name isEqualToStringCaseInsensitive:@"atom"]) {
            name = @"Bonjour";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";
        }
        else if ([name isEqualToStringCaseInsensitive:@"burn"] || [name isEqualToStringCaseInsensitive:@"hazard"]) {
            name = @"BurningIcon";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";
        }
        else if ([name isEqualToStringCaseInsensitive:@"caution"]) {
            name = @"AlertCautionIcon";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";
        }
        else if ([name isEqualToStringCaseInsensitive:@"document"]) {
            name = @"GenericDocumentIcon";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";
        }
        else if ([name isEqualToStringCaseInsensitive:@"documents"]) {
            name = @"ToolbarDocumentsFolderIcon";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";
        }
        else if ([name isEqualToStringCaseInsensitive:@"download"]) {
            name = @"ToolbarDownloadsFolderIcon";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";
        }
        else if ([name isEqualToStringCaseInsensitive:@"eject"]) {
            name = @"EjectMediaIcon";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";
        }
        else if ([name isEqualToStringCaseInsensitive:@"everyone"]) {
            name = @"Everyone";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";
        }
        else if ([name isEqualToStringCaseInsensitive:@"executable"]) {
            name = @"ExecutableBinaryIcon";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";
        }
        else if ([name isEqualToStringCaseInsensitive:@"favorite"] || [name isEqualToStringCaseInsensitive:@"heart"]) {
            name = @"ToolbarFavoritesIcon";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";
        }
        else if ([name isEqualToStringCaseInsensitive:@"fileserver"]) {
            name = @"GenericFileServerIcon";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";
        }
        else if ([name isEqualToStringCaseInsensitive:@"filevault"]) {
            name = @"FileVaultIcon";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";
        }
        else if ([name isEqualToStringCaseInsensitive:@"finder"]) {
            name = @"FinderIcon";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";
        }
        else if ([name isEqualToStringCaseInsensitive:@"folder"]) {
            name = @"GenericFolderIcon";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";
        }
        else if ([name isEqualToStringCaseInsensitive:@"folderopen"]) {
            name = @"OpenFolderIcon";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";
        }
        else if ([name isEqualToStringCaseInsensitive:@"foldersmart"]) {
            name = @"SmartFolderIcon";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";
        }
        else if ([name isEqualToStringCaseInsensitive:@"gear"]) {
            name = @"ToolbarAdvanced";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";
        }
        else if ([name isEqualToStringCaseInsensitive:@"general"]) {
            name = @"General";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";
        }
        else if ([name isEqualToStringCaseInsensitive:@"globe"]) {
            name = @"BookmarkIcon";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";
        }
        else if ([name isEqualToStringCaseInsensitive:@"group"]) {
            name = @"GroupIcon";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";
        }
        else if ([name isEqualToStringCaseInsensitive:@"home"]) {
            name = @"HomeFolderIcon";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";
        }
        else if ([name isEqualToStringCaseInsensitive:@"info"]) {
            name = @"ToolbarInfo";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";
        }
        else if ([name isEqualToStringCaseInsensitive:@"ipod"]) {
            name = @"com.apple.ipod-touch-4";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";
        }
        else if ([name isEqualToStringCaseInsensitive:@"movie"]) {
            name = @"ToolbarMovieFolderIcon";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";
        }
        else if ([name isEqualToStringCaseInsensitive:@"music"]) {
            name = @"ToolbarMusicFolderIcon";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";
        }
        else if ([name isEqualToStringCaseInsensitive:@"network"]) {
            name = @"GenericNetworkIcon";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";
        }
        else if ([name isEqualToStringCaseInsensitive:@"notice"]) {
            name = @"AlertNoteIcon";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";
        }
        else if ([name isEqualToStringCaseInsensitive:@"stop"] || [name isEqualToStringCaseInsensitive:@"x"]) {
            name = @"AlertStopIcon";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";
        }
        else if ([name isEqualToStringCaseInsensitive:@"sync"]) {
            name = @"Sync";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";
        }
        else if ([name isEqualToStringCaseInsensitive:@"trash"]) {
            name = @"TrashIcon";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";
        }
        else if ([name isEqualToStringCaseInsensitive:@"trashfull"]) {
            name = @"FullTrashIcon";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";
        }
        else if ([name isEqualToStringCaseInsensitive:@"url"]) {
            name = @"GenericURLIcon";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";
        }
        else if ([name isEqualToStringCaseInsensitive:@"user"] || [name isEqualToStringCaseInsensitive:@"person"]) {
            name = @"UserIcon";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";
        }
        else if ([name isEqualToStringCaseInsensitive:@"utilities"]) {
            name = @"ToolbarUtilitiesFolderIcon";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";
        }
        else if ([name isEqualToStringCaseInsensitive:@"dashboard"]) {
            name = @"Dashboard";
            bundle = @"com.apple.dashboard.installer";
        }
        else if ([name isEqualToStringCaseInsensitive:@"dock"]) {
            name = @"Dock";
            bundle = @"com.apple.dock";
        }
        else if ([name isEqualToStringCaseInsensitive:@"widget"]) {
            name = @"widget";
            bundle = @"com.apple.dock";
        }
        else if ([name isEqualToStringCaseInsensitive:@"help"]) {
            name = @"HelpViewer";
            bundle = @"com.apple.helpviewer";
        }
        else if ([name isEqualToStringCaseInsensitive:@"installer"]) {
            name = @"Installer";
            bundle = @"com.apple.installer";
        }
        else if ([name isEqualToStringCaseInsensitive:@"package"]) {
            name = @"package";
            bundle = @"com.apple.installer";
        }
        else if ([name isEqualToStringCaseInsensitive:@"firewire"]) {
            name = @"FireWireHD";
            bundle = @"com.apple.iokit.IOSCSIArchitectureModelFamily";
            path = @"/System/Library/Extensions/IOSCSIArchitectureModelFamily.kext";
        }
        else if ([name isEqualToStringCaseInsensitive:@"usb"]) {
            name = @"USBHD";
            bundle = @"com.apple.iokit.IOSCSIArchitectureModelFamily";
            path = @"/System/Library/Extensions/IOSCSIArchitectureModelFamily.kext";
        }
        else if ([name isEqualToStringCaseInsensitive:@"cd"]) {
            name = @"CD";
            bundle = @"com.apple.ODSAgent";
        }
        else if ([name isEqualToStringCaseInsensitive:@"sound"]) {
            name = @"SoundPref";
            path = @"/System/Library/PreferencePanes/Sound.prefPane";
        }
        else if ([name isEqualToStringCaseInsensitive:@"printer"]) {
            name = @"Printer";
            bundle = @"com.apple.print.PrintCenter";
        }
        else if ([name isEqualToStringCaseInsensitive:@"screenshare"]) {
            name = @"ScreenSharing";
            bundle = @"com.apple.ScreenSharing";
        }
        else if ([name isEqualToStringCaseInsensitive:@"security"]) {
            name = @"Security";
            bundle = @"com.apple.securityagent";
        }
        else if ([name isEqualToStringCaseInsensitive:@"update"]) {
            name = @"SoftwareUpdate";
            bundle = @"com.apple.SoftwareUpdate";
        }
        else if ([name isEqualToStringCaseInsensitive:@"search"] || [name isEqualToStringCaseInsensitive:@"find"]) {
            name = @"Spotlight";
            path = @"/System/Library/CoreServices/Search.bundle";
        }
        else if ([name isEqualToStringCaseInsensitive:@"preferences"]) {
            name = @"PrefApp";
            bundle = @"com.apple.systempreferences";
        }
    }

    // Process bundle image path only if image has not already been set from above
    if (!hasImage) {
        if (bundle != nil || path != nil) {
            NSString * fileName = nil;
            if (path == nil) {
                NSWorkspace *workspace = [NSWorkspace sharedWorkspace];
                fileName = [[NSBundle bundleWithPath:[workspace absolutePathForAppBundleWithIdentifier:bundle]] pathForResource:name ofType:iconType];
            }
            else {
                fileName = [[NSBundle bundleWithPath:path] pathForResource:name ofType:iconType];
            }
            if (fileName != nil) {
                image = [[[NSImage alloc] initWithContentsOfFile:fileName] autorelease];
                if (image == nil) {
                    [self warning:@"Could not retrieve image from specified icon file %@.", fileName.doubleQuote, nil];
                }
            }
            else {
                [self warning:@"Cannot find icon %@ in bundle %@.", name.doubleQuote, bundle.doubleQuote, nil];
            }
        }
        else {
            [self warning:@"Unknown icon %@. No --icon-bundle specified.", name.doubleQuote, nil];
        }
    }
    return image;
}

- (void) setIconFromOptions {
    if (_iconObject != nil) {
        NSImage *image = [self icon];
        if (option[@"icon-file"].wasProvided) {
            image = [self iconFromFile:option[@"icon-file"].stringValue];
        }
        else if (option[@"icon"].wasProvided) {
            image = [self iconFromName:option[@"icon"].stringValue];
        }

        // Set default icon sizes
        float iconWidth = _iconObject.frame.size.width;
        float iconHeight = _iconObject.frame.size.height;
        NSSize resize = NSMakeSize(iconWidth, iconHeight);

        // Control should display icon, process image.
        if (image != nil) {
            // Set default icon height
            // Get icon sizes from user options
            if (option[@"icon-size"].wasProvided) {
                NSUInteger iconSize = option[@"icon-size"].unsignedIntegerValue;
                switch (iconSize) {
                    case 256: iconWidth = 256.0; iconHeight = 256.0; break;
                    case 128: iconWidth = 128.0; iconHeight = 128.0; break;
                    case 48: iconWidth = 48.0; iconHeight = 48.0; break;
                    case 32: iconWidth = 32.0; iconHeight = 32.0; break;
                    case 16: iconWidth = 16.0; iconHeight = 16.0; break;
                }
            }
            else {
                if (option[@"icon-width"].wasProvided) {
                    iconWidth = option[@"icon-width"].floatValue;
                }
                if (option[@"icon-height"].wasProvided) {
                    iconHeight = option[@"icon-height"].floatValue;
                }
            }
            // Set sizes
            resize = NSMakeSize(iconWidth, iconHeight);
            [self setIconWithImage:image withSize:resize withControls:_iconControls];
        }
        // Control shouldn't display icon, remove it and resize.
        else {
            [self setIconWithImage:nil withSize:resize withControls:_iconControls];
        }
    }
}

- (void) setIconWithImage:(NSImage *)anImage withSize:(NSSize)aSize {
    if (anImage != nil) {
        NSSize originalSize = anImage.size;
        // Resize Icon
        if (originalSize.width != aSize.width || originalSize.height != aSize.height) {
            NSImage *resizedImage = [[[NSImage alloc] initWithSize: aSize] autorelease];
            [resizedImage lockFocus];
            [anImage drawInRect: NSMakeRect(0, 0, aSize.width, aSize.height) fromRect: NSMakeRect(0, 0, originalSize.width, originalSize.height) operation: NSCompositeSourceOver fraction: 1.0];
            [resizedImage unlockFocus];
            _iconObject.image = resizedImage;
        }
        else {
            _iconObject.image = anImage;
        }
        // Resize icon frame
        NSRect iconFrame = _iconObject.frame;
        float iconHeightDiff = aSize.height - iconFrame.size.height;
        NSRect newIconFrame = NSMakeRect(iconFrame.origin.x, iconFrame.origin.y - iconHeightDiff, aSize.width, aSize.height);
        _iconObject.frame = newIconFrame;
        iconFrame = _iconObject.frame;

        // Add the icon to the panel's minimum content size
        NSSize panelMinSize = panel.contentMinSize;
        panelMinSize.height += iconFrame.size.height + 40.0f;
        panelMinSize.width += iconFrame.size.width + 30.0f;
        panel.contentMinSize = panelMinSize;
    }
}

- (void) setIconWithImage:(NSImage *)anImage withSize:(NSSize)aSize withControls:(NSArray *)anArray {
    // Icon has image
    if (anImage != nil) {
        // Set current icon frame
        NSRect iconFrame = _iconObject.frame;

        // Set image and resize icon
        [self setIconWithImage:anImage withSize:aSize];

        float iconWidthDiff = _iconObject.frame.size.width - iconFrame.size.width;
        NSEnumerator *en = [anArray objectEnumerator];
        NSControl *_control;
        while (_control = [en nextObject]) {
            // Make sure the control exists
            if (_control != nil) {
                NSRect controlFrame = [_control frame];
                NSRect newControlFrame = NSMakeRect(controlFrame.origin.x + iconWidthDiff, controlFrame.origin.y, controlFrame.size.width - iconWidthDiff, controlFrame.size.height);
                [_control setFrame:newControlFrame];
            }
        }

    }
    // Icon does not have image
    else {
        // Set current icon frame
        NSRect iconFrame = _iconObject.frame;
        // Remove the icon
        [_iconObject removeFromSuperview];
        _iconObject = nil;
        // Move the controls to the left and increase their width
        NSEnumerator *en = [anArray objectEnumerator];
        id _control;
        while (_control = [en nextObject]) {
            // Make sure the control exists
            if (_control != nil) {
                NSRect controlFrame = [_control frame];
                float newControlWidth = controlFrame.size.width + (controlFrame.origin.x - iconFrame.origin.x);
                NSRect newControlFrame = NSMakeRect(iconFrame.origin.x, controlFrame.origin.y, newControlWidth, controlFrame.size.height);
                [_control setFrame:newControlFrame];
            }
        }
    }
}

// Panel.

- (void)addMinHeight:(CGFloat)height {
    NSSize panelMinSize = panel.contentMinSize;
    panelMinSize.height += height;
    panel.contentMinSize = panelMinSize;
}
- (void)addMinWidth:(CGFloat)width {
    NSSize panelMinSize = panel.contentMinSize;
    panelMinSize.width += width;
    panel.contentMinSize = panelMinSize;
}

- (NSSize) findNewSize {
    NSRect screenFrame = self.getScreen.frame;
    NSSize size = NSZeroSize;
    NSSize oldSize;
    float width, height;

    size = panel.contentView.frame.size;
    oldSize.width = size.width;
    oldSize.height = size.height;
    if (option[@"width"].wasProvided) {
        NSNumber *percent = option[@"width"].percentValue;
        if (percent != nil) {
            width = ((float) screenFrame.size.width / 100) * [percent floatValue];
        }
        else {
            width = option[@"width"].floatValue;
        }
        if (width != 0.0) {
            size.width = width;
        }
    }
    if (option[@"height"].wasProvided) {
        NSNumber *percent = option[@"height"].percentValue;
        if (percent != nil) {
            height = ((float) screenFrame.size.height / 100) * [percent floatValue];
        }
        else {
            height = option[@"height"].floatValue;
        }
        if (height != 0.0) {
            size.height = height;
        }
    }
    NSSize minSize = panel.contentMinSize;
    if (size.height < minSize.height) {
        size.height = minSize.height;
    }
    if (size.width < minSize.width) {
        size.width = minSize.width;
    }
    if (size.width != oldSize.width || size.height != oldSize.height) {
        return size;
    } else {
        return NSMakeSize(0.0,0.0);
    }
}

- (NSScreen *)getScreen {
    NSUInteger index = option[@"screen"].unsignedIntegerValue;
    NSArray *screens = [NSScreen screens];
    if (index >= [screens count]) {
        [self warning:@"Unknown screen index: %@. Using screen where keyboard has focus.", [NSNumber numberWithUnsignedInteger:index], nil];
        return [NSScreen mainScreen];
    }
    return [screens objectAtIndex:index];
}

- (BOOL) needsResize {
    NSSize size = [self findNewSize];
    if (size.width != 0.0 || size.height != 0.0) {
        return YES;
    } else {
        return NO;
    }
}
- (void) resize {
    // resize if necessary
    if ([self needsResize]) {
        [panel setContentSize:[self findNewSize]];
    }
}
- (void) setFloat {
    if (panel != nil) {
        if (option[@"no-float"].wasProvided) {
            [panel setFloatingPanel:NO];
            [panel setLevel:NSNormalWindowLevel];
        }
        else {
            [panel setFloatingPanel: YES];
            [panel setLevel:NSFloatingWindowLevel];
        }
        [panel makeKeyAndOrderFront:nil];
    }
}
- (void) setPanelEmpty {
    panel = [[[NSPanel alloc] initWithContentRect:NSMakeRect(0, 0, 0, 0)
                                        styleMask:NSBorderlessWindowMask
                                          backing:NSBackingStoreBuffered
                                            defer:NO] autorelease];
}
- (void) setPosition {
    NSScreen *screen = [self getScreen];
    CGFloat x = NSMinX(screen.visibleFrame);
    CGFloat y = NSMinY(screen.visibleFrame);
    CGFloat height = NSHeight(screen.visibleFrame);
    CGFloat width = NSWidth(screen.visibleFrame);
    CGFloat top = y + height;
    CGFloat left = x;
    CGFloat padding = 20.0;
    NSNumberFormatter *nf = [[[NSNumberFormatter alloc] init] autorelease];

    NSString *posX, *posY;

    // Has posX option
    if (option[@"posX"].wasProvided) {
        posX = option[@"posX"].stringValue;
        NSNumber *posXNumber = [nf numberFromString:posX];
        // Left
        if ([posX isEqualToStringCaseInsensitive:@"left"]) {
            left += padding;
        }
        // Right
        else if ([posX isEqualToStringCaseInsensitive:@"right"]) {
            left = left + width - NSWidth(panel.frame) - padding;
        }
        // Manual posX coords
        else if (posXNumber != nil) {
            left += [posXNumber floatValue];
        }
        // Center
        else {
            left = left + ((width - NSWidth(panel.frame)) / 2 - padding);
        }
    }
    // Center
    else {
        left = left + ((width - NSWidth(panel.frame)) / 2 - padding);
    }

    // Has posY option
    if (option[@"posY"].wasProvided) {
        posY = option[@"posY"].stringValue;
        NSNumber *posYNumber = [nf numberFromString:posY];
        // Bottom
        if ([posY isEqualToStringCaseInsensitive:@"bottom"]) {
            top = y + padding;
        }
        // Top
        else if ([posY isEqualToStringCaseInsensitive:@"top"]) {
            top = top - NSHeight(panel.frame) - padding;
        }
        // Manual posY coords
        else if (posYNumber != nil) {
            top = top - NSHeight(panel.frame) - [posYNumber floatValue];
        }
        // Center
        else {
            top = (height / 1.8) - (NSHeight(panel.frame) / 1.8);
        }
    }
    // Center
    else {
        top = (height / 1.8) - (NSHeight(panel.frame) / 1.8);
    }

    // Ensure the panel has the correct relative frame origins.
    [panel setFrameOrigin:NSMakePoint(left, top)];
}

- (void)setTitle {
    panel.title = option[@"title"].wasProvided ? option[@"title"].stringValue : NSLocalizedString(@"APP_TITLE", nil);
}

- (void) setTitle:(NSString *)string {
    panel.title = string != nil && ![string isBlank] ? string : NSLocalizedString(@"APP_TITLE", nil);
}

- (NSString *) formatSecondsForString:(NSInteger)timeInSeconds {
    NSString *timerFormat = option[@"timeout-format"].stringValue;
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

        panel = controlPanel;
    }
    if (controlIcon != nil) {
        _iconObject = controlIcon;
    }
    return YES;
}

- (void) showUsage {
    NSUInteger margin = 4;

    // If (for whatever reason) there is no terminal width, default to 80.
    NSUInteger terminalColumns = [self.terminal colsWithMinimum:80] - margin;

    NSMutableString *controlUsage = [NSMutableString string];
    if (self.isBaseControl || controlName == nil) {
        [controlUsage appendString:[NSString stringWithFormat:@"<%@>", NSLocalizedString(@"CONTROL", nil).lowercaseString]];
    }
    else {
        [controlUsage appendString:controlName];
        if (option.requiredOptions.count) {
            for (NSString *name in option.requiredOptions.allKeys.sortedAlphabetically) {
                [controlUsage appendString:@" "];
                CDOption *opt = option.requiredOptions[name];
                NSMutableString *required = [NSMutableString stringWithString:opt.label.white.bold];
                NSString *requiredType = opt.typeLabel;
                if (requiredType != nil) {
                    [required appendString:@" "];
                    [required appendString:requiredType];
                }
                [controlUsage appendString:required];
                [controlUsage appendString:@"".white.bold];
            }
        }
    }

    [self.terminal writeNewLine];
    [self.terminal writeLine:[NSString stringWithFormat:NSLocalizedString(@"USAGE", nil), controlUsage].white.bold.stop];

    // Show avilable controls if it's the CDControl class printing this.
    if ([self class] == [CDControl class]) {
        [self.terminal writeNewLine];
        [self.terminal writeLine:NSLocalizedString(@"USAGE_CATEGORY_CONTROLS", nil).uppercaseString.white.bold.underline.stop];
        NSArray<NSString *> *controls = [AppController availableControls];
        [self.terminal writeNewLine];

        NSUInteger rowIndex = 0;
        for (NSUInteger i = 0; i < controls.count; i++) {
            if (rowIndex == 0) {
                [self.terminal write:[[NSString string] stringByPaddingToLength:margin withString:@" " startingAtIndex:0]];
            }
            [self.terminal write:controls[i]];
            if (rowIndex <= 6 && i != controls.count - 1) {
                [self.terminal write:@", "];
                rowIndex++;
            }
            if (rowIndex == 6) {
                [self.terminal writeNewLine];
                rowIndex = 0;
            }
        }

        [self.terminal writeNewLine];
    }

    // Get all available options and put them in their necessary categories.
    NSDictionary<NSString *, CDOptions *> *categories = [self availableOptions].groupByCategories;

    // Print options for each category.
    NSEnumerator *sortedCategories = [[NSArray arrayWithArray:[categories.allKeys sortedArrayUsingComparator:^NSComparisonResult(NSString *a, NSString *b) {
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
        [self.terminal writeNewLine];
        [self.terminal writeLine:category.uppercaseString.white.bold.underline.stop];
        [self.terminal writeNewLine];

        CDOptions *categoryOptions = categories[category];
        NSArray *sorted = categoryOptions.allKeys.sortedAlphabetically;
        for (NSString *name in sorted) {
            CDOption *categoryOption = categoryOptions[name];

            NSMutableString *column = [NSMutableString string];
            NSMutableString *extra = [NSMutableString string];

            [column appendString:[categoryOption.name.optionFormat indent:margin].white.bold.stop];

            // Add the "type" of option, if available.
            CDColor *typeColor = categoryOption.typeColor;
            NSString *typeLabel = categoryOption.typeLabel;
            if (typeLabel != nil) {
                if (categoryOption.hasAutomaticDefaultValue) {
                    typeLabel = typeLabel.dim;
                }
                [column appendString:@" "];
                [column appendString:typeLabel.stop];
            }

            if (categoryOption.required) {
                [column appendString:[NSString stringWithFormat:@" (%@)", NSLocalizedString(@"OPTION_REQUIRED_VALUE", nil).lowercaseString].red.bold.stop];
            }

            // Add the option help text (description).
            if (categoryOption.helpText != nil) {
                [column appendString:@"\n"];

                NSMutableString *helpText = [NSMutableString stringWithString:categoryOption.helpText];

                // Wrap the column to fit available space.
                helpText = [NSMutableString stringWithString:[helpText wrapToLength:(terminalColumns - (margin * 2))]];

                // Replace new lines so they're intented properly.
                helpText = [NSMutableString stringWithString:[helpText indentNewlinesWith:(margin * 2)]];

                [column appendString:[helpText indent:(margin * 2)]];
            }

            // Add the default/required values.
            id defaultValue = categoryOption.defaultValue;
            if (categoryOption.hasAutomaticDefaultValue) {
                CDOptionAutomaticDefaultValue block = (CDOptionAutomaticDefaultValue) defaultValue;
                defaultValue = block();
            }
            if (defaultValue != nil && [defaultValue isKindOfClass:[NSString class]]) {
                NSString *defaultValueString = (NSString *) defaultValue;
                defaultValue = defaultValueString.doubleQuote;
            }
            else if (defaultValue != nil && [defaultValue isKindOfClass:[NSNumber class]]) {
                NSNumber *defaultValueNumber = (NSNumber *) defaultValue;
                defaultValue = [defaultValueNumber stringValue];
            }

            if (defaultValue != nil) {
                if (categoryOption.hasAutomaticDefaultValue) {
                    defaultValue = [NSString stringWithFormat:@"%@ (%@)", defaultValue, NSLocalizedString(@"OPTION_AUTOMATIC_DEFAULT_VALUE", nil).lowercaseString];
                }
                [extra appendString:[NSString stringWithFormat:NSLocalizedString(@"OPTION_DEFAULT_VALUE", nil).white.bold.stop, [defaultValue applyColor:typeColor]].stop];
            }

            if (![extra isBlank]) {
                [column appendString:@"\n\n"];
                [column appendString:[extra indent:(margin * 2)]];
            }

            if (categoryOption.notes.count) {
                [column appendString:@"\n\n"];
                [column appendString:[[NSString stringWithFormat:@"%@:", NSLocalizedString(@"NOTE", nil).uppercaseString] indent:(margin * 2)].yellow.bold.stop];
                if (categoryOption.notes.count == 1) {
                    [column appendString:[NSString stringWithFormat:@" %@", categoryOption.notes[0]].yellow.stop];
                }
                else {
                    for (NSUInteger i = 0; i < categoryOption.notes.count; i++) {
                        [column appendString:@"\n"];
                        [column appendString:[[NSString stringWithFormat:@"* %@", categoryOption.notes[i]] indent:(margin * 3)].yellow.stop];
                    }
                }
            }

            if (categoryOption.warnings.count) {
                [column appendString:@"\n\n"];
                [column appendString:[[NSString stringWithFormat:@"%@:", NSLocalizedString(@"WARNING", nil).uppercaseString] indent:(margin * 2)].red.bold.stop];
                if (categoryOption.warnings.count == 1) {
                    [column appendString:[NSString stringWithFormat:@" %@", categoryOption.warnings[0]].red.stop];
                }
                else {
                    for (NSUInteger i = 0; i < categoryOption.warnings.count; i++) {
                        [column appendString:@"\n"];
                        [column appendString:[[NSString stringWithFormat:@"* %@", categoryOption.warnings[i]] indent:(margin * 3)].red.stop];
                    }
                }
            }

            [column appendString:@"\n"];
            [self.terminal writeLine:column];
        }
    }

    [self.terminal writeNewLine];
    [self.terminal writeNewLine];

    [self.terminal writeLine:[NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"USAGE_VERSION", nil).uppercaseString.underline.white.bold.stop, [AppController appVersion].cyan]];

    [self.terminal writeNewLine];

    [self.terminal writeLine:[NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"USAGE_WEBSITE", nil).uppercaseString.underline.white.bold.stop, @CDSite.cyan.stop]];
}

- (void) runControl {
    // The control must either: 1) sub-class -(NSString *) controlNib, return the name of the NIB, and then connect "controlPanel" in IB or 2) set the panel manually with [self setPanel:(NSPanel *)]  when creating the control.
    if (self.panel == nil) {
        [self fatalError:@"The control has not specified the panel it is to use and cocoaDialog cannot continue.", nil];
    }

    // Set icon
    if (self.iconObject != nil) {
        [self setIconFromOptions];
    }
    // Reposition Panel
    [self setPosition];
    [self setFloat];
    [NSApp run];
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
        NSSize p = panel.contentView.frame.size;
        p.height += labelHeightDiff;
        [panel setContentSize:p];
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
    options[@"color"].defaultValue = (CDOptionAutomaticDefaultValue) ^() {
        return [NSNumber numberWithBool:self.terminal.supportsColor];
    };

    [options addOption:[CDOptionFlag                    name:@"debug"               category:@"GLOBAL_OPTION"]];
    [options[@"debug"].warnings addObject:NSLocalizedString(@"OPTION_WARNING_AFFECTS_OUTPUT", nil)];

    [options addOption:[CDOptionFlag                    name:@"help"                category:@"GLOBAL_OPTION"]];
    [options addOption:[CDOptionFlag                    name:@"no-newline"          category:@"GLOBAL_OPTION"]];
    [options addOption:[CDOptionFlag                    name:@"no-warnings"         category:@"GLOBAL_OPTION"]];
    [options addOption:[CDOptionFlag                    name:@"quiet"               category:@"GLOBAL_OPTION"]];

    [options addOption:[CDOptionSingleNumber            name:@"screen"              category:@"GLOBAL_OPTION"]];
    options[@"screen"].defaultValue = (CDOptionAutomaticDefaultValue) ^() {
        return [NSNumber numberWithUnsignedInteger:[[NSScreen screens] indexOfObject:[NSScreen mainScreen]]];
    };

    [options addOption:[CDOptionFlag                    name:@"string-output"       category:@"GLOBAL_OPTION"]];
    [options addOption:[CDOptionSingleNumber            name:@"timeout"             category:@"GLOBAL_OPTION"]];
    [options addOption:[CDOptionSingleString            name:@"timeout-format"      category:@"GLOBAL_OPTION"]];
    options[@"timeout-format"].defaultValue = @"Time remaining: %r...";

    [options addOption:[CDOptionFlag                    name:@"verbose"             category:@"GLOBAL_OPTION"]];
    [options addOption:[CDOptionFlag                    name:@"version"             category:@"GLOBAL_OPTION"]];
    [options[@"verbose"].warnings addObject:NSLocalizedString(@"OPTION_WARNING_AFFECTS_OUTPUT", nil)];

    // Panel.
    [options addOption:[CDOptionSingleNumber            name:@"height"              category:@"WINDOW_OPTION"]];
    [options addOption:[CDOptionFlag                    name:@"no-float"            category:@"WINDOW_OPTION"]];
//    @todo Add max/min height/width options back once there is logic in place to support them.
//    [options addOption:[CDOptionSingleNumber            name:@"max-height"          category:@"WINDOW_OPTION"]];
//    [options addOption:[CDOptionSingleNumber            name:@"max-width"           category:@"WINDOW_OPTION"]];
//    [options addOption:[CDOptionSingleNumber            name:@"min-height"          category:@"WINDOW_OPTION"]];
//    [options addOption:[CDOptionSingleNumber            name:@"min-width"           category:@"WINDOW_OPTION"]];

    [options addOption:[CDOptionSingleStringOrNumber    name:@"posX"                category:@"WINDOW_OPTION"]];
    options[@"posX"].defaultValue = @"center";

    [options addOption:[CDOptionSingleStringOrNumber    name:@"posY"                category:@"WINDOW_OPTION"]];
    options[@"posY"].defaultValue = @"center";

    [options addOption:[CDOptionFlag                    name:@"resize"              category:@"WINDOW_OPTION"]];
    [options addOption:[CDOptionSingleString            name:@"title"               category:@"WINDOW_OPTION"]];
    options[@"title"].defaultValue = @"cocoadialog";

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
