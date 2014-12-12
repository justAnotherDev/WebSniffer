//
//  AppDelegate.m
//  WebSniffer
//
//  Created by Casey E on 12/10/14.
//  Copyright (c) 2014 Casey E. All rights reserved.
//

#import "AppDelegate.h"
#import "WebSnifferURLProtocol.h"

@interface AppDelegate ()
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	
	// all web traffic will now route through WebSniffer
	[NSURLProtocol registerClass:[WebSnifferURLProtocol class]];
	
	_viewController = [[ViewController alloc] init];
	
	_window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	_window.rootViewController = _viewController;
	[_window makeKeyAndVisible];
	
	
	return YES;
}




@end
