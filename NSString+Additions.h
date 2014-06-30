//
//  NSString+Additions.h
//  iSpace
//
//  Created by CC on 14-6-27.
//  Copyright (c) 2014年 xiabing. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSString (Additions)

// 测试一个字符串是否全是数字
- (BOOL)isNumber;

// 测试一个字符串是否是一个邮件地址
- (BOOL)isEmail;

@end
