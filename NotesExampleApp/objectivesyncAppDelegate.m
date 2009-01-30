//
//  objectivesyncAppDelegate.m
//  objectivesync
//
//  Created by vickeryj on 1/27/09.
//  Copyright Joshua Vickery 2009. All rights reserved.
//

#import "objectivesyncAppDelegate.h"
#import "OSYService.h"
#import "ObjectiveResource.h"

@implementation objectivesyncAppDelegate

@synthesize window, navigationController, noteListController;

- (void)applicationDidFinishLaunching:(UIApplication *)application {    
	[ObjectiveResourceConfig setSite:@"http://localhost:3000/"];
	[OSYService setupWithSyncDelegate:(id)noteListController];
	
    // Override point for customization after application launch
	[window addSubview:navigationController.view];
    [window makeKeyAndVisible];
}


- (void)dealloc {
    [window release];
	[navigationController release];
	[noteListController release];
    [super dealloc];
}


@end
