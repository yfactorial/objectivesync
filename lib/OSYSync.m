//
//  OSYSync.m
//  objectivesync
//
//  Created by vickeryj on 1/30/09.
//  Copyright 2009 Joshua Vickery. All rights reserved.
//

#import "OSYSync.h"
#import "OSYLog.h"
#import "ObjectiveResource.h"

@interface OSYSync()

-(void)syncCreated;
-(void)syncDeleted;

@end


@implementation OSYSync

-(void)runSync {
	[self syncCreated];
	[self syncDeleted];
}

-(void) syncCreated {
	NSArray *created = [OSYLog newlyCreated];
	for (OSYLog *log in created) {
		Class cls = [[NSBundle mainBundle] classNamed:log.loggedClassName];
		id obj = [cls findByPK:log.loggedPk];
		if ([obj saveORS]) {
			[obj save];
			[log deleteObject];
		}
	}
}

-(void) syncDeleted {
	NSArray *deleted = [OSYLog newlyDeleted];
	for (OSYLog *log in deleted) {
		Class cls = [[NSBundle mainBundle] classNamed:log.loggedClassName];
		id obj = [[[cls alloc] init] autorelease];
		[obj setORSId:log.remoteId];
		if ([obj destroyORS]) {
			[log deleteObject];
		}
	}
}

@end
