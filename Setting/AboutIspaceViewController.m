//
//  AboutIspaceViewController.m
//  iSpace
//
//  Created by bear on 14-6-19.
//  Copyright (c) 2014年 莫景涛. All rights reserved.
//

#import "AboutIspaceViewController.h"

@interface AboutIspaceViewController ()

@end

@implementation AboutIspaceViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
//        if (_test == versionAbout) {
//            self.titleLabel.text = @"关于床头宝" ;
//            [self.titleLabel sizeToFit];
//        }else{
//            self.titleLabel.text = @"关于床头宝22" ;
//            [self.titleLabel sizeToFit];
//        }
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
   
    if (_direction == versionAbout) {
        self.titleLabel.text = @"版本介绍" ;
        [self.titleLabel sizeToFit];
    }else{
        self.titleLabel.text = @"用户协议" ;
        [self.titleLabel sizeToFit];
    }

    int height = ScreenHeight - 10 ;
    
    if (Version > 6.9 && Version < 7.09) {
        height = height+64 ;
    }else if (Version<7.0){
        height = height - 54 ;
    }
    _webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, height)];
    _webView.delegate = self ;
    [self.view addSubview:_webView];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:_urlStr]];
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
