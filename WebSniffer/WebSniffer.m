//
//  WebSniffer.m
//  WebSniffer
//
//  Created by Casey E on 12/10/14.
//  Copyright (c) 2014 Casey E. All rights reserved.
//

#import "WebSniffer.h"

@interface WebSniffer() <UIWebViewDelegate, UITextFieldDelegate>
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) UITextField *urlField;
@property (nonatomic, strong) UIButton *refreshButton;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIButton *forwardButton;

@end

@implementation WebSniffer

// view creation
-(id)init {
	self = [super init];
	if (!self)
		return nil;
	
	self.backgroundColor = [UIColor lightGrayColor];
	
	UIView *topBar = [self createTopBar];
	topBar.translatesAutoresizingMaskIntoConstraints = NO;
	[self addSubview:topBar];
	
	_webView = [[UIWebView alloc] init];
	_webView.translatesAutoresizingMaskIntoConstraints = NO;
	_webView.scalesPageToFit = YES;
	_webView.delegate = self;
	[self addSubview:_webView];
	
	[_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.asdf.com"]]];
	
	NSDictionary *views = NSDictionaryOfVariableBindings(topBar, _webView);
	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[topBar]|" options:0 metrics:nil views:views]];
	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_webView]|" options:0 metrics:nil views:views]];
	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[topBar(==42)][_webView]|" options:0 metrics:nil views:views]];
	
	[self updateBarButtons];
	
	return self;
}
-(UIView*)createTopBar {
	UIView *topBar = [[UIView alloc] init];
	
	UIColor *buttonColor = [UIColor whiteColor];
	UIColor *buttonTextColor = [UIColor blueColor];
	UIColor *disabledColor = [UIColor lightGrayColor];
	
	_urlField = [[UITextField alloc] init];
	_urlField.translatesAutoresizingMaskIntoConstraints = NO;
	_urlField.backgroundColor = [UIColor whiteColor];
	_urlField.delegate = self;
	_urlField.clearButtonMode = UITextFieldViewModeWhileEditing;
	[topBar addSubview:_urlField];
	
	_refreshButton = [[UIButton alloc] init];
	_refreshButton.translatesAutoresizingMaskIntoConstraints = NO;
	_refreshButton.backgroundColor = buttonColor;
	[_refreshButton setTitle:@"R" forState:UIControlStateNormal];
	[_refreshButton setTitleColor:buttonTextColor forState:UIControlStateNormal];
	[_refreshButton setTitleColor:disabledColor forState:UIControlStateDisabled];
	[_refreshButton addTarget:self action:@selector(didTapRefresh) forControlEvents:UIControlEventTouchUpInside];
	[topBar addSubview:_refreshButton];
	
	_backButton = [[UIButton alloc] init];
	_backButton.translatesAutoresizingMaskIntoConstraints = NO;
	_backButton.backgroundColor = buttonColor;
	[_backButton setTitle:@"←" forState:UIControlStateNormal];
	[_backButton setTitleColor:buttonTextColor forState:UIControlStateNormal];
	[_backButton setTitleColor:disabledColor forState:UIControlStateDisabled];
	[_backButton addTarget:self action:@selector(didTapBack) forControlEvents:UIControlEventTouchUpInside];
	[topBar addSubview:_backButton];
	
	_forwardButton = [[UIButton alloc] init];
	_forwardButton.translatesAutoresizingMaskIntoConstraints = NO;
	_forwardButton.backgroundColor = buttonColor;
	[_forwardButton setTitle:@"→" forState:UIControlStateNormal];
	[_forwardButton setTitleColor:buttonTextColor forState:UIControlStateNormal];
	[_forwardButton setTitleColor:disabledColor forState:UIControlStateDisabled];
	[_forwardButton addTarget:self action:@selector(didTapForward) forControlEvents:UIControlEventTouchUpInside];
	[topBar addSubview:_forwardButton];
	
	NSDictionary *views = NSDictionaryOfVariableBindings(_urlField, _refreshButton, _backButton, _forwardButton);
	[topBar addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-4-[_backButton(==30)]-4-[_forwardButton(==_backButton)]-4-[_urlField]-4-[_refreshButton(==_backButton)]-4-|" options:0 metrics:nil views:views]];
	[topBar addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-4-[_urlField]-4-|" options:0 metrics:nil views:views]];
	[topBar addConstraint:[NSLayoutConstraint constraintWithItem:_refreshButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_urlField attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
	[topBar addConstraint:[NSLayoutConstraint constraintWithItem:_backButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_urlField attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
	[topBar addConstraint:[NSLayoutConstraint constraintWithItem:_forwardButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_urlField attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
	
	
	return topBar;
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
-(void)didTapRefresh {
	[_webView reload];
	[self updateBarButtons];
}

// webview delegate
-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	[[NSOperationQueue mainQueue] addOperationWithBlock:^ {
		[_urlField setText:[[[webView request] URL] absoluteString]];
		[self updateBarButtons];
		
	}];
	
	return YES;
}
-(void)webViewDidFinishLoad:(UIWebView *)webView {
	
	[[NSOperationQueue mainQueue] addOperationWithBlock:^ {
		[_urlField setText:[[[webView request] URL] absoluteString]];
		[self updateBarButtons];
		
	}];
}
-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
	// pop the error
	[[[UIAlertView alloc] initWithTitle:@"URL Failed" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil] show];
	
	[[NSOperationQueue mainQueue] addOperationWithBlock:^ {
		[self updateBarButtons];
	}];
}

// text field delegate
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
-(void)textFieldDidBeginEditing:(UITextField *)textField {
	if (![[textField text] length]) {
		[textField setText:@"http://"];
	}
}
-(BOOL)textFieldShouldClear:(UITextField *)textField {
	[textField setText:@"http://"];
	return NO;
}

@end
