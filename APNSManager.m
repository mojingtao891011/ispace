//
//  PushNotificationManager.m
//  iSpace
//
//  Created by CC on 14-5-10.
//  Copyright (c) 2014年 xiabing. All rights reserved.
//

#import "APNSManager.h"
#import "Constants.h"
#import "MessageManager.h"
#import "NSDictionary+Additions.h"


static APNSManager *_defaultInstance = nil;


@interface APNSManager (Private)

//@property (copy, nonatomic) NSString *deviceToken;

@end



@implementation APNSManager


+ (APNSManager *)defaultInstance
{
	@synchronized(self)
	{
		if (_defaultInstance == nil)
		{
			_defaultInstance = [[APNSManager alloc] init];
		}
	}
	return _defaultInstance;
}


// 启动
- (void)initAPNSManager
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(handleRegisterAPNSResult:)
                   name:NM_REGISTER_APNS_RESULT
                 object:nil];
    [center addObserver:self
               selector:@selector(handleAPNSMessage:)
                   name:NM_APNS_MESSAGE
                 object:nil];
}


// 启停
- (void)uninitAPNSManager
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self];
}


// 处理注册APNS结果
- (void)handleRegisterAPNSResult:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    if (userInfo)        // 成功
    {
        NSData *deviceTokenData = [userInfo objectForKey:@"device_token"];
        NSString *deviceTokenString = [[NSString alloc] initWithFormat:@"%@", deviceTokenData];
        deviceTokenString = [deviceTokenString stringByReplacingOccurrencesOfString:@" " withString:@""];
        deviceTokenString = [deviceTokenString stringByReplacingOccurrencesOfString:@"<" withString:@""];
        deviceTokenString = [deviceTokenString stringByReplacingOccurrencesOfString:@">" withString:@""];

        [self uploadDeviceToken:deviceTokenString];
    }
    else                // 失败
    {
    }
}



// 处理获取到的推送消息
- (void)handleAPNSMessage:(NSNotification *)notification
{
    // 登录成功时, 清除数字标识
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;

    NSDictionary *userInfo = [notification userInfo];
    NSInteger ec_type = [userInfo getInteger:@"ec_type"];
    switch (ec_type)
    {
        case 8:                             // 添加好友通知
        {
            NSNotification *notification = [NSNotification notificationWithName:NM_SERVER_PUSH_MSG_8
                                                                         object:nil
                                                                       userInfo:nil];
            [[NSNotificationCenter defaultCenter] postNotification:notification];
        }
        break;
        default:
            break;
    }
}



// 上传设备Token到推送服务器
- (void)uploadDeviceToken:(NSString *)deviceToken
{
    NSString* deviceName = [[UIDevice currentDevice] systemName];       // 设备名称
    NSString* osVersion = [[UIDevice currentDevice] systemVersion];     // 手机系统版本

    NSMutableDictionary *params = [NetDataService needCommand:@"2092"
                                                andNeedUserId:USER_ID
                                            AndNeedBobyArrKey:@[@"type", @"brand", @"os_version", @"imei"]
                                          andNeedBobyArrValue:@[@"1", deviceName, osVersion, deviceToken]];
    [NetDataService requestWithUrl:SVR_URL
                        dictParams:params
                        httpMethod:@"POST"
                 andisWaitActivity:YES
              andWaitActivityTitle:nil
                        andViewCtl:nil
                     isShowWaiting:FALSE
                       failedBlock:NULL
                     completeBlock:^(id result)
     {
         dispatch_async(dispatch_get_main_queue(),
                        ^{
                            [self handleUploadDeviceTokenResult:result];
                        });
     }];
}


// 处理上传Token结果
- (void)handleUploadDeviceTokenResult:(id)result
{
    NSDictionary *msgBody = [result objectForKey:@"message_body"];
    NSNumber *errorCode = [msgBody objectForKey:@"error"];
    if ([errorCode integerValue] == 0)          // 成功
    {
        NSLog(@"%@", result);
    }
}

@end
