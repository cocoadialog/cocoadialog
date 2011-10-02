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
//	NSNumber *vMul = [NSNumber numberWithInt:CDOptionsMultipleValues];
    
	return [[NSDictionary dictionaryWithObjectsAndKeys:
            vOne, @"priority",
            nil] autorelease];
}

// Even though implementing Growl is a new feature, the script could still be using old CDBubbleControl options
- (NSDictionary *) depreciatedKeys
{
	return [[NSDictionary dictionaryWithObjectsAndKeys:
            @"description", @"text",
            @"descriptions", @"texts",
            @"sticky", @"no-timeout",
            nil] autorelease];
}

- (NSArray *) runControlFromOptions:(CDOptions *)options
{
    [GrowlApplicationBridge setGrowlDelegate:self];
    
    notifications = [[[NSMutableArray alloc] init] autorelease];
    
	NSArray *titles = [options optValues:@"titles"];
    NSArray *descriptions = [options optValues:@"descriptions"];

    // Multiple notifications
	if (descriptions != nil && [descriptions count] && titles != nil && [titles count] && [titles count] == [descriptions count]) {
        
    }
    // Single notification
    else if ([options hasOpt:@"title"] && [options hasOpt:@"description"]) {
        int priority = 0;
        if ([options hasOpt:@"priority"]) {
            priority = [[options optValue:@"priority"] intValue];
        }
        NSData *iconData = [NSData data];
        if ([options hasOpt:@"icon-file"]) {
            iconData = [[[self getIconFromFile:[options optValue:@"icon-file"]] TIFFRepresentation] autorelease];
            
        } else if ([options hasOpt:@"icon"]) {
            iconData = [[[self getIconWithName:[options optValue:@"icon"]] TIFFRepresentation] autorelease];
        }
        id clickContext = nil;
        [notifications addObject:[[NSDictionary dictionaryWithObjectsAndKeys:
                                   [options optValue:@"title"],        @"title",
                                   [options optValue:@"description"],  @"description",
                                   iconData,                           @"iconData",
                                   priority,                           @"priority",
                                   [options hasOpt:@"sticky"],         @"sticky",
                                   clickContext,                       @"clickContext",
                                   nil] autorelease]];
    }
    // Error
    else {
        if ([options hasOpt:@"debug"]) {
            [self debug:@"You must specify either --title and --description, or --titles and --descriptions (with the same number of args)"];
        }
        return [NSArray array];
    }
    
    NSEnumerator *en = [[notifications objectEnumerator] autorelease];
    NSDictionary * notification = [[[NSDictionary alloc] init] autorelease];
    while (notification = [en nextObject]) {
        [GrowlApplicationBridge
         notifyWithTitle:[notification objectForKey:@"title"]
         description:[notification objectForKey:@"description"]
         notificationName:@"General Notification"
         iconData:[notification objectForKey:@"iconData"]
         priority:[[notification objectForKey:@"priority"] intValue]
         isSticky:[[notification objectForKey:@"sticky"] boolValue]
         clickContext:[notification objectForKey:@"clickContext"]];
    }

//	[NSApp run];
	return [NSArray array];
}

#pragma mark - Growl Integration
// Register Growl Notifications
- (NSDictionary *) registrationDictionaryForGrowl
{
    NSArray * notificationsForGrowl = [[[NSArray alloc] initWithObjects:@"General Notification", nil] autorelease];
    NSDictionary * growlDict = [[NSDictionary dictionaryWithObjectsAndKeys:
                                 [NSNumber numberWithInt:1], @"TicketVersion",
                                 notificationsForGrowl, @"AllNotifications",
                                 notificationsForGrowl, @"DefaultNotifications",
                                 nil] autorelease];
    return growlDict;
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


@end
