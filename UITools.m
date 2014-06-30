//
//  UITools.m
//  iSpace
//
//  Created by CC on 14-5-5.
//  Copyright (c) 2014年 xiabing. All rights reserved.
//

#import "UITools.h"
#import "GTMBase64.h"


@implementation UITools

// 隐藏UITableView多余的分割线
+ (void)setExtraCellLineHidden:(UITableView *)tableView
{
    UIView *view =[ [UIView alloc]init];
    view.backgroundColor = [UIColor clearColor];
    [tableView setTableFooterView:view];
    [tableView setTableHeaderView:view];
}


// 关闭iOS7 UITableView的分隔线缩进
+ (void)turnOffTableViewSeperatorIndent:(UITableView *)tableView
{
    if ([tableView respondsToSelector:@selector(setSeparatorInset:)])
    {
        tableView.separatorInset = UIEdgeInsetsZero;
    }
}


// 返回性别描述
+ (NSString *)sexDescription:(int)index
{
    if (index == 0)         // 女
    {
        return NSLocalizedString(@"Female Text", nil);
    }
    else if (index == 1)    // 男
    {
        return NSLocalizedString(@"Male Text", nil);
    }
    
    return @"未知";
}



// 编码Base64
+ (NSString *)encodeBase64:(NSString *)string
{
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSData *base64Data = [GTMBase64 encodeData:data];
    NSString *base64String = [[NSString alloc] initWithData:base64Data encoding:NSUTF8StringEncoding];
    
    return base64String;
}


// 解码Base64字符串
+ (NSString *)decodeBase64:(NSString *)string
{
    NSData *data = [GTMBase64 decodeString:string];
    NSString *newString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    return newString;
}


// 显示标准警告对话框
+ (void)showMessage:(NSString *)message
{
    NSString *okString = NSLocalizedString(@"OK Text", nil);
	UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:nil
                          message:message
                          delegate:nil
                          cancelButtonTitle:okString
                          otherButtonTitles:nil];
	[alert show];
}


// 显示错误信息
+ (void)showError:(NSInteger)errorCode
{
    NSString *errorMessage = nil;
    
    switch (errorCode)
    {
        case 1:
            errorMessage = @"已经是你的好友了, 禁止重复添加";
            break;
        case -100:
            errorMessage = @"设备不存在或序列号非法";
            break;
        case -101:
            errorMessage = @"未知错误";
            break;
        case -103:
            errorMessage = @"设备未绑定好友";
            break;
        case -105:
            errorMessage = @"设备已授权给其他用户";
            break;
        case -200:
            errorMessage = @"用户不存在";
            break;
        case -213:
            errorMessage = @"系统禁止添加自己";
            break;
        case -214:
            errorMessage = @"已经达到收藏数量上线,不能再收藏了";
            break;
        case -300:
            errorMessage = @"不能授权给自己";
            break;
        case -304:
            errorMessage = @"好友不能解绑管理员";
            break;
        case -2506:
            errorMessage = @"没有找到FM信息";
            break;
        default:
            errorMessage = @"未知错误";
            break;
    }
    
    if (errorMessage)
    {
        [self showMessage:errorMessage];
    }
}


// 判断设备是否4寸屏幕
+ (BOOL)isiPhone5
{
    return [UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO;
}


// 判断设备是否iOS7
+ (BOOL)isiOS7
{
    return ([[[UIDevice currentDevice] systemVersion] compare:@"7.0"] != NSOrderedAscending);
}

@end
