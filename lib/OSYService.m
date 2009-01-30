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

@synthesize delegate;

+(void)setupWithSyncDelegate:(NSObject<OSYSyncDelegate> *)delegate {
	__instance = [[OSYService alloc] init];
	[__instance setDelegate:delegate];
	OSYDataChangedDelegate *dataChanged = [[OSYDataChangedDelegate alloc] init];
	[SQLitePersistentObject setDataChangedDelegate:dataChanged];
}

+(OSYService *)instance {
	return __instance;
}


-(void)dataChanged {
	NSLog(@"data changed");
	//basic, sync immediately strategy
	OSYSync *sync = [[[OSYSync alloc] init] autorelease];
	[sync runSync];
	[delegate syncCompleteWithSuccess:YES];
}

#pragma mark cleanup
- (void) dealloc
{
	[delegate release];
	[super dealloc];
}


@end
