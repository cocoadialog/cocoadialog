// CDProgressbar.h
// cocoadialog
//
// Copyright (c) 2004-2017 Mark A. Stratman <mark@sporkstorms.org>, Mark Carver <mark.carver@me.com>.
// All rights reserved.
// Licensed under GPL-2.

#import <sys/select.h>
#import "CDDialog.h"
#import "CDProgressbarView.h"
#import "CDProgressbarInputHandler.h"

@protocol CDProgressbarProtocol <NSObject>

- (void) progressUpdate:(NSDictionary *)data;
- (void) progressFinished;

@end

@interface CDProgressbar : CDDialog <NSWindowDelegate, CDProgressbarProtocol>

# pragma mark - Properties
@property (strong)                   CDProgressbarView           *progressbar;
@property (strong)       IBOutlet    NSButton                    *stopButton;
@property (strong)                   NSAlert                     *confirmationSheet;
@property (strong)                   NSArray <NSString *>        *labels;
@property (nonatomic)                           BOOL                        stopped;

# pragma mark - Public instance methods

-(void) alertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo;

# pragma mark - Actions

-(IBAction) stop:(id)sender;

@end
