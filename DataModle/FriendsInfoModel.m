//
//  FriendsInfoModel.m
//  iSpace
//
//  Created by 莫景涛 on 14-4-26.
//  Copyright (c) 2014年 莫景涛. All rights reserved.
//

#import "FriendsInfoModel.h"

@implementation FriendsInfoModel
- (NSDictionary*)attributeMapDictionary
{
    NSDictionary *dict = @{
                           
                           @"city" :          @"city" ,
                           @"pic_id" :     @"pic_id" ,
                           @"pic_url" :    @"pic_url" ,
                           @"sex" :         @"sex"
                           
                           };
    return dict ;
}
- (void)setAttributes:(NSDictionary *)dataDic
{
    [super setAttributes:dataDic];
    NSDictionary *accDict  = dataDic[@"acc_info"];
    self.email = accDict[@"email"];
    self.name = accDict[@"name"];
    self.phone_no = accDict[@"phone_no"];
    self.uid = accDict[@"uid"];
    
}

@end
