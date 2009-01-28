//
//  NoteListController.m
//  objectivesync
//
//  Created by vickeryj on 1/27/09.
//  Copyright 2009 Joshua Vickery. All rights reserved.
//

#import "NoteListController.h"
#import "Note.h"
#import "NoteEditController.h"

@implementation NoteListController

@synthesize notes;


- (IBAction) addButtonPressed {
	NoteEditController *editor = [[[NoteEditController alloc] initWithNibName:@"NoteEdit" bundle:nil] autorelease];
	editor.note = [[[Note alloc] init] autorelease];
	[notes addObject:editor.note];
	[self.navigationController pushViewController:editor animated:YES];
}

#pragma mark UIViewController methods
- (void)viewDidLoad {
	self.notes = [NSMutableArray arrayWithArray:[Note findByCriteria:@""]];
}

- (void)viewDidAppear:(BOOL)animated {
	[self.tableView reloadData];
}


#pragma mark Table view methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [notes count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
    }
	cell.text = [[notes objectAtIndex:indexPath.row] noteText];
    return cell;
}

#pragma mark cleanup
- (void)dealloc {
	[notes release];
    [super dealloc];
}


@end

