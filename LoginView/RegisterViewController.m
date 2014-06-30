//
//  RegisterViewController.m
//  BedsideTreasure
//
//  Created by 莫景涛 on 14-4-2.
//  Copyright (c) 2014年 莫景涛. All rights reserved.
//

#import "RegisterViewController.h"
#import "TabBarViewController.h"
#import "AgreementViewController.h"
#import <CommonCrypto/CommonDigest.h>

@interface RegisterViewController ()

@end

@implementation RegisterViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.titleLabel.text = @"注册" ;
        [self.titleLabel sizeToFit];
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    _userPassword.secureTextEntry = YES , _confirmPassword.secureTextEntry = YES ;
    self.originalHeight = self.registerScrollView.top ;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickTap:)];
    [self.view addGestureRecognizer:tap];
    
   //
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
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
   
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}
- (void)backAction
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark-----clickTapAction
- (void)clickTap:(UITapGestureRecognizer*)tap
{
    for (UIView *subView in self.registerScrollView.subviews) {
        for (UIView *view in subView.subviews) {
            if ([view isKindOfClass:[UITextField class]]) {
                [view resignFirstResponder];
            }
        }
    }
}
#pragma mark-----NotificationCenter
- (void)keyboardWillShow:(NSNotification*)showNote
{
    if (self.tempTextField.tag != 5) {
        return ;
    }else if (ScreenHeight > 480)
    {
        return ;
    }
    CGRect rect =[[showNote userInfo][@"UIKeyboardFrameEndUserInfoKey"]CGRectValue] ;
    self.keybordNote = showNote ;
    CGFloat  moveHeight = self.phoneNumberView.bottom - ( ScreenHeight - rect.size.height - 44 - 20) ;
    [UIView animateWithDuration:0.5 animations:^{
        self.registerScrollView.top = self.originalHeight ;
        self.registerScrollView.top = self.registerScrollView.top - moveHeight ;
    }];
    
}
- (void)keyboardWillHide:(NSNotification*)hideNote
{
    [UIView animateWithDuration:0.5 animations:^{
        self.registerScrollView.top = self.originalHeight ;
    }];
}

#pragma mark-----UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES ;
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    self.tempTextField = textField ;
    [self keyboardWillShow:self.keybordNote ];
    return YES ;
}
#pragma mark-----customAction
#pragma mark------是否同意使用条款
- (IBAction)checkActin:(id)sender {
    UIButton *button = (UIButton*)sender ;
    button.selected = !button.selected ;
    _isAgree = button.selected ;
}
#pragma mark------查看同意使用条款
- (IBAction)agreeAction:(id)sender {
    AgreementViewController *agreeViewCtl = [[AgreementViewController alloc]init];
    [self.navigationController pushViewController:agreeViewCtl animated:YES];
}
#pragma mark------提交注册信息
- (IBAction)registerAction:(id)sender {
    
//    //点击注册改变背景颜色
//    UIButton *button = (UIButton*)sender ;
//    [button setBackgroundColor:buttonSelectedBackgundColor];
    
    //判断输入信息是否符合要求
    BOOL isRight = [self judgeUserEnter];
    if (isRight) {
        [self startNetwork];
    }else
    {
        UIAlertView *MessageAlertView = [[UIAlertView alloc]initWithTitle:@"友情提示：" message:_promptMessage delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [MessageAlertView show];
    }
    
}
#pragma mark------开始网络请求
- (void)startNetwork
{
    
    //请求体
    //用户名Base64加密
    NSData *data = [_userName.text dataUsingEncoding:NSUTF8StringEncoding];
    _baseUserName = [[NSString alloc] initWithData:[GTMBase64 encodeData:data] encoding:NSUTF8StringEncoding];
    
   
    NSMutableDictionary *Dict  = [NetDataService needCommand:@"2048" andNeedUserId:@"0" AndNeedBobyArrKey:@[@"name" , @"password" , @"email"] andNeedBobyArrValue:@[_baseUserName , _MD5Password , _email.text]];


    //请求网络
    [NetDataService requestWithUrl:SVR_URL dictParams:Dict httpMethod:@"POST" AndisWaitActivity:YES AndWaitActivityTitle:@"注册中……" andViewCtl:self completeBlock:^(id result){
        NSLog(@"%@" , result);
        NSDictionary *returnInfoDict = result[@"message_body"];
        NSString *returnInt = returnInfoDict[@"error"];
        int infoInt = [returnInt intValue];
        //保存user_id
        if (infoInt == 0) {
            NSString *userID = returnInfoDict[@"user_id"];
            [[NSUserDefaults standardUserDefaults] setObject:userID forKey:@"uid"];
            [[NSUserDefaults standardUserDefaults]  synchronize];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self isSuccessRegister:infoInt];
        });

    }];
}
#pragma mark------从网络获取到数据后返回到主界面
- (void)isSuccessRegister:(int)infoInt
{
    
    _errorInt = infoInt ;
    //根据返回的数据判断注册是否成功 0:注册成功 -1:注册失败,未知错误 -203:用户名已注册 -204:邮箱名已注册 -205:手机号已注册
    switch (infoInt) {
        case 0:
            _isSuccessLabel.text = @"注册成功" ;
            _errorMessage = @"恭喜您成为iSpace的用户" ;
            _label.alpha = 1.0  , _userNameLabel.alpha = 1.0 ;
            _userNameLabel.text = _userName.text ;
            [_userNameLabel sizeToFit] ;
            //注册成功保存用户名
            [[NSUserDefaults standardUserDefaults] setObject:_baseUserName forKey:@"USERNAME"];
            [[NSUserDefaults standardUserDefaults]  synchronize];
            
            [[NSUserDefaults standardUserDefaults]setObject:_MD5Password forKey:@"MD5PASSWORD"];
            [[NSUserDefaults standardUserDefaults]synchronize];

            break;
        case -1:
            _label.alpha = 0.0  , _userNameLabel.alpha = 0.0 ;
            _isSuccessLabel.text = @"注册失败" ;
            _errorMessage = @"注册失败,未知错误" ;
            break;
        case -203:
            _label.alpha = 0.0  , _userNameLabel.alpha = 0.0 ;
            _isSuccessLabel.text = @"注册失败" ;
            _errorMessage = @"用户名已注册" ;
            break;
        case -204:
            _label.alpha = 0.0  , _userNameLabel.alpha = 0.0 ;
            _isSuccessLabel.text = @"注册失败" ;
            _errorMessage = @"邮箱名已注册" ;
            break;
        case -205:
            _label.alpha = 0.0  , _userNameLabel.alpha = 0.0 ;
            _isSuccessLabel.text = @"注册失败" ;
            _errorMessage = @"手机号已注册" ;
            break;
        default:
            break;
    }
   //提示用户是否注册成功的提示框
    self.alertView.height = ScreenHeight ;
    self.alertView.top = 0 ;
    self.alertView.alpha = 0.0 ;
    [UIView animateWithDuration:0.5 animations:^{
        self.alertView.alpha = 0.9 ;
        _messageLabel.text = _errorMessage ;
        [self.view addSubview:self.alertView];
        }];
    
}
#pragma mark------判断用户输入的信息是否符合规范
//判断用户输入的信息是否符合规范
- (BOOL)judgeUserEnter
{
    //用户名不能为纯数字,不能带标点符号,编码后的总长度不能超过 32 个字节
    BOOL isName ;
    NSString * regexNumber = @"^[0-9]{4,16}$"; //都为数字[A-Za-z0-9]
    NSPredicate *predAlphabet = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regexNumber];
    BOOL isNumber = [predAlphabet evaluateWithObject:_userName.text] ;
    if (isNumber) {
        isName = NO ;
    }
    else {
        NSString * regex = @"^[a-zA-Z0-9\u4e00-\u9fa5]{4,16}$";//都有字母、数字 、中文
        NSPredicate *predNumber = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
        BOOL isRegex = [predNumber evaluateWithObject:_userName.text] ;
        isName = isRegex ;
    }
    
    //判断两次输入密码是否相同并且长度小于32个字节
    BOOL isPassword =[_userPassword.text isEqualToString:_confirmPassword.text]&&_userPassword.text.length <= 16&&_userPassword.text.length >= 6;
     //如果都符合要求则对密码进行MD5加密
    if (isPassword) {
        _MD5Password = [self md5:_userPassword.text];
        _MD5ConfirmPassword = [self md5:_confirmPassword.text];
    }
    //判断输入的是否为正确邮箱而且长度小于256个字节
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES%@",emailRegex];
    BOOL isEmail = [emailTest evaluateWithObject:_email.text];
    
    //如果条件都符合则向服务器提交注册信息
    if (isName && isPassword && isEmail&&_isAgree) {
        //非必须项没有输入（手机号码没有输入）
        if (_phoneNumber.text.length == 0) {
            return YES ;
        }//非必须项有输入（手机号码有输入）
        else{
           
            return [[NSString alloc]checkTel:_phoneNumber.text];
        }
        
    }else{
        if (!isName) {
            _promptMessage = @"用户名不符合要求" ;
        
        }
        else if (!isPassword){
            _promptMessage = @"密码输入不符合要求" ;
        }
        else if (!isEmail){
            _promptMessage = @"邮箱输入不符合要求" ;
        }
        else if (!_isAgree){
            _promptMessage = @"您还未同意我们的使用条款" ;
        }
    }
    return NO ;
    
}
#pragma mark------对密码进行MD5加密
- (NSString *)md5:(NSString *)str

{
    //转换成utf-8
    const char *cStr = [str UTF8String];
    //开辟一个16字节（128位：md5加密出来就是128位/bit）的空间（一个字节=8字位=8个二进制数）
    unsigned char result[16];
    //官方封装好的加密方法
    CC_MD5(cStr, strlen(cStr), result); // This is the md5 call
    // 把cStr字符串转换成了32位的16进制数列（这个过程不可逆转） 存储到了result这个空间中
    NSMutableString *Mstr = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH];
    for (int i=0; i<CC_MD5_DIGEST_LENGTH; i++) {
        //x表示十六进制，%02X  意思是不足两位将用0补齐，如果多余两位则不影响
        [Mstr appendFormat:@"%02x",result[i]];
        
    }
    
    return Mstr;
    
}

#pragma mark-----点击自定义弹出提示框的“确定”按钮时
- (IBAction)registerOkAction:(id)sender {
    if (_errorInt == 0) {
        TabBarViewController *tabBarViewCtl = [[TabBarViewController alloc]init];
        [self presentViewController:tabBarViewCtl animated:YES completion:NULL];
    }
    [UIView animateWithDuration:0.5 animations:^{
        self.alertView.alpha = 0.0 ;
    }];
    self.alertView.top = ScreenHeight ;
  }
@end
