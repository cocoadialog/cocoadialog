// CDIcon.m
// cocoadialog
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.

#import "CDIcon.h"

@implementation CDIcon

+ (instancetype)sharedInstance {
  static CDIcon *sharedInstance;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedInstance = [[CDIcon alloc] init];
  });
  return sharedInstance;
}

- (instancetype)init {
  self = [super init];
  if (self) {
    _app = [CDApplication sharedApplication];
    _terminal = [CDTerminal sharedInstance];
    _template = [CDTemplate sharedInstance];
  }
  return self;
}

- (NSImage *)iconFromFile:(NSString *)file {
  NSImage *image = [[NSImage alloc] initWithContentsOfFile:file];
  if (image == nil) {
    self.terminal.warning(@"Could not return icon from specified file: %@.", file.doubleQuote, nil);
  }
  return image;
}

- (NSImage *)iconFromName:(NSString *)value {
  CDOptions *options = self.app.control.options;
  BOOL hasImage = NO;
  NSImage *image = [[NSImage alloc] init];
  NSString *bundle = options[@"icon-bundle"].stringValue;
  NSString *path = nil;

  // Set default bundle identifier
  if (bundle == nil) {
    // Application icon
    if ([value isEqualToStringCaseInsensitive:@"cocoadialog"]) {
      image = NSApp.applicationIconImage;
      hasImage = YES;
    }
      // User specific computer image
    else if ([value isEqualToStringCaseInsensitive:@"computer"]) {
      image = [NSImage imageNamed:NSImageNameComputer];
      hasImage = YES;
    }
      // Bundle Identifications
    else if ([value isEqualToStringCaseInsensitive:@"addressbook"]) {
      value = @"AppIcon";
      bundle = @"com.apple.AddressBook";
    }
    else if ([value isEqualToStringCaseInsensitive:@"airport"]) {
      value = @"AirPort";
      bundle = @"com.apple.AirPortBaseStationAgent";
    }
    else if ([value isEqualToStringCaseInsensitive:@"airport2"]) {
      value = @"AirPort";
      bundle = @"com.apple.wifi.diagnostics";
    }
    else if ([value isEqualToStringCaseInsensitive:@"archive"]) {
      value = @"bah";
      bundle = @"com.apple.archiveutility";
    }
    else if ([value isEqualToStringCaseInsensitive:@"bluetooth"]) {
      value = @"AppIcon";
      bundle = @"com.apple.BluetoothAudioAgent";
    }
    else if ([value isEqualToStringCaseInsensitive:@"application"]) {
      value = @"GenericApplicationIcon";
      path = @"/System/Library/CoreServices/CoreTypes.bundle";
    }
    else if ([value isEqualToStringCaseInsensitive:@"bonjour"] || [value isEqualToStringCaseInsensitive:@"atom"]) {
      value = @"Bonjour";
      path = @"/System/Library/CoreServices/CoreTypes.bundle";
    }
    else if ([value isEqualToStringCaseInsensitive:@"burn"] || [value isEqualToStringCaseInsensitive:@"hazard"]) {
      value = @"BurningIcon";
      path = @"/System/Library/CoreServices/CoreTypes.bundle";
    }
    else if ([value isEqualToStringCaseInsensitive:@"caution"]) {
      value = @"AlertCautionIcon";
      path = @"/System/Library/CoreServices/CoreTypes.bundle";
    }
    else if ([value isEqualToStringCaseInsensitive:@"document"]) {
      value = @"GenericDocumentIcon";
      path = @"/System/Library/CoreServices/CoreTypes.bundle";
    }
    else if ([value isEqualToStringCaseInsensitive:@"documents"]) {
      value = @"ToolbarDocumentsFolderIcon";
      path = @"/System/Library/CoreServices/CoreTypes.bundle";
    }
    else if ([value isEqualToStringCaseInsensitive:@"download"]) {
      value = @"ToolbarDownloadsFolderIcon";
      path = @"/System/Library/CoreServices/CoreTypes.bundle";
    }
    else if ([value isEqualToStringCaseInsensitive:@"eject"]) {
      value = @"EjectMediaIcon";
      path = @"/System/Library/CoreServices/CoreTypes.bundle";
    }
    else if ([value isEqualToStringCaseInsensitive:@"everyone"]) {
      value = @"Everyone";
      path = @"/System/Library/CoreServices/CoreTypes.bundle";
    }
    else if ([value isEqualToStringCaseInsensitive:@"executable"]) {
      value = @"ExecutableBinaryIcon";
      path = @"/System/Library/CoreServices/CoreTypes.bundle";
    }
    else if ([value isEqualToStringCaseInsensitive:@"favorite"] || [value isEqualToStringCaseInsensitive:@"heart"]) {
      value = @"ToolbarFavoritesIcon";
      path = @"/System/Library/CoreServices/CoreTypes.bundle";
    }
    else if ([value isEqualToStringCaseInsensitive:@"fileserver"]) {
      value = @"GenericFileServerIcon";
      path = @"/System/Library/CoreServices/CoreTypes.bundle";
    }
    else if ([value isEqualToStringCaseInsensitive:@"filevault"]) {
      value = @"FileVaultIcon";
      path = @"/System/Library/CoreServices/CoreTypes.bundle";
    }
    else if ([value isEqualToStringCaseInsensitive:@"finder"]) {
      value = @"FinderIcon";
      path = @"/System/Library/CoreServices/CoreTypes.bundle";
    }
    else if ([value isEqualToStringCaseInsensitive:@"folder"]) {
      value = @"GenericFolderIcon";
      path = @"/System/Library/CoreServices/CoreTypes.bundle";
    }
    else if ([value isEqualToStringCaseInsensitive:@"folderopen"]) {
      value = @"OpenFolderIcon";
      path = @"/System/Library/CoreServices/CoreTypes.bundle";
    }
    else if ([value isEqualToStringCaseInsensitive:@"foldersmart"]) {
      value = @"SmartFolderIcon";
      path = @"/System/Library/CoreServices/CoreTypes.bundle";
    }
    else if ([value isEqualToStringCaseInsensitive:@"gear"]) {
      value = @"ToolbarAdvanced";
      path = @"/System/Library/CoreServices/CoreTypes.bundle";
    }
    else if ([value isEqualToStringCaseInsensitive:@"general"]) {
      value = @"General";
      path = @"/System/Library/CoreServices/CoreTypes.bundle";
    }
    else if ([value isEqualToStringCaseInsensitive:@"globe"]) {
      value = @"BookmarkIcon";
      path = @"/System/Library/CoreServices/CoreTypes.bundle";
    }
    else if ([value isEqualToStringCaseInsensitive:@"group"]) {
      value = @"GroupIcon";
      path = @"/System/Library/CoreServices/CoreTypes.bundle";
    }
    else if ([value isEqualToStringCaseInsensitive:@"home"]) {
      value = @"HomeFolderIcon";
      path = @"/System/Library/CoreServices/CoreTypes.bundle";
    }
    else if ([value isEqualToStringCaseInsensitive:@"info"]) {
      value = @"ToolbarInfo";
      path = @"/System/Library/CoreServices/CoreTypes.bundle";
    }
    else if ([value isEqualToStringCaseInsensitive:@"ipod"]) {
      value = @"com.apple.ipod-touch-4";
      path = @"/System/Library/CoreServices/CoreTypes.bundle";
    }
    else if ([value isEqualToStringCaseInsensitive:@"movie"]) {
      value = @"ToolbarMovieFolderIcon";
      path = @"/System/Library/CoreServices/CoreTypes.bundle";
    }
    else if ([value isEqualToStringCaseInsensitive:@"music"]) {
      value = @"ToolbarMusicFolderIcon";
      path = @"/System/Library/CoreServices/CoreTypes.bundle";
    }
    else if ([value isEqualToStringCaseInsensitive:@"network"]) {
      value = @"GenericNetworkIcon";
      path = @"/System/Library/CoreServices/CoreTypes.bundle";
    }
    else if ([value isEqualToStringCaseInsensitive:@"notice"]) {
      value = @"AlertNoteIcon";
      path = @"/System/Library/CoreServices/CoreTypes.bundle";
    }
    else if ([value isEqualToStringCaseInsensitive:@"stop"] || [value isEqualToStringCaseInsensitive:@"x"]) {
      value = @"AlertStopIcon";
      path = @"/System/Library/CoreServices/CoreTypes.bundle";
    }
    else if ([value isEqualToStringCaseInsensitive:@"sync"]) {
      value = @"Sync";
      path = @"/System/Library/CoreServices/CoreTypes.bundle";
    }
    else if ([value isEqualToStringCaseInsensitive:@"trash"]) {
      value = @"TrashIcon";
      path = @"/System/Library/CoreServices/CoreTypes.bundle";
    }
    else if ([value isEqualToStringCaseInsensitive:@"trashfull"]) {
      value = @"FullTrashIcon";
      path = @"/System/Library/CoreServices/CoreTypes.bundle";
    }
    else if ([value isEqualToStringCaseInsensitive:@"url"]) {
      value = @"GenericURLIcon";
      path = @"/System/Library/CoreServices/CoreTypes.bundle";
    }
    else if ([value isEqualToStringCaseInsensitive:@"user"] || [value isEqualToStringCaseInsensitive:@"person"]) {
      value = @"UserIcon";
      path = @"/System/Library/CoreServices/CoreTypes.bundle";
    }
    else if ([value isEqualToStringCaseInsensitive:@"utilities"]) {
      value = @"ToolbarUtilitiesFolderIcon";
      path = @"/System/Library/CoreServices/CoreTypes.bundle";
    }
    else if ([value isEqualToStringCaseInsensitive:@"dashboard"]) {
      value = @"Dashboard";
      bundle = @"com.apple.dashboard.installer";
    }
    else if ([value isEqualToStringCaseInsensitive:@"dock"]) {
      value = @"Dock";
      bundle = @"com.apple.dock";
    }
    else if ([value isEqualToStringCaseInsensitive:@"widget"]) {
      value = @"widget";
      bundle = @"com.apple.dock";
    }
    else if ([value isEqualToStringCaseInsensitive:@"help"]) {
      value = @"HelpViewer";
      bundle = @"com.apple.helpviewer";
    }
    else if ([value isEqualToStringCaseInsensitive:@"installer"]) {
      value = @"Installer";
      bundle = @"com.apple.installer";
    }
    else if ([value isEqualToStringCaseInsensitive:@"package"]) {
      value = @"package";
      bundle = @"com.apple.installer";
    }
    else if ([value isEqualToStringCaseInsensitive:@"firewire"]) {
      value = @"FireWireHD";
      bundle = @"com.apple.iokit.IOSCSIArchitectureModelFamily";
      path = @"/System/Library/Extensions/IOSCSIArchitectureModelFamily.kext";
    }
    else if ([value isEqualToStringCaseInsensitive:@"usb"]) {
      value = @"USBHD";
      bundle = @"com.apple.iokit.IOSCSIArchitectureModelFamily";
      path = @"/System/Library/Extensions/IOSCSIArchitectureModelFamily.kext";
    }
    else if ([value isEqualToStringCaseInsensitive:@"cd"]) {
      value = @"CD";
      bundle = @"com.apple.ODSAgent";
    }
    else if ([value isEqualToStringCaseInsensitive:@"sound"]) {
      value = @"SoundPref";
      path = @"/System/Library/PreferencePanes/Sound.prefPane";
    }
    else if ([value isEqualToStringCaseInsensitive:@"printer"]) {
      value = @"Printer";
      bundle = @"com.apple.print.PrintCenter";
    }
    else if ([value isEqualToStringCaseInsensitive:@"screenshare"]) {
      value = @"ScreenSharing";
      bundle = @"com.apple.ScreenSharing";
    }
    else if ([value isEqualToStringCaseInsensitive:@"security"]) {
      value = @"Security";
      bundle = @"com.apple.securityagent";
    }
    else if ([value isEqualToStringCaseInsensitive:@"update"]) {
      value = @"SoftwareUpdate";
      bundle = @"com.apple.SoftwareUpdate";
    }
    else if ([value isEqualToStringCaseInsensitive:@"search"] || [value isEqualToStringCaseInsensitive:@"find"]) {
      value = @"Spotlight";
      path = @"/System/Library/CoreServices/Search.bundle";
    }
    else if ([value isEqualToStringCaseInsensitive:@"preferences"]) {
      value = @"PrefApp";
      bundle = @"com.apple.systempreferences";
    }
  }

  // Process bundle image path only if image has not already been set from above
  if (!hasImage) {
    if (bundle != nil || path != nil) {
      NSString *fileName = nil;
      if (path == nil) {
        NSWorkspace *workspace = [NSWorkspace sharedWorkspace];
        fileName = [[NSBundle bundleWithPath:[workspace absolutePathForAppBundleWithIdentifier:bundle]] pathForResource:value ofType:options[@"icon-type"].stringValue];
      }
      else {
        fileName = [[NSBundle bundleWithPath:path] pathForResource:value ofType:options[@"icon-type"].stringValue];
      }
      if (fileName != nil) {
        image = [[NSImage alloc] initWithContentsOfFile:fileName];
        if (image == nil) {
          self.terminal.warning(@"Could not retrieve image from specified icon file %@.", fileName.doubleQuote, nil);
        }
      }
      else {
        self.terminal.warning(@"Cannot find icon %@ in bundle %@.", value.doubleQuote, bundle.doubleQuote, nil);
      }
    }
    else {
      self.terminal.warning(@"Unknown icon %@. No --icon-bundle specified.", value.doubleQuote, nil);
    }
  }
  return image;
}

@end
