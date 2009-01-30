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

@end


@implementation OSYSync

-(void)runSync {
	[self syncCreated];
}

-(void) syncCreated {	
	NSArray *created = [OSYLog newlyCreated];
	for (OSYLog *log in created) {
		Class cls = [[NSBundle mainBundle] classNamed:log.loggedClassName];
		id obj = [cls findByPK:log.loggedPk];
		if ([obj saveORS]) {
			[log deleteObject];
		}
	}
}

@end
