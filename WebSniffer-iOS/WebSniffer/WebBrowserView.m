//
//  WebBrowserView.m
//  WebBrowserView
//
//  Created by Casey E on 12/10/14.
//  Copyright (c) 2014 Casey E. All rights reserved.
//

#import "WebBrowserView.h"

@interface WebBrowserView() <UIWebViewDelegate, UITextFieldDelegate>
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) UITextField *urlField;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIButton *forwardButton;
@end

@implementation WebBrowserView

// view creation
-(id)init {
	self = [super init];
	if (!self)
		return nil;
	
	// create the to toolbar
	UIView *toolbarView = [self createTopBar];
	
	// create the web view
	_webView = [[UIWebView alloc] init];
	_webView.translatesAutoresizingMaskIntoConstraints = NO;
	_webView.scalesPageToFit = YES;
	_webView.delegate = self;
	[self addSubview:_webView];

	// define the frames using layout constraints
	NSDictionary *views = NSDictionaryOfVariableBindings(_webView, toolbarView);
	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(-1)-[toolbarView]-(-1)-|" options:0 metrics:nil views:views]];
	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_webView]|" options:0 metrics:nil views:views]];
	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(-1)-[toolbarView(==60)][_webView]|" options:0 metrics:nil views:views]];
	
	return self;
}
-(UIView*)createTopBar {
	UIView *toolbarView = [[UIView alloc] init];
	toolbarView.translatesAutoresizingMaskIntoConstraints = NO;
	toolbarView.backgroundColor = [UIColor colorWithRed:252/255. green:252/255. blue:252/255. alpha:1];
	toolbarView.layer.borderColor = [[UIColor darkGrayColor] CGColor];
	toolbarView.layer.borderWidth = 1;
	[self addSubview:toolbarView];
	
	
	_urlField = [[UITextField alloc] init];
	_urlField.translatesAutoresizingMaskIntoConstraints = NO;
	_urlField.backgroundColor = [UIColor whiteColor];
	_urlField.borderStyle = UITextBorderStyleRoundedRect;
	_urlField.delegate = self;
	_urlField.clearButtonMode = UITextFieldViewModeWhileEditing;
	_urlField.rightViewMode = UITextFieldViewModeUnlessEditing;
	[toolbarView addSubview:_urlField];

	UIButton *refreshButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
	[refreshButton setImage:[UIImage imageNamed:@"reload"] forState:UIControlStateNormal];
	[refreshButton addTarget:self action:@selector(didTapReload) forControlEvents:UIControlEventTouchUpInside];
	[_urlField setRightView:refreshButton];
	
	UIColor *buttonTextColor = [UIColor blueColor];
	UIColor *disabledColor = [UIColor lightGrayColor];

	_backButton = [[UIButton alloc] init];
	_backButton.translatesAutoresizingMaskIntoConstraints = NO;
	[_backButton setTitle:@"←" forState:UIControlStateNormal];
	[_backButton setTitleColor:buttonTextColor forState:UIControlStateNormal];
	[_backButton setTitleColor:disabledColor forState:UIControlStateDisabled];
	[_backButton addTarget:self action:@selector(didTapBack) forControlEvents:UIControlEventTouchUpInside];
	[toolbarView addSubview:_backButton];

	_forwardButton = [[UIButton alloc] init];
	_forwardButton.translatesAutoresizingMaskIntoConstraints = NO;
	[_forwardButton setTitle:@"→" forState:UIControlStateNormal];
	[_forwardButton setTitleColor:buttonTextColor forState:UIControlStateNormal];
	[_forwardButton setTitleColor:disabledColor forState:UIControlStateDisabled];
	[_forwardButton addTarget:self action:@selector(didTapForward) forControlEvents:UIControlEventTouchUpInside];
	[toolbarView addSubview:_forwardButton];

	UIButton *logButton = [[UIButton alloc] init];
	logButton.translatesAutoresizingMaskIntoConstraints = NO;
	[logButton setImage:[UIImage imageNamed:@"document"] forState:UIControlStateNormal];
	[logButton addTarget:self action:@selector(didTapLog) forControlEvents:UIControlEventTouchUpInside];
	[toolbarView addSubview:logButton];

	
	NSDictionary *views = NSDictionaryOfVariableBindings(_urlField, _backButton, _forwardButton, logButton);
	[toolbarView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-4-[_backButton(==30)]-4-[_forwardButton(==_backButton)]-4-[_urlField]-4-[logButton(==25)]-4-|" options:0 metrics:nil views:views]];
	[toolbarView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-24-[_urlField]-4-|" options:0 metrics:nil views:views]];
	[toolbarView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[logButton(==25)]" options:0 metrics:nil views:views]];
	[toolbarView addConstraint:[NSLayoutConstraint constraintWithItem:_backButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_urlField attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
	[toolbarView addConstraint:[NSLayoutConstraint constraintWithItem:_forwardButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_urlField attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
	[toolbarView addConstraint:[NSLayoutConstraint constraintWithItem:logButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_urlField attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
	
	
	return toolbarView;
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
-(void)didTapLog {
	if ([_delegate respondsToSelector:@selector(webBrowserRequestsLog:)]) {
		[_delegate webBrowserRequestsLog:self];
	}
}

-(void)loadURL:(NSURL *)aURL {
	[_webView loadRequest:[NSURLRequest requestWithURL:aURL]];
}

// webview delegate
-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	// update the top bar
	if (![_urlField isFirstResponder]) {
		[_urlField setText:[[request URL] absoluteString]];
	}
	[self updateBarButtons];
	
	// start the activity spinner
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	
	return YES;
}
-(void)webViewDidFinishLoad:(UIWebView *)webView {
	// update the top bar
	if (![_urlField isFirstResponder]) {
		NSString *webURL = [webView stringByEvaluatingJavaScriptFromString:@"document.URL"];
		if (![webURL length]) {
			webURL = [[[webView request] URL] absoluteString];
		}
		[_urlField setText:webURL];
	}
	[self updateBarButtons];
	
	// stop spinning the activity spinner
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}
-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
	// update the top bar
	[self updateBarButtons];
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

// utilities
-(UIImage*)maskMaskedImageNamed:(NSString *)name color:(UIColor *)color{
	UIImage *image = [UIImage imageNamed:name];
	CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);
	UIGraphicsBeginImageContextWithOptions(rect.size, NO, image.scale);
	CGContextRef c = UIGraphicsGetCurrentContext();
	[image drawInRect:rect];
	CGContextSetFillColorWithColor(c, [color CGColor]);
	CGContextSetBlendMode(c, kCGBlendModeSourceAtop);
	CGContextFillRect(c, rect);
	UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return result;
}

@end
