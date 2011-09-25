/*
	CDThreeButtonControl.m
	CocoaDialog
	Copyright (C) 2004-2006 Mark A. Stratman <mark@sporkstorms.org>
 
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

#import "CDThreeButtonControl.h"

@implementation CDThreeButtonControl


- (id)init
{
    self = [super init];
    controlItems = [[[NSMutableArray alloc] init] retain];
	return self;
}

- (void) dealloc
{
	[controlItems release];
	[super dealloc];
}



- (void) runAndSetRv
{
	// Run modal
	[panel center];
	if ([[self options] hasOpt:@"float"]) {
		[panel setFloatingPanel: YES];
		[panel setLevel:NSScreenSaverWindowLevel];
	}		
	
	[panel makeKeyAndOrderFront:nil];
	[NSApp run];
}

// Needs to be overriden in control
- (void) setControl:(id)sender { }

- (void) setControl: (id)sender matrixRows:(NSInteger)rows matrixColumns:(NSInteger)columns items:(NSArray *)items precedence:(int)precedence
{
    if (controlMatrix != nil) {
        // Default exact columns/rows
        int exactColumns = [items count] / rows;
        float exactColumnsFloat = (float) [items count] / (float)rows;
        
        int exactRows = [items count] / columns;
        float exactRowsFloat = (float)[items count] / (float)columns;
        
        switch (precedence) {
                // Rows have precedence over columns, if items extend past number of rows
                // columns will be increased to account for the additional items.
            case 1:
                // Items do not fill rows, reduce the rows to fit
                if (exactRowsFloat < (float)rows) {
                    rows = exactRows;
                }
                // Items exceed rows, expand columns
                else if (exactRowsFloat > (float)rows) {
                    columns = [items count] / rows;
                    float exactColumnsFloat = (float)[items count] / (float)rows;
                    if (exactColumnsFloat > (float) columns) {
                        columns++;
                    }
                }
                // Extend rows once more if the division is greater than a whole number
                if (exactColumnsFloat > (float) columns) {
                    columns++;
                }
                break;
                
                // Columns have precedence over rows, if items extend past number of columns
                // rows will be increased to account for the additional items.
            default:
                // Items do not fill columns, reduce the columns to fit
                if (exactColumnsFloat < (float)columns) {
                    columns = (int) exactColumns;
                }
                // Items exceed columns, expand rows
                else if (exactColumnsFloat > (float)columns) {
                    rows = [items count] / columns;
                    exactRowsFloat = (float)[items count] / (float)columns;
                    if (exactRowsFloat > (float) rows) {
                        rows++;
                    }
                    exactColumnsFloat = (float) [items count] / (float)rows;
                    if (exactColumnsFloat <= (float)columns) {
                        columns = (int) exactColumnsFloat;
                    }
                }
                // Extend rows once more if the division is greater than a whole number
                if (exactRowsFloat > (float) rows) {
                    rows++;
                }
                break;
        }
        // Tell the matrix how many rows and columns it has
        [controlMatrix renewRows:rows columns:columns];
    }
}

- (void) setIcon
{
    if (icon != nil) {
        NSImage *image = [[[NSImage alloc] initWithData:nil] autorelease];
        CDOptions *options = [self options];
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
        float iconWidth = 48.0;
        float iconHeight = 48.0;
        NSSize resize = NSMakeSize(iconWidth, iconHeight);
        
        // Add default controls
        if (expandingLabel != nil && ![controlItems containsObject:expandingLabel]) {
            [controlItems addObject:expandingLabel];
        }
        if (controlMatrix != nil && ![controlItems containsObject:controlMatrix]) {
            [controlItems addObject:controlMatrix];
        }
        
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
            [self setIconWithImage:image withSize:resize withControls:controlItems];
        }
        // Control shouldn't display icon, remove it and resize.
        else {
            [self setIconWithImage:nil withSize:resize withControls:controlItems];
        }
    }
}
- (void) setIconWithImage:(NSImage *)anImage withSize:(NSSize)aSize
{
    if (anImage != nil) {
        NSSize originalSize = [anImage size];
        // Resize Icon
        if (originalSize.width != aSize.width || originalSize.height != aSize.height) {
            NSImage *resizedImage = [[[NSImage alloc] initWithSize: aSize] autorelease];
            [resizedImage lockFocus];
            [anImage drawInRect: NSMakeRect(0, 0, aSize.width, aSize.height) fromRect: NSMakeRect(0, 0, originalSize.width, originalSize.height) operation: NSCompositeSourceOver fraction: 1.0];
            [resizedImage unlockFocus];
            [icon setImage:resizedImage];
        }
        else {
            [icon setImage:anImage];
        }
        // Resize icon frame
        NSRect iconFrame = [icon frame];
        float iconHeightDiff = aSize.height - iconFrame.size.height;
        NSRect newIconFrame = NSMakeRect(iconFrame.origin.x, iconFrame.origin.y - iconHeightDiff, aSize.width, aSize.height);
        [icon setFrame:newIconFrame];
    }
}

- (void) setIconWithImage:(NSImage *)anImage withSize:(NSSize)aSize withControls:(NSArray *)anArray
{
    // Icon has image
    if (anImage != nil) {
        // Set current icon frame
        NSRect iconFrame = [icon frame];

        // Set image and resize icon
        [self setIconWithImage:anImage withSize:aSize];
        
        float iconWidthDiff = [icon frame].size.width - iconFrame.size.width;
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
        NSRect iconFrame = [icon frame];
        // Remove the icon
        [icon removeFromSuperview];
        icon = nil;
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

- (void) setTitle:(NSString*)aTitle forButton:(NSButton*)aButton
{
	if (aTitle && ![aTitle isEqualToString:@""]) {
		[aButton setTitle:aTitle];
		float maxX = NSMaxX([aButton frame]);
		[aButton sizeToFit];
		NSRect r = [aButton frame];
		r.size.width += 12.0f;
		if (maxX > 100.0f) { // button is in the right side
			r.origin.x = maxX - NSWidth(r);
		}
		[aButton setFrame:r];
		[aButton setEnabled:YES];
		[aButton setHidden:NO];
	} else {
		[aButton setEnabled:NO];
		[aButton setHidden:YES];
	}
}

// This resizes
- (void) setTitleButtonsLabel:(NSString *)labelText
{

	[self setTitle];
    [self setIcon];
	[self setButtons];
	if ([self windowNeedsResize:panel]) {
		[panel setContentSize:[self findNewSizeForWindow:panel]];
	}
    
    [self setLabel:labelText];
    
	if ([self windowNeedsResize:panel]) {
		[panel setContentSize:[self findNewSizeForWindow:panel]];
	}
    
    if (controlMatrix != nil) {
        // Remember old controlMatrix size
        NSRect m = [controlMatrix frame];
        float oldHeight = m.size.height;
        float oldWidth = m.size.width;
        
        // Call the control
        [self setControl:self];

        // Resize
        [controlMatrix sizeToCells];
        [[controlMatrix superview] setNeedsDisplay:YES];
        m = [controlMatrix frame];

        // Set panel's new width and height
        NSSize p = [[panel contentView] frame].size;
        p.height += m.size.height - oldHeight;
        p.width += m.size.width - oldWidth;
        [panel setContentSize:p];
        [panel center];
        
        if ([self windowNeedsResize:panel]) {
            [panel setContentSize:[self findNewSizeForWindow:panel]];
        }
    }

}

- (void) setButtons
{
	unsigned i;
	struct { NSString *key; NSButton *button; } const buttons[] = {
		{ @"button1", button1 },
		{ @"button2", button2 },
		{ @"button3", button3 }
	};

	CDOptions *options = [self options];

	float minWidth = 2 * 20.0f; // margin
	for (i = 0; i != sizeof(buttons)/sizeof(buttons[0]); i++) {
		[self setTitle:[options optValue:buttons[i].key] forButton:buttons[i].button];
        if ([[self options] hasOpt:@"cancel"]) {
            if ([[options optValue:@"cancel"] isEqualToString:buttons[i].key]) {
                [buttons[i].button setKeyEquivalent:@"\e"];
            }
        }
        else {
            if ([[options optValue:buttons[i].key] isEqualToString:@"Cancel"]) {
                [buttons[i].button setKeyEquivalent:@"\e"];
            }
        }
		if ([buttons[i].button isHidden] == NO) {
			minWidth += NSWidth([buttons[i].button frame]);
		}
	}

	// move button2 so that it aligns with button1
	NSRect r = [button2 frame];
	r.origin.x = NSMinX([button1 frame]) - NSWidth(r);
	[button2 setFrame:r];

	// move button3 to the left
	r = [button3 frame];
	r.origin.x = 14;
	[button3 setFrame:r];

	// ensure that the buttons never gets clipped
	NSSize s = [panel contentMinSize];
	s.width = minWidth;
	[panel setContentMinSize:s];
}

// Should be called after setButtons, and before resize
- (void) setLabel:(NSString *)labelText
{
	if (labelText != nil) {
		[expandingLabel setStringValue:labelText];
	} else {
		[expandingLabel setStringValue:@""];
	}
    
    NSRect labelRect = [expandingLabel frame];
    NSTextStorage *textStorage = [[[NSTextStorage alloc] initWithString: labelText]autorelease];
    NSTextContainer *textContainer = [[[NSTextContainer alloc] initWithContainerSize:NSMakeSize(labelRect.size.width, FLT_MAX)] autorelease];
    NSLayoutManager *layoutManager = [[[NSLayoutManager alloc]init] autorelease];
    [layoutManager addTextContainer: textContainer];
    [textStorage addLayoutManager: layoutManager];
    [layoutManager glyphRangeForTextContainer:textContainer];
    
    float labelNewHeight = [layoutManager usedRectForTextContainer:textContainer].size.height;
    float labelHeightDiff = labelNewHeight - labelRect.size.height;
    
    // Set label's new height
    NSRect l = NSMakeRect(labelRect.origin.x, labelRect.origin.y - labelHeightDiff, labelRect.size.width, labelNewHeight);
    [expandingLabel setFrame: l];
    
    // Set panel's new width and height
    NSSize p = [[panel contentView] frame].size;
	p.height += labelHeightDiff;
	[panel setContentSize:p];
    [panel center];
}

- (void) setTitle
{
	CDOptions *options = [self options];
	// set title
	if ([options optValue:@"title"] != nil) {
		[panel setTitle:[options optValue:@"title"]];
	}
}

- (void) setTimeout
{
	CDOptions *options = [self options];
	if ([options hasOpt:@"timeout"]) {
		NSTimeInterval t;
		if ([[NSScanner scannerWithString:[options optValue:@"timeout"]] scanDouble:&t]) {
			[self performSelector:@selector(timeout:) withObject:panel afterDelay:t];
		} else {
			if ([options hasOpt:@"debug"]) {
				[CDControl debug:@"Could not parse the timeout option"];
			}
		}
	}
}

// TODO - this needs to return a value properly
- (IBAction) timeout:(id)sender
{
	rv = 0;
	// For some reason, this doesn't return the run loop until the mouse is moved over the window or something. I think it has something to do with threading.
	[NSApp stop:self];
	// So termination is needed or it won't return
	// But since that doesn't return, we have to put the exit stuff here.
	// Bah.
	NSFileHandle *fh = [NSFileHandle fileHandleWithStandardOutput];
	if ([[self options] hasOpt:@"string-output"]) {
		if (fh) {
			[fh writeData:[@"timeout" dataUsingEncoding:NSUTF8StringEncoding]];
		}
	} else {
		if (fh) {
			[fh writeData:[@"0" dataUsingEncoding:NSUTF8StringEncoding]];
		}
	}
	if (![[self options] hasOpt:@"no-newline"]) {
		[fh writeData:[@"\n" dataUsingEncoding:NSUTF8StringEncoding]];
	}
	[NSApp terminate:nil];
}

- (IBAction) button1Pressed:(id)sender
{
	rv = 1;
	[NSApp stop:nil];
	return;
}

- (IBAction) button2Pressed:(id)sender
{
	rv = 2;
	[NSApp stop:nil];
	return;
}

- (IBAction) button3Pressed:(id)sender
{
	rv = 3;
	[NSApp stop:nil];
	return;
}

@end
