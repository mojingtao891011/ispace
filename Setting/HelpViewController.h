//
//  HelpViewController.h
//  BedsideTreasure
//
//  Created by 莫景涛 on 14-4-6.
//  Copyright (c) 2014年 莫景涛. All rights reserved.
//

#import "BaseViewController.h"

#define HELP_URL @"http://www.momoda.com/help/html/help.html"
@interface HelpViewController : BaseViewController<UIWebViewDelegate>

@property (retain, nonatomic) UIWebView *webView;
@end
