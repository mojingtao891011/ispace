//
//  UserInfoModel.m
//  iSpace
//
//  Created by 莫景涛 on 14-4-17.
//  Copyright (c) 2014年 莫景涛. All rights reserved.
//

#import "UserInfoModel.h"

@implementation UserInfoModel
+(UserInfoModel*)shareManager
{
    static UserInfoModel *shareManager = nil ;
    static dispatch_once_t once ;
    dispatch_once(&once ,^{
        shareManager = [[self alloc]init ];
    });
    return shareManager ;
}
- (void)creatUserInfoModel:(id)result{
    
        
        NSDictionary *retrunDict = result[@"message_body"] ;
        NSString *errorInt = retrunDict[@"error"];
        if (errorInt.intValue != 0 ) {
            [MKNetWork shareMannger].failBlock(errorInt);
            return ;
        }
        //保存用户信息到用户信息模型
        UserInfoModel *userInfoModel = [[UserInfoModel alloc]initWithDataDic:retrunDict];
       [MKNetWork shareMannger].fininshBlock(userInfoModel);
    
        //保存用户ID
        NSDictionary *headDict = result[@"message_head"] ;
        NSString *userID = headDict[@"user_id"];
        [[NSUserDefaults standardUserDefaults] setObject:userID forKey:@"uid"];
        [[NSUserDefaults standardUserDefaults]  synchronize];

}
- (void)setAttributes:(NSDictionary *)dataDic
{
    [super setAttributes:dataDic];
    
    NSDictionary *baseInfodict = dataDic[@"detail"][@"base_info"];
    self.city = baseInfodict[@"city"];
    self.pic_id = baseInfodict[@"pic_id"];
    self.pic_url = baseInfodict[@"pic_url"];
    self.sex = baseInfodict[@"sex"];
    
    NSDictionary *accountInfoDict = baseInfodict[@"acc_info"];
    self.email = accountInfoDict[@"email"];
    self.name = accountInfoDict[@"name"];
    self.phone_no = accountInfoDict[@"phone_no"];
    self.uid = accountInfoDict[@"uid"];
    
    NSDictionary *birthdayInfoDict = dataDic[@"detail"][@"birthday"];
    self.year = birthdayInfoDict[@"year"];
    self.month = birthdayInfoDict[@"month"];
    self.day = birthdayInfoDict[@"day"];
    
}
@end
