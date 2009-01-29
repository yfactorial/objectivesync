//
//  OSYService.m
//  objectivesync
//
//  Created by vickeryj on 1/28/09.
//  Copyright 2009 Joshua Vickery. All rights reserved.
//

#import "OSYService.h"
#import "OSYDataChangedDelegate.h"
#import "SQLitePersistentObject.h"
#import "OSYLog.h"
#import "NSObject+ObjectiveResource.h"

static OSYService *__instance;

@implementation OSYService

+(void)setup  {
	__instance = [[OSYService alloc] init];
	OSYDataChangedDelegate *delegate = [[OSYDataChangedDelegate alloc] init];
	[SQLitePersistentObject setDataChangedDelegate:delegate];
}

+(OSYService *)instance {
	return __instance;
}


-(void)dataChanged {
	NSLog(@"data changed");
	NSArray *changed = [OSYLog findByCriteria:@""];
	for (OSYLog *log in changed) {
		Class cls = [[NSBundle mainBundle] classNamed:log.loggedClassName];
		id obj = [cls findByPK:log.loggedPk];
		[obj saveORS];
		NSLog(@"found: %@:%d, %@",log.loggedClassName, log.loggedPk, log.loggedAction);
	}
}

@end
