//
//  WWXSRequest.m
//  MJTNet
//
//  Created by 莫景涛 on 14-4-30.
//  Copyright (c) 2014年 莫景涛. All rights reserved.
//

#import "NetRequest.h"
#import "MBProgressHUD.h"

@implementation NetRequest

- (void)startAsynrc:(BOOL)isWaitActivity AndWaitActivityTitle:(NSString*) waitTitle andViewCtl:(UIViewController*)viewCtl
{
    //是否要显示等待指示器
    self.showWaitActivityCtl = viewCtl ;
    if (isWaitActivity) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:_showWaitActivityCtl.view animated:YES];
        hud.alpha = 0.5 ;
        hud.mode = MBProgressHUDModeCustomView ;
        hud.labelText = waitTitle;
    }

    self.data = [NSMutableData data];
    self.connection = [NSURLConnection connectionWithRequest:self delegate:self];
}
#pragma mark-----NSURLConnectionDelegate
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.data appendData:data];
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    self.block(self.data);
    [MBProgressHUD hideHUDForView:_showWaitActivityCtl.view animated:YES];
}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [MBProgressHUD hideHUDForView:_showWaitActivityCtl.view animated:YES];
    UIAlertView *alertView =[ [UIAlertView alloc]initWithTitle:nil message:@"网络不给力" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
    [alertView show];
    
    if (self.failedBlock)
    {
        self.failedBlock();
    }
}
@end
