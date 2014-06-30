//
//  Tools.h
//  iSpace
//
//  Created by CC on 14-5-10.
//  Copyright (c) 2014年 莫景涛. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Tools : NSObject


// 获取应用程序文档目录
+ (NSString *)applicationDocumentDirectory;

// 判断文件是否存在
+ (BOOL)isFileExist:(NSString*)path;

// 删除文件
+ (BOOL)deleteFileIfExist:(NSString*)path;

// 转换timestamp为字符串格式
+ (NSString *)stringOfTimestamp:(NSNumber *)timestamp;

// 时:分描述
+ (NSString *)descriptionOfTimestamp:(NSNumber *)timestamp;

@end
