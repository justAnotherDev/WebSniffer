//
//  WebLoggerView.m
//  WebSniffer
//
//  Created by Casey E on 12/10/14.
//  Copyright (c) 2014 Casey E. All rights reserved.
//

#import "WebLoggerView.h"
#import "WebSniffer.h"
#import "WebLoggerCell.h"

@interface WebLoggerView() <UITableViewDataSource, UITableViewDelegate, WebSnifferDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIButton *recordingButton;
@property (nonatomic) BOOL currentlyAnimatingRecord;
@property (nonatomic, strong) NSMutableArray *selectedIndexes;
@end

static NSString *cellKey = @"loggerCell";

@implementation WebLoggerView

-(id)init {
	self = [super init];
	if (!self)
		return nil;
	
	// create the to toolbar
	UIView *toolbarView = [self createTopBar];
	[self addSubview:toolbarView];
	
	_tableView = [[UITableView alloc] init];
	_tableView.translatesAutoresizingMaskIntoConstraints = NO;
	_tableView.delegate	= self;
	_tableView.dataSource = self;
	_tableView.allowsMultipleSelection = NO;
	[self addSubview:_tableView];
	
	NSDictionary *views = NSDictionaryOfVariableBindings(_tableView, toolbarView);
	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(-1)-[toolbarView]-(-1)-|" options:0 metrics:nil views:views]];
	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_tableView]|" options:0 metrics:nil views:views]];
	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(-1)-[toolbarView(==60)][_tableView]|" options:0 metrics:nil views:views]];
	
	// start listening to the requests
	[[WebSniffer sharedInstance] addDelegate:self];
	
	[self pulseRecordButton];
	
	return self;
}
-(UIView*)createTopBar {
	UIView *toolbarView = [[UIView alloc] init];
	toolbarView.translatesAutoresizingMaskIntoConstraints = NO;
	toolbarView.backgroundColor = [UIColor colorWithRed:252/255. green:252/255. blue:252/255. alpha:1];
	toolbarView.layer.borderColor = [[UIColor darkGrayColor] CGColor];
	toolbarView.layer.borderWidth = 1;
	
	_recordingButton = [[UIButton alloc] init];
	_recordingButton.translatesAutoresizingMaskIntoConstraints = NO;
	_recordingButton.backgroundColor = [UIColor redColor];
	_recordingButton.layer.cornerRadius = 10;
	_recordingButton.alpha = 0.8;
	[_recordingButton addTarget:self action:@selector(didTapRecording) forControlEvents:UIControlEventTouchUpInside];
	[toolbarView addSubview:_recordingButton];
	
	UIButton *trashButton = [[UIButton alloc] init];
	trashButton.translatesAutoresizingMaskIntoConstraints = NO;
	[trashButton setImage:[UIImage imageNamed:@"waste"] forState:UIControlStateNormal];
	[trashButton addTarget:self action:@selector(didTapTrash) forControlEvents:UIControlEventTouchUpInside];
	[toolbarView addSubview:trashButton];
	
	
	UIButton *webViewButton = [[UIButton alloc] init];
	webViewButton.translatesAutoresizingMaskIntoConstraints = NO;
	[webViewButton setImage:[UIImage imageNamed:@"domain"] forState:UIControlStateNormal];
	[webViewButton addTarget:self action:@selector(didTapWebView) forControlEvents:UIControlEventTouchUpInside];
	[toolbarView addSubview:webViewButton];
	
	
	NSDictionary *views = NSDictionaryOfVariableBindings(webViewButton, _recordingButton, trashButton);
	[toolbarView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[_recordingButton(==20)]-10-[trashButton(==25)]" options:0 metrics:nil views:views]];
	[toolbarView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[webViewButton(==25)]-6-|" options:0 metrics:nil views:views]];
	[toolbarView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_recordingButton(==20)]-8-|" options:0 metrics:nil views:views]];
	[toolbarView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[webViewButton(==25)]-6-|" options:0 metrics:nil views:views]];
	[toolbarView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[trashButton(==25)]-6-|" options:0 metrics:nil views:views]];
	
	
	return toolbarView;
}
-(void)isBackOnscreen {
	[[WebSniffer sharedInstance] addDelegate:self];
	[_tableView reloadData];
}

// animation
-(void)pulseRecordButton {
	// bail if we aren't recording anymore
	if (![[WebSniffer sharedInstance] shouldLogRequests]) {
		[_recordingButton setAlpha:0.3];
		return;
	}
	
	// bail if this animation is already happing
	if (_currentlyAnimatingRecord) {
		return;
	}
	
	// get the new desired alpha
	float newAlpha = 0.3;
	if (newAlpha == _recordingButton.alpha)
		newAlpha = 0.8;
	
	// animate the alpha change
	[UIView animateWithDuration:1.5 delay:0.5 options:UIViewAnimationOptionAllowUserInteraction animations:^{
		[_recordingButton setAlpha:newAlpha];
		_currentlyAnimatingRecord = YES;
	} completion:^(BOOL complete) {
		_currentlyAnimatingRecord = NO;
		[self pulseRecordButton];
	}];
}

// user interaction
-(void)didTapWebView {
	// stop listening
	[[WebSniffer sharedInstance] removeDelegate:self];
	
	if ([_delegate respondsToSelector:@selector(webLoggerRequestsWebView:)]) {
		[_delegate webLoggerRequestsWebView:self];
	}
}
-(void)didTapRecording {
	[[WebSniffer sharedInstance] setShouldLogRequests:![[WebSniffer sharedInstance] shouldLogRequests]];
	
	[self pulseRecordButton];
}
-(void)didTapTrash {
	[_selectedIndexes removeAllObjects];
	[_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
	[[WebSniffer sharedInstance] clearLog];
	[_tableView reloadData];
}

// table view delegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [[WebSniffer sharedInstance] requestCount];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([_selectedIndexes containsObject:indexPath]) {
		return 180;
	}
	
	return 35;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	WebLoggerCell *aCell = [tableView dequeueReusableCellWithIdentifier:cellKey];
	if (!aCell) {
		aCell = [[WebLoggerCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellKey];
		aCell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
	
	WebSniffObject *aWebObject = [[WebSniffer sharedInstance] requestAtIndex:indexPath.row];
	[aCell setRequestObject:aWebObject];
	[aCell setIsExpanded:[_selectedIndexes containsObject:indexPath]];
	return aCell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if (!_selectedIndexes)
		_selectedIndexes = [NSMutableArray array];
	
	
	if ([_selectedIndexes containsObject:indexPath]) {
		[_selectedIndexes removeObject:indexPath];
	} else {
		[_selectedIndexes addObject:indexPath];
	}
	
	
	WebLoggerCell *aWebObject = (WebLoggerCell*)[tableView cellForRowAtIndexPath:indexPath];
	[aWebObject setIsExpanded:[_selectedIndexes containsObject:indexPath]];
	
	[tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

// web logger delegate
-(void)webSniffer:(WebSniffer *)webSniffer didStartLoading:(WebSniffObject *)aWebObject atIndex:(NSUInteger)requestIndex {
	dispatch_sync(dispatch_get_main_queue(), ^{
	
		[_tableView beginUpdates];
		[_tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:requestIndex inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
		[_tableView endUpdates];
	
		[_tableView setContentOffset:CGPointMake(0, _tableView.contentSize.height)];	/* Do UI work here */
	});
}
-(void)webSniffer:(WebSniffer *)webSniffer didFinishLoading:(WebSniffObject *)aWebObject atIndex:(NSUInteger)requestIndex{
	dispatch_sync(dispatch_get_main_queue(), ^{
		[_tableView beginUpdates];
		[_tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:requestIndex inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
		[_tableView endUpdates];
	});
}

@end
