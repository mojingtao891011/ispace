//
//  HandleRequestData.h
//  NSoperation
//
//  Created by 莫景涛 on 14-6-4.
//  Copyright (c) 2014年 莫景涛. All rights reserved.
//处理从网络请求下来的数据

#import <Foundation/Foundation.h>


@interface HandleRequestData : NSObject

+ (HandleRequestData*)shareManager ;

- (void)handleDate:(NSString*)command andResult:(id)result;


@end
