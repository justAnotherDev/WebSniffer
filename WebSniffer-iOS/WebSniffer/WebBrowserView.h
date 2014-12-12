//
//  WebBrowserView.h
//  WebBrowserView
//
//  Created by Casey E on 12/10/14.
//  Copyright (c) 2014 Casey E. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WebBrowserView;
@protocol WebBrowserViewDelegate <NSObject>
-(void)webBrowserRequestsLog:(WebBrowserView*)webBrowser;
@end

@interface WebBrowserView : UIView

@property (nonatomic, assign) id <WebBrowserViewDelegate> delegate;

-(void)loadURL:(NSURL*)aURL;

@end
