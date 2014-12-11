//
//  WebBrowserViewController.m
//  WebBrowserViewController
//
//  Created by Casey E on 12/10/14.
//  Copyright (c) 2014 Casey E. All rights reserved.
//

#import "WebBrowserViewController.h"

@interface WebBrowserViewController() <UIWebViewDelegate, UITextFieldDelegate>
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) UITextField *urlField;
@property (nonatomic, strong) UIBarButtonItem *refreshButton;
@property (nonatomic, strong) UIBarButtonItem *backButton;
@property (nonatomic, strong) UIBarButtonItem *forwardButton;

@end

@implementation WebBrowserViewController

// view creation
-(void)viewDidLoad {
	[super viewDidLoad];
	
	self.view.backgroundColor = [UIColor lightGrayColor];
	
	/*UIView *topBar = [self createTopBar];
	topBar.translatesAutoresizingMaskIntoConstraints = NO;
	[self.view addSubview:topBar];
	*/
	_backButton = [[UIBarButtonItem alloc] initWithTitle:@"← " style:UIBarButtonItemStylePlain target:self action:@selector(didTapBack)];
	_forwardButton = [[UIBarButtonItem alloc] initWithTitle:@" →" style:UIBarButtonItemStylePlain target:self action:@selector(didTapForward)];
	[self.navigationItem setLeftBarButtonItems:@[_backButton, _forwardButton]];
	
	_refreshButton = [[UIBarButtonItem alloc] initWithTitle:@"Reload" style:UIBarButtonItemStylePlain target:self action:@selector(didTapReload)];
	[self.navigationItem setRightBarButtonItems:@[_refreshButton]];
	
	
	_urlField = [[UITextField alloc] initWithFrame:CGRectMake(40, 0, 220, 24)];
	_urlField.translatesAutoresizingMaskIntoConstraints = NO;
	_urlField.backgroundColor = [UIColor whiteColor];
	_urlField.delegate = self;
	_urlField.textAlignment = NSTextAlignmentCenter;
	_urlField.layer.cornerRadius = 5;
	_urlField.clearButtonMode = UITextFieldViewModeWhileEditing;
	[self.navigationItem setTitleView:_urlField];
	
	
	//[self.navigationController.toolbar addSubview:topBar];
	
	_webView = [[UIWebView alloc] init];
	_webView.translatesAutoresizingMaskIntoConstraints = NO;
	_webView.scalesPageToFit = YES;
	_webView.delegate = self;
	[self.view addSubview:_webView];
	
	[_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.asdf.com"]]];
	
	NSDictionary *views = NSDictionaryOfVariableBindings(_webView);
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_webView]|" options:0 metrics:nil views:views]];
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_webView]|" options:0 metrics:nil views:views]];
	
	[self updateBarButtons];
}

// view modification
-(void)updateBarButtons {
	_backButton.enabled = [_webView canGoBack];
	_forwardButton.enabled = [_webView canGoForward];
}

// user interaction
-(void)didTapBack {
	[_webView goBack];
}
-(void)didTapForward {
	[_webView goForward];
}
-(void)didTapReload {
	[_webView reload];
	[self updateBarButtons];
}

// webview delegate
-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	
	[_urlField setText:[[request URL] absoluteString]];
	[self updateBarButtons];
	
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	
	return YES;
}
-(void)webViewDidFinishLoad:(UIWebView *)webView {
	
	[[NSOperationQueue mainQueue] addOperationWithBlock:^ {
		[_urlField setText:[[[webView request] URL] absoluteString]];
		[self updateBarButtons];
		
	}];
	
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}
-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
	// pop the error
	[[[UIAlertView alloc] initWithTitle:@"URL Failed" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil] show];
	
	[[NSOperationQueue mainQueue] addOperationWithBlock:^ {
		[self updateBarButtons];
	}];
}

// text field delegate
-(void)textFieldDidBeginEditing:(UITextField *)textField {
	[textField setTextAlignment:NSTextAlignmentLeft];
	if (![[textField text] length]) {
		[textField setText:@"http://"];
	}
}
-(void)textFieldDidEndEditing:(UITextField *)textField {
	if ([textField.text isEqual:@"http://"]) {
		[textField setText:[[[_webView request] URL] absoluteString]];
	}
	[textField setTextAlignment:NSTextAlignmentCenter];
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	
	NSURL *enteredURL = [NSURL URLWithString:[textField text]];
	
	// see if we have a valid url
	if (!enteredURL || !enteredURL.scheme) {
		// pop error and bail
		[[[UIAlertView alloc] initWithTitle:@"Bad URL" message:@"\nTry Again." delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil] show];
		return NO;
	}
	
	// load the request
	[_webView loadRequest:[NSURLRequest requestWithURL:enteredURL]];
	
	// return no since we don't want the \n appended
	return NO;
	
}
-(BOOL)textFieldShouldClear:(UITextField *)textField {
	[textField setText:@"http://"];
	return NO;
}

@end
