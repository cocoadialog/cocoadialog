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
@synthesize hasFinished;

- (id)initWithOptions:(CDOptions *)options
{
    hasFinished = YES;
    controlItems = [[[NSMutableArray alloc] init] retain];
	self = [super init];
    if (options != nil) {
        [self setOptions:options];
    }
	return self;
}
- (id)init
{
	return [self initWithOptions:nil];
}

- (void) dealloc
{
	[_options release];
    [controlItems release];
	[super dealloc];
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
    return [NSDictionary dictionaryWithObjectsAndKeys:
            vNone, @"help",
            vNone, @"debug",
            vOne,  @"title",
            vOne,  @"width",
            vOne,  @"height",
            vOne,  @"posX",
            vOne,  @"posY",
            vNone, @"minimize",
            vNone, @"resize",
            vOne,  @"icon",
            vOne,  @"icon-bundle",
            vOne,  @"icon-type",
            vOne,  @"icon-file",
            vOne,  @"icon-size",
            vOne,  @"icon-width",
            vOne,  @"icon-height",
            vNone, @"string-output",
            vNone, @"no-newline",
            nil];
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

- (void) findPositionForWindow:(NSWindow *)window;
{
	CDOptions *options = [self options];
    NSRect screen = [[NSScreen mainScreen] visibleFrame];

    CGFloat leftPoint = 0.0;
	CGFloat topPoint = 0.0;
    CGFloat padding = 10.0;

    id posX;
    id posY;
    // Has posX option
	if ([options hasOpt:@"posX"]) {
		posX = [options optValue:@"posX"];
        // Left
		if ([posX caseInsensitiveCompare:@"left"] == NSOrderedSame) {
            leftPoint = padding;
		}
        // Right
        else if ([posX caseInsensitiveCompare:@"right"] == NSOrderedSame) {
            leftPoint = NSWidth(screen) - NSWidth([window frame]) - padding;
		}
        // Manual posX coords
        else if ([posX floatValue] > 0.0) {
            leftPoint = [posX floatValue];
        }
        // Center
        else {
            leftPoint = (NSWidth(screen)-NSWidth([window frame]))/2 - padding;
		}
	}
    // Center
    else {
        leftPoint = (NSWidth(screen)-NSWidth([window frame]))/2 - padding;
	}
    // Has posY option
	if ([options hasOpt:@"posY"]) {
		posY = [options optValue:@"posY"];
        // Bottom
		if ([posY caseInsensitiveCompare:@"bottom"] == NSOrderedSame) {
            topPoint = NSMinY(screen) + padding + NSHeight([window frame]);
		}
        // Top
        else if ([posY caseInsensitiveCompare:@"top"] == NSOrderedSame) {
            topPoint = NSMaxY(screen) - padding;
		}
        // Manual posY coords
        else if ([posY floatValue] > 0.0) {
            topPoint = NSMaxY(screen) - [posY floatValue];
        }
        // Center
        else {
            topPoint = NSMaxY(screen)/1.8 + NSHeight([window frame]);
		}
	}
    // Center
    else {
		topPoint = NSMaxY(screen)/1.8 + NSHeight([window frame]);
	}
	
	[window setFrameTopLeftPoint:NSMakePoint(leftPoint, topPoint)];

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

- (void) debug:(NSString *)message
{
	NSString *output = [NSString stringWithFormat:@"ERROR: %@\n", message]; 
    // Output to stdErr
	NSFileHandle *fh = [NSFileHandle fileHandleWithStandardError];
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

- (NSImage *)getIconFromFile:(NSString *)aFile
{
    CDOptions *options = [self options];
    NSImage *image = nil;
    image = [[[NSImage alloc] initWithContentsOfFile:aFile] autorelease];
    if (image == nil && [options hasOpt:@"debug"]) {
        [self debug:[NSString stringWithFormat:@"Could not get image from specified icon file '%@'.", aFile]];
    }
    return image;
}

- (NSImage *)getIconWithName:(NSString *)aName
{
    CDOptions *options = [self options];
    NSImage *image = [[[NSImage alloc] initWithData:nil] autorelease];
    NSString *bundle = nil;
    NSString *path = nil;
    NSString *iconType = @"icns";
    if ([options hasOpt:@"icon-type"]) {
        iconType = [options optValue:@"icon-type"];
    }
    // Use bundle identifier
    if ([options hasOpt:@"icon-bundle"]) {
        bundle = [options optValue:@"icon-bundle"];
    }
    // Set default bundle identifier
    if (bundle == nil) {
        // Application icon
        if ([aName caseInsensitiveCompare:@"cocoadialog"] == NSOrderedSame) {
            image = [NSApp applicationIconImage];
        }
        // User specific computer image
        else if ([aName caseInsensitiveCompare:@"computer"] == NSOrderedSame) {
            image = [NSImage imageNamed: NSImageNameComputer];
        }
        // Bundle Identifications
        else if ([aName caseInsensitiveCompare:@"addressbook"] == NSOrderedSame) {
            aName = @"AppIcon";
            bundle = @"com.apple.AddressBook";
        }
        else if ([aName caseInsensitiveCompare:@"airport"] == NSOrderedSame) {
            aName = @"AirPort";
            bundle = @"com.apple.AirPortBaseStationAgent";
        }
        else if ([aName caseInsensitiveCompare:@"airport2"] == NSOrderedSame) {
            aName = @"AirPort";
            bundle = @"com.apple.wifi.diagnostics";
        }
        else if ([aName caseInsensitiveCompare:@"archive"] == NSOrderedSame) {
            aName = @"bah";
            bundle = @"com.apple.archiveutility";
        }
        else if ([aName caseInsensitiveCompare:@"bluetooth"] == NSOrderedSame) {
            aName = @"AppIcon";
            bundle = @"com.apple.BluetoothAudioAgent";
        }
        else if ([aName caseInsensitiveCompare:@"application"] == NSOrderedSame) {
            aName = @"GenericApplicationIcon";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";
        }
        else if ([aName caseInsensitiveCompare:@"bonjour"] == NSOrderedSame || [aName caseInsensitiveCompare:@"atom"] == NSOrderedSame) {
            aName = @"Bonjour";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";							
        }
        else if ([aName caseInsensitiveCompare:@"burn"] == NSOrderedSame || [aName caseInsensitiveCompare:@"hazard"] == NSOrderedSame) {
            aName = @"BurningIcon";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";							
        }
        else if ([aName caseInsensitiveCompare:@"caution"] == NSOrderedSame) {
            aName = @"AlertCautionIcon";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";							
        }
        else if ([aName caseInsensitiveCompare:@"document"] == NSOrderedSame) {
            aName = @"GenericDocumentIcon";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";							
        }
        else if ([aName caseInsensitiveCompare:@"documents"] == NSOrderedSame) {
            aName = @"ToolbarDocumentsFolderIcon";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";							
        }
        else if ([aName caseInsensitiveCompare:@"download"] == NSOrderedSame) {
            aName = @"ToolbarDownloadsFolderIcon";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";							
        }
        else if ([aName caseInsensitiveCompare:@"eject"] == NSOrderedSame) {
            aName = @"EjectMediaIcon";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";							
        }
        else if ([aName caseInsensitiveCompare:@"everyone"] == NSOrderedSame) {
            aName = @"Everyone";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";							
        }
        else if ([aName caseInsensitiveCompare:@"executable"] == NSOrderedSame) {
            aName = @"ExecutableBinaryIcon";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";							
        }
        else if ([aName caseInsensitiveCompare:@"favorite"] == NSOrderedSame || [aName caseInsensitiveCompare:@"heart"] == NSOrderedSame) {
            aName = @"ToolbarFavoritesIcon";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";							
        }
        else if ([aName caseInsensitiveCompare:@"fileserver"] == NSOrderedSame) {
            aName = @"GenericFileServerIcon";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";							
        }
        else if ([aName caseInsensitiveCompare:@"filevault"] == NSOrderedSame) {
            aName = @"FileVaultIcon";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";							
        }
        else if ([aName caseInsensitiveCompare:@"finder"] == NSOrderedSame) {
            aName = @"FinderIcon";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";							
        }
        else if ([aName caseInsensitiveCompare:@"folder"] == NSOrderedSame) {
            aName = @"GenericFolderIcon";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";							
        }
        else if ([aName caseInsensitiveCompare:@"folderopen"] == NSOrderedSame) {
            aName = @"OpenFolderIcon";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";							
        }
        else if ([aName caseInsensitiveCompare:@"foldersmart"] == NSOrderedSame) {
            aName = @"SmartFolderIcon";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";							
        }
        else if ([aName caseInsensitiveCompare:@"gear"] == NSOrderedSame) {
            aName = @"ToolbarAdvanced";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";							
        }
        else if ([aName caseInsensitiveCompare:@"general"] == NSOrderedSame) {
            aName = @"General";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";							
        }
        else if ([aName caseInsensitiveCompare:@"globe"] == NSOrderedSame) {
            aName = @"BookmarkIcon";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";							
        }
        else if ([aName caseInsensitiveCompare:@"group"] == NSOrderedSame) {
            aName = @"GroupIcon";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";							
        }
        else if ([aName caseInsensitiveCompare:@"home"] == NSOrderedSame) {
            aName = @"HomeFolderIcon";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";							
        }
        else if ([aName caseInsensitiveCompare:@"info"] == NSOrderedSame) {
            aName = @"ToolbarInfo";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";							
        }
        else if ([aName caseInsensitiveCompare:@"ipod"] == NSOrderedSame) {
            aName = @"com.apple.ipod-touch-4";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";							
        }
        else if ([aName caseInsensitiveCompare:@"movie"] == NSOrderedSame) {
            aName = @"ToolbarMovieFolderIcon";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";							
        }
        else if ([aName caseInsensitiveCompare:@"music"] == NSOrderedSame) {
            aName = @"ToolbarMusicFolderIcon";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";							
        }
        else if ([aName caseInsensitiveCompare:@"network"] == NSOrderedSame) {
            aName = @"GenericNetworkIcon";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";							
        }
        else if ([aName caseInsensitiveCompare:@"notice"] == NSOrderedSame) {
            aName = @"AlertNoteIcon";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";							
        }
        else if ([aName caseInsensitiveCompare:@"stop"] == NSOrderedSame || [aName caseInsensitiveCompare:@"x"] == NSOrderedSame) {
            aName = @"AlertStopIcon";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";							
        }
        else if ([aName caseInsensitiveCompare:@"sync"] == NSOrderedSame) {
            aName = @"Sync";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";							
        }
        else if ([aName caseInsensitiveCompare:@"trash"] == NSOrderedSame) {
            aName = @"TrashIcon";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";							
        }
        else if ([aName caseInsensitiveCompare:@"trashfull"] == NSOrderedSame) {
            aName = @"FullTrashIcon";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";							
        }
        else if ([aName caseInsensitiveCompare:@"url"] == NSOrderedSame) {
            aName = @"GenericURLIcon";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";							
        }
        else if ([aName caseInsensitiveCompare:@"user"] == NSOrderedSame || [aName caseInsensitiveCompare:@"person"] == NSOrderedSame) {
            aName = @"UserIcon";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";							
        }
        else if ([aName caseInsensitiveCompare:@"utilities"] == NSOrderedSame) {
            aName = @"ToolbarUtilitiesFolderIcon";
            path = @"/System/Library/CoreServices/CoreTypes.bundle";							
        }
        else if ([aName caseInsensitiveCompare:@"dashboard"] == NSOrderedSame) {
            aName = @"Dashboard";
            bundle = @"com.apple.dashboard.installer";
        }
        else if ([aName caseInsensitiveCompare:@"dock"] == NSOrderedSame) {
            aName = @"Dock";
            bundle = @"com.apple.dock";
        }
        else if ([aName caseInsensitiveCompare:@"widget"] == NSOrderedSame) {
            aName = @"widget";
            bundle = @"com.apple.dock";
        }
        else if ([aName caseInsensitiveCompare:@"help"] == NSOrderedSame) {
            aName = @"HelpViewer";
            bundle = @"com.apple.helpviewer";
        }
        else if ([aName caseInsensitiveCompare:@"installer"] == NSOrderedSame) {
            aName = @"Installer";
            bundle = @"com.apple.installer";
        }
        else if ([aName caseInsensitiveCompare:@"package"] == NSOrderedSame) {
            aName = @"package";
            bundle = @"com.apple.installer";
        }
        else if ([aName caseInsensitiveCompare:@"firewire"] == NSOrderedSame) {
            aName = @"FireWireHD";
            bundle = @"com.apple.iokit.IOSCSIArchitectureModelFamily";
            path = @"/System/Library/Extensions/IOSCSIArchitectureModelFamily.kext";
        }
        else if ([aName caseInsensitiveCompare:@"usb"] == NSOrderedSame) {
            aName = @"USBHD";
            bundle = @"com.apple.iokit.IOSCSIArchitectureModelFamily";
            path = @"/System/Library/Extensions/IOSCSIArchitectureModelFamily.kext";
        }
        else if ([aName caseInsensitiveCompare:@"cd"] == NSOrderedSame) {
            aName = @"CD";
            bundle = @"com.apple.ODSAgent";
        }
        else if ([aName caseInsensitiveCompare:@"sound"] == NSOrderedSame) {
            aName = @"SoundPref";
            path = @"/System/Library/PreferencePanes/Sound.prefPane";
        }
        else if ([aName caseInsensitiveCompare:@"printer"] == NSOrderedSame) {
            aName = @"Printer";
            bundle = @"com.apple.print.PrintCenter";
        }
        else if ([aName caseInsensitiveCompare:@"screenshare"] == NSOrderedSame) {
            aName = @"ScreenSharing";
            bundle = @"com.apple.ScreenSharing";
        }
        else if ([aName caseInsensitiveCompare:@"security"] == NSOrderedSame) {
            aName = @"Security";
            bundle = @"com.apple.securityagent";
        }
        else if ([aName caseInsensitiveCompare:@"update"] == NSOrderedSame) {
            aName = @"Software Update";
            bundle = @"com.apple.SoftwareUpdate";
        }
        else if ([aName caseInsensitiveCompare:@"search"] == NSOrderedSame || [aName caseInsensitiveCompare:@"find"] == NSOrderedSame) {
            aName = @"Spotlight";
            path = @"/System/Library/CoreServices/Search.bundle";
        }
        else if ([aName caseInsensitiveCompare:@"preferences"] == NSOrderedSame) {
            aName = @"PrefApp";
            bundle = @"com.apple.systempreferences";
        }
    }
    // Process bundle image path only if image has not already been set from above
    if (image == nil) {
        if (bundle != nil || path != nil) {
            NSString * fileName = nil;
            if (path == nil) {
                NSWorkspace *workspace = [NSWorkspace sharedWorkspace];
                fileName = [[NSBundle bundleWithPath:[workspace absolutePathForAppBundleWithIdentifier:bundle]] pathForResource:aName ofType:iconType];
            }
            else {
                fileName = [[NSBundle bundleWithPath:path] pathForResource:aName ofType:iconType];
            }
            if (fileName != nil) {
                image = [[[NSImage alloc] initWithContentsOfFile:fileName] autorelease];
                if (image == nil && [options hasOpt:@"debug"]) {
                    [self debug:[NSString stringWithFormat:@"Could not get image from specified icon file '%@'.", fileName]];
                }
            }
            else if ([options hasOpt:@"debug"]) {
                [self debug:[NSString stringWithFormat:@"Cannot find icon '%@' in bundle '%@'.", aName, bundle]];
            }
        }
        else {
            if ([options hasOpt:@"debug"]) {
                [self debug:[NSString stringWithFormat:@"Unknown icon '%@'. No --icon-bundle specified.", aName]];
            }
        }
    }
    return image;
}


- (void) setIconForWindow:(NSWindow *)aWindow
{
    if (controlIcon != nil) {
        CDOptions *options = [self options];
        NSImage *image = [[[NSImage alloc] initWithData:nil] autorelease];
        if ([options hasOpt:@"icon-file"]) {
            image = [self getIconFromFile:[options optValue:@"icon-file"]];
        }
        else if ([options hasOpt:@"icon"]) {
            image = [self getIconWithName:[options optValue:@"icon"]];
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

@end
