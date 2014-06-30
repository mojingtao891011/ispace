//
//  FriendInfoModel.m
//  iSpace
//
//  Created by 莫景涛 on 14-5-8.
//  Copyright (c) 2014年 莫景涛. All rights reserved.
//

#import "FriendInfoModel.h"

@implementation FriendInfoModel
- (NSDictionary*)attributeMapDictionary
{
    NSDictionary *dict = @{
                           
                           @"city" :                @"city" ,
                           @"pic_id" :             @"pic_id" ,
                           @"pic_url" :            @"pic_url" ,
                           @"sex" :                 @"sex"
                           
                           };
    return dict ;
}
- (void)setAttributes:(NSDictionary *)dataDic
{
    [super setAttributes:dataDic];
    NSDictionary *acc_infoDict = dataDic[@"acc_info"];
    self.email = acc_infoDict[@"email"];
    self.name = acc_infoDict[@"name"];
    self.phone_no = acc_infoDict[@"phone_no"];
    self.uid = acc_infoDict[@"uid"];
}

@end
