/*
	CDControl.m
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

#import "AppController.h"
#import "CDControl.h"


@implementation CDControl

- (id)initWithOptions:(CDOptions *)options
{
	self = [super init];
    if (options != nil) {
        [self setOptions:options];
    }
	return self;
}
- (id)init
{
    controlItems = [[[NSMutableArray alloc] init] retain];
	return [self initWithOptions:nil];
}

- (CDOptions *) options
{
	return _options;
}
- (void) setOptions:(CDOptions *)options
{
	[options retain];
	[_options release];
	_options = options;
}

- (NSArray *) runControl
{
	if ([self options] != nil) {
		return [self runControlFromOptions:[self options]];
	} else {
		return nil;
	}
}
// This must be overridden
- (NSArray *) runControlFromOptions:(CDOptions *)options
{
	return nil;
}

// This must be sub-classed if you want options local to your control
- (NSDictionary *) availableKeys
{
	return nil;
}

// This must be sub-classed if you want specify local depreciated keys for your control
- (NSDictionary *) depreciatedKeys
{
    return nil;
}
// This must be sub-classed if you want validate local options for your control
- (BOOL) validateControl:(CDOptions *)options
{
    return YES;
}

// This must be overridden if you want local global options for your control
- (NSDictionary *) globalAvailableKeys {
    NSNumber *vOne = [NSNumber numberWithInt:CDOptionsOneValue];
	NSNumber *vNone = [NSNumber numberWithInt:CDOptionsNoValues];
    return [[NSDictionary dictionaryWithObjectsAndKeys:
            vNone, @"help",
            vNone, @"debug",
            vOne,  @"title",
            vOne,  @"width",
            vOne,  @"height",
            vNone, @"minimize",
            vNone, @"resize",
            vOne,  @"icon",
            vOne,  @"icon-bundle",
            vOne,  @"icon-file",
            vOne,  @"icon-size",
            vOne,  @"icon-width",
            vOne,  @"icon-height",
            vNone, @"string-output",
            vNone, @"no-newline",
            nil] autorelease];
}

- (CDOptions *) controlOptionsFromArgs:(NSArray *)args
{
	return [CDOptions getOpts:args availableKeys:[self availableKeys] depreciatedKeys:[self depreciatedKeys]];
}
- (CDOptions *) controlOptionsFromArgs:(NSArray *)args withGlobalKeys:(NSDictionary *)globalKeys
{
	NSMutableDictionary *allKeys = [[[NSMutableDictionary alloc] init] autorelease];
    [allKeys addEntriesFromDictionary:globalKeys];

	NSDictionary *localKeys = [self availableKeys];
	if (localKeys != nil) {
		[allKeys addEntriesFromDictionary:localKeys];
	}
    
    NSDictionary *depreciatedKeys = [self depreciatedKeys];
    
	CDOptions* options;
	options=[CDOptions getOpts:args availableKeys:allKeys depreciatedKeys:depreciatedKeys];
	return options;
}

- (NSSize) findNewSizeForWindow:(NSWindow *)window
{
	NSSize size = NSZeroSize;
	NSSize oldSize;
	NSString *width, *height;
	CDOptions *options = [self options];

	if (options == nil || window == nil) {
		return size;
	}
	
	size = [[window contentView] frame].size;
	oldSize.width = size.width;
	oldSize.height = size.height;
	if ([options hasOpt:@"width"]) {
		width = [options optValue:@"width"];
		if ([width floatValue] != 0.0) {
			size.width = [width floatValue];
		}
	}
	if ([options hasOpt:@"height"]) {
		height = [options optValue:@"height"];
		if ([height floatValue] != 0.0) {
			size.height = [height floatValue];
		}
	}
	NSSize minSize = [window contentMinSize];
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
- (BOOL) windowNeedsResize:(NSWindow *)window
{
	NSSize size = [self findNewSizeForWindow:window];
	if (size.width != 0.0 || size.height != 0.0) {
		return YES;
	} else {
		return NO;
	}
}

+ (void) debug:(NSString *)message
{
	NSFileHandle *fh = [NSFileHandle fileHandleWithStandardError];
	NSString *output = [NSString stringWithFormat:@"ERROR: %@\n", message]; 
	if (fh) {
		[fh writeData:[output dataUsingEncoding:NSUTF8StringEncoding]];
	}
}

+ (void) printHelpTo:(NSFileHandle *)fh
{
	if (fh) {
        [fh writeData:[@"Usage: cocoaDialog <run-mode> [options]\n\tAvailable run-modes:\n" dataUsingEncoding:NSUTF8StringEncoding]];
        NSArray *sortedAvailableKeys = [NSArray arrayWithArray:[[[AppController availableControls] allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];
        
        NSEnumerator *en = [sortedAvailableKeys objectEnumerator];
        id key;
        unsigned i = 0;
        unsigned currKey = 0;
        while (key = [en nextObject]) {
            if (i == 0) {
                [fh writeData:[@"\t\t" dataUsingEncoding:NSUTF8StringEncoding]];
            }
            [fh writeData:[key dataUsingEncoding:NSUTF8StringEncoding]];
            if (i <= 6 && currKey != [sortedAvailableKeys count] - 1) {
                [fh writeData:[@", " dataUsingEncoding:NSUTF8StringEncoding]];
                i++;
            }
            if (i == 6) {
                [fh writeData:[@"\n" dataUsingEncoding:NSUTF8StringEncoding]];
                i = 0;
            }
            currKey++;
        }

        [fh writeData:[@"\n\tGlobal Options:\n\t\t--help, --debug, --title, --width, --height,\n\t\t--string-output, --no-newline\n\nSee http://mstratman.github.com/cocoadialog/#documentation\nfor detailed documentation.\n" dataUsingEncoding:NSUTF8StringEncoding]];
	}
}


- (void) setIconForWindow:(NSWindow *)aWindow
{
    if (controlIcon != nil) {
        CDOptions *options = [self options];
        NSImage *image = [[[NSImage alloc] initWithData:nil] autorelease];
        if ([options hasOpt:@"icon-file"]) {
            image = [[[NSImage alloc ]initWithContentsOfFile:[options optValue:@"icon-file"]] autorelease];
            if (image == nil && [options hasOpt:@"debug"]) {
                [CDControl debug:[NSString stringWithFormat:@"Could not get image from specified icon file '%@'.", [options optValue:@"icon-file"]]];
            }
            
        } else if ([options hasOpt:@"icon"]) {
            NSString *iconName = [options optValue:@"icon"];
            NSString *bundle = nil;
            NSString *path = nil;
            // Use bundle identifier
            if ([options hasOpt:@"icon-bundle"]) {
                bundle = [options optValue:@"icon-bundle"];
            }
            // Set default bundle identifier
            if (bundle == nil) {
                // Application icon
                if ([iconName caseInsensitiveCompare:@"cocoadialog"] == NSOrderedSame) {
                    image = [NSApp applicationIconImage];
                }
                // User specific computer image
                else if ([iconName caseInsensitiveCompare:@"computer"] == NSOrderedSame) {
                    image = [NSImage imageNamed: NSImageNameComputer];
                }
                // Bundle Identifications
                else if ([iconName caseInsensitiveCompare:@"addressbook"] == NSOrderedSame) {
                    iconName = @"AppIcon";
                    bundle = @"com.apple.AddressBook";
                }
                else if ([iconName caseInsensitiveCompare:@"airport"] == NSOrderedSame) {
                    iconName = @"AirPort";
                    bundle = @"com.apple.AirPortBaseStationAgent";
                }
                else if ([iconName caseInsensitiveCompare:@"airport2"] == NSOrderedSame) {
                    iconName = @"AirPort";
                    bundle = @"com.apple.wifi.diagnostics";
                }
                else if ([iconName caseInsensitiveCompare:@"archive"] == NSOrderedSame) {
                    iconName = @"bah";
                    bundle = @"com.apple.archiveutility";
                }
                else if ([iconName caseInsensitiveCompare:@"bluetooth"] == NSOrderedSame) {
                    iconName = @"AppIcon";
                    bundle = @"com.apple.BluetoothAudioAgent";
                }
                else if ([iconName caseInsensitiveCompare:@"application"] == NSOrderedSame) {
                    iconName = @"GenericApplicationIcon";
                    path = @"/System/Library/CoreServices/CoreTypes.bundle";
                }
                else if ([iconName caseInsensitiveCompare:@"bonjour"] == NSOrderedSame || [iconName caseInsensitiveCompare:@"atom"] == NSOrderedSame) {
                    iconName = @"Bonjour";
                    path = @"/System/Library/CoreServices/CoreTypes.bundle";							
                }
                else if ([iconName caseInsensitiveCompare:@"burn"] == NSOrderedSame || [iconName caseInsensitiveCompare:@"hazard"] == NSOrderedSame) {
                    iconName = @"BurningIcon";
                    path = @"/System/Library/CoreServices/CoreTypes.bundle";							
                }
                else if ([iconName caseInsensitiveCompare:@"caution"] == NSOrderedSame) {
                    iconName = @"AlertCautionIcon";
                    path = @"/System/Library/CoreServices/CoreTypes.bundle";							
                }
                else if ([iconName caseInsensitiveCompare:@"document"] == NSOrderedSame) {
                    iconName = @"GenericDocumentIcon";
                    path = @"/System/Library/CoreServices/CoreTypes.bundle";							
                }
                else if ([iconName caseInsensitiveCompare:@"documents"] == NSOrderedSame) {
                    iconName = @"ToolbarDocumentsFolderIcon";
                    path = @"/System/Library/CoreServices/CoreTypes.bundle";							
                }
                else if ([iconName caseInsensitiveCompare:@"download"] == NSOrderedSame) {
                    iconName = @"ToolbarDownloadsFolderIcon";
                    path = @"/System/Library/CoreServices/CoreTypes.bundle";							
                }
                else if ([iconName caseInsensitiveCompare:@"eject"] == NSOrderedSame) {
                    iconName = @"EjectMediaIcon";
                    path = @"/System/Library/CoreServices/CoreTypes.bundle";							
                }
                else if ([iconName caseInsensitiveCompare:@"everyone"] == NSOrderedSame) {
                    iconName = @"Everyone";
                    path = @"/System/Library/CoreServices/CoreTypes.bundle";							
                }
                else if ([iconName caseInsensitiveCompare:@"executable"] == NSOrderedSame) {
                    iconName = @"ExecutableBinaryIcon";
                    path = @"/System/Library/CoreServices/CoreTypes.bundle";							
                }
                else if ([iconName caseInsensitiveCompare:@"favorite"] == NSOrderedSame || [iconName caseInsensitiveCompare:@"heart"] == NSOrderedSame) {
                    iconName = @"ToolbarFavoritesIcon";
                    path = @"/System/Library/CoreServices/CoreTypes.bundle";							
                }
                else if ([iconName caseInsensitiveCompare:@"fileserver"] == NSOrderedSame) {
                    iconName = @"GenericFileServerIcon";
                    path = @"/System/Library/CoreServices/CoreTypes.bundle";							
                }
                else if ([iconName caseInsensitiveCompare:@"filevault"] == NSOrderedSame) {
                    iconName = @"FileVaultIcon";
                    path = @"/System/Library/CoreServices/CoreTypes.bundle";							
                }
                else if ([iconName caseInsensitiveCompare:@"finder"] == NSOrderedSame) {
                    iconName = @"FinderIcon";
                    path = @"/System/Library/CoreServices/CoreTypes.bundle";							
                }
                else if ([iconName caseInsensitiveCompare:@"folder"] == NSOrderedSame) {
                    iconName = @"GenericFolderIcon";
                    path = @"/System/Library/CoreServices/CoreTypes.bundle";							
                }
                else if ([iconName caseInsensitiveCompare:@"folderopen"] == NSOrderedSame) {
                    iconName = @"OpenFolderIcon";
                    path = @"/System/Library/CoreServices/CoreTypes.bundle";							
                }
                else if ([iconName caseInsensitiveCompare:@"foldersmart"] == NSOrderedSame) {
                    iconName = @"SmartFolderIcon";
                    path = @"/System/Library/CoreServices/CoreTypes.bundle";							
                }
                else if ([iconName caseInsensitiveCompare:@"gear"] == NSOrderedSame) {
                    iconName = @"ToolbarAdvanced";
                    path = @"/System/Library/CoreServices/CoreTypes.bundle";							
                }
                else if ([iconName caseInsensitiveCompare:@"general"] == NSOrderedSame) {
                    iconName = @"General";
                    path = @"/System/Library/CoreServices/CoreTypes.bundle";							
                }
                else if ([iconName caseInsensitiveCompare:@"globe"] == NSOrderedSame) {
                    iconName = @"BookmarkIcon";
                    path = @"/System/Library/CoreServices/CoreTypes.bundle";							
                }
                else if ([iconName caseInsensitiveCompare:@"group"] == NSOrderedSame) {
                    iconName = @"GroupIcon";
                    path = @"/System/Library/CoreServices/CoreTypes.bundle";							
                }
                else if ([iconName caseInsensitiveCompare:@"home"] == NSOrderedSame) {
                    iconName = @"HomeFolderIcon";
                    path = @"/System/Library/CoreServices/CoreTypes.bundle";							
                }
                else if ([iconName caseInsensitiveCompare:@"info"] == NSOrderedSame) {
                    iconName = @"ToolbarInfo";
                    path = @"/System/Library/CoreServices/CoreTypes.bundle";							
                }
                else if ([iconName caseInsensitiveCompare:@"ipod"] == NSOrderedSame) {
                    iconName = @"com.apple.ipod-touch-4";
                    path = @"/System/Library/CoreServices/CoreTypes.bundle";							
                }
                else if ([iconName caseInsensitiveCompare:@"movie"] == NSOrderedSame) {
                    iconName = @"ToolbarMovieFolderIcon";
                    path = @"/System/Library/CoreServices/CoreTypes.bundle";							
                }
                else if ([iconName caseInsensitiveCompare:@"music"] == NSOrderedSame) {
                    iconName = @"ToolbarMusicFolderIcon";
                    path = @"/System/Library/CoreServices/CoreTypes.bundle";							
                }
                else if ([iconName caseInsensitiveCompare:@"network"] == NSOrderedSame) {
                    iconName = @"GenericNetworkIcon";
                    path = @"/System/Library/CoreServices/CoreTypes.bundle";							
                }
                else if ([iconName caseInsensitiveCompare:@"notice"] == NSOrderedSame) {
                    iconName = @"AlertNoteIcon";
                    path = @"/System/Library/CoreServices/CoreTypes.bundle";							
                }
                else if ([iconName caseInsensitiveCompare:@"stop"] == NSOrderedSame || [iconName caseInsensitiveCompare:@"x"] == NSOrderedSame) {
                    iconName = @"AlertStopIcon";
                    path = @"/System/Library/CoreServices/CoreTypes.bundle";							
                }
                else if ([iconName caseInsensitiveCompare:@"sync"] == NSOrderedSame) {
                    iconName = @"Sync";
                    path = @"/System/Library/CoreServices/CoreTypes.bundle";							
                }
                else if ([iconName caseInsensitiveCompare:@"trash"] == NSOrderedSame) {
                    iconName = @"TrashIcon";
                    path = @"/System/Library/CoreServices/CoreTypes.bundle";							
                }
                else if ([iconName caseInsensitiveCompare:@"trashfull"] == NSOrderedSame) {
                    iconName = @"FullTrashIcon";
                    path = @"/System/Library/CoreServices/CoreTypes.bundle";							
                }
                else if ([iconName caseInsensitiveCompare:@"url"] == NSOrderedSame) {
                    iconName = @"GenericURLIcon";
                    path = @"/System/Library/CoreServices/CoreTypes.bundle";							
                }
                else if ([iconName caseInsensitiveCompare:@"user"] == NSOrderedSame || [iconName caseInsensitiveCompare:@"person"] == NSOrderedSame) {
                    iconName = @"UserIcon";
                    path = @"/System/Library/CoreServices/CoreTypes.bundle";							
                }
                else if ([iconName caseInsensitiveCompare:@"utilities"] == NSOrderedSame) {
                    iconName = @"ToolbarUtilitiesFolderIcon";
                    path = @"/System/Library/CoreServices/CoreTypes.bundle";							
                }
                else if ([iconName caseInsensitiveCompare:@"dashboard"] == NSOrderedSame) {
                    iconName = @"Dashboard";
                    bundle = @"com.apple.dashboard.installer";
                }
                else if ([iconName caseInsensitiveCompare:@"dock"] == NSOrderedSame) {
                    iconName = @"Dock";
                    bundle = @"com.apple.dock";
                }
                else if ([iconName caseInsensitiveCompare:@"widget"] == NSOrderedSame) {
                    iconName = @"widget";
                    bundle = @"com.apple.dock";
                }
                else if ([iconName caseInsensitiveCompare:@"help"] == NSOrderedSame) {
                    iconName = @"HelpViewer";
                    bundle = @"com.apple.helpviewer";
                }
                else if ([iconName caseInsensitiveCompare:@"installer"] == NSOrderedSame) {
                    iconName = @"Installer";
                    bundle = @"com.apple.installer";
                }
                else if ([iconName caseInsensitiveCompare:@"package"] == NSOrderedSame) {
                    iconName = @"package";
                    bundle = @"com.apple.installer";
                }
                else if ([iconName caseInsensitiveCompare:@"firewire"] == NSOrderedSame) {
                    iconName = @"FireWireHD";
                    bundle = @"com.apple.iokit.IOSCSIArchitectureModelFamily";
                    path = @"/System/Library/Extensions/IOSCSIArchitectureModelFamily.kext";
                }
                else if ([iconName caseInsensitiveCompare:@"usb"] == NSOrderedSame) {
                    iconName = @"USBHD";
                    bundle = @"com.apple.iokit.IOSCSIArchitectureModelFamily";
                    path = @"/System/Library/Extensions/IOSCSIArchitectureModelFamily.kext";
                }
                else if ([iconName caseInsensitiveCompare:@"cd"] == NSOrderedSame) {
                    iconName = @"CD";
                    bundle = @"com.apple.ODSAgent";
                }
                else if ([iconName caseInsensitiveCompare:@"sound"] == NSOrderedSame) {
                    iconName = @"SoundPref";
                    path = @"/System/Library/PreferencePanes/Sound.prefPane";
                }
                else if ([iconName caseInsensitiveCompare:@"printer"] == NSOrderedSame) {
                    iconName = @"Printer";
                    bundle = @"com.apple.print.PrintCenter";
                }
                else if ([iconName caseInsensitiveCompare:@"screenshare"] == NSOrderedSame) {
                    iconName = @"ScreenSharing";
                    bundle = @"com.apple.ScreenSharing";
                }
                else if ([iconName caseInsensitiveCompare:@"security"] == NSOrderedSame) {
                    iconName = @"Security";
                    bundle = @"com.apple.securityagent";
                }
                else if ([iconName caseInsensitiveCompare:@"update"] == NSOrderedSame) {
                    iconName = @"Software Update";
                    bundle = @"com.apple.SoftwareUpdate";
                }
                else if ([iconName caseInsensitiveCompare:@"search"] == NSOrderedSame || [iconName caseInsensitiveCompare:@"find"] == NSOrderedSame) {
                    iconName = @"Spotlight";
                    path = @"/System/Library/CoreServices/Search.bundle";
                }
                else if ([iconName caseInsensitiveCompare:@"preferences"] == NSOrderedSame) {
                    iconName = @"PrefApp";
                    bundle = @"com.apple.systempreferences";
                }
            }
            // Process bundle image path only if image has not already been set from above
            if (image == nil) {
                if (bundle != nil || path != nil) {
                    NSString * fileName = nil;
                    if (path == nil) {
                        NSWorkspace *workspace = [NSWorkspace sharedWorkspace];
                        fileName = [[NSBundle bundleWithPath:[workspace absolutePathForAppBundleWithIdentifier:bundle]] pathForResource:iconName ofType:@"icns"];
                    }
                    else {
                        fileName = [[NSBundle bundleWithPath:path] pathForResource:iconName ofType:@"icns"];
                    }
                    if (fileName != nil) {
                        image = [[[NSImage alloc] initWithContentsOfFile:fileName] autorelease];
                        if (image == nil && [options hasOpt:@"debug"]) {
                            [CDControl debug:[NSString stringWithFormat:@"Could not get image from specified icon file '%@'.", fileName]];
                        }
                    }
                    else if ([options hasOpt:@"debug"]) {
                        [CDControl debug:[NSString stringWithFormat:@"Cannot find icon '%@' in bundle '%@'.", iconName, bundle]];
                    }
                }
                else {
                    if ([options hasOpt:@"debug"]) {
                        [CDControl debug:[NSString stringWithFormat:@"Unknown icon '%@'. No --icon-bundle specified.", iconName]];
                    }
                }
            }
        }
        
        // Set default icon sizes
        float iconWidth = [controlIcon frame].size.width;
        float iconHeight = [controlIcon frame].size.height;
        NSSize resize = NSMakeSize(iconWidth, iconHeight);
        
        // Control should display icon, process image.
        if (image != nil) {
            // Set default icon height
            // Get icon sizes from user options
            if ([options hasOpt:@"icon-size"]) {
                int iconSize = [[options optValue:@"icon-size"] intValue];
                switch (iconSize) {
                    case 256: iconWidth = 256.0; iconHeight = 256.0; break;
                    case 128: iconWidth = 128.0; iconHeight = 128.0; break;
                    case 48: iconWidth = 48.0; iconHeight = 48.0; break;
                    case 32: iconWidth = 32.0; iconHeight = 32.0; break;
                    case 16: iconWidth = 16.0; iconHeight = 16.0; break;
                }
            }
            else {
                if ([options hasOpt:@"icon-width"]) {
                    iconWidth = [[options optValue:@"icon-width"] floatValue];
                }
                if ([options hasOpt:@"icon-height"]) {
                    iconHeight = [[options optValue:@"icon-height"] floatValue];
                }
            }
            // Set sizes
            resize = NSMakeSize(iconWidth, iconHeight);
            [self setIconForWindow:aWindow withImage:image withSize:resize withControls:controlItems];
        }
        // Control shouldn't display icon, remove it and resize.
        else {
            [self setIconForWindow:aWindow withImage:nil withSize:resize withControls:controlItems];
        }
    }
}
- (void) setIconForWindow:(NSWindow *)aWindow withImage:(NSImage *)anImage withSize:(NSSize)aSize
{
    if (anImage != nil) {
        NSSize originalSize = [anImage size];
        // Resize Icon
        if (originalSize.width != aSize.width || originalSize.height != aSize.height) {
            NSImage *resizedImage = [[[NSImage alloc] initWithSize: aSize] autorelease];
            [resizedImage lockFocus];
            [anImage drawInRect: NSMakeRect(0, 0, aSize.width, aSize.height) fromRect: NSMakeRect(0, 0, originalSize.width, originalSize.height) operation: NSCompositeSourceOver fraction: 1.0];
            [resizedImage unlockFocus];
            [controlIcon setImage:resizedImage];
        }
        else {
            [controlIcon setImage:anImage];
        }
        // Resize icon frame
        NSRect iconFrame = [controlIcon frame];
        float iconHeightDiff = aSize.height - iconFrame.size.height;
        NSRect newIconFrame = NSMakeRect(iconFrame.origin.x, iconFrame.origin.y - iconHeightDiff, aSize.width, aSize.height);
        [controlIcon setFrame:newIconFrame];
        iconFrame = [controlIcon frame];

        // Add the icon to the panel's minimum content size
        NSSize windowContent = [aWindow contentMinSize];
        windowContent.height += iconFrame.size.height + 40.0f;
        windowContent.width += iconFrame.size.width + 30.0f;
        [aWindow setContentMinSize:windowContent];
    }
}

- (void) setIconForWindow:(NSWindow *)aWindow withImage:(NSImage *)anImage withSize:(NSSize)aSize withControls:(NSArray *)anArray
{
    // Icon has image
    if (anImage != nil) {
        // Set current icon frame
        NSRect iconFrame = [controlIcon frame];
        
        // Set image and resize icon
        [self setIconForWindow:aWindow withImage:anImage withSize:aSize];
        
        float iconWidthDiff = [controlIcon frame].size.width - iconFrame.size.width;
        NSEnumerator *en = [anArray objectEnumerator];
        id control;
        while (control = [en nextObject]) {
            // Make sure the control exists
            if (control != nil) {
                NSRect controlFrame = [control frame];
                NSRect newControlFrame = NSMakeRect(controlFrame.origin.x + iconWidthDiff, controlFrame.origin.y, controlFrame.size.width - iconWidthDiff, controlFrame.size.height);
                [control setFrame:newControlFrame];
            }
        }
        
    }
    // Icon does not have image
    else {
        // Set current icon frame
        NSRect iconFrame = [controlIcon frame];
        // Remove the icon
        [controlIcon removeFromSuperview];
        controlIcon = nil;
        // Move the controls to the left and increase their width
        NSEnumerator *en = [anArray objectEnumerator];
        id control;
        while (control = [en nextObject]) {
            // Make sure the control exists
            if (control != nil) {
                NSRect controlFrame = [control frame];
                float newControlWidth = controlFrame.size.width + (controlFrame.origin.x - iconFrame.origin.x);
                NSRect newControlFrame = NSMakeRect(iconFrame.origin.x, controlFrame.origin.y, newControlWidth, controlFrame.size.height);
                [control setFrame:newControlFrame];
            }
        }
    }
}

- (void) dealloc
{
	[_options release];
    [controlItems release];
	[super dealloc];
}

@end
