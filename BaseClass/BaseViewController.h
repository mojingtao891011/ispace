//
//  BaseViewController.h
//  BedsideTreasure
//
//  Created by 莫景涛 on 14-4-1.
//  Copyright (c) 2014年 莫景涛. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseViewController : UIViewController<UIAlertViewDelegate>
{
    UIWindow *_tipWindow ;
    MBProgressHUD *_hud ;
}
@property(nonatomic , retain)UILabel *titleLabel ;
@property(nonatomic , assign)BOOL isBack ;

- (void)showStatus ;
- (void)showStatusTip:(BOOL)show andTitle:(NSString*)title ;

- (void)showHUD:(NSString*)title isDim:(BOOL)isDim ;
- (void)showHUDComplete:(NSString*)title isSuccess:(BOOL)isSuccess ;
- (void)hideHUD ;

@end
