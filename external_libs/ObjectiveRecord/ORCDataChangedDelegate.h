//
//  ORCDataChangedDelegate.h
//  objectivesync
//
//  Created by vickeryj on 1/27/09.
//  Copyright 2009 Joshua Vickery. All rights reserved.
//

/*! action types */
typedef enum {
	CreatedAction = 1,
	DeletedAction = 2,
} ORCActionTypes;

@protocol ORCDataChangedDelegate

- (void) objectOfClass:(Class)cls withPk:(int)pk 
		   andRemoteId:(NSString *)remoteId was:(ORCActionTypes)action;
@end
