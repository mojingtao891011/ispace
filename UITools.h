//
//  UITools.h
//  iSpace
//
//  Created by CC on 14-5-5.
//  Copyright (c) 2014年 xiabing. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UITools : NSObject

// 隐藏UITableView多余的分割线
+ (void)setExtraCellLineHidden:(UITableView *)tableView;

// 关闭iOS7 UITableView的分隔线缩进
+ (void)turnOffTableViewSeperatorIndent:(UITableView *)tableView;

// 返回性别描述
+ (NSString *)sexDescription:(int)index;

// 编码Base64
+ (NSString *)encodeBase64:(NSString *)string;

// 解码Base64字符串
+ (NSString *)decodeBase64:(NSString *)string;

// 显示标准警告对话框
+ (void)showMessage:(NSString *)message;

// 显示错误信息
+ (void)showError:(NSInteger)errorCode;

// 判断设备是否4寸屏幕
+ (BOOL)isiPhone5;

// 判断设备是否iOS7
+ (BOOL)isiOS7;


@end
