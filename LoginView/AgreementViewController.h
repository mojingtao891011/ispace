//
//  AgreementViewController.h
//  iSpace
//
//  Created by 莫景涛 on 14-4-14.
//  Copyright (c) 2014年 莫景涛. All rights reserved.
//

#import "BaseViewController.h"

#define AGREEMENT_URL  @"http://www.momoda.com/help/html/userProtocol.html"
@interface AgreementViewController : BaseViewController<UIWebViewDelegate>
{
    UIWebView *_webView ;
}

@end
