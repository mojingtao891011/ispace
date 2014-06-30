//
//  CheckVervsionClass.h
//  iSpace
//
//  Created by bear on 14-6-24.
//  Copyright (c) 2014年 莫景涛. All rights reserved.
//

#import "WXBaseModel.h"

@interface CheckVervsionClass : WXBaseModel

@property(nonatomic , copy)NSString     *ver_num ;            //最新版本数字
@property(nonatomic , copy)NSString     *ver_str ;               //最新版本字符
@property(nonatomic , copy)NSString     *descript ;              //新版本说明
@property(nonatomic , copy)NSString     *type ;                   //用户端类型
@property(nonatomic , copy)NSString     *url ;                       //下载地址
@property(nonatomic , copy)NSString     *suggest ;               //升级强制性

+(CheckVervsionClass*)shareManager ;
- (void)starCheckVersion:(id)result ;
@end
