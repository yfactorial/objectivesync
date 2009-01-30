//
//  NoteListController.h
//  objectivesync
//
//  Created by vickeryj on 1/27/09.
//  Copyright 2009 Joshua Vickery. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OSYSyncDelegate.h"

@interface NoteListController : UITableViewController <OSYSyncDelegate> {

	NSMutableArray *notes;
	
}

- (IBAction) addButtonPressed;

@property(nonatomic, retain) NSMutableArray *notes;

@end
