//
//  CacheHandle.m
//  iSpace
//
//  Created by 莫景涛 on 14-6-6.
//  Copyright (c) 2014年 莫景涛. All rights reserved.
//

#import "CacheHandle.h"

@implementation CacheHandle
//保存到沙盒的代码：
+ (void)saveCache:(NSString*)command andString:(id)str
{
    NSUserDefaults * setting = [NSUserDefaults standardUserDefaults];
    NSString *userName = [[NSString alloc]decodeBase64:USERNAME];
    NSString *key = [NSString stringWithFormat:@"%@%@" ,userName , command ];
    [setting setObject:str forKey:key];
    [setting synchronize];
}
//读取本地沙盒的代码,读取之前首先根据type和Id判断本地是否有
+ (id)getCache:(NSString*)command
{
    NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
    NSString *userName = [[NSString alloc]decodeBase64:USERNAME];
    NSString *key = [NSString stringWithFormat:@"%@%@" ,userName , command ];
    NSString *value = [settings objectForKey:key];
    return value;
}

@end
