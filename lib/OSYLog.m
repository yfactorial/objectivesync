//
//  OSYLog.m
//  objectivesync
//
//  Created by vickeryj on 1/28/09.
//  Copyright 2009 Joshua Vickery. All rights reserved.
//

#import "OSYLog.h"

static NSString *CREATE = @"CREATE";

@implementation OSYLog

@synthesize loggedClassName, loggedPk, loggedAction;

+(void)logToDBWithCreatedClass:(Class) createdClass andPk:(int) createdPk {
	OSYLog *result = [[[OSYLog alloc] init] autorelease];
	result.loggedAction = CREATE;
	result.loggedClassName = [createdClass className];
	result.loggedPk = createdPk;
	[result save];
}

#pragma mark cleanup
- (void) dealloc
{
	[loggedClassName release];
	[loggedAction release];
	[super dealloc];
}


@end
