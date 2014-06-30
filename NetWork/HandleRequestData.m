//
//  HandleRequestData.m
//  NSoperation
//
//  Created by 莫景涛 on 14-6-4.
//  Copyright (c) 2014年 莫景涛. All rights reserved.
//处理从网络请求下来的数据

#import "HandleRequestData.h"
#import "DevicesInfoModel.h"
#import "WeatherInfo.h"
#import "RecordModel.h"
#import "CacheHandle.h"
#import "MKNetWork.h"
#import "UserInfoModel.h"
#import "UploadModel.h"
#import "CheckVervsionClass.h"


#define LANDCOMMAND                     2049    //登陆
#define UPDETADEVICESCOMMAND    2051    //更新设备
#define GETFMINFO                               2053    //获取fm信息
#define SUBMITALERTSETTING              2056    //上传获取url、id
#define GETUSERINFO                            2063    //获取用户信息
#define GETONLINEMUSIC                     2074   //获取在线音乐、收藏
#define GETCOLLECTMUSIC                   2075      //获取在线音乐、收藏
#define GETWEATHERCOMMAND         2076   //获取天气信息
#define GETCHECKVERSION                           2079     //获取版本信息
#define GETMYUPLOAD                           2096  //获取我的上传

@implementation HandleRequestData
+ (HandleRequestData*)shareManager
{
    static HandleRequestData *shareManager = nil ;
    static dispatch_once_t once ;
    dispatch_once(&once , ^{
        shareManager = [[self alloc]init];
    });
    return shareManager ;
}
- (void)handleDate:(NSString*)command andResult:(id)result
{
    int commandInt = command.intValue ;
    if (commandInt == UPDETADEVICESCOMMAND)//更新设备2051
    {
        
        [[DevicesInfoModel shareManager]handleData:result andIsCacheRead:NO];
        
    }
    else if (commandInt == LANDCOMMAND)//登陆2049
    {
       NSString *error = result[@"message_body"][@"error"];
        if ([error isEqualToString:@"0"]) {
            //保存用户ID
            NSString *userID = result[@"message_body"][@"uid"];
            [[NSUserDefaults standardUserDefaults] setObject:userID forKey:@"uid"];
            [[NSUserDefaults standardUserDefaults]  synchronize];
           
        }
        [MKNetWork shareMannger].fininshBlock(error);
    }
    else if(commandInt == GETUSERINFO)//获取用户信息
    {
        [[UserInfoModel shareManager]creatUserInfoModel:result];
    }
    else if(commandInt == GETWEATHERCOMMAND)//获取天气信息2076
    {
        [[WeatherInfo shareManager]creatWeatherModel:result];
        
    }
    else if (commandInt == SUBMITALERTSETTING)//上传获取url、id 2056
    {
        int errorInt = [result[@"message_body"][@"error"] intValue];
        if (errorInt == 0) {
            //拼接上传地址 @"http://115.29.199.95:23000/iSpaceSvr/?cmd=3000&uid=79&fid=631&uts=1399448645&rid=-1&tpn=0"
            NSString *host = result[@"message_body"][@"host"] ;
            NSString *port = result[@"message_body"][@"port"] ;
            NSString *param = result[@"message_body"][@"param"] ;

//            NSString *hostName = [NSString stringWithFormat:@"%@:%@",host , port];
//            NSString *serverPath = [NSString stringWithFormat:@"/iSpaceSvr/?%@" , param];
 //           NSArray *paramArr = @[hostName , serverPath];
            NSArray *arr = @[host , port , param];
            [MKNetWork shareMannger].fininshBlock(arr);
           
        }else{
            [MKNetWork shareMannger].failBlock(result[@"message_body"][@"error"]);
           
        }

    }
    else if (commandInt == GETCOLLECTMUSIC || commandInt == GETONLINEMUSIC)//获取在线音乐、收藏2074 、2075
    {
        [[RecordModel sharedManager] creatModel:result];
    }
    else if (commandInt == GETFMINFO)//获取fm信息
    {
        int errorInt = [result[@"message_body"][@"error"] intValue];
        int totalInt = [result[@"message_body"][@"fm_info"][@"total"] intValue];
        if (errorInt == 0 && totalInt != 0) {
            NSArray *FMlist = result[@"message_body"][@"fm_info"][@"list"];
            NSMutableArray *fmArr = nil ;
            [fmArr removeAllObjects];
            if (fmArr == nil) {
                fmArr = [[NSMutableArray alloc]initWithCapacity:20];
            }
            for (NSString *FMChannel in FMlist) {
                [fmArr addObject:FMChannel];
            }
            [MKNetWork shareMannger].fininshBlock(fmArr);
           
        }else
        {
            [MKNetWork shareMannger].fininshBlock(result[@"message_body"][@"error"]);
            
        }
    }
    else if (commandInt == GETMYUPLOAD)//获取我的上传
    {
        [[UploadModel shareManager]creatUploadModel:result];
    }
    else if (commandInt == GETCHECKVERSION)//检测版本
    {
        [[CheckVervsionClass shareManager]starCheckVersion:result];
    }
    else
    {
        NSString *error = result[@"message_body"][@"error"];
        [MKNetWork shareMannger].fininshBlock(error);
        
    }
}
@end
