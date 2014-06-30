//
//  Tools.m
//  iSpace
//
//  Created by CC on 14-5-10.
//  Copyright (c) 2014年 xiabing. All rights reserved.
//

#import "Tools.h"

@implementation Tools

// 获取应用程序文档目录
+ (NSString *)applicationDocumentDirectory
{
    NSArray *array = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [array objectAtIndex:0];
    
    return documentDirectory;
}


// 判断文件是否存在
+ (BOOL)isFileExist:(NSString*)path
{
    return [[NSFileManager defaultManager] fileExistsAtPath:path];
}


// 删除文件
+ (BOOL)deleteFileIfExist:(NSString*)path
{
    return [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
}


// 转换timestamp为字符串格式
+ (NSString *)stringOfTimestamp:(NSNumber *)timestamp
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[timestamp integerValue]];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *string = [dateFormatter stringFromDate:date];
    
    return string;
}


// 时:分描述
+ (NSString *)descriptionOfTimestamp:(NSNumber *)timestamp
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[timestamp integerValue]];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm"];
    NSString *string = [dateFormatter stringFromDate:date];
    
    return string;
}


@end
