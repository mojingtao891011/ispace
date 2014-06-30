//
//  FriendInfoModel.h
//  iSpace
//
//  Created by 莫景涛 on 14-5-8.
//  Copyright (c) 2014年 莫景涛. All rights reserved.
//

#import "WXBaseModel.h"

@interface FriendInfoModel : WXBaseModel

@property(nonatomic , copy)NSString             *name ;
@property(nonatomic , copy)NSString             *email ;
@property(nonatomic , copy)NSString             *phone_no ;
@property(nonatomic , copy)NSString             *uid ;

@property(nonatomic , copy)NSString             *city ;
@property(nonatomic , copy)NSString             *pic_id ;
@property(nonatomic , copy)NSString             *pic_url ;
@property(nonatomic , copy)NSString             *sex ;


@end
