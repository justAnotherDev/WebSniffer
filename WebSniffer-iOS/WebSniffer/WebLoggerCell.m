//
//  WebLoggerCell.m
//  WebSniffer
//
//  Created by Casey E on 12/12/14.
//  Copyright (c) 2014 Casey E. All rights reserved.
//

#import "WebLoggerCell.h"

@interface WebLoggerCell()
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *successImage;
@property (nonatomic, strong) UILabel *statusCodeLabel;
@property (nonatomic, strong) UIView *expandedView;
@property (nonatomic, strong) UIButton *requestButton;
@property (nonatomic, strong) UIButton *responseButton;
@property (nonatomic, strong) UITextView *textView;
@end
@implementation WebLoggerCell

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	if (!self)
		return nil;
	
	self.clipsToBounds = YES;
	
	_titleLabel = [[UILabel alloc] init];
	_titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
	_titleLabel.textAlignment = NSTextAlignmentLeft;
	[self addSubview:_titleLabel];
	
	_successImage = [[UIImageView alloc] init];
	_successImage.translatesAutoresizingMaskIntoConstraints = NO;
	[self addSubview:_successImage];
	
	_statusCodeLabel = [[UILabel alloc] init];
	_statusCodeLabel.translatesAutoresizingMaskIntoConstraints = NO;
	_statusCodeLabel.textAlignment = NSTextAlignmentLeft;
	_statusCodeLabel.font = [UIFont systemFontOfSize:10];
	_statusCodeLabel.textColor = [UIColor lightGrayColor];
	[self addSubview:_statusCodeLabel];
	
	NSDictionary *views = NSDictionaryOfVariableBindings(_titleLabel, _successImage, _statusCodeLabel);
	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-4-[_titleLabel][_successImage(==18)]-4-|" options:0 metrics:nil views:views]];
	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_statusCodeLabel(==_successImage)]-4-|" options:0 metrics:nil views:views]];
	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-4-[_titleLabel(==25)]" options:0 metrics:nil views:views]];
	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-4-[_successImage(==18)][_statusCodeLabel]" options:0 metrics:nil views:views]];

	return self;
}
-(UIView*)createExpandedView {
	UIView *aExpandedView = [[UIView alloc] init];
	aExpandedView.userInteractionEnabled = YES;
	aExpandedView.translatesAutoresizingMaskIntoConstraints = NO;
	
	UIColor *buttonTextColor = [UIColor blueColor];
	UIColor *disabledColor = [UIColor lightGrayColor];
	
	_requestButton = [[UIButton alloc] init];
	_requestButton.translatesAutoresizingMaskIntoConstraints = NO;
	[_requestButton setTitle:@"REQUEST" forState:UIControlStateNormal];
	[_requestButton setTitleColor:buttonTextColor forState:UIControlStateNormal];
	[_requestButton setTitleColor:disabledColor forState:UIControlStateDisabled];
	[[_requestButton titleLabel] setFont:[UIFont boldSystemFontOfSize:12]];
	[_requestButton addTarget:self action:@selector(didTapRequest) forControlEvents:UIControlEventTouchUpInside];
	_requestButton.userInteractionEnabled = NO;
	_requestButton.titleLabel.textAlignment = NSTextAlignmentLeft;
	[aExpandedView addSubview:_requestButton];
	
	_responseButton = [[UIButton alloc] init];
	_responseButton.translatesAutoresizingMaskIntoConstraints = NO;
	[_responseButton setTitle:@"RESPONSE" forState:UIControlStateNormal];
	[_responseButton setTitleColor:buttonTextColor forState:UIControlStateNormal];
	[_responseButton setTitleColor:disabledColor forState:UIControlStateDisabled];
	[[_responseButton titleLabel] setFont:[UIFont systemFontOfSize:12]];
	[_responseButton addTarget:self action:@selector(didTapResponse) forControlEvents:UIControlEventTouchUpInside];
	_responseButton.titleLabel.textAlignment = NSTextAlignmentLeft;
	[aExpandedView addSubview:_responseButton];
	
	_textView = [[UITextView alloc] init];
	_textView.translatesAutoresizingMaskIntoConstraints = NO;
	_textView.editable = NO;
	_textView.text = [_requestObject requestRawString];
	[aExpandedView addSubview:_textView];
	
	NSDictionary *views = NSDictionaryOfVariableBindings(_requestButton, _responseButton, _textView);
	[aExpandedView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-4-[_requestButton]-6-[_responseButton]" options:0 metrics:nil views:views]];
	[aExpandedView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_textView]|" options:0 metrics:nil views:views]];
	[aExpandedView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_requestButton(==14)]-2-[_textView]-4-|" options:0 metrics:nil views:views]];
	[aExpandedView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_responseButton(==14)]" options:0 metrics:nil views:views]];
	
	return aExpandedView;
}

// prevent the cell from closing when expanded view is tapped
-(id)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
	id hitView = [super hitTest:point withEvent:event];
	if (hitView == _expandedView)
		return nil;
	else
		return hitView;
}

// user interaction
-(void)didTapResponse {
	UIFont *fontBackup = _responseButton.titleLabel.font;
	
	_responseButton.userInteractionEnabled = NO;
	_requestButton.userInteractionEnabled = YES;
	_responseButton.titleLabel.font = _requestButton.titleLabel.font;
	_requestButton.titleLabel.font = fontBackup;
	
	[_textView setContentOffset:CGPointMake(0,0)];
	[_textView setText:[_requestObject responseRawString]];
}
-(void)didTapRequest {
	UIFont *fontBackup = _requestButton.titleLabel.font;
	
	_requestButton.userInteractionEnabled = NO;
	_responseButton.userInteractionEnabled = YES;
	_requestButton.titleLabel.font = _responseButton.titleLabel.font;
	_responseButton.titleLabel.font = fontBackup;
	
	[_textView setContentOffset:CGPointMake(0,0)];
	[_textView setText:[_requestObject requestRawString]];
}
-(void)setIsExpanded:(BOOL)isExpanded {
	
	if (_isExpanded == isExpanded)
		return;
	
	_isExpanded = isExpanded;
	if (!_isExpanded) {
		[_textView removeFromSuperview];
		_textView = nil;
		
		[_responseButton removeFromSuperview];
		_responseButton = nil;
		
		[_requestButton removeFromSuperview];
		_requestButton = nil;
		
		[_expandedView removeFromSuperview];
		_expandedView = nil;
		
		_isExpanded = NO;
		return;
	}
	
	
	_expandedView = [self createExpandedView];
	[self addSubview:_expandedView];
	
	NSDictionary *views = NSDictionaryOfVariableBindings(_expandedView);
	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_expandedView]|" options:0 metrics:nil views:views]];
	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_expandedView(==140)]|" options:0 metrics:nil views:views]];
	
}
-(void)setRequestObject:(WebSniffObject *)requestObject {
	
	if (_requestObject == requestObject)
		return;
	
	_requestObject = requestObject;
	
	NSString *urlPathComponent = [[requestObject requestURL] lastPathComponent];
	if (!urlPathComponent)
		urlPathComponent = @"";
	
	NSMutableAttributedString *requestMethodString = [[NSMutableAttributedString alloc] initWithString:[requestObject requestMethod]];
	NSMutableAttributedString *spaceString = [[NSMutableAttributedString alloc] initWithString:@" "];
	NSMutableAttributedString *urlString = [[NSMutableAttributedString alloc] initWithString:urlPathComponent];
	
	NSMutableAttributedString *titleString = [[NSMutableAttributedString alloc] init];
	[titleString appendAttributedString:requestMethodString];
	[titleString appendAttributedString:spaceString];
	[titleString appendAttributedString:urlString];
	
	NSDictionary *requestMethodAttrs = @{NSFontAttributeName:[UIFont boldSystemFontOfSize:14], NSForegroundColorAttributeName:[UIColor lightGrayColor]};
	NSDictionary *urlAttrs = @{NSFontAttributeName:[UIFont systemFontOfSize:16]};
	
	[titleString setAttributes:requestMethodAttrs range:NSMakeRange(0, requestMethodString.length)];
	[titleString setAttributes:urlAttrs range:NSMakeRange(requestMethodString.length+1, urlString.length)];
	
	
	_titleLabel.attributedText = titleString;
	if ([requestObject statusCode]) {
		_statusCodeLabel.text = [NSString stringWithFormat:@"%lu", [requestObject statusCode]];
	}
	if ([requestObject statusCode] < 400) {
		_successImage.image = [UIImage imageNamed:@"checkmark"];
	} else {
		_successImage.image = [UIImage imageNamed:@"error"];
	}
}

@end
