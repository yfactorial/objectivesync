//
//  Note.h
//  objectivesync
//
//  Created by vickeryj on 1/27/09.
//  Copyright 2009 Joshua Vickery. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SQLitePersistentObject.h"

@interface Note : SQLitePersistentObject {

	NSString *noteText;
	
}

@property(nonatomic, retain) NSString *noteText;

@end
