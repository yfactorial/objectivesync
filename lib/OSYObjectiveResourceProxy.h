//
//  OSYObjectiveResourceProxy.h
//  objectivesync
//
//  Created by vickeryj on 1/28/09.
//  Copyright 2009 Joshua Vickery. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ObjectiveResource.h"

@interface OSYObjectiveResourceProxy : ObjectiveResource {

	id proxiedObject;
	
}

@property(nonatomic, retain) id proxiedObject;

+ (OSYObjectiveResourceProxy *)proxyFor:(id)object;

@end
