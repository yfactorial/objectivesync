//
//  OSYObjectiveResourceProxy.m
//  objectivesync
//
//  Created by vickeryj on 1/28/09.
//  Copyright 2009 Joshua Vickery. All rights reserved.
//

#import "OSYObjectiveResourceProxy.h"


@implementation OSYObjectiveResourceProxy

@synthesize proxiedObject;

+ (OSYObjectiveResourceProxy *)proxyFor:(id)object {
	OSYObjectiveResourceProxy *proxy = [[[OSYObjectiveResourceProxy alloc] init] autorelease];
	proxy.proxiedObject = object;
	return proxy;
}

#pragma mark proxied ObjectiveResource methods

- (Class)class {
	return [proxiedObject class];
}

#pragma mark proxied NSObject+PropertySupport methods
- (NSDictionary *)properties {
	return [proxiedObject properties];
}

- (void)setProperties:(NSDictionary *)overrideProperties {
	for (NSString *property in [overrideProperties allKeys]) {
		[proxiedObject setValue:[overrideProperties valueForKey:property] forKey:property];
	}
}

#pragma mark cleanup
- (void) dealloc
{
	[proxiedObject release];
	[super dealloc];
}


@end
