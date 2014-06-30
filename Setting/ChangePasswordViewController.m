//
//  ChangePasswordViewController.m
//  iSpace
//
//  Created by 莫景涛 on 14-5-1.
//  Copyright (c) 2014年 莫景涛. All rights reserved.
//

#import "ChangePasswordViewController.h"
#import <CommonCrypto/CommonDigest.h>

@interface ChangePasswordViewController ()

@end

@implementation ChangePasswordViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.titleLabel.text = @"修改密码" ;
        [self.titleLabel sizeToFit];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _cellArr = @[_firstCell , _sencondCell , _threeCell , _fourCell];
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
    NSArray *heightArr = @[@"44" , @"44" ,@"44", @"60"];
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

#pragma mark----提交修改
- (IBAction)submitChange:(id)sender
{
    if (_oldPassword.text.length==0) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:@"请输入旧密码" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alertView show];
        return ;
    }
    if (_Password.text.length < 6 && _Password.text.length > 16 ) {
        if (_Password.text.length == 0) {
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:@"密码不能留空" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
            [alertView show];

        }else{
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:@"密码长度在6-16字符" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
            [alertView show];
        }
        return ;
    }
    if ([_Password.text isEqualToString:_againPassword.text]) {
        
    }else{
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:@"密码不一致" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alertView show];
        return ;
    }
    
    NSDictionary *accInfoDict = @{
                                  @"name": USERNAME,
                                  @"email":@"",
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
                               @"password":[self md5:_Password.text],
                               @"birthday" :birthdayDict,
                               };
    NSMutableDictionary *dict = [NetDataService needCommand:@"2057" andNeedUserId:USER_ID AndNeedBobyArrKey:@[@"info" , @"password" , @"req_id"] andNeedBobyArrValue:@[infoDict ,  [self md5:_oldPassword.text] , @"-1"]];
    
    [NetDataService requestWithUrl:SVR_URL dictParams:dict httpMethod:@"POST" AndisWaitActivity:YES AndWaitActivityTitle:nil andViewCtl:self completeBlock:^(id result){
        NSLog(@"%@" , result);
        int errorInt = [result[@"message_body"][@"error"]intValue];
        NSString *str = nil ;
        if (errorInt == 0) {
            _isSuccess = YES ;
            str = @"修改密码成功" ;
            [[NSUserDefaults standardUserDefaults]setObject:[self md5:_Password.text] forKey:@"MD5PASSWORD"];
            [[NSUserDefaults standardUserDefaults]synchronize];
    
        }else{
            str = @"修改密码失败" ;
            _isSuccess = NO ;
        }
        UIAlertView *alertView =[ [UIAlertView alloc]initWithTitle:nil message:str delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alertView show];
    }];

}
#pragma mark----MD5加密
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
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (_isSuccess) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}
@end
