//
//  TabBarViewController.m
//  BedsideTreasure
//
//  Created by 莫景涛 on 14-4-1.
//  Copyright (c) 2014年 莫景涛. All rights reserved.
//

#import "TabBarViewController.h"
#import "DeviceHomeViewController.h"
#import "HomeViewController.h"
#import "SettingViewController.h"
#import "BaseNavViewController.h"
#import "HomeViewController.h"
#import "MyRingViewController.h"
#import "MessageManager.h"


#define kMessageTipViewTag      0x400



@interface TabBarViewController ()
@end

@implementation TabBarViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self _initViewController];
    
    // 监听设备消息数量变更通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleDeviceMessageChanged:)
                                                 name:NM_DEVICE_MESSAGE_CHANGED
                                               object:nil];
}


#pragma mark - 消息提醒

// 监听设备消息数量变更通知
- (void)handleDeviceMessageChanged:(NSNotification *)notification
{
    if ([[MessageManager defaultInstance] hasUnreadMessageForApp])
    {
        [self showMessageTip];
    }
    else
    {
        [self hideMessageTip];
    }
}


// 显示消息提醒
- (void)showMessageTip
{
    UIImageView *imageView = (UIImageView *)[_tabbarView viewWithTag:kMessageTipViewTag];
    if (!imageView)
    {
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake((ScreenWidth / 4) - 27, 4, 7.0f, 7.0f)];
        imageView.tag = kMessageTipViewTag;
        imageView.image = [UIImage imageNamed:@"band_number_background"];
        [_tabbarView addSubview:imageView];
    }
}


// 隐藏消息提醒
- (void)hideMessageTip
{
    UIImageView *imageView = (UIImageView *)[_tabbarView viewWithTag:kMessageTipViewTag];
    if (imageView)
    {
        [imageView removeFromSuperview];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//初始化视图
- (void)_initViewController
{
    DeviceHomeViewController *friendsCtl = [[DeviceHomeViewController alloc]init];
    HomeViewController *homeCtl = [[HomeViewController alloc]init];
    MyRingViewController *ringCtl = [[MyRingViewController alloc]init];
    SettingViewController *settingCtl = [[SettingViewController alloc]init];
    NSArray *ctlArr = @[  friendsCtl , homeCtl , ringCtl , settingCtl ];
    NSMutableArray *navArr = [[NSMutableArray alloc]initWithCapacity:ctlArr.count];
    for (UIViewController *ctl in ctlArr) {
        BaseNavViewController *nav = [[BaseNavViewController alloc]initWithRootViewController:ctl];
        nav.delegate = self ;
        [navArr addObject:nav];
    }
    self.viewControllers = navArr ;
    self.selectedIndex = 1 ;
    self.tabBar.hidden = YES ;
    [self CustomTabbar];
}
- (void)CustomTabbar
{
    _tabbarView = [[UIView alloc]initWithFrame:CGRectMake(-1, ScreenHeight - 48 , ScreenWidth+2, 49)];
    _tabbarView.layer.borderColor = NAVANDTABCOLOR.CGColor ;
    _tabbarView.layer.borderWidth = 1 ;
    _tabbarView.backgroundColor =  NAVANDTABCOLOR;
    [self.view addSubview:_tabbarView];
    NSArray *imgStateNormalArr = @[@"bt_friends_normal" , @"bt_home_normal" , @"bt_ring_normal" , @"bt_setting_normal" ] ;
    NSArray *imgStateSelectedArr = @[@"bt_friends_pressed" , @"bt_home_pressed" , @"bt_ring_pressed" , @"bt_setting_pressed" ] ;
    
    for (int i = 0 ; i < imgStateNormalArr.count; i++) {
       
        UIButton *big_button = [UIButton buttonWithType:UIButtonTypeCustom];
        [big_button setFrame:CGRectMake(i*80, 0, 80, 49)];
        big_button.tag = 200 + i ;
        big_button.backgroundColor = [UIColor clearColor];
        [big_button addTarget:self action:@selector(selectleViewController:) forControlEvents:UIControlEventTouchUpInside];
        [_tabbarView addSubview:big_button];
        
         UIButton *tabBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [tabBarButton setFrame:CGRectMake( (ScreenWidth/4 - 35) / 2 + i*80, 2, 35, 49)];
        tabBarButton.backgroundColor = [UIColor clearColor];
        [tabBarButton setBackgroundImage:[UIImage imageNamed:imgStateNormalArr[i]] forState:UIControlStateNormal];
        [tabBarButton setBackgroundImage:[UIImage imageNamed:imgStateSelectedArr[i]] forState:UIControlStateSelected];
        //tabBarButton.tintColor = [UIColor clearColor];
        tabBarButton.tag = 100 + i ;
        if (tabBarButton.tag == 101|| big_button.tag == 201) {
            _selectedButton = tabBarButton ;
            _selectedButton.selected = YES ;
        }
        [tabBarButton addTarget:self action:@selector(selectleViewController:) forControlEvents:UIControlEventTouchUpInside];
        [_tabbarView addSubview:tabBarButton];
    }
   
}
- (void)selectleViewController:(UIButton*)button
{
    if (button.tag < 200) {
        self.selectedIndex = button.tag - 100 ;
    }else{
        self.selectedIndex = button.tag - 200 ;
        button = (UIButton*)[_tabbarView viewWithTag:button.tag - 100];
    }
    _selectedButton.selected = NO ;
    button.selected = YES ;
    _selectedButton = button ;
}
//是否要显示BarItem
- (void)showBarItem:(BOOL)show
{
    [UIView animateWithDuration:0 animations:^{
        if (show) {
            self.tabBar.hidden = YES;
            [_tabbarView setFrame:CGRectMake(0, ScreenHeight-49, ScreenWidth,49)];
        }else{
           
            [_tabbarView setFrame:CGRectMake(-ScreenWidth, ScreenHeight-49, ScreenWidth,49)];
        }
        
    }];
    [self resizeView:show];
}
//隐藏tabBar后调整frame
- (void)resizeView:(BOOL)isFrame{
    
    
    for (UIView *subView in self.view.subviews) {
        
        if ([subView isKindOfClass:NSClassFromString(@"UITransitionView")]) {
            if (isFrame) {
                [subView setFrame:CGRectMake(subView.frame.origin.x, subView.frame.origin.y, ScreenWidth, ScreenHeight-49)];
            }else{
                [subView setFrame:CGRectMake(subView.frame.origin.x, subView.frame.origin.y, ScreenWidth, ScreenHeight)];
            }
        }
    }}

#pragma mark-----UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    
    NSInteger count = navigationController.viewControllers.count ;
    if (count == 1) {
        [self showBarItem:YES];
    }else{
        [self showBarItem:NO];
    }
}

@end
