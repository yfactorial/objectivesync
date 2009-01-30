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
#import "OSYSync.h"


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
	//basic, sync immediately strategy
	OSYSync *sync = [[[OSYSync alloc] init] autorelease];
	[sync runSync];
}

@end
