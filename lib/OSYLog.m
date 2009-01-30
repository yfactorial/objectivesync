//
//  OSYLog.m
//  objectivesync
//
//  Created by vickeryj on 1/28/09.
//  Copyright 2009 Joshua Vickery. All rights reserved.
//

#import "OSYLog.h"
#import "ORCDataChangedDelegate.h"


@implementation OSYLog

@synthesize loggedClassName, loggedPk, loggedAction, loggedAt;

+(NSArray *)newlyCreated {
	NSString *query = [NSString stringWithFormat:@"WHERE logged_action = '%d'", CreatedAction];
	return [self findByCriteria:query];;
}

+(void) logAction:(ORCActionTypes)action toDBWithClass:(Class)createdClass andPk:(int)createdPk {
	OSYLog *log = [[[OSYLog alloc] init] autorelease];
	log.loggedAction = action;
	log.loggedClassName = [createdClass className];
	log.loggedPk = createdPk;
	log.loggedAt = [NSDate date];
	[log save];
}


#pragma mark cleanup
- (void) dealloc
{
	[loggedClassName release];
	[loggedAt release];
	[super dealloc];
}


@end
