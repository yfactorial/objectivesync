//
//  objectivesyncAppDelegate.h
//  objectivesync
//
//  Created by vickeryj on 1/27/09.
//  Copyright Joshua Vickery 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NoteListController;

@interface objectivesyncAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
	UINavigationController *navigationController;
	NoteListController *noteListController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;
@property (nonatomic, retain) IBOutlet NoteListController *noteListController;


@end

