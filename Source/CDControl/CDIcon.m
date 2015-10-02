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

- (instancetype) initWithOptions:(CDOptions *)opts {
    self = [super initWithOptions:opts];
    controls = @[].mutableCopy;
    return self;
}


- (void) addControl:(id)obj {
    if (obj != nil) {
        [controls addObject:obj];
    }
}

- (NSArray *)controls {
    return [controls copy];
}

- (NSImage *)icon {
    if ([self.options hasOpt:@"icon-file"]) {
        iconImage = [self iconFromFile:[self.options optValue:@"icon-file"]];
    }
    else if ([self.options hasOpt:@"icon"]) {
        iconImage = [self iconFromName:[self.options optValue:@"icon"]];
    }
    return iconImage;
}
- (NSData *)iconData {
    return [[self icon] TIFFRepresentation];
}
- (NSImage *)iconWithDefault {
    if ([self icon] == nil) {
        iconImage = [NSApp applicationIconImage];
    }
    return iconImage;
}
- (NSData *)iconDataWithDefault {
    return [[self iconWithDefault] TIFFRepresentation];
}


- (NSImage *)iconFromFile:(NSString *)file {
    NSImage *image = nil;
    image = [NSImage.alloc initWithContentsOfFile:file];
    if (image == nil && [self.options hasOpt:@"debug"]) {
        [self debug:[NSString stringWithFormat:@"Could not return icon from specified file: \"%@\".", file]];
    }
    return image;
}
- (NSImage *)iconFromName:(NSString *)name {
    NSImage *image = [NSImage.alloc initWithData:nil];
    NSString *bundle = nil;
    NSString *path = nil;
    NSString *iconType = @"icns";
    if ([self.options hasOpt:@"icon-type"]) {
        iconType = [self.options optValue:@"icon-type"];
    }
    // Use bundle identifier
    if ([self.options hasOpt:@"icon-bundle"]) {
        bundle = [self.options optValue:@"icon-bundle"];
    }
    // Set default bundle identifier
    if (bundle == nil) {
        // Application icon
        if ([name caseInsensitiveCompare:@"cocoadialog"] == NSOrderedSame) {
            image = [NSApp applicationIconImage];
        }
        // User specific computer image
        else if ([name caseInsensitiveCompare:@"computer"] == NSOrderedSame) {
            image = [NSImage imageNamed: NSImageNameComputer];
        }
        // Bundle Identifications
        else if ([name caseInsensitiveCompare:@"addressbook"] == NSOrderedSame) {
            name = @"AppIcon";
            bundle = @"com.apple.AddressBook";
        }
        else if ([name caseInsensitiveCompare:@"airport"] == NSOrderedSame) {
            name = @"AirPort";
            bundle = @"com.apple.AirPortBaseStationAgent";
        }
        else if ([name caseInsensitiveCompare:@"airport2"] == NSOrderedSame) {
            name = @"AirPort";
            bundle = @"com.apple.wifi.diagnostics";
        }
        else if ([name caseInsensitiveCompare:@"archive"] == NSOrderedSame) {
            name = @"bah";
            bundle = @"com.apple.archiveutility";
        }
        else if ([name caseInsensitiveCompare:@"bluetooth"] == NSOrderedSame) {
            name = @"AppIcon";
            bundle = @"com.apple.BluetoothAudioAgent";
        }
        else if ([name caseInsensitiveCompare:@"application"] == NSOrderedSame) {
            name = @"GenericApplicationIcon";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";
        }
        else if ([name caseInsensitiveCompare:@"bonjour"] == NSOrderedSame || [name caseInsensitiveCompare:@"atom"] == NSOrderedSame) {
            name = @"Bonjour";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";							
        }
        else if ([name caseInsensitiveCompare:@"burn"] == NSOrderedSame || [name caseInsensitiveCompare:@"hazard"] == NSOrderedSame) {
            name = @"BurningIcon";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";							
        }
        else if ([name caseInsensitiveCompare:@"caution"] == NSOrderedSame) {
            name = @"AlertCautionIcon";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";							
        }
        else if ([name caseInsensitiveCompare:@"document"] == NSOrderedSame) {
            name = @"GenericDocumentIcon";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";							
        }
        else if ([name caseInsensitiveCompare:@"documents"] == NSOrderedSame) {
            name = @"ToolbarDocumentsFolderIcon";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";							
        }
        else if ([name caseInsensitiveCompare:@"download"] == NSOrderedSame) {
            name = @"ToolbarDownloadsFolderIcon";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";							
        }
        else if ([name caseInsensitiveCompare:@"eject"] == NSOrderedSame) {
            name = @"EjectMediaIcon";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";							
        }
        else if ([name caseInsensitiveCompare:@"everyone"] == NSOrderedSame) {
            name = @"Everyone";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";							
        }
        else if ([name caseInsensitiveCompare:@"executable"] == NSOrderedSame) {
            name = @"ExecutableBinaryIcon";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";							
        }
        else if ([name caseInsensitiveCompare:@"favorite"] == NSOrderedSame || [name caseInsensitiveCompare:@"heart"] == NSOrderedSame) {
            name = @"ToolbarFavoritesIcon";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";							
        }
        else if ([name caseInsensitiveCompare:@"fileserver"] == NSOrderedSame) {
            name = @"GenericFileServerIcon";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";							
        }
        else if ([name caseInsensitiveCompare:@"filevault"] == NSOrderedSame) {
            name = @"FileVaultIcon";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";							
        }
        else if ([name caseInsensitiveCompare:@"finder"] == NSOrderedSame) {
            name = @"FinderIcon";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";							
        }
        else if ([name caseInsensitiveCompare:@"folder"] == NSOrderedSame) {
            name = @"GenericFolderIcon";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";							
        }
        else if ([name caseInsensitiveCompare:@"folderopen"] == NSOrderedSame) {
            name = @"OpenFolderIcon";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";							
        }
        else if ([name caseInsensitiveCompare:@"foldersmart"] == NSOrderedSame) {
            name = @"SmartFolderIcon";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";							
        }
        else if ([name caseInsensitiveCompare:@"gear"] == NSOrderedSame) {
            name = @"ToolbarAdvanced";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";							
        }
        else if ([name caseInsensitiveCompare:@"general"] == NSOrderedSame) {
            name = @"General";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";							
        }
        else if ([name caseInsensitiveCompare:@"globe"] == NSOrderedSame) {
            name = @"BookmarkIcon";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";							
        }
        else if ([name caseInsensitiveCompare:@"group"] == NSOrderedSame) {
            name = @"GroupIcon";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";							
        }
        else if ([name caseInsensitiveCompare:@"home"] == NSOrderedSame) {
            name = @"HomeFolderIcon";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";							
        }
        else if ([name caseInsensitiveCompare:@"info"] == NSOrderedSame) {
            name = @"ToolbarInfo";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";							
        }
        else if ([name caseInsensitiveCompare:@"ipod"] == NSOrderedSame) {
            name = @"com.apple.ipod-touch-4";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";							
        }
        else if ([name caseInsensitiveCompare:@"movie"] == NSOrderedSame) {
            name = @"ToolbarMovieFolderIcon";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";							
        }
        else if ([name caseInsensitiveCompare:@"music"] == NSOrderedSame) {
            name = @"ToolbarMusicFolderIcon";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";							
        }
        else if ([name caseInsensitiveCompare:@"network"] == NSOrderedSame) {
            name = @"GenericNetworkIcon";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";							
        }
        else if ([name caseInsensitiveCompare:@"notice"] == NSOrderedSame) {
            name = @"AlertNoteIcon";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";							
        }
        else if ([name caseInsensitiveCompare:@"stop"] == NSOrderedSame || [name caseInsensitiveCompare:@"x"] == NSOrderedSame) {
            name = @"AlertStopIcon";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";							
        }
        else if ([name caseInsensitiveCompare:@"sync"] == NSOrderedSame) {
            name = @"Sync";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";							
        }
        else if ([name caseInsensitiveCompare:@"trash"] == NSOrderedSame) {
            name = @"TrashIcon";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";							
        }
        else if ([name caseInsensitiveCompare:@"trashfull"] == NSOrderedSame) {
            name = @"FullTrashIcon";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";							
        }
        else if ([name caseInsensitiveCompare:@"url"] == NSOrderedSame) {
            name = @"GenericURLIcon";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";							
        }
        else if ([name caseInsensitiveCompare:@"user"] == NSOrderedSame || [name caseInsensitiveCompare:@"person"] == NSOrderedSame) {
            name = @"UserIcon";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";							
        }
        else if ([name caseInsensitiveCompare:@"utilities"] == NSOrderedSame) {
            name = @"ToolbarUtilitiesFolderIcon";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";							
        }
        else if ([name caseInsensitiveCompare:@"dashboard"] == NSOrderedSame) {
            name = @"Dashboard";
            bundle = @"com.apple.dashboard.installer";
        }
        else if ([name caseInsensitiveCompare:@"dock"] == NSOrderedSame) {
            name = @"Dock";
            bundle = @"com.apple.dock";
        }
        else if ([name caseInsensitiveCompare:@"widget"] == NSOrderedSame) {
            name = @"widget";
            bundle = @"com.apple.dock";
        }
        else if ([name caseInsensitiveCompare:@"help"] == NSOrderedSame) {
            name = @"HelpViewer";
            bundle = @"com.apple.helpviewer";
        }
        else if ([name caseInsensitiveCompare:@"installer"] == NSOrderedSame) {
            name = @"Installer";
            bundle = @"com.apple.installer";
        }
        else if ([name caseInsensitiveCompare:@"package"] == NSOrderedSame) {
            name = @"package";
            bundle = @"com.apple.installer";
        }
        else if ([name caseInsensitiveCompare:@"firewire"] == NSOrderedSame) {
            name = @"FireWireHD";
            bundle = @"com.apple.iokit.IOSCSIArchitectureModelFamily";
            path = @"/System/Library/Extensions/IOSCSIArchitectureModelFamily.kext";
        }
        else if ([name caseInsensitiveCompare:@"usb"] == NSOrderedSame) {
            name = @"USBHD";
            bundle = @"com.apple.iokit.IOSCSIArchitectureModelFamily";
            path = @"/System/Library/Extensions/IOSCSIArchitectureModelFamily.kext";
        }
        else if ([name caseInsensitiveCompare:@"cd"] == NSOrderedSame) {
            name = @"CD";
            bundle = @"com.apple.ODSAgent";
        }
        else if ([name caseInsensitiveCompare:@"sound"] == NSOrderedSame) {
            name = @"SoundPref";
            path = @"/System/Library/PreferencePanes/Sound.prefPane";
        }
        else if ([name caseInsensitiveCompare:@"printer"] == NSOrderedSame) {
            name = @"Printer";
            bundle = @"com.apple.print.PrintCenter";
        }
        else if ([name caseInsensitiveCompare:@"screenshare"] == NSOrderedSame) {
            name = @"ScreenSharing";
            bundle = @"com.apple.ScreenSharing";
        }
        else if ([name caseInsensitiveCompare:@"security"] == NSOrderedSame) {
            name = @"Security";
            bundle = @"com.apple.securityagent";
        }
        else if ([name caseInsensitiveCompare:@"update"] == NSOrderedSame) {
            name = @"Software Update";
            bundle = @"com.apple.SoftwareUpdate";
        }
        else if ([name caseInsensitiveCompare:@"search"] == NSOrderedSame || [name caseInsensitiveCompare:@"find"] == NSOrderedSame) {
            name = @"Spotlight";
            path = @"/System/Library/CoreServices/Search.bundle";
        }
        else if ([name caseInsensitiveCompare:@"preferences"] == NSOrderedSame) {
            name = @"PrefApp";
            bundle = @"com.apple.systempreferences";
        }
    }
    // Process bundle image path only if image has not already been set from above
    if (image == nil) {
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
                image = [NSImage.alloc initWithContentsOfFile:fileName];
                if (image == nil && [self.options hasOpt:@"debug"]) {
                    [self debug:[NSString stringWithFormat:@"Could not get image from specified icon file '%@'.", fileName]];
                }
            }
            else if ([self.options hasOpt:@"debug"]) {
                [self debug:[NSString stringWithFormat:@"Cannot find icon '%@' in bundle '%@'.", name, bundle]];
            }
        }
        else {
            if ([self.options hasOpt:@"debug"]) {
                [self debug:[NSString stringWithFormat:@"Unknown icon '%@'. No --icon-bundle specified.", name]];
            }
        }
    }
    return image;
}

- (void) setIconFromOptions {
    if (control != nil) {
        NSImage *image = [self icon];
        if ([self.options hasOpt:@"icon-file"]) {
            image = [self iconFromFile:[self.options optValue:@"icon-file"]];
        }
        else if ([self.options hasOpt:@"icon"]) {
            image = [self iconFromName:[self.options optValue:@"icon"]];
        }
        
        // Set default icon sizes
        float iconWidth = [control frame].size.width;
        float iconHeight = [control frame].size.height;
        NSSize resize = NSMakeSize(iconWidth, iconHeight);
        
        // Control should display icon, process image.
        if (image != nil) {
            // Set default icon height
            // Get icon sizes from user options
            if ([self.options hasOpt:@"icon-size"]) {
                int iconSize = [[self.options optValue:@"icon-size"] intValue];
                switch (iconSize) {
                    case 256: iconWidth = 256.0; iconHeight = 256.0; break;
                    case 128: iconWidth = 128.0; iconHeight = 128.0; break;
                    case 48: iconWidth = 48.0; iconHeight = 48.0; break;
                    case 32: iconWidth = 32.0; iconHeight = 32.0; break;
                    case 16: iconWidth = 16.0; iconHeight = 16.0; break;
                }
            }
            else {
                if ([self.options hasOpt:@"icon-width"]) {
                    iconWidth = [[self.options optValue:@"icon-width"] floatValue];
                }
                if ([self.options hasOpt:@"icon-height"]) {
                    iconHeight = [[self.options optValue:@"icon-height"] floatValue];
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
        NSSize originalSize = [anImage size];
        // Resize Icon
        if (originalSize.width != aSize.width || originalSize.height != aSize.height) {
            NSImage *resizedImage = [NSImage.alloc initWithSize: aSize];
            [resizedImage lockFocus];
            [anImage drawInRect: NSMakeRect(0, 0, aSize.width, aSize.height) fromRect: NSMakeRect(0, 0, originalSize.width, originalSize.height) operation: NSCompositeSourceOver fraction: 1.0];
            [resizedImage unlockFocus];
            [control setImage:resizedImage];
        }
        else {
            [control setImage:anImage];
        }
        // Resize icon frame
        NSRect iconFrame = [control frame];
        float iconHeightDiff = aSize.height - iconFrame.size.height;
        NSRect newIconFrame = NSMakeRect(iconFrame.origin.x, iconFrame.origin.y - iconHeightDiff, aSize.width, aSize.height);
        [control setFrame:newIconFrame];
        iconFrame = [control frame];
        
        // Add the icon to the panel's minimum content size
        NSSize panelMinSize = [[panel panel] contentMinSize];
        panelMinSize.height += iconFrame.size.height + 40.0f;
        panelMinSize.width += iconFrame.size.width + 30.0f;
        [[panel panel] setContentMinSize:panelMinSize];
    }
}
- (void) setIconWithImage:(NSImage *)anImage withSize:(NSSize)aSize withControls:(NSArray *)anArray {
    // Icon has image
    if (anImage != nil) {
        // Set current icon frame
        NSRect iconFrame = [control frame];
        
        // Set image and resize icon
        [self setIconWithImage:anImage withSize:aSize];
        
        float iconWidthDiff = [control frame].size.width - iconFrame.size.width;
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
        NSRect iconFrame = [control frame];
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
