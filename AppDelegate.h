//
//  AppDelegate.h
//  BedsideTreasure
//
//  Created by 莫景涛 on 14-4-1.
//  Copyright (c) 2014年 莫景涛. All rights reserved.
//

#import <UIKit/UIKit.h>
#import"MBProgressHUD.h"
#import"BaseViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    MBProgressHUD *_hud ;
    BOOL _isBackground ;
    BOOL _isJustEnterForeground ;
     NSString *_url ;
    UIImageView *_bg_imgView ;
    UIActivityIndicatorView *_activityView;
}
@property (strong, nonatomic) UIWindow *window;

@end
