//
//  Note.m
//  objectivesync
//
//  Created by vickeryj on 1/27/09.
//  Copyright 2009 Joshua Vickery. All rights reserved.
//

#import "Note.h"

@implementation Note

@synthesize noteText, noteId;

#pragma mark cleanup
- (void) dealloc
{
	[noteText release];
	[noteId release];
	[super dealloc];
}


@end
