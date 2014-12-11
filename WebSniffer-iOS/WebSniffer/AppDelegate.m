//
//  AppDelegate.m
//  WebSniffer
//
//  Created by Casey E on 12/10/14.
//  Copyright (c) 2014 Casey E. All rights reserved.
//

#import "AppDelegate.h"
#import "WebSniffingURLProtocol.h"

@interface AppDelegate ()
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	
	_viewController = [[ViewController alloc] init];
	
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:_viewController];
	
	_window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	_window.rootViewController = navController;
	[_window makeKeyAndVisible];
	
	[NSURLProtocol registerClass:[WebSniffingURLProtocol class]];
	
	return YES;
}




@end
