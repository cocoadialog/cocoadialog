//
//  SUAppcastItem.h
//  Sparkle
//
//  Created by Andy Matuschak on 3/12/06.
//  Copyright 2006 Andy Matuschak. All rights reserved.
//

#ifndef SUAPPCASTITEM_H
#define SUAPPCASTITEM_H

@interface SUAppcastItem : NSObject
{
@private
	NSString *title;
	NSDate *date;
	NSString *itemDescription;
	
	NSURL *releaseNotesURL;
	
	NSString *DSASignature;	
	NSString *minimumSystemVersion;
	
	NSURL *fileURL;
	NSString *versionString;
	NSString *displayVersionString;

	NSDictionary *deltaUpdates;

	NSDictionary *propertiesDictionary;
    
	NSURL *infoURL;	// UK 2007-08-31
}

// Initializes with data from a dictionary provided by the RSS class.
- (instancetype) initWithDictionary:(NSDictionary *)dict;
- (instancetype) initWithDictionary:(NSDictionary *)dict failureReason:(NSString**)error;

@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *title;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *versionString;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *displayVersionString;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSDate *date;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *itemDescription;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSURL *releaseNotesURL;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSURL *fileURL;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *DSASignature;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *minimumSystemVersion;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSDictionary *deltaUpdates;
@property (NS_NONATOMIC_IOSONLY, getter=isDeltaUpdate, readonly) BOOL deltaUpdate;
@property (NS_NONATOMIC_IOSONLY, getter=isCriticalUpdate, readonly) BOOL criticalUpdate;

// Returns the dictionary provided in initWithDictionary; this might be useful later for extensions.
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSDictionary *propertiesDictionary;

@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSURL *infoURL;						// UK 2007-08-31

@end

#endif
