//
//  iSpaceApp.m
//  iSpace
//
//  Created by CC on 14-5-26.
//  Copyright (c) 2014年 xiabing. All rights reserved.
//

#import "iSpaceApp.h"
#import "APNSManager.h"
#import "MessageManager.h"
#import "UITools.h"
#import "NSDictionary+Additions.h"


static iSpaceApp *_defaultInstance = nil;


@implementation iSpaceApp

+ (iSpaceApp *)defaultInstance
{
	@synchronized(self)
	{
		if (_defaultInstance == nil)
		{
			_defaultInstance = [[iSpaceApp alloc] init];
		}
	}
	return _defaultInstance;
}


// 初始化App
- (void)initApp
{
    [[APNSManager defaultInstance] initAPNSManager];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(handleUserLoginSucceeded:)
                   name:NM_USER_LOGIN_SUCCEEDED
                 object:nil];
    [center addObserver:self
               selector:@selector(handleUserLogout:)
                   name:NM_USER_LOGOUT
                 object:nil];
    [center addObserver:self
               selector:@selector(handleBroadcast:)
                   name:NM_SERVER_PUSH_MSG_101
                 object:nil];
}


// 终止APP
- (void)uninitApp
{
    [[APNSManager defaultInstance] uninitAPNSManager];
}


// 启动
- (void)start
{
    if (self.isLogined)
    {
        [[MessageManager defaultInstance] start];
    }
}


// 停止
- (void)stop
{
    [[MessageManager defaultInstance] stop];
}


// 暂停
- (void)pause
{
    
}


// 恢复
- (void)resume
{
    
}


// 用户已成功登录客户端
- (void)handleUserLoginSucceeded:(NSNotification *)notification
{
    // 记住登录状态
    self.isLogined = TRUE;
    
    // 登录成功时, 清除数字标识
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    UIRemoteNotificationType notificationTypes = UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert;
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:notificationTypes];
    
    [[MessageManager defaultInstance] start];
}


// 用户已登出
- (void)handleUserLogout:(NSNotification *)notification
{
    // 记住登录状态
    self.isLogined = TRUE;
    
    [[MessageManager defaultInstance] stop];
}


// 系统广播
- (void)handleBroadcast:(NSNotification *)notification
{
    if (self.isLogined)
    {
        NSDictionary *userInfo = notification.userInfo;
        NSDictionary *msgDict = [userInfo getDictionary:@"message_body"];
        NSString *message = [msgDict getString:@"arg2"];
        [UITools showMessage:message];
    }
}



// 用户是否第一次使用
- (BOOL)isFirstUseOnPhone
{
    NSString *value = [[NSUserDefaults standardUserDefaults] objectForKey:@"Alread_Used_Flag"];
    if ([value length] < 1 ||
        ![value isEqualToString:@"TRUE"])
    {
        return TRUE;
    }
    
    return FALSE;
}


- (void)setAlreadyUsedOnPhone
{
    [[NSUserDefaults standardUserDefaults] setObject:@"TRUE" forKey:@"Alread_Used_Flag"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


@end
