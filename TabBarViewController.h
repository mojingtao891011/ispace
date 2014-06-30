//
//  TabBarViewController.h
//  BedsideTreasure
//
//  Created by 莫景涛 on 14-4-1.
//  Copyright (c) 2014年 莫景涛. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TabBarViewController : UITabBarController<UINavigationControllerDelegate>
{
    UIButton *_selectedButton ;
    UIView *_tabbarView ;
}
- (void)showBarItem:(BOOL)show;
@end
