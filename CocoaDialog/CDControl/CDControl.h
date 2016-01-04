
#import "CDCommon.h"
#import "CDOptions.h"
#import "CDPanel.h"
#import "CDIcon.h"

/*! All controls must include the methods @c createControl and @c validateOptions.
    This should look at the options and display a control (dialog with message, inputbox, or whatever) to the user,
    get any necessary info from it, and return an NSArray of NSString objects.
    Each NSString is printed to stdout on its own line.
    @return an empty NSArray if there is no output to be printed, or nil on error.
 */
@protocol CDControl

#pragma mark - Internal Control Methods

@property (readonly, copy) NSString *controlNib;

@optional

- (void) createControl;

- (CDOptions*) controlOptionsFromArgs:(NSArray*)args;
- (CDOptions*) controlOptionsFromArgs:(NSArray*)args withGlobalKeys:(NSDictionary*)globalKeys;

@property (readonly) BOOL validateOptions;

#pragma mark - Subclassable Control Methods -

@property (readonly, copy) NSDictionary

* availableKeys,        // must be sub-classed if you want options local to your control
* depreciatedKeys,      // must be sub-classed if you want specify local depreciated keys for your control
* globalAvailableKeys;  // must be overridden if you want local global options for your control

// This must be sub-classed if you want validate local options for your control
- (BOOL) validateControl:(CDOptions*)options;

// Subclasses should implement to use in testing.
- (BOOL) testControl;

@end

/*! CDControl provides a runControl method.
 It invokes runControlFromOptions: with the options specified in initWithOptions:
 @note You must override runControlFromOptions.
 */
@interface CDControl : CDCommon <CDControl>


@property (readonly, copy) NSString *controlExitStatusString;
@property (readonly, copy) NSMutableArray *controlItems, *controlReturnValues;
@property (readonly) int controlExitStatus;
@property CGFloat timeout;

// Outlets
@property IBOutlet NSPanel     * controlPanel;
@property IBOutlet NSImageView * controlIcon;
@property IBOutlet NSTextField * timeoutLabel;

// Classes
@property  CDIcon * icon;
@property CDPanel * panel;

+ (void) printHelpTo:(NSFileHandle*)fh;
+ (NSDictionary*) availableControls;

- (void) createTimer;
- (NSString*) formatSecondsForString:(NSInteger)timeInSeconds;
- (BOOL) loadControlNib:(NSString*)nib;
- (void) processTimer;
- (void) runControl;
- (void) setTimeout;
- (void) setTimeoutLabel;
- (void) stopControl;
- (void) stopTimer;

@end
