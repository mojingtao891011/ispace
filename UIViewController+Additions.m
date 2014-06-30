//
//  UIViewController+Additions.m
//  iSpace
//
//  Created by CC on 14-6-10.
//  Copyright (c) 2014年 xiabing. All rights reserved.
//

#import "UIViewController+Additions.h"


@implementation UIViewController (Additions)

- (void)showWaiting
{
    if (self.tabBarController.tabBar)
    {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.tabBarController.tabBar animated:YES];
        hud.mode = MBProgressHUDModeCustomView;
    }
    else if (self.view)
    {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeCustomView;
    }
}


- (void)hideWaiting
{
    if (self.tabBarController.tabBar)
    {
        [MBProgressHUD hideHUDForView:self.tabBarController.tabBar animated:YES];
    }
    else if (self.view)
    {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }
}


@end
