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

@synthesize window, navigationController;


- (void)applicationDidFinishLaunching:(UIApplication *)application {    
	[ObjectiveResource setSite:@"http://localhost:3000/"];
	[OSYService setup];
	
    // Override point for customization after application launch
	[window addSubview:navigationController.view];
    [window makeKeyAndVisible];
}


- (void)dealloc {
    [window release];
	[navigationController release];
    [super dealloc];
}


@end
