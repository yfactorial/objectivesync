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
#import "OSYObjectiveResourceProxy.h"

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
		[Class classForClassName:<#(NSString *)codedName#>
		OSYObjectiveResourceProxy *oResProxy = [OSYObjectiveResourceProxy proxyFor:
		NSLog(@"found: %@:%d, %@",log.loggedClassName, log.loggedPk, log.loggedAction);
	}
}

@end
