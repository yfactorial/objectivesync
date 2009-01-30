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
	NSString *loggedAction;
	NSDate *loggedAt;
	
}

@property(nonatomic, retain) NSString *loggedClassName;
@property(nonatomic) int loggedPk;
@property(nonatomic, retain) NSString *loggedAction;
@property(nonatomic, retain) NSDate *loggedAt;

/*! log an object creation */
+(void) logToDBWithCreatedClass:(Class) createdClass andPk:(int) createdPk;

/*! findAll newly created objects that have not yet been uploaded */
+(NSArray *)newlyCreated;

@end
