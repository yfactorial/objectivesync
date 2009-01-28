//
//  NoteEditController.m
//  objectivesync
//
//  Created by vickeryj on 1/27/09.
//  Copyright 2009 Joshua Vickery. All rights reserved.
//

#import "NoteEditController.h"
#import "Note.h"

@implementation NoteEditController

@synthesize note;

#pragma mark UIViewController methods
- (void)viewWillAppear:(BOOL)animated {
	textView.text = [note noteText];
}
- (void)viewDidAppear:(BOOL)animated {
	[textView becomeFirstResponder];
}
- (void)viewWillDisappear:(BOOL)animated {
	note.noteText = textView.text;
	[note save];
}



#pragma mark cleanup

- (void)dealloc {
	[note release];
    [super dealloc];
}


@end
