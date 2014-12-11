//
//  ViewController.m
//  WebSniffer
//
//  Created by Casey E on 12/10/14.
//  Copyright (c) 2014 Casey E. All rights reserved.
//

#import "ViewController.h"
#import "WebBrowserViewController.h"
#import "WebSnifferLogger.h"

@interface ViewController ()
@property (nonatomic, strong) WebBrowserViewController *webSniffer;
@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.view.backgroundColor = [UIColor lightGrayColor];
	
	// create the web sniffer
	_webSniffer = [[WebBrowserViewController alloc] init];
	[self.navigationController pushViewController:_webSniffer animated:NO];
}

-(void)saveLogFile {
	[[WebSnifferLogger sharedInstace] writeLogToFile:[NSHomeDirectory() stringByAppendingString:@"/Documents/log.txt"]];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

@end
