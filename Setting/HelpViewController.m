//
//  HelpViewController.m
//  BedsideTreasure
//
//  Created by 莫景涛 on 14-4-6.
//  Copyright (c) 2014年 莫景涛. All rights reserved.
//

#import "HelpViewController.h"

@interface HelpViewController ()

@end

@implementation HelpViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.titleLabel.text = @"使用帮助" ;
        [self.titleLabel sizeToFit];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    int height = ScreenHeight -10;
   
    if (Version > 6.9 && Version < 7.09) {
        height = height+64 ;
    }else if (Version<7.0){
        height = height - 54 ;
    }
    _webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, height)];
    _webView.delegate = self ;
    [self.view addSubview:_webView];
    
//    self.webView.translatesAutoresizingMaskIntoConstraints = NO ;
//    //创建一个存放约束的数组
//    NSMutableArray * tempConstraints = [NSMutableArray array];
//    /*
//     创建竖直方向的约束:在竖直方向上,leftButton距离父视图顶部30，leftButton高度30
//     */
//    [tempConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_webView(568)]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_webView)]];
//    [tempConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_webView(568)]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_webView)]];
//    
//    [self.view addConstraints:tempConstraints];

    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:HELP_URL]];
    [self.webView loadRequest:request];
        
//    NSURL *url = [NSURL URLWithString:HELP_URL];
//    [[UIApplication sharedApplication] openURL:url];
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
