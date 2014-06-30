//
//  CacheHandle.h
//  iSpace
//
//  Created by 莫景涛 on 14-6-6.
//  Copyright (c) 2014年 莫景涛. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CacheHandle : NSObject

//保存到沙盒的代码：
+ (void)saveCache:(NSString*)command andString:(id)str;

//读取本地沙盒的代码,读取之前首先根据type和Id判断本地是否有
+ (id)getCache:(NSString*)command ;

@end
