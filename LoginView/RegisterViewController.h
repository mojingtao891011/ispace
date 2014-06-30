//
//  RegisterViewController.h
//  BedsideTreasure
//
//  Created by 莫景涛 on 14-4-2.
//  Copyright (c) 2014年 莫景涛. All rights reserved.
//

#import "BaseViewController.h"

@interface RegisterViewController : BaseViewController<UITextFieldDelegate >

@property (weak, nonatomic) IBOutlet UIScrollView *registerScrollView;
@property(nonatomic , retain)UITextField *tempTextField ;
@property(nonatomic , retain)NSNotification* keybordNote ;
@property(nonatomic , assign)NSInteger originalHeight ;

@property(nonatomic , retain)NSString *promptMessage ;
@property(nonatomic , assign)BOOL isAgree ;

@property(nonatomic , copy) NSString *baseUserName ;
@property (weak, nonatomic) IBOutlet UITextField *userName;
@property (weak, nonatomic) IBOutlet UITextField *userPassword;
@property (weak, nonatomic) IBOutlet UITextField *confirmPassword;
@property (weak, nonatomic) IBOutlet UITextField *email;
@property (weak, nonatomic) IBOutlet UIView *phoneNumberView;
@property (weak, nonatomic) IBOutlet UITextField *phoneNumber;
@property(nonatomic , retain)NSString *MD5Password ;
@property(nonatomic , retain)NSString *MD5ConfirmPassword ;

@property (strong, nonatomic) IBOutlet UIView *alertView;
@property (weak, nonatomic) IBOutlet UILabel *isSuccessLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property(nonatomic , retain)NSString *errorMessage ;
@property(nonatomic , assign)int errorInt ;

- (IBAction)checkActin:(id)sender;
- (IBAction)agreeAction:(id)sender;
- (IBAction)registerAction:(id)sender;
- (IBAction)registerOkAction:(id)sender;

@end
