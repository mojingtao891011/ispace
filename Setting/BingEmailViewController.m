//
//  BingEmailViewController.m
//  iSpace
//
//  Created by 莫景涛 on 14-5-1.
//  Copyright (c) 2014年 莫景涛. All rights reserved.
//

#import "BingEmailViewController.h"

@interface BingEmailViewController ()

@end

@implementation BingEmailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.titleLabel.text = @"绑定邮箱" ;
        [self.titleLabel sizeToFit];
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
    NSArray *heightArr = @[@"55" , @"55" , @"60"];
    return [heightArr[indexPath.row] floatValue];
}
//UITableView隐藏多余的分割线
- (void)setExtraCellLineHidden: (UITableView *)tableView
{
    UIView *view =[ [UIView alloc]init];
    view.backgroundColor = [UIColor clearColor];
    [tableView setTableFooterView:view];
    [tableView setTableHeaderView:view];
}
#pragma mark----获取验证码
- (IBAction)sendVerified:(UIButton *)sender {
    
    if (_emailAddress.text.length == 0) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:@"亲~您还未输入邮箱哦" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alertView show];
        return ;
    }
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES%@",emailRegex];
    BOOL isEmail = [emailTest evaluateWithObject:_emailAddress.text];
    if (!isEmail) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:@"请输入正确的邮箱地址" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alertView show];
        return ;
    }
    //请求体
    NSMutableDictionary *dict = [NetDataService needCommand:@"2058" andNeedUserId:USER_ID AndNeedBobyArrKey:@[@"request_id" , @"goal" ,@"receiver"] andNeedBobyArrValue:@[ @"2" , @"1" ,_emailAddress.text]] ;
    
    //请求网络
    [NetDataService requestWithUrl:SVR_URL dictParams:dict httpMethod:@"POST" AndisWaitActivity:YES AndWaitActivityTitle:@"Sending" andViewCtl:self completeBlock:^(id result){

        NSDictionary *returnInfo = result[@"message_body"];
        int errorInt = [returnInfo[@"error"] intValue];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (errorInt == 0) {
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:@"验证码已发送请注意查收" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
                [alertView show];

            }else{
                static NSString *alertInfo = nil ;
                if (errorInt == -204) {
                    alertInfo = @"该邮箱已被注册" ;
                }else{
                    alertInfo = @"验证码获取失败" ;
                }
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:alertInfo delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
                [alertView show];

            }
        });
    }];

}
#pragma mark----提交验证码
- (IBAction)enterChange:(UIButton *)sender
{
    if (_emailAddress.text.length == 0) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:@"亲~您还未输入邮箱哦" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alertView show];
        return ;
    }
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES%@",emailRegex];
    BOOL isEmail = [emailTest evaluateWithObject:_emailAddress.text];
    if (!isEmail) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:@"请输入正确的邮箱地址" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alertView show];
        return ;
    }

    if (_verifiedInfo.text.length != 0) {
        NSDictionary *accInfoDict = @{
                                      @"name": USERNAME,
                                      @"email":_emailAddress.text,
                                      @"phone_no":@"",
                                      @"uid":USER_ID
                                      };
        NSDictionary *baseDict = @{
                                   @"acc_info": accInfoDict,
                                   @"sex" :@"-1" ,
                                   @"city" :@"" ,
                                   @"pic_url":@"",
                                   @"pic_id" :@"-1"
                                   };
        NSDictionary *birthdayDict = @{
                                       @"year": @"-1",
                                       @"month":@"-1",
                                       @"day":@"-1"
                                       };
        NSDictionary *infoDict = @{
                                   @"base_info": baseDict ,
                                   @"password":@"",
                                   @"birthday" :birthdayDict,
                                   };
        NSMutableDictionary *dict = [NetDataService needCommand:@"2057" andNeedUserId:USER_ID AndNeedBobyArrKey:@[@"info" , @"password" , @"req_id"] andNeedBobyArrValue:@[infoDict ,  _verifiedInfo.text , @"2"]];
        
        [NetDataService requestWithUrl:SVR_URL dictParams:dict httpMethod:@"POST" AndisWaitActivity:YES AndWaitActivityTitle:nil andViewCtl:self completeBlock:^(id result){
           
            int  errorInt = [result[@"message_body"][@"error"] intValue];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (errorInt == 0) {
                    NSArray *infoArr = @[_emailAddress.text , @"6"];
                   [[NSNotificationCenter defaultCenter]postNotificationName:REFRESHTABLEVIEW object:infoArr];
                    _isSuccess = YES ;
                    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:@"绑定成功" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
                    [alertView show];
                }else{
                
                    _isSuccess = NO ;
                    static NSString *alertInfo = nil ;
                    if (errorInt == -210) {
                        alertInfo = @"验证码错误绑定失败" ;
                    }else if (errorInt == -211){
                        alertInfo = @"验证码逾期绑定失败" ;
                    }else{
                        alertInfo = @"绑定失败" ;
                    }
                    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:alertInfo delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
                    [alertView show];

                    
                }
                
            
                
            });

        }];
        
    }else
    {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:@"请输入验证码" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alertView show];

    }
}
#pragma mark-----UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (_isSuccess) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}
@end
