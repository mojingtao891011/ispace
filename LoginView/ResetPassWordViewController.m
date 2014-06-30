//
//  ResetPassWordViewController.m
//  BedsideTreasure
//
//  Created by 莫景涛 on 14-4-6.
//  Copyright (c) 2014年 莫景涛. All rights reserved.
//

#import "ResetPassWordViewController.h"
#import <CommonCrypto/CommonDigest.h>
#import "TabBarViewController.h"
#import "LoginViewController.h"

@interface ResetPassWordViewController ()

@end

@implementation ResetPassWordViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.titleLabel.text = @"重设密码" ;
        [self.titleLabel sizeToFit] ;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _cellArr = @[_firstCell , _sencondCell , _threeCell];
    [self setExtraCellLineHidden:_tableView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
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

#pragma mark -----UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES ;
}
#pragma mark-------提交重设的密码
- (IBAction)resetAction:(id)sender {
    
    //提交前判断是否符合要求
    if (_password.text.length >= 6 && [_password.text isEqualToString:_confirmPassword.text]) {
        //对密码进行MD5加密
        NSString *MD5Password = [[NSString alloc]md5:_password.text];
        
        //请求体
        NSMutableDictionary *dict = [NetDataService needCommand:@"2062" andNeedUserId:USER_ID AndNeedBobyArrKey:@[@"request_id" ,@"verify_code" , @"password"] andNeedBobyArrValue:@[@"1" , _captcha , MD5Password] ];
        //请求网络
        [NetDataService requestWithUrl:SVR_URL dictParams:dict httpMethod:@"POST" AndisWaitActivity:YES AndWaitActivityTitle:@"Reseting" andViewCtl:self completeBlock:^(id result){
            
            NSDictionary *returnDict = result[@"message_body"];
            NSString *returnInfo = returnDict[@"error"];
            
            //保存用户ID
            NSDictionary *headerDict = result[@"message_head"];
            NSString *userID = headerDict[@"user_id"];
            [[NSUserDefaults standardUserDefaults] setObject:userID forKey:@"uid"];
            [[NSUserDefaults standardUserDefaults]  synchronize];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                int errorInt = returnInfo.intValue ;
                NSString *infoStr ;
                if (errorInt == 0) {
                    infoStr = @"密码重设成功" ;
                }else
                {
                    infoStr = @"密码重设失败" ;
                }
                UIAlertView *alertView =[[UIAlertView alloc]initWithTitle:@"温馨提示" message:infoStr delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
                [alertView show] ;
            });

        }];
    }else{
        UIAlertView *alertViews =[[UIAlertView alloc]initWithTitle:@"温馨提示" message:@"输入密码不符合要求" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alertViews show] ;

        return ;
    }
}
#pragma mark-----UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
       if ([alertView.message isEqualToString:@"密码重设成功"]) {
           NSString *MD5Password = [[NSString alloc]md5:_password.text];
           [[NSUserDefaults standardUserDefaults]setObject:MD5Password forKey:@"MD5PASSWORD"];
           [[NSUserDefaults standardUserDefaults]synchronize];
           
           if (USERNAME != NULL && USERPASSWORD != NULL) {
               [[MKNetWork shareMannger]startNetworkWithNeedCommand:@"2049" andNeedUserId:USER_ID AndNeedBobyArrKey:@[@"account" , @"password"] andNeedBobyArrValue:@[USERNAME , USERPASSWORD] needCacheData:NO needFininshBlock:^(id result){
                   if ([result isEqualToString:@"0"] || [result isEqualToString:@"-202"]) {
                       TabBarViewController *tabBarViewCtl = [[TabBarViewController  alloc]init];
                       [self presentViewController:tabBarViewCtl animated:YES completion:nil];
                       
                       [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"QUIT"];
                       [[NSUserDefaults standardUserDefaults]synchronize];
                       
                }
                   else{
                       LoginViewController *loginViewCtl = [[LoginViewController alloc]init];
                       [self presentViewController:loginViewCtl animated:YES completion:nil];
                   }
               }needFailBlock:^(id fail){
                   LoginViewController *loginViewCtl = [[LoginViewController alloc]init];
                   [self presentViewController:loginViewCtl animated:YES completion:nil];
               }];
               
           }

           
           
           
            }
    

}
@end
