//
//  NSString+Additions.m
//  iSpace
//
//  Created by CC on 14-6-27.
//  Copyright (c) 2014年 xiabing. All rights reserved.
//

#import "NSString+Additions.h"


@implementation NSString (Additions)

// 测试一个字符串是否全是数字
- (BOOL)isNumber
{
    NSScanner *scanner = [NSScanner scannerWithString:self];
    NSInteger value;
    BOOL result = [scanner scanInt:&value] && [scanner isAtEnd];
    
    return result;
}


// 测试一个字符串是否是一个邮件地址
- (BOOL)isEmail
{
    NSRange range = [self rangeOfString:@"@"];
    BOOL result = (range.location == NSNotFound) ? FALSE : TRUE;
    
    return result;
}


@end
