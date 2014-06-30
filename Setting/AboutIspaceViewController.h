//
//  AboutIspaceViewController.h
//  iSpace
//
//  Created by bear on 14-6-19.
//  Copyright (c) 2014年 莫景涛. All rights reserved.
//

#import "BaseViewController.h"

typedef enum  WW_direction{
    versionAbout = 0, //版本介绍
    userAgreement  = 1 ,//用户协议
}WW_direction;
@interface AboutIspaceViewController : BaseViewController<UIWebViewDelegate>
{
    UIWebView *_webView ;
}
@property (nonatomic , copy)NSString *urlStr ;
@property (nonatomic , assign)WW_direction direction ;
@end
