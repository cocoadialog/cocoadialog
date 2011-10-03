//
//  CDGrowl.m
//  CocoaDialog
//
//  Created by Mark Carver on 10/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "CDGrowlControl.h"

@implementation CDGrowlControl

- (NSDictionary *) availableKeys
{
	NSNumber *vOne = [NSNumber numberWithInt:CDOptionsOneValue];
//	NSNumber *vNone = [NSNumber numberWithInt:CDOptionsNoValues];
	NSNumber *vMul = [NSNumber numberWithInt:CDOptionsMultipleValues];
    
	return [NSDictionary dictionaryWithObjectsAndKeys:
            vOne, @"priority",
            vMul, @"priorities",
            nil];
}

- (void)addNotificationWithTitle:(NSString *)title description:(NSString *)description icon:(NSImage *)icon priority:(NSNumber *)priority sticky:(BOOL)sticky clickPath:(NSString *)clickPath clickArg:(NSString *)clickArg
{
    NSMutableDictionary * notification = [NSMutableDictionary dictionary];
    [notification setObject:title forKey:@"title"];
    [notification setObject:description forKey:@"description"];
    NSData *iconData = [NSData dataWithData:[icon TIFFRepresentation]];
    if (iconData == nil) {
        iconData = [NSData data];
    }
    [notification setObject:iconData forKey:@"iconData"];
    if (priority == nil) {
        priority = 0;
    }
    [notification setObject:priority forKey:@"priority"];
    [notification setObject:[NSNumber numberWithBool:sticky] forKey:@"sticky"];
    if (clickPath == nil) {
        clickPath = @"";
    }
    [notification setObject:clickPath forKey:@"clickPath"];
    if (clickArg == nil) {
        clickArg = @"";
    }
    [notification setObject:clickArg forKey:@"clickArg"];
    [notifications addObject:notification];
}

- (NSArray *) runControlFromOptions:(CDOptions *)options
{
    [GrowlApplicationBridge setGrowlDelegate:self];
    
    NSString *clickPath = @"";
    if ([options hasOpt:@"click-path"]) {
        clickPath = [options optValue:@"click-path"];
    }
    
    NSString *clickArg = @"";
    if ([options hasOpt:@"click-arg"]) {
        clickArg = [options optValue:@"click-arg"];
    }
    
	NSArray *titles = [options optValues:@"titles"];
    NSArray *descriptions = [options optValues:@"descriptions"];
    
    NSNumber * priority = [NSNumber numberWithInt:0];
    if ([options hasOpt:@"priority"]) {
        priority = [NSNumber numberWithInt:[[options optValue:@"priority"] intValue]];
    }
    BOOL sticky = [options hasOpt:@"sticky"];
    // Multiple notifications
	if (descriptions != nil && [descriptions count] && titles != nil && [titles count] && [titles count] == [descriptions count]) {
		NSArray *givenIconImages = [self notificationIcons];
		NSImage *fallbackIcon = nil;
		NSMutableArray *icons = nil;
		unsigned i;
		// See what icons we got at the command line, or set a fallback
		// icon to use for all bubbles
		if (givenIconImages == nil) {
			fallbackIcon = [self notificationIcon];
		} else {
			icons = [NSMutableArray arrayWithArray:givenIconImages];
		}
		// If we were given less icons than we have bubbles, use a default
		// for any extra bubbles
		if ([icons count] < [descriptions count]) {
			NSImage *defaultIcon = [self notificationIcon];
			unsigned long numToAdd = [descriptions count] - [icons count];
			for (i = 0; i < numToAdd; i++) {
				[icons addObject:defaultIcon];
			}
		}
        NSArray * priorities = [NSArray arrayWithArray:[options optValues:@"priorities"]];
        NSArray * clickPaths = [NSArray arrayWithArray:[options optValues:@"click-paths"]];
        NSArray * clickArgs = [NSArray arrayWithArray:[options optValues:@"click-args"]];
		// Create the bubbles
		for (i = 0; i < [descriptions count]; i++) {
			NSImage *icon = fallbackIcon == nil ? (NSImage *)[icons objectAtIndex:i] : fallbackIcon;
            [self addNotificationWithTitle:[titles objectAtIndex:i]
                               description:[descriptions objectAtIndex:i]
                                      icon:icon
                                  priority:[priorities count] ? [priorities objectAtIndex:i] : priority
                                    sticky:sticky
                                 clickPath:[clickPaths count] ? [clickPaths objectAtIndex:i] : clickPath
                                  clickArg:[clickArgs count] ? [clickArgs objectAtIndex:i] : clickArg
             ];

		}
    }
    // Single notification
    else if ([options hasOpt:@"title"] && [options hasOpt:@"description"]) {
        NSImage * icon = [self notificationIcon];
        [self addNotificationWithTitle:[options optValue:@"title"]
                           description:[options optValue:@"description"]
                                  icon:icon
                              priority:priority
                                sticky:sticky
                             clickPath:clickPath
                              clickArg:clickArg
         ];
    }
    // Error
    else {
        if ([options hasOpt:@"debug"]) {
            [self debug:@"You must specify either --title and --description, or --titles and --descriptions (with the same number of args)"];
        }
        return [NSArray array];
    }
    
    NSEnumerator *en = [notifications objectEnumerator];
    id obj;
    while (obj = [en nextObject]) {
        NSDictionary * notification = [NSDictionary dictionaryWithDictionary:obj];
        [GrowlApplicationBridge
         notifyWithTitle:[notification objectForKey:@"title"]
         description:[notification objectForKey:@"description"]
         notificationName:@"General Notification"
         iconData:[notification objectForKey:@"iconData"]
         priority:[[notification objectForKey:@"priority"] intValue]
         isSticky:[[notification objectForKey:@"sticky"] boolValue]
         clickContext:[NSString stringWithFormat:@"%d", activeNotifications]];
        activeNotifications++;
    }
	return [NSArray array];
}

- (void) debug:(NSString *)message
{
    [GrowlApplicationBridge
     notifyWithTitle:@"cocoaDialog Debug"
     description:message
     notificationName:@"General Notification"
     iconData:[[self getIconWithName:@"caution"] TIFFRepresentation]
     priority:2
     isSticky:YES
     clickContext:nil];
}

#pragma mark - Growl Integration
// Register Growl Notifications
- (NSDictionary *) registrationDictionaryForGrowl
{
    NSArray * notificationsForGrowl = [NSArray arrayWithObjects:@"General Notification", nil];
    return [NSDictionary dictionaryWithObjectsAndKeys:
                                 [NSNumber numberWithInt:1], @"TicketVersion",
                                 notificationsForGrowl, @"AllNotifications",
                                 notificationsForGrowl, @"DefaultNotifications",
                                 nil];
}

- (NSArray *) parseTextForArguments:(NSString *)string
{
    NSMutableArray* masterArray = [NSMutableArray arrayWithArray:nil];
    // Make quotes on their own lines
    string = [string stringByReplacingOccurrencesOfString:@"\"" withString:[NSString stringWithFormat: @"\n\"\n"]];
    NSArray * quotedArray = [string componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    BOOL inQuote = NO;
    NSEnumerator *en = [quotedArray objectEnumerator];
    id arg;
    while (arg = [en nextObject]) {
        NSMutableArray* spacedArray = [NSMutableArray arrayWithArray:nil];
        // Determine if we're in a quote
        if ([[arg substringToIndex:1] isEqualToString:@"\""]) {
            if (inQuote) {
                inQuote = NO;
            }
            else {
                inQuote = YES;
            }
            continue;
        }
        if (![arg isEqualToString:@""] || arg != nil) {
            if (inQuote) {
                [spacedArray addObject:arg];
            }
            else {
                // Trim any spaces or newlines from the beginning or end
                arg = [arg stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                [spacedArray addObjectsFromArray: [arg componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
            }
            [masterArray addObjectsFromArray:spacedArray];
        }
    }
    return masterArray;
}

- (void) growlNotificationWasClicked:(id)clickContext
{
    NSDictionary * notification = [NSDictionary dictionaryWithDictionary:[notifications objectAtIndex:[clickContext intValue]]];
    NSString * clickPath = [notification objectForKey:@"clickPath"];
    if ([clickPath caseInsensitiveCompare:@"cocoaDialog"] == NSOrderedSame) {
        clickPath = [[[NSProcessInfo processInfo] arguments] objectAtIndex:0];
    }
    NSArray *arguments = nil;
    if (![[notification objectForKey:@"clickArg"] isEqualToString:@""]) {
        arguments = [NSArray arrayWithArray:[self parseTextForArguments:[notification objectForKey:@"clickArg"]]];
    }
    NSMutableArray * clickArg = [NSMutableArray arrayWithArray:arguments];
    // Check to ensure the file exists before launching the command
    if (![clickPath isEqualToString:@""] && [[NSFileManager defaultManager] fileExistsAtPath:clickPath]) {
        // Relaunch cocoaDialog with the new runMode
        NSString *launcherSource = [[NSBundle bundleForClass:[SUUpdater class]]  pathForResource:@"relaunch" ofType:@""];
        NSString *launcherTarget = [NSTemporaryDirectory() stringByAppendingPathComponent:[launcherSource lastPathComponent]];
        NSString *pid = [NSString stringWithFormat:@"%d", [[NSProcessInfo processInfo] processIdentifier]];
        [clickArg insertObject:pid atIndex:0];
        [clickArg insertObject:clickPath atIndex:0];
        [clickArg insertObject:launcherTarget atIndex:0];
#if defined __ppc__
        [clickArg insertObject:@"-ppc" atIndex:0];
#elif defined __ppc64__
        [clickArg insertObject:@"-ppc64" atIndex:0];
#elif defined __i386__
        [clickArg insertObject:@"-i386" atIndex:0];
#elif defined __x86_64__
        [clickArg insertObject:@"-x86_64" atIndex:0];
#endif
        [[NSFileManager defaultManager] removeItemAtPath:launcherTarget error:NULL];
        [[NSFileManager defaultManager] copyItemAtPath:launcherSource toPath:launcherTarget error:NULL];
        NSTask *task = [[[NSTask alloc] init] autorelease];
        // Output must be silenced to not hang this process
        [task setStandardError:[NSPipe pipe]];
        [task setStandardOutput:[NSPipe pipe]];
        [task setLaunchPath:@"/usr/bin/arch"];
        [task setArguments:clickArg];
        [task launch];
    }
    activeNotifications--;
    // Terminate cocoaDialog once all the notifications for this dialog are through
    if (activeNotifications <= 0) {
        hasFinished = YES;
        [self dealloc];
        [NSApp replyToApplicationShouldTerminate: YES];
    }
}

- (void) growlNotificationTimedOut:(id)clickContext
{
    activeNotifications--;
    if (activeNotifications <= 0) {
        hasFinished = YES;
        [NSApp replyToApplicationShouldTerminate: YES];
    }
}

@end
