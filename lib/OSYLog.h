//
//  OSYLog.h
//  objectivesync
//
//  Created by vickeryj on 1/28/09.
//  Copyright 2009 Joshua Vickery. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SQLitePersistentObject.h"

@interface OSYLog : SQLitePersistentObject {

	NSString *loggedClassName;
	int loggedPk;
	int loggedAction;
	NSDate *loggedAt;
	NSString *remoteId;
	
}

@property(nonatomic, retain) NSString *loggedClassName;
@property(nonatomic) int loggedPk;
@property(nonatomic) int loggedAction;
@property(nonatomic, retain) NSDate *loggedAt;
@property(nonatomic, retain) NSString *remoteId;

/*! log an object that was Created, Deleted or Updated */
+(void) logAction:(ORCActionTypes)action toDBWithClass:(Class)loggedClass 
	  andRemoteId:(NSString *)loggedRemoteId andPk:(int)loggedPk;


//finders
+(NSArray *)newlyCreated;
+(NSArray *)newlyDeleted;

@end
