// CDFile.h
// cocoadialog
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.

@class CDFile;

#import "CDDialog.h"

@interface CDFile : CDDialog <NSOpenSavePanelDelegate>

@property (strong)      NSString*           directory;
@property (strong)      NSArray*            extensions;
@property (strong)      NSString*           file;
@property (strong)      NSFileManager*      fileManager;
@property (strong)      NSSavePanel*        savePanel;

- (void) createSavePanel;

- (BOOL) isExtensionAllowed:(NSString *)filename;

@end
