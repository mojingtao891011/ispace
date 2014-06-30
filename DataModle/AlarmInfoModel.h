//
//  AlarmInfoModel.h
//  iSpace
//
//  Created by 莫景涛 on 14-4-21.
//  Copyright (c) 2014年 莫景涛. All rights reserved.

//单个 ALARM 信息结构

#import "WXBaseModel.h"

@interface AlarmInfoModel : WXBaseModel

@property(nonatomic , copy) NSString       *index ;
@property(nonatomic , copy) NSString       *state ;
@property(nonatomic , copy) NSString        *frequency ;
@property(nonatomic , copy) NSString        *sleep_times ;
@property(nonatomic , copy) NSString        *sleep_gap ;
@property(nonatomic , copy) NSString       *hour ;
@property(nonatomic , copy) NSString        *minute ;
@property(nonatomic , copy) NSString        *vol_level ;
@property(nonatomic , copy) NSString       *vol_type ;
@property(nonatomic , copy)NSString        *fm_chnl ;
@property(nonatomic , copy)NSString        *file_path ;
@property(nonatomic , copy)NSString        *file_id ;
@property(nonatomic , copy)NSString        *name ;
@property(nonatomic , copy)NSString         *flag ;

@end
