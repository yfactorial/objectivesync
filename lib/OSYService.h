//
//  OSYService.h
//  objectivesync
//
//  Created by vickeryj on 1/28/09.
//  Copyright 2009 Joshua Vickery. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface OSYService : NSObject {

}

+(void)setup;
+(OSYService *)instance;
-(void)dataChanged;

@end
