//
//  LoginViewController.m
//  BedsideTreasure
//
//  Created by 莫景涛 on 14-4-2.
//  Copyright (c) 2014年 莫景涛. All rights reserved.
//

#import "LoginViewController.h"
#import "RegisterViewController.h"
#import "LookPassWordViewController.h"
#import "TabBarViewController.h"
#import <CommonCrypto/CommonDigest.h>
#import "UIImageView+WebCache.h"
#import "MBProgressHUD.h"
#import "MKNetWork.h"


@interface LoginViewController ()

@end

@implementation LoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [super showStatus];
    _count = 0 ;
    self.userName_bg.layer.borderColor = NAVANDTABCOLOR.CGColor;
    self.userName_bg.layer.borderWidth = 1;
    self.password_bg.layer.borderColor = NAVANDTABCOLOR.CGColor;
    self.password_bg.layer.borderWidth = 1;
   
    
    self.originalHeight = self.bodyView.top ;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickTap:)];
    [self.view addGestureRecognizer:tap];
    
    BOOL isEmai = [[NSString alloc]isEmail:_userName.text];
    BOOL isNunberPbone = [[NSString alloc]checkTel:_userName.text] ;
    if (isEmai || isNunberPbone ) {
        _userName.text = USERNAME ;
    }else{
        _userName.text = [[NSString alloc]decodeBase64:USERNAME] ;
    }

     [self drawUserImageView];
    
    self.navigationController.navigationBarHidden = YES ;
    
    
    
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //删除启动图片通知
    [[NSNotificationCenter defaultCenter]postNotificationName:REMORESTARIMG object:nil userInfo:nil];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
   // [[UIApplication sharedApplication] setStatusBarHidden:YES];
    self.navigationController.navigationBarHidden = YES ;
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
  
    
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //self.navigationController.navigationBarHidden = NO ;
    //[[UIApplication sharedApplication] setStatusBarHidden:NO];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
   
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
   
}
#pragma mark------------------------------NoteAction---------------------------------------
#pragma mark-----NotificationCenter
- (void)keyboardWillShow:(NSNotification*)showNote
{
    if (ScreenHeight > 480) {
        return ;
    }
    CGRect rect =[[showNote userInfo][@"UIKeyboardFrameEndUserInfoKey"]CGRectValue] ;
    CGFloat  moveHeight ;
    if (Version < 7.0) {
        moveHeight = self.password_bg.bottom - ( ScreenHeight - rect.size.height  - 44 - 20) ;
    }else{
        moveHeight = self.password_bg.bottom - ( ScreenHeight - rect.size.height  - 44 ) ;
    }
    [UIView animateWithDuration:0.5 animations:^{
            self.bodyView.top = self.originalHeight ;
            self.bodyView.top = self.bodyView.top - moveHeight ;
    }];
}
- (void)keyboardWillHide:(NSNotification*)hideNote
{
    [UIView animateWithDuration:0.5 animations:^{
        self.bodyView.top = self.originalHeight ;
    }];
}
#pragma mark------------------------------UITextFieldDelegate---------------------------------------
#pragma mark-----UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES ;
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    self.userName_bg.layer.borderColor = NAVANDTABCOLOR.CGColor;
    
    if (textField.tag == 9527) {
        
        [self drawUserImageView];
    }
    return YES ;
}

#pragma mark------------------------------customAction---------------------------------------
#pragma mark-----clickTapAction
- (void)clickTap:(UITapGestureRecognizer*)tap
{
    [self.userName resignFirstResponder];
    [self.passWord resignFirstResponder];
}
#pragma mark-----customAction
#pragma mark-----画圆形的用户头像
- (void)drawUserImageView
{
    UIImageView * imageView = [[UIImageView alloc] init];
    imageView.frame = CGRectMake( 0.f, 0.f, 156.f, 156.f);
    imageView.left = (self.bodyView.width - imageView.width) / 2.0 ;
    imageView.layer.masksToBounds = YES;
    imageView.layer.cornerRadius = 78;
    [self.bodyView addSubview:imageView];
    imageView.backgroundColor = NAVANDTABCOLOR;
    
    UIImageView * imageView1 = [[UIImageView alloc] init];
    imageView1.frame = CGRectMake(20.f, 20.f, 150.f, 150.f);
    [imageView1 setCenter:CGPointMake(imageView.bounds.size.width / 2 , imageView.bounds.size.height / 2 )];
    imageView1.layer.masksToBounds = YES;
    imageView1.layer.cornerRadius = 75;
    [imageView addSubview:imageView1];
    imageView1.backgroundColor = [UIColor whiteColor];
    
    UIImageView * imageView2 = [[UIImageView alloc] init];
    imageView2.frame = CGRectMake(20.f, 20.f, 140.f, 140.f);
    [imageView2 setCenter:CGPointMake(imageView.bounds.size.width / 2 , imageView.bounds.size.height / 2 )];
    imageView2.layer.masksToBounds = YES;
    imageView2.layer.cornerRadius = 70;
    [imageView addSubview:imageView2];
    
    NSString *pic_url = [[NSUserDefaults standardUserDefaults]objectForKey:_userName.text];
    
    [imageView2 setImageWithURL:[NSURL URLWithString:pic_url] placeholderImage:[UIImage imageNamed:@"ic_test_head"]];
    
    
}
#pragma mark-----点击登录按钮时
- (IBAction)loginAction:(id)sender
{
//    //点击注册改变背景颜色
//    UIButton *landButton = (UIButton*)sender ;
//    [landButton setBackgroundColor:buttonSelectedBackgundColor];
    
   //在同一个界面两次输入不同用户名
    if (![_userName.text isEqualToString:_lastUserName]) {
        _count = 0 ;
    }
    _lastUserName = _userName.text ;
    //点击登录前判断用户名和密码是否为空
    if (_userName.text.length == 0 ) {
        _alertInfo.text = @"用户名不能为空" ;
        [self errorInfo];
        return ;
    }else if(_passWord.text.length == 0){
        _alertInfo.text = @"密码不能为空" ;
        [self errorInfo];
        return ;
    }
    
   
    //用户名Base64加密
    BOOL isEmai = [[NSString alloc]isEmail:_userName.text];
    BOOL isNunberPbone = [[NSString alloc]checkTel:_userName.text] ;
    if (isEmai || isNunberPbone ) {
        _baseUserName = _userName.text ;
    }else{
        _baseUserName = [[NSString alloc]encodeBase64:_userName.text];
    }

    _MD5Password = [[NSString alloc]md5:_passWord.text];
    
   
     //请求网络
    //等待指示器
    [super showHUD:@"正在登陆" isDim:YES];
    
    [[MKNetWork shareMannger] startNetworkWithNeedCommand:@"2049" andNeedUserId:@"0" AndNeedBobyArrKey:@[@"account" , @"password"] andNeedBobyArrValue:@[_baseUserName,  _MD5Password] needCacheData:NO needFininshBlock:^(id result){
        [super hideHUD];
        _statusInt = [result intValue];
        [self landAction];

    }needFailBlock:^(id fail){
        [super hideHUD];
    }];
    
}
#pragma mark-----从网络反馈数据回到主界面
- (void)landAction
{/*
    0:登录成功
    -1:登录失败,未知错误
    -200:用户不存在
    -202:用户已登录
    -206:密码错误
    -207:用户冻结(多次输入错误密码时冻结账户) 
    -208:账户异常,需要启用确认机制 
    -209:账户长期不用,需要重新激活
  */
    TabBarViewController *tabBarViewCtl = [[TabBarViewController  alloc]init];
    tabBarViewCtl.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal ;
        switch (_statusInt) {
        case 0:
            _count = 0 ;
            //保存用户名和密码
            [[NSUserDefaults standardUserDefaults] setObject:_baseUserName forKey:@"USERNAME"];
            [[NSUserDefaults standardUserDefaults]  synchronize];
             
            [[NSUserDefaults standardUserDefaults]setObject:_MD5Password forKey:@"MD5PASSWORD"];
            [[NSUserDefaults standardUserDefaults]synchronize];
                
            [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"QUIT"];
            [[NSUserDefaults standardUserDefaults]synchronize];
                
            [self presentViewController:tabBarViewCtl animated:YES completion:nil];
                return;
            break;
        case -1:
            _alertInfo.text = @"登录失败,未知错误" ;
            break;
        case -200:
            _alertInfo.text = @"用户不存在" ;
            break;
        case -202:
                //保存用户名和密码
                [[NSUserDefaults standardUserDefaults] setObject:_baseUserName forKey:@"USERNAME"];
                [[NSUserDefaults standardUserDefaults]  synchronize];
                [[NSUserDefaults standardUserDefaults]setObject:_MD5Password forKey:@"MD5PASSWORD"];
                [[NSUserDefaults standardUserDefaults]synchronize];

                [self presentViewController:tabBarViewCtl animated:YES completion:nil];
            _alertInfo.text = @"用户已登录" ;
            break;
        case -206:
            _alertInfo.text = @"密码错误" ;
            _count++;
            break;
        case -207:
            _alertInfo.text = @"用户冻结(多次输入错误密码时冻结账户)" ;
            break;
        case -208:
            _alertInfo.text = @"账户异常,需要启用确认机制" ;
            break;
        case -209:
            _alertInfo.text = @"账户长期不用,需要重新激活" ;
            break;

        default:
            break;
    }
    
    //非0 表示有错误
    if (_statusInt != 0) {
         [self errorInfo];
    }
   

}
#pragma mark-----错误提示
- (void)errorInfo
{
    //错误信息提示框
    self.promptView.layer.cornerRadius = 5.0 ;
    self.promptView.alpha = 0.0 ;
    self.promptView.frame = CGRectMake(20, 400, ScreenWidth-40, 60);
    [UIView animateWithDuration:0.5 animations:^{
        self.promptView.alpha = 1.0 ;
    }];
    [self.view addSubview:self.promptView];
    [self performSelector:@selector(hidesPromptView) withObject:nil afterDelay:2];
    
    //登录错误三次弹出找回密码框
    if (_userName.text.length == 0 || _passWord.text.length == 0) {
        return ;
    }

    if (_count >= 3)
    {
        self.alertView.height = ScreenHeight ;
        self.alertView.top = 0 ;
        self.alertView.alpha = 0.0 ;
        [UIView animateWithDuration:0.5 animations:^{
            self.alertView.alpha = 0.9 ;
            [self.view addSubview:self.alertView];
        }];
        
    }
    

}
#pragma mark-----隐藏错误信息提示框
- (void)hidesPromptView
{
    [UIView animateWithDuration:0.5 animations:^{
        self.promptView.alpha = 0.0 ;
    }];

}
#pragma mark-----点击注册按钮
- (IBAction)RegisterAction:(id)sender {
    
    RegisterViewController *registerViewCtl = [[RegisterViewController alloc]init];
    registerViewCtl.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal ;
    BaseNavViewController *nav = [[BaseNavViewController alloc]initWithRootViewController:registerViewCtl];
    [self presentViewController:nav animated:YES completion:nil];
    
    
    
}
#pragma mark-----忘记密码框的确定按钮(和找回密码按钮)
- (IBAction)forgetPassWord:(id)sender {
    
    UIButton *button = (UIButton*)sender ;
    [[MKNetWork shareMannger]cancelNetwork];
    if (button.tag == 100 &&_userName.text.length == 0) {
        self.userName_bg.layer.borderColor = ORANGECOLOR.CGColor;
        UIAlertView *alerView = [[UIAlertView alloc]initWithTitle:@"温馨提示" message:@"找回密码时用户名不能留空" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alerView show];
        return ;
    }
    
    [super showHUD:@"请稍等…" isDim:YES];
    //用户名Base64加密
    BOOL isEmai = [[NSString alloc]isEmail:_userName.text];
    BOOL isNunberPbone = [[NSString alloc]checkTel:_userName.text] ;
    if (isEmai || isNunberPbone ) {
        _baseUserName = _userName.text ;
    }else{
        _baseUserName = [[NSString alloc]encodeBase64:_userName.text];
    }
    //保存用户名
    [[NSUserDefaults standardUserDefaults] setObject:_baseUserName forKey:@"USERNAME"];
    [[NSUserDefaults standardUserDefaults]  synchronize];

    LookPassWordViewController *lookPassWordViewCtl = [[LookPassWordViewController alloc]init] ;
    [[MKNetWork shareMannger]startNetworkWithNeedCommand:@"2063" andNeedUserId:@"0" AndNeedBobyArrKey:@[@"account"] andNeedBobyArrValue:@[_baseUserName] needCacheData:NO needFininshBlock:^(id result){
        [super hideHUD];
       
        if (button.tag != 100) {
            [button setBackgroundColor:ORANGECOLOR];
            self.alertView.top = ScreenHeight ;
        }
        
        lookPassWordViewCtl.userInfoModel = (UserInfoModel*)result ;
        lookPassWordViewCtl.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal ;
        BaseNavViewController *nav = [[BaseNavViewController alloc]initWithRootViewController:lookPassWordViewCtl];
        [self presentViewController:nav animated:YES completion:nil];
        
        
    }needFailBlock:^(id fail){
        [super hideHUD];
        if ([fail isEqualToString:@"-200"]) {
            UIAlertView *alerView = [[UIAlertView alloc]initWithTitle:@"温馨提示" message:@"该用户尚未注册" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
            [alerView show];
        }
        

    }];
   
}
#pragma mark-----忘记密码框的取消按钮
- (IBAction)cancelLookPassWord:(id)sender {
    [UIView animateWithDuration:0.5 animations:^{
        self.alertView.alpha = 0.0 ;
    }];
    self.alertView.top = ScreenHeight ;
}
@end
