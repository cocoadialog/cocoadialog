

#import "CDGrowlControl.h"

@implementation CDGrowlControl

- (NSDictionary*) availableKeys
{
	return @{@"priority":  @CDOptionsOneValue, @"priorities": @CDOptionsMultipleValues};
}

- (instancetype)initWithOptions:(CDOptions*)opts {

	self = [super initWithOptions:opts];

  NSBundle *growlBundle = [NSBundle bundleWithPath:[NSBundle.mainBundle.privateFrameworksPath stringByAppendingPathComponent:@"Growl.framework"]];
    if (growlBundle && [growlBundle load]) {
        // Register ourselves as a Growl delegate
        [GrowlApplicationBridge setGrowlDelegate:self];
    } else {
        [self debug:@"Could not load Growl.framework"];
    }
	return self;
}

- (BOOL) validateOptions {
    BOOL pass = YES;
    if ([self.options hasOpt:@"title"]) {
        if (![self.options hasOpt:@"description"]) {
            pass = NO;
        }
    }
    else if ([self.options hasOpt:@"titles"]) {
        if (![self.options hasOpt:@"descriptions"]) {
            pass = NO;
        }
    }
    else {
        pass = NO;
    }
    if (!pass && [self.options hasOpt:@"debug"]) {
        [self debug:@"You must specify either --title and --description, or --titles and --descriptions (with the same number of args)"];
    }
    return pass;
}

- (void) createControl {
    [self.panel setPanelEmpty];

    NSString *clickPath = @"";
    if ([self.options hasOpt:@"click-path"]) {
        clickPath = [self.options optValue:@"click-path"];
    }
    
    NSString *clickArg = @"";
    if ([self.options hasOpt:@"click-arg"]) {
        clickArg = [self.options optValue:@"click-arg"];
    }
    
	NSArray *titles = [self.options optValues:@"titles"];
    NSArray *descriptions = [self.options optValues:@"descriptions"];
    
    NSNumber * priority = @0;
    if ([self.options hasOpt:@"priority"]) {
        priority = @([[self.options optValue:@"priority"] intValue]);
    }
    BOOL sticky = [self.options hasOpt:@"sticky"];
    // Multiple notifications
	if (descriptions != nil && [descriptions count] && titles != nil && [titles count] && [titles count] == [descriptions count]) {
		NSArray *givenIconImages = [self notificationIcons];
		NSImage *fallbackIcon = nil;
		NSMutableArray *icons = nil;
		unsigned i;
		// See what icons we got at the command line, or set a fallback icon to use for all bubbles
		if (givenIconImages == nil) fallbackIcon = self.icon.iconWithDefault;
		else
			icons = [NSMutableArray arrayWithArray:givenIconImages];

		// If we were given less icons than we have bubbles, use a default for any extra bubbles
		if (icons.count < descriptions.count) {
			NSImage *defaultIcon = self.icon.iconWithDefault;
			unsigned long numToAdd = [descriptions count] - [icons count];
			for (i = 0; i < numToAdd; i++) {
				[icons addObject:defaultIcon];
			}
		}
        NSArray * priorities = [NSArray arrayWithArray:[self.options optValues:@"priorities"]];
        NSArray * clickPaths = [NSArray arrayWithArray:[self.options optValues:@"click-paths"]];
        NSArray * clickArgs = [NSArray arrayWithArray:[self.options optValues:@"click-args"]];
		// Create the bubbles
		for (i = 0; i < [descriptions count]; i++) {
			NSImage *_icon = fallbackIcon == nil ? (NSImage *)icons[i] : fallbackIcon;
            [self addNotificationWithTitle:titles[i]
                               description:descriptions[i]
                                      icon:_icon
                                  priority:[priorities count] ? priorities[i] : priority
                                    sticky:sticky
                                 clickPath:[clickPaths count] ? clickPaths[i] : clickPath
                                  clickArg:[clickArgs count] ? clickArgs[i] : clickArg
             ];

		}
    }
    // Single notification
    else if ([self.options hasOpt:@"title"] && [self.options hasOpt:@"description"]) {
        NSImage * _icon = self.icon.iconWithDefault;
        [self addNotificationWithTitle:[self.options optValue:@"title"]
                           description:[self.options optValue:@"description"]
                                  icon:_icon
                              priority:priority
                                sticky:sticky
                             clickPath:clickPath
                              clickArg:clickArg
         ];
    }
    
    NSEnumerator *en = [notifications objectEnumerator];
    id obj;
    while (obj = [en nextObject]) {
        NSDictionary * notification = [NSDictionary dictionaryWithDictionary:obj];
        [GrowlApplicationBridge
         notifyWithTitle:notification[@"title"]
         description:notification[@"description"]
         notificationName:@"General Notification"
         iconData:notification[@"iconData"]
         priority:[notification[@"priority"] intValue]
         isSticky:[notification[@"sticky"] boolValue]
         clickContext:[NSString stringWithFormat:@"%d", activeNotifications]];
        activeNotifications++;
    }
}

- (void) debug:(NSString*)message
{
    [GrowlApplicationBridge
     notifyWithTitle:@"cocoaDialog Debug"
     description:message
     notificationName:@"General Notification"
     iconData:[self.icon iconFromName:@"caution"].TIFFRepresentation
     priority:2
     isSticky:YES
     clickContext:nil];
}

#pragma mark - Growl Integration
// Register Growl Notifications
- (NSDictionary*) registrationDictionaryForGrowl
{
    NSArray * notificationsForGrowl = @[@"General Notification"];
    return @{@"TicketVersion": @1,
                                 @"AllNotifications": notificationsForGrowl,
                                 @"DefaultNotifications": notificationsForGrowl};
}

- (void) growlNotificationWasClicked:(id)clickContext
{
    [self notificationWasClicked:clickContext];
    activeNotifications--;
    // Terminate cocoaDialog once all the notifications are complete
    if (activeNotifications <= 0) {
        [self stopControl];
    }
}

- (void) growlNotificationTimedOut:(id)clickContext
{
    activeNotifications--;
    if (activeNotifications <= 0) {
        [self stopControl];
    }
}

@end
