//
//  CDIcon.m
//  cocoaDialog
//
//  Created by Mark Whitaker on 10/28/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "CDIcon.h"

@interface CDIcon (private)
- (void) setIconWithImage:(NSImage *)anImage withSize:(NSSize)aSize;
- (void) setIconWithImage:(NSImage *)anImage withSize:(NSSize)aSize withControls:(NSArray *)anArray;
@end

@implementation CDIcon
@synthesize control;
@synthesize panel;

- (instancetype)initWithArguments:(CDArguments *)args {
    self = [super initWithArguments:args];
    if (self) {
        controls = [[[NSMutableArray alloc] init] retain];
    }
    return self;
}

- (void) dealloc {
    [control release];
    [panel release];
    [super dealloc];
}

- (void) addControl:(id)obj {
    if (obj != nil) {
        [controls addObject:obj];
    }
}

- (NSArray *)controls {
    return [[controls copy] autorelease];
}

- (NSImage *)icon {
    if (arguments.options[@"icon-file"].wasProvided) {
        iconImage = [self iconFromFile:arguments.options[@"icon-file"].stringValue];
    }
    else if (arguments.options[@"icon"].wasProvided) {
        iconImage = [self iconFromName:arguments.options[@"icon"].stringValue];
    }
    return iconImage;
}
- (NSData *)iconData {
    return [self icon].TIFFRepresentation;
}
- (NSImage *)iconWithDefault {
    if ([self icon] == nil) {
        iconImage = NSApp.applicationIconImage;
    }
    return iconImage;
}
- (NSData *)iconDataWithDefault {
    return [self iconWithDefault].TIFFRepresentation;
}


- (NSImage *)iconFromFile:(NSString *)file {
    NSImage *image = nil;
    image = [[[NSImage alloc] initWithContentsOfFile:file] autorelease];
    if (image == nil) {
        [self warning:@"Could not return icon from specified file: \"%@\".", file, nil];
    }
    return image;
}

- (NSImage *)iconFromName:(NSString *)name {
    BOOL hasImage = NO;
    NSImage *image = [[[NSImage alloc] init] autorelease];
    NSString *bundle = nil;
    NSString *path = nil;
    NSString *iconType = @"icns";
    if (arguments.options[@"icon-type"].wasProvided) {
        iconType = arguments.options[@"icon-type"].stringValue;
    }
    // Use bundle identifier
    if (arguments.options[@"icon-bundle"].wasProvided) {
        bundle = arguments.options[@"icon-bundle"].stringValue;
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
                    [self warning:@"Could not retrieve image from specified icon file \"%@\".", fileName, nil];
                }
            }
            else {
                [self warning:@"Cannot find icon \"%@\" in bundle \"%@\".", name, bundle, nil];
            }
        }
        else {
            [self warning:@"Unknown icon \"%@\". No --icon-bundle specified.", name, nil];
        }
    }
    return image;
}

- (void) setIconFromOptions {
    if (control != nil) {
        NSImage *image = [self icon];
        if (arguments.options[@"icon-file"].wasProvided) {
            image = [self iconFromFile:arguments.options[@"icon-file"].stringValue];
        }
        else if (arguments.options[@"icon"].wasProvided) {
            image = [self iconFromName:arguments.options[@"icon"].stringValue];
        }
        
        // Set default icon sizes
        float iconWidth = control.frame.size.width;
        float iconHeight = control.frame.size.height;
        NSSize resize = NSMakeSize(iconWidth, iconHeight);
        
        // Control should display icon, process image.
        if (image != nil) {
            // Set default icon height
            // Get icon sizes from user options
            if (arguments.options[@"icon-size"].wasProvided) {
                NSUInteger iconSize = arguments.options[@"icon-size"].unsignedIntegerValue;
                switch (iconSize) {
                    case 256: iconWidth = 256.0; iconHeight = 256.0; break;
                    case 128: iconWidth = 128.0; iconHeight = 128.0; break;
                    case 48: iconWidth = 48.0; iconHeight = 48.0; break;
                    case 32: iconWidth = 32.0; iconHeight = 32.0; break;
                    case 16: iconWidth = 16.0; iconHeight = 16.0; break;
                }
            }
            else {
                if (arguments.options[@"icon-width"].wasProvided) {
                    iconWidth = arguments.options[@"icon-width"].floatValue;
                }
                if (arguments.options[@"icon-height"].wasProvided) {
                    iconHeight = arguments.options[@"icon-height"].floatValue;
                }
            }
            // Set sizes
            resize = NSMakeSize(iconWidth, iconHeight);
            [self setIconWithImage:image withSize:resize withControls:controls];
        }
        // Control shouldn't display icon, remove it and resize.
        else {
            [self setIconWithImage:nil withSize:resize withControls:controls];
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
            control.image = resizedImage;
        }
        else {
            control.image = anImage;
        }
        // Resize icon frame
        NSRect iconFrame = control.frame;
        float iconHeightDiff = aSize.height - iconFrame.size.height;
        NSRect newIconFrame = NSMakeRect(iconFrame.origin.x, iconFrame.origin.y - iconHeightDiff, aSize.width, aSize.height);
        control.frame = newIconFrame;
        iconFrame = control.frame;
        
        // Add the icon to the panel's minimum content size
        NSSize panelMinSize = panel.panel.contentMinSize;
        panelMinSize.height += iconFrame.size.height + 40.0f;
        panelMinSize.width += iconFrame.size.width + 30.0f;
        panel.panel.contentMinSize = panelMinSize;
    }
}
- (void) setIconWithImage:(NSImage *)anImage withSize:(NSSize)aSize withControls:(NSArray *)anArray {
    // Icon has image
    if (anImage != nil) {
        // Set current icon frame
        NSRect iconFrame = control.frame;
        
        // Set image and resize icon
        [self setIconWithImage:anImage withSize:aSize];
        
        float iconWidthDiff = control.frame.size.width - iconFrame.size.width;
        NSEnumerator *en = [anArray objectEnumerator];
        id _control;
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
        NSRect iconFrame = control.frame;
        // Remove the icon
        [control removeFromSuperview];
        control = nil;
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



@end
