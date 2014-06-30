//
//  AgreementViewController.m
//  iSpace
//
//  Created by 莫景涛 on 14-4-14.
//  Copyright (c) 2014年 莫景涛. All rights reserved.
//

#import "AgreementViewController.h"

@interface AgreementViewController ()

@end

@implementation AgreementViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.titleLabel.text = @"用户协议" ;
        [self.titleLabel sizeToFit];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
   
    int height = ScreenHeight - 64 ;
    
    if (Version > 6.9 && Version < 7.09) {
        height = height+64 ;
    }
    _webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, height)];
    _webView.delegate = self ;
    [self.view addSubview:_webView];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:AGREEMENT_URL]];
    [_webView loadRequest:request];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark-------UIWebViewDelegate
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [super showHUD:@"正在加载" isDim:YES];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [super hideHUD];
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error;
{
    [super showHUDComplete:@"加载失败" isSuccess:NO];
}

@end
