//
//  NoteEditController.h
//  objectivesync
//
//  Created by vickeryj on 1/27/09.
//  Copyright 2009 Joshua Vickery. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Note;

@interface NoteEditController : UIViewController {

	IBOutlet UITextView *textView;
	Note *note;
}

@property(nonatomic, retain) Note *note;

@end
