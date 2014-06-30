//
//  EmailLookPassWordViewController.m
//  BedsideTreasure
//
//  Created by 莫景涛 on 14-4-5.
//  Copyright (c) 2014年 莫景涛. All rights reserved.
//

#import "LookStyleViewController.h"
#import "ResetPassWordViewController.h"

@interface LookStyleViewController ()

@end

@implementation LookStyleViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.titleLabel.text = @"找回密码" ;
        [self.titleLabel sizeToFit] ;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _cellArr = @[_firstCell , _sencondCell , _threeCell];
    [self searchStyle:_searchStyle];
    [self setExtraCellLineHidden:_tableView];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark-----UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _cellArr.count ;
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = _cellArr[indexPath.row];
    return cell ;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *heightArr = @[@"44" , @"44" , @"60"];
    return [heightArr[indexPath.row] floatValue];
}
//UITableView隐藏多余的分割线
- (void)setExtraCellLineHidden: (UITableView *)tableView{
    UIView *view =[ [UIView alloc]init];
    view.backgroundColor = [UIColor clearColor];
    [tableView setTableFooterView:view];
    [tableView setTableHeaderView:view];
}

#pragma mark----判断是那种找回方式
- (void)searchStyle:(NSString*)index
{
    if ([index isEqualToString:@"0"]) {
        if (_userInfoModel.phone_no.length != 0) {
            
             _searchStyleName.text = @"手机号码" ;
            NSMutableString *mutablestr = [[NSMutableString alloc]initWithString:_userInfoModel.phone_no] ;
            [ mutablestr replaceCharactersInRange:NSMakeRange(3, 4) withString:@"*****"];
            _showLabel.text = mutablestr ;

        }else{
            [self showAlertView:@"该账号未绑定手机"];
        }
    }else{
        _searchStyleName.text = @"邮箱地址" ;
        NSMutableString *mutableEmail = [[NSMutableString alloc]initWithString:_userInfoModel.email];
        NSRange range =[_userInfoModel.email rangeOfString:@"@"] ;
        if (range.location > 3) {
            [mutableEmail replaceCharactersInRange:NSMakeRange(3,range.location-3) withString:@"*****"];
        }else{
            [mutableEmail replaceCharactersInRange:NSMakeRange(0,range.location) withString:@"*****"];
        }
        _showLabel.text = mutableEmail ;
    }
}
#pragma mark -----UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES ;
}
#pragma mark-----点击确定按钮
- (IBAction)enterAction:(id)sender {
    
    //提交前判断是否已经输入验证码
    if (_captchaTextfield.text.length == 0) {
        [self showAlertView:@"您还未输入验证码"];
        return ;
    }
    //请求体
    NSMutableDictionary *dict = [NetDataService needCommand:@"2059" andNeedUserId:USER_ID AndNeedBobyArrKey:@[@"account" , @"request_id" , @"verify_code"] andNeedBobyArrValue:@[ _userInfoModel.name , @"1" , _captchaTextfield.text]];
    
    //请求网络
    [NetDataService requestWithUrl:SVR_URL dictParams:dict httpMethod:@"POST" AndisWaitActivity:YES AndWaitActivityTitle:@"" andViewCtl:self completeBlock:^(id result){
        NSDictionary *returnDict = result[@"message_body"] ;
        NSString *returnError = returnDict[@"error"] ;
        dispatch_async(dispatch_get_main_queue(), ^{

            [self returnMainPage:returnError];
        });

    }];
    
}
#pragma mark-----返回到主界面刷UI(点击确定按钮)
- (void)returnMainPage:(NSString*)errorInfo
{
    
    /*
    ￼0:验证码验证成功,界面需要跳转到重设密码那边 -200:账户未注册
    -210:验证码错误(请求 ID 和对应的验证码不对应) -211:验证码超时(验
    */
    ResetPassWordViewController *resetPasswordView = [[ResetPassWordViewController alloc]init];
    
    NSString *infoPrompt ;
    
    int errorInt  = errorInfo.intValue;
    switch (errorInt) {
        case 0:
            resetPasswordView.captcha = _captchaTextfield.text ;
            [self.navigationController pushViewController:resetPasswordView animated:YES];
            return ;
            break;
        case -200:
            infoPrompt = @"账户未注册" ;
            break;
        case -210:
            infoPrompt = @"验证码错误" ;
            break;
        case -211:
            infoPrompt = @"验证码超时" ;
            break;
        default:
            break;
    }
    [self showAlertView:infoPrompt];
}
#pragma mark----显示提示框
- (void)showAlertView:(NSString*)infoPrompt
{
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"" message:infoPrompt delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
    [alertView show];
}
#pragma mark-----点击发送验证码按钮
- (IBAction)sendCaptchaAction:(id)sender {
   
    //请求体
    NSMutableDictionary *dict = [NetDataService needCommand:@"2058" andNeedUserId:USER_ID AndNeedBobyArrKey:@[@"request_id" , @"goal" ,@"receiver"] andNeedBobyArrValue:@[ @"1" , _searchStyle  ,@""]] ;
    
    //请求网络
    [NetDataService requestWithUrl:SVR_URL dictParams:dict httpMethod:@"POST" AndisWaitActivity:YES AndWaitActivityTitle:@"Sending" andViewCtl:self completeBlock:^(id result){
        
        NSDictionary *returnInfo = result[@"message_body"];
        NSString *returnError = returnInfo[@"error"];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self returmMain:returnError];
        });
    }];
  
}
#pragma mark-----返回到主界面刷UI(点击发送验证码按钮)
- (void)returmMain:(NSString*)infoPrompt
{
    //0:验证码已发送成功 -1;验证码获取失败,未知错误
    NSString *infoContent ;
    int infoInt = infoPrompt.intValue ;
    switch (infoInt) {
        case 0:
            infoContent = @"验证码已发送成功" ;
            break;
        case -1:
             infoContent = @"验证码获取失败,未知错误" ;
            break;
            
        default:
            break;
    }
    [self showAlertView:infoContent];
}
#pragma mark----UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([alertView.message isEqualToString:@"该账号未绑定手机"]) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}
@end
