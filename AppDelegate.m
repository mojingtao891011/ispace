//
//  AppDelegate.m
//  BedsideTreasure
//
//  Created by 莫景涛 on 14-4-1.
//  Copyright (c) 2014年 莫景涛. All rights reserved.
//

#import "AppDelegate.h"
#import "Constants.h"
#import "iSpaceApp.h"
#import "CoreDataManager.h"
#import "MainViewController.h"
#import "BaseNavViewController.h"
#import "LoginViewController.h"
#import "CheckVervsionClass.h"
#import "GuideRootViewController.h"


@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
   
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    if ([[iSpaceApp defaultInstance] isFirstUseOnPhone])
    {
        GuideRootViewController *controller = [[GuideRootViewController alloc] initWithNibName:@"GuideRootViewController" bundle:nil];
        self.window.rootViewController = controller;
        
        // 开始使用通知
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleStartUseNotification:)
                                                     name:NM_START_USE
                                                   object:nil];
    }
    else
    {
        
        MainViewController *mainViewCtl = [[MainViewController alloc]init];
        self.window.rootViewController = mainViewCtl ;
        [self loadStarImg];
    }

    // 启动客户端相应功能
    [[iSpaceApp defaultInstance] initApp];
    [[iSpaceApp defaultInstance] start];
    
    //下线通知
     [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(kickedOutAction:) name:NM_SERVER_PUSH_MSG_8 object:nil];
    
    //删除启动图片通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(removeStarImg) name:REMORESTARIMG object:nil];
    
    
    
    return YES;
}
//加载启动图片
- (void)loadStarImg
{
    _bg_imgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    if (ScreenHeight <568) {
        
        _bg_imgView.image = [UIImage imageNamed:@"Default.png"];
    }else{
        _bg_imgView.image = [UIImage imageNamed:@"Default-568h.png"];
        
    }
    [self.window addSubview:_bg_imgView];
    
    _activityView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [_activityView setFrame:CGRectMake(150, 100, 50, 50)];
    _activityView.color = [UIColor redColor];
    _activityView.center = self.window.center ;
    [_bg_imgView addSubview:_activityView];
    [_activityView startAnimating];

}
//删除启动图片
- (void)removeStarImg
{
      [UIView animateWithDuration:0.5 animations:^{
        _bg_imgView.alpha = 0.0 ;
        [_activityView stopAnimating];
    }completion:^(BOOL flag){
        if (flag) {
            [_bg_imgView removeFromSuperview];
            [_activityView removeFromSuperview];
        }
    }];
    
}
// 处理开始使用通知
- (void)handleStartUseNotification:(NSNotification *)notification
{
    
    LoginViewController *loginViewCtl = [[LoginViewController alloc]init];
    self.window.rootViewController = loginViewCtl;
    
    
    [[iSpaceApp defaultInstance] setAlreadyUsedOnPhone];
}


#pragma mark------踢出登陆
- (void)kickedOutAction:(NSNotification*)kickedOutNote
{
    if (_isJustEnterForeground) {
        _isJustEnterForeground = NO ;
        return ;
    }
    //NSLog(@"用户在别的地方登陆");
    if (!_isBackground) {

        [[MKNetWork shareMannger]startNetworkWithNeedCommand:@"2054" andNeedUserId:USER_ID AndNeedBobyArrKey:@[@"cause"] andNeedBobyArrValue:@[ @"2" ] needCacheData:NO needFininshBlock:^(id result){
            
            int errorInt = [result intValue];
            if (errorInt == 0) {
                //退出通知
                [[NSNotificationCenter defaultCenter]postNotificationName:NM_USER_LOGOUT object:nil];
            }
        }needFailBlock:^(id fail){
            
        }];
        
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"下线通知" message:@"您的账号在别的地方登陆!" delegate:self cancelButtonTitle:@"退出" otherButtonTitles:@"重新登陆", nil];
        alertView.tag = 10 ;
        [alertView show];

    }
   
}
#pragma mark-------进入后台自动退出
- (void)appEnterBackgroundAutoExit
{
    if (USER_ID == NULL) {
        return ;
    }
    [[MKNetWork shareMannger]cancelNetwork];
    [[MKNetWork shareMannger]startNetworkWithNeedCommand:@"2054" andNeedUserId:USER_ID AndNeedBobyArrKey:@[@"cause"] andNeedBobyArrValue:@[@"0"] needCacheData:NO needFininshBlock:^(id result){
        if ([result isEqualToString:@"0"]) {
            NSLog(@"自动退出成功" );
        }
        
    }needFailBlock:^(id fail){
        NSLog(@"自动退出失败" );
    }];
}
#pragma mark-------进入前台自动登陆
- (void)appEnterForegroundAutoLogin
{
    if (USER_ID == NULL) {
        return ;
    }
    [[MKNetWork shareMannger]cancelNetwork];
    //NSLog(@"%@ , %@" , USERNAME , USERPASSWORD);
    if (USERNAME != NULL && USERPASSWORD != NULL) {
        [[MKNetWork shareMannger]startNetworkWithNeedCommand:@"2049" andNeedUserId:USER_ID AndNeedBobyArrKey:@[@"account" , @"password"] andNeedBobyArrValue:@[USERNAME , USERPASSWORD] needCacheData:NO needFininshBlock:^(id result){
            if ([result isEqualToString:@"0"]) {
                NSLog(@"自动登陆成功" );
                [self checkVersion];
            }

        }needFailBlock:^(id fail){
           NSLog(@"自动登陆失败" );
        }];

    }
}
#pragma mark------登陆成功自动检查版本
- (void)checkVersion
{
    [[MKNetWork shareMannger]startNetworkWithNeedCommand:@"2079" andNeedUserId:USER_ID AndNeedBobyArrKey:@[@"req_id" , @"type" , @"ver_num"] andNeedBobyArrValue:@[@"-1" , @"1" , VER_NUM] needCacheData:NO needFininshBlock:^(id result){
        NSLog(@"自动检查——ok");
        if ([result isKindOfClass:[CheckVervsionClass class]]) {
            CheckVervsionClass *model = result ;
            int versionInt = [model.ver_num intValue];
            int suggestInt = [model.suggest intValue];
            int curInt = [VER_NUM intValue];
            NSString *descript = [[NSString alloc]decodeBase64:model.descript] ;
            _url = model.url ;
            if (descript.length == 0) {
                descript = @"发现新版本请升级" ;
            }
            if (suggestInt == 1) {
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"升级通知" message:descript delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
                alertView.tag = 11 ;
                [alertView show];
            }
            else if(versionInt > curInt && suggestInt == 0){
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"升级通知" message:descript delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                alertView.tag = 12 ;
                [alertView show];
            }
            else{
                NSString *info = [NSString stringWithFormat:@"您当前为最新版本%0.1d" , versionInt];
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:info delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                [alertView show];
            }
            
        }
            }needFailBlock:^(id fail){
                NSLog(@"自动检查——fail");
               
    }];

}
#pragma mark-----UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if (alertView.tag == 10) {
        [[MKNetWork shareMannger]cancelNetwork];
        [self hideHUD];
        if (buttonIndex == 0) {
            [[NSNotificationCenter defaultCenter]postNotificationName:@"pushLogin" object:nil];
            //记录退出
            [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"QUIT"];
            [[NSUserDefaults standardUserDefaults]synchronize];
           
        }else if (buttonIndex == 1){
            
            [self showHUD:@"正在登陆" isDim:YES];
            [[MKNetWork shareMannger] startNetworkWithNeedCommand:@"2049" andNeedUserId:@"0" AndNeedBobyArrKey:@[@"account" , @"password"] andNeedBobyArrValue:@[USERNAME,  USERPASSWORD] needCacheData:NO needFininshBlock:^(id result){
                
                if ([result isEqualToString:@"0"]) {
                   [self showHUDComplete:@"登陆成功" isSuccess:YES];
                    //登陆成功通知
                    [[ NSNotificationCenter defaultCenter]postNotificationName:NM_USER_LOGIN_SUCCEEDED object:nil];
                    
                }else{
                    [self showHUDComplete:@"登陆失败" isSuccess:NO];
                    LoginViewController *loginViewCtl = [[LoginViewController alloc]init];
                    BaseNavViewController *nav = [[BaseNavViewController alloc]initWithRootViewController:loginViewCtl];
                    self.window.rootViewController = nav ;
                }
                
            }needFailBlock:^(id fail){
                    [self showHUDComplete:@"登陆失败" isSuccess:NO];
                    LoginViewController *loginViewCtl = [[LoginViewController alloc]init];
                    BaseNavViewController *nav = [[BaseNavViewController alloc]initWithRootViewController:loginViewCtl];
                    self.window.rootViewController = nav ;
            }];
            
        }
    }
    else if (alertView.tag == 11) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:_url]];
    }else if (alertView.tag == 12){
        if (buttonIndex == 1) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:_url]];
        }
    }
}
#pragma mark-----HUD
- (void)showHUD:(NSString*)title isDim:(BOOL)isDim
{
    _hud = [MBProgressHUD showHUDAddedTo:self.window animated:YES];
    _hud.dimBackground = isDim ;
    _hud.labelText = title ;
}
- (void)showHUDComplete:(NSString*)title isSuccess:(BOOL)isSuccess
{
    if (isSuccess) {
        _hud.customView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
    }else{
        _hud.customView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"failure.png"]];
    }
    _hud.mode = MBProgressHUDModeCustomView ;
    if (title.length > 0) {
        _hud.labelText = title ;
    }
    [_hud hide:YES afterDelay:1.5];
}
- (void)hideHUD
{
    [_hud hide:YES];
}

#pragma mark-----UIApplicationDelegate
// 应用程序暂停(例如:来电,来短信)
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    [[iSpaceApp defaultInstance] pause];
}


// 应用程序进入后台
- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [[iSpaceApp defaultInstance] stop];
    
    //开启一个后台任务
    __block UIBackgroundTaskIdentifier taskId ;
    taskId = [application beginBackgroundTaskWithExpirationHandler:^{
        [application endBackgroundTask:taskId];
    }];
    _isBackground = YES ;
    _isJustEnterForeground = NO ;
    [self appEnterBackgroundAutoExit];
    
    //[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(test) userInfo:nil repeats:YES];
    
}
// 应用程序进入前台
- (void)applicationWillEnterForeground:(UIApplication *)application
{
    _isBackground = NO ;
    _isJustEnterForeground = YES ;
    [self appEnterForegroundAutoLogin];
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [[iSpaceApp defaultInstance] start];
}


// 应用程序变为活跃
- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
}


// 应用程序即将终止
- (void)applicationWillTerminate:(UIApplication *)application
{
    [[iSpaceApp defaultInstance] uninitApp];
    
    NSLog(@"applicationWillTerminate");
    
}

#pragma mark - 推送相关

// 接收到APNS下发的DeviceToken
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSDictionary *userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:deviceToken, @"device_token", nil];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:NM_REGISTER_APNS_RESULT
                          object:nil
                        userInfo:userInfo];
}


// 注册APNS失败
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:NM_REGISTER_APNS_RESULT
                          object:nil
                        userInfo:nil];
}


// 接收到APNS推送的通知
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:NM_APNS_MESSAGE
                          object:nil
                        userInfo:userInfo];
}


@end
