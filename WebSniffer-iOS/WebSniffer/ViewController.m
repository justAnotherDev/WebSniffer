//
//  ViewController.m
//  WebSniffer
//
//  Created by Casey E on 12/10/14.
//  Copyright (c) 2014 Casey E. All rights reserved.
//

#import "ViewController.h"
#import "WebBrowserView.h"
#import "WebSniffer.h"

@interface ViewController ()
@property (nonatomic, strong) WebBrowserView *webBrowser;
@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.view.backgroundColor = [UIColor lightGrayColor];
	
	// create the web sniffer
	_webBrowser = [[WebBrowserView alloc] initWithNavItem:self.navigationItem];
	_webBrowser.translatesAutoresizingMaskIntoConstraints = NO;
	[self.view addSubview:_webBrowser];
	
	// setup the layout constraints (handles rotation too!)
	NSDictionary *views = NSDictionaryOfVariableBindings(_webBrowser);
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_webBrowser]|" options:0 metrics:nil views:views]];
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_webBrowser]|" options:0 metrics:nil views:views]];
}

-(void)saveLogFile {
	[[WebSniffer sharedInstace] writeLogToFile:[NSHomeDirectory() stringByAppendingString:@"/Documents/log.txt"]];
}

-(UINavigationItem*)webBrowserRequestsNavItem:(WebBrowserView *)webBrowser {
	return self.navigationItem;
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

@end
