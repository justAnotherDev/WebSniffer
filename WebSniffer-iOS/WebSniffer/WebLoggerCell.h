//
//  WebLoggerCell.h
//  WebSniffer
//
//  Created by Casey E on 12/12/14.
//  Copyright (c) 2014 Casey E. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebSniffer.h"

@interface WebLoggerCell : UITableViewCell

@property (nonatomic, strong) WebSniffObject *requestObject;
@property (nonatomic, assign) BOOL isExpanded;

@end
