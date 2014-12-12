//
//  WebLoggerView.h
//  WebSniffer
//
//  Created by Casey E on 12/10/14.
//  Copyright (c) 2014 Casey E. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WebLoggerView;
@protocol WebLoggerViewDelegate <NSObject>
-(void)webLoggerRequestsWebView:(WebLoggerView*)webLogger;
@end

@interface WebLoggerView : UIView

@property (nonatomic, assign) id <WebLoggerViewDelegate> delegate;

-(void)isBackOnscreen;

@end
