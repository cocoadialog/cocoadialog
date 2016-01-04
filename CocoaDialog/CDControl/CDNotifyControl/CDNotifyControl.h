

#import "CDControl.h"

@interface CDNotifyControl : CDControl {
    int             activeNotifications;
    NSMutableArray  *notifications;
}

- (void) addNotificationWithTitle:(NSString*)title
                      description:(NSString *)description
                             icon:(NSImage *)_icon
                         priority:(NSNumber *)priority
                           sticky:(BOOL)sticky
                        clickPath:(NSString *)clickPath
                         clickArg:(NSString *)clickArg;

@property (readonly, copy) NSArray *notificationIcons;

- (void) notificationWasClicked:(id)clickContext;
- (NSArray*) parseTextForArguments:(NSString*)string;

@end
