//
//  ORCDataChangedDelegate.h
//  objectivesync
//
//  Created by vickeryj on 1/27/09.
//  Copyright 2009 Joshua Vickery. All rights reserved.
//



@protocol ORCDataChangedDelegate

- (void) objectOfClass:(Class)cls createdWithPk:(int)pk;

@end
