//
//  DevicesInfoModel.m
//  iSpace
//
//  Created by 莫景涛 on 14-4-15.
//  Copyright (c) 2014年 莫景涛. All rights reserved.
//

#import "DevicesInfoModel.h"
#import "CacheHandle.h"

@implementation DevicesInfoModel
+(DevicesInfoModel*)shareManager
{
    static DevicesInfoModel *shareManager = nil ;
    static dispatch_once_t once ;
    dispatch_once(&once , ^{
        shareManager = [[self alloc]init];
    });
    return shareManager ;
}
- (void)handleData:(id)resultData andIsCacheRead:(BOOL)isCacheRead
{
    
    NSDictionary *returnDict = resultData[@"message_body"];
    NSString *returnInfo = returnDict[@"error"];
    int returnInt = [returnInfo intValue];
    
    //如果等于0说明有绑定设备
    if (returnInt == 0)
    {
        NSDictionary *dev_list = returnDict[@"dev_list"];
        NSArray *listArr = dev_list[@"list"] ;
        [_devicesTotalArr removeAllObjects];
        if (_devicesTotalArr == nil) {
            _devicesTotalArr = [[NSMutableArray alloc]initWithCapacity:4];
        }
        for (NSDictionary *deviceDict in listArr) {
            //  把闹钟信息装进模型里
            DevicesInfoModel *devicesInfoModel = [[DevicesInfoModel alloc]initWithDataDic:deviceDict];
            //把绑定设备个数一一装进数组里
            [_devicesTotalArr addObject:devicesInfoModel];
            
        }
        [MKNetWork shareMannger].fininshBlock(_devicesTotalArr);
       
    }
    else
    {
        [MKNetWork shareMannger].failBlock(returnInfo);
    }

}
- (NSDictionary*)attributeMapDictionary
{
    NSDictionary *dict = @{
                           
                           @"dev_idx" :                     @"dev_idx" ,
                           @"dev_online" :                @"dev_online" ,
                           @"dev_sn" :                       @"dev_sn",
                           @"dev_city" :                     @"dev_city",
                           @"dev_name" :                  @"dev_name",
                           @"unread" :                         @"unread",
                           @"led"  :                              @"led" ,
                           @"vol" :                                 @"vol"
                           
                           };
    return dict ;
}
- (void)setAttributes:(NSDictionary *)dataDic
{
    [super setAttributes:dataDic];
    
    if (_alermInfoArr == nil) {
            _alermInfoArr = [[NSMutableArray alloc]initWithCapacity:4];
        }

    NSDictionary *alarmDict = dataDic[@"alarm_info"] ;
    NSString *totalStr = alarmDict[@"total"] ;
    int total = totalStr.intValue ;
    //说明设备有设定闹钟（total != 0）
    if (total != 0) {
        NSArray *alarmInfoList = alarmDict[@"list"];
        for (NSDictionary *alarmInfoDict in alarmInfoList) {
        self.alermInfo = [[AlarmInfoModel alloc]initWithDataDic:alarmInfoDict];
            [_alermInfoArr addObject:self.alermInfo];
        }
        //通过index排序
            NSSortDescriptor *indexSort = [NSSortDescriptor sortDescriptorWithKey:@"index" ascending:YES];
            NSArray *indexSortArray = [NSArray arrayWithObject:indexSort];
            NSArray *sortedArray = [_alermInfoArr sortedArrayUsingDescriptors:indexSortArray];
            [_alermInfoArr removeAllObjects];
            [_alermInfoArr addObjectsFromArray:sortedArray];
    }
    //fm信息
    int fmTotal = [dataDic[@"fm_info"][@"total"] intValue] ;
    if (fmTotal != 0) {
        self.fm_list = dataDic[@"fm_info"][@"list"];
    }
    //管理员信息
    self.owerInfo = [[FriendInfoModel alloc]initWithDataDic:dataDic[@"owner"]];
    //密友信息
    self.friendInfo = [[FriendInfoModel alloc]initWithDataDic:dataDic[@"friend"]];
}


@end
