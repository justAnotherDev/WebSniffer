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
#import "WebLoggerView.h"

@interface ViewController () <WebLoggerViewDelegate, WebBrowserViewDelegate, WebLoggerViewDelegate>

@property (nonatomic, strong) WebBrowserView *webBrowser;
@property (nonatomic, strong) WebLoggerView *webLoggerView;

@end

@implementation ViewController

-(void)viewDidLoad {
	[super viewDidLoad];
	
	self.view.backgroundColor = [UIColor lightGrayColor];
	
	// create the web sniffer, will be presented in didAppear:
	_webBrowser = [[WebBrowserView alloc] init];
	_webBrowser.translatesAutoresizingMaskIntoConstraints = NO;
	_webBrowser.delegate = self;
	[self.view addSubview:_webBrowser];
	
	[_webBrowser loadURL:[NSURL URLWithString:@"http://www.asdf.com"]];
	
	NSDictionary *views = NSDictionaryOfVariableBindings(_webBrowser);
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_webBrowser]|" options:0 metrics:nil views:views]];
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_webBrowser]|" options:0 metrics:nil views:views]];
	
}

-(void)webBrowserRequestsLog:(WebBrowserView *)webBrowser {
	if (!_webLoggerView) {
		_webLoggerView = [[WebLoggerView alloc] init];
		_webLoggerView.translatesAutoresizingMaskIntoConstraints = NO;
		_webLoggerView.delegate = self;
	}
	
	[self swapView:_webBrowser withView:_webLoggerView usingAnimation:UIViewAnimationOptionTransitionFlipFromRight withCompletionBlock:^{
		[_webLoggerView isBackOnscreen];
	}];
}
-(void)webLoggerRequestsWebView:(WebLoggerView*)webLogger {
	if (!_webBrowser) {
		_webBrowser = [[WebBrowserView alloc] init];
		_webBrowser.translatesAutoresizingMaskIntoConstraints = NO;
		_webBrowser.delegate = self;
	}
	
	[self swapView:_webLoggerView withView:_webBrowser usingAnimation:UIViewAnimationOptionTransitionFlipFromLeft withCompletionBlock:^{
		
	}];
}

-(void)swapView:(UIView*)aView withView:(UIView*)bView usingAnimation:(UIViewAnimationOptions)animateOptions withCompletionBlock:(void (^)(void))completion {
	[self.view addSubview:bView];
	
	NSDictionary *views = NSDictionaryOfVariableBindings(bView);
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[bView]|" options:0 metrics:nil views:views]];
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[bView]|" options:0 metrics:nil views:views]];
	
	
	[UIView transitionFromView:aView toView:bView duration:0.75 options:animateOptions completion:^(BOOL finished){
		[aView removeFromSuperview];
	}];
}


-(void)saveLogFile {
	[[WebSniffer sharedInstance] writeLogToFile:[NSHomeDirectory() stringByAppendingString:@"/Documents/log.txt"]];
}


- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

@end
