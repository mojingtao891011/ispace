//
//  LoginViewController.h
//  BedsideTreasure
//
//  Created by 莫景涛 on 14-4-2.
//  Copyright (c) 2014年 莫景涛. All rights reserved.
//

#import "BaseViewController.h"
#import "BaseNavViewController.h"
@interface LoginViewController : BaseViewController<UITextFieldDelegate>

@property(nonatomic , assign)int  statusInt ;//保存从服务器反馈回来的整形值
@property(nonatomic , assign)int count ; //记录密码输错次数
@property(nonatomic , retain)NSString *lastUserName; //用来记录上一次输入的用户名

@property(nonatomic , assign)NSInteger originalHeight ;
@property (weak, nonatomic) IBOutlet UIView *bodyView;
@property (strong, nonatomic) IBOutlet UIView *alertView;
@property (weak, nonatomic) IBOutlet UILabel *alertInfo;

@property (strong, nonatomic) IBOutlet UIView *promptView;

@property (weak, nonatomic) IBOutlet UIView *userName_bg;
@property (weak, nonatomic) IBOutlet UIView *password_bg;
@property (weak, nonatomic) IBOutlet UITextField *userName;
@property (weak, nonatomic) IBOutlet UITextField *passWord;
@property (nonatomic , retain)NSString *MD5Password ;
@property(nonatomic , copy)NSString *baseUserName ;

- (IBAction)loginAction:(id)sender;
- (IBAction)RegisterAction:(id)sender;
- (IBAction)forgetPassWord:(id)sender;
- (IBAction)cancelLookPassWord:(id)sender;

@end
