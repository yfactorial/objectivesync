//
//  OSYDataChangedDelegate.m
//  objectivesync
//
//  Created by vickeryj on 1/28/09.
//  Copyright 2009 Joshua Vickery. All rights reserved.
//

#import "OSYDataChangedDelegate.h"
#import "OSYLog.h"
#import "OSYService.h"

@implementation OSYDataChangedDelegate

- (void) objectOfClass:(Class)cls createdWithPk:(int)pk {
	if (![[cls className] isEqualTo:@"OSYLog"]) {
		[OSYLog logToDBWithCreatedClass:cls andPk:pk];
		[[OSYService instance] dataChanged];
	}
}

@end
