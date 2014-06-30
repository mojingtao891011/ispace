//
//  BingViewController.m
//  iSpace
//
//  Created by 莫景涛 on 14-4-30.
//  Copyright (c) 2014年 莫景涛. All rights reserved.
//

#import "BingPhoneViewController.h"
#import "VerifiedViewController.h"

@interface BingPhoneViewController ()

@end

@implementation BingPhoneViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.titleLabel.text = @"绑定手机" ;
        [self.titleLabel sizeToFit];
    } 
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setExtraCellLineHidden:_bingTabelView];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark------UITableViewDataSource 
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3 ;
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"cellID" ;
    UITableViewCell *bingCell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (bingCell == nil) {
            bingCell = [[NSBundle mainBundle]loadNibNamed:@"BingViewControllerCell" owner:nil options:nil][indexPath.row];
    }
    if (indexPath.row == 1) {
         _phoneNunber = (UITextField*)[bingCell.contentView viewWithTag:201];
    }
    if (indexPath.row == 2) {
        UIButton *button = (UIButton*)[bingCell.contentView viewWithTag:400];
        [button addTarget:self action:@selector(nextAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return bingCell ;
}
#pragma mark------UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 2) {
        return 60 ;
    }
    return 55 ;
}
//UITableView隐藏多余的分割线
- (void)setExtraCellLineHidden: (UITableView *)tableView{
    UIView *view =[ [UIView alloc]init];
    view.backgroundColor = [UIColor clearColor];
    [tableView setTableFooterView:view];
    [tableView setTableHeaderView:view];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES ;
}
#pragma mark-----coustomAction(获取验证码)
- (void)nextAction:(UIButton*)sender
{
    BOOL isMobileNumber = [[NSString alloc]checkTel:_phoneNunber.text];
    if (!isMobileNumber) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:@"请输入正确的手机号码" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alertView show];
        return ;
    }
    //请求体
    NSMutableDictionary *dict = [NetDataService needCommand:@"2058" andNeedUserId:USER_ID AndNeedBobyArrKey:@[@"request_id" , @"goal" ,@"receiver"] andNeedBobyArrValue:@[ @"3" , @"0",_phoneNunber.text ]] ;
  
    //请求网络
    [NetDataService requestWithUrl:SVR_URL dictParams:dict httpMethod:@"POST" AndisWaitActivity:YES AndWaitActivityTitle:@"发送中……" andViewCtl:self completeBlock:^(id result){
        NSDictionary *returnInfo = result[@"message_body"];
        int returnErrorInt = [returnInfo[@"error"] intValue];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self returmMain:returnErrorInt];
        });
    }];

    
}

- (void)returmMain:(int)errorInt
{
    if (errorInt == 0) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:@"验证码已发送请注意查收" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alertView show];

        VerifiedViewController *VerifiedViewCtl = [[VerifiedViewController alloc]init];
        VerifiedViewCtl.phoneNumber = _phoneNunber.text ;
        [self.navigationController pushViewController:VerifiedViewCtl animated:YES];
    }
    else{
        if (errorInt == -205) {
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:@"该手机已被绑定" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
            [alertView show];
        }else
        {
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:@"验证码获取失败" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
            [alertView show];
        }
        
    }
}
@end
