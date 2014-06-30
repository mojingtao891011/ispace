//
//  BaseViewController.m
//  BedsideTreasure
//
//  Created by 莫景涛 on 14-4-1.
//  Copyright (c) 2014年 莫景涛. All rights reserved.
//

#import "BaseViewController.h"
#import <AudioToolbox/AudioToolbox.h>
#import "LoginViewController.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.titleLabel = [[UILabel alloc]init];
        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.titleLabel.textColor = [UIColor whiteColor] ;
        self.navigationItem.titleView = self.titleLabel ;
        self.titleLabel.font = [UIFont fontWithName:@"TrebuchetMS-Bold" size:20];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = ViewBackgroundColor;
    
    if (self.navigationController.viewControllers.count > 1 && !_isBack ) {
        UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [backButton setFrame:CGRectMake(0, 0, 50, 44)];
        backButton.backgroundColor = [UIColor clearColor];
        UIImageView *imgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 10, 12, 20)];
        [imgView setImage:[UIImage imageNamed:@"bt_back" ]];
        [backButton addSubview:imgView];
        [backButton addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *barBrttonItem = [[UIBarButtonItem alloc]initWithCustomView:backButton];
        self.navigationItem.leftBarButtonItem = barBrttonItem ;
    }

   [[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleLightContent  ];
    
 
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
    
}
- (void)showStatus
{
    //状态栏
    UIWindow *statuWindow = [[UIWindow alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 20)];
    statuWindow.windowLevel = UIWindowLevelStatusBar ;
    statuWindow.backgroundColor = NAVANDTABCOLOR;
    statuWindow.hidden = NO ;
    
    CGFloat IOSDevice = [[[UIDevice currentDevice]systemVersion]floatValue];
    if (IOSDevice >= 7.0 ) {
        [self.view addSubview:statuWindow];
    }

}
#pragma mark----StatusTip
- (void)showStatusTip:(BOOL)show andTitle:(NSString*)title 
{
    
    if (_tipWindow == nil) {
        _tipWindow = [[UIWindow alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 20)];
        _tipWindow.windowLevel = UIWindowLevelStatusBar ;
        _tipWindow.backgroundColor = [UIColor blackColor];
        
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 50)];
        label.textAlignment = NSTextAlignmentCenter ;
        label.textColor = [UIColor whiteColor];
        label.backgroundColor = NAVANDTABCOLOR;
        label.font = [UIFont systemFontOfSize:18.0];
        label.tag = 9527 ;
        [_tipWindow addSubview:label];
        
    }
    UILabel *titleLabel =(UILabel*) [_tipWindow viewWithTag:9527];
    if (show) {
        titleLabel.text = title ;
        _tipWindow.hidden = NO ;
    }else{
        titleLabel.text = title ;
        _tipWindow.hidden = NO ;
        [self performSelector:@selector(removeTipwindow) withObject:nil afterDelay:2];
    }
    
    //提示音
    NSString *musicPath = [[NSBundle mainBundle]pathForResource:@"pixiedust" ofType:@"wav"];
    NSURL *url = [NSURL URLWithString:musicPath];
    SystemSoundID  soundID ;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)url, &soundID);
    AudioServicesPlaySystemSound(soundID);
}
- (void)removeTipwindow{
    [UIView animateWithDuration:0.5 animations:^{
       _tipWindow.hidden = YES ; 
    }];
    
}
#pragma mark-----HUD
- (void)showHUD:(NSString*)title isDim:(BOOL)isDim
{
    _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
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
@end
