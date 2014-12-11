//
//  ViewController.m
//  WebSniffer
//
//  Created by Casey E on 12/10/14.
//  Copyright (c) 2014 Casey E. All rights reserved.
//

#import "ViewController.h"
#import "WebSniffer.h"
#import "WebSniffLogger.h"

@interface ViewController ()
@property (nonatomic, strong) WebSniffer *webSniffer;
@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.view.backgroundColor = [UIColor greenColor];
	
	
	// create the web sniffer
	_webSniffer = [[WebSniffer alloc] init];
	_webSniffer.translatesAutoresizingMaskIntoConstraints = NO;
	[self.view addSubview:_webSniffer];
	
	// setup the layout constraints (handles rotation too!)
	NSDictionary *views = NSDictionaryOfVariableBindings(_webSniffer);
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_webSniffer]|" options:0 metrics:nil views:views]];
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[_webSniffer]|" options:0 metrics:nil views:views]];
}

-(void)saveLogFile {
	[[WebSniffLogger sharedInstace] writeLogToFile:[NSHomeDirectory() stringByAppendingString:@"/Documents/log.txt"]];
	
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

@end
