//
//  SettingViewController.m
//  BedsideTreasure
//
//  Created by 莫景涛 on 14-4-1.
//  Copyright (c) 2014年 莫景涛. All rights reserved.
//

#import "SettingViewController.h"
#import "AccountViewController.h"
#import "DeviceSettingViewController.h"
#import "HelpViewController.h"
#import "FeedbackViewController.h"
#import "DevicesInfoModel.h"
#import "NoDeviceViewController.h"
#import "DirectoryViewController.h"
#import "CheckVervsionClass.h"

@interface SettingViewController ()

@end

@implementation SettingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.titleLabel.text = @"设置" ;
        [self.titleLabel sizeToFit];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.dataSourceArr = @[@"账号设置" , @"设备设置" , @"使用帮助" , @"意见反馈" , @"检查新版本"  , @"关于床头宝"] ;
    self.imgameArr = @[@"ic_user_setting" ,@"DevicesSetting" , @"ic_help" , @"ic_feedback" ,@"ic_update" , @"ic_agreement@2x"   ];//ic_pages
    [self setExtraCellLineHidden:_settingTableView];
   
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//UITableView隐藏多余的分割线
- (void)setExtraCellLineHidden: (UITableView *)tableView{
    UIView *view =[ [UIView alloc]init];
    view.backgroundColor = [UIColor clearColor];
    [tableView setTableFooterView:view];
    [tableView setTableHeaderView:view];
}

#pragma mark-----UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSourceArr.count ;
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"cellID" ;
    UITableViewCell *setInfoCell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (setInfoCell == nil ) {
        setInfoCell = [[NSBundle mainBundle]loadNibNamed:@"SettingViewControllerCell" owner:nil options:nil][0];
    }
    UIImageView *imgView = (UIImageView*)[setInfoCell.contentView viewWithTag:1];
    UILabel *titleLabel = (UILabel*)[setInfoCell.contentView viewWithTag:2];
    imgView.image = [UIImage imageNamed:_imgameArr[indexPath.row]];
    titleLabel.text = _dataSourceArr[indexPath.row];
    setInfoCell.selectionStyle = UITableViewCellSelectionStyleGray ;
    return setInfoCell ;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.row == 0) {
       static  AccountViewController *accountViewCtl = nil ;
        if (accountViewCtl == nil) {
            accountViewCtl = [[AccountViewController alloc]init];
        }
          [self.navigationController pushViewController:accountViewCtl animated:YES];
    }
    else if(indexPath.row == 1){
        static DeviceSettingViewController*deviceViewCtl  = nil ;
        NSMutableArray *arr = [DevicesInfoModel shareManager].devicesTotalArr;
        
        if (arr.count == 0) {
           
            NoDeviceViewController *noDeviceViewCtl = [[NoDeviceViewController alloc]init];
            [self.navigationController pushViewController:noDeviceViewCtl animated:YES];
        }else
        {
            if (deviceViewCtl == nil) {
                deviceViewCtl = [[DeviceSettingViewController alloc]init];
            }
            [self.navigationController pushViewController:deviceViewCtl animated:YES];
        }
        
    }
    else if (indexPath.row == 2){
        static HelpViewController *helpViewCtl = nil ;
        if (helpViewCtl == nil) {
            helpViewCtl = [[HelpViewController alloc]init];
        }
        [self.navigationController pushViewController:helpViewCtl animated:YES];
    }
    else if (indexPath.row == 3){
        FeedbackViewController *feedbackCtl = [[FeedbackViewController alloc]init];
        [self.navigationController pushViewController:feedbackCtl animated:YES];
    }
    else if (indexPath.row == 4){
        [self checkVersionToServer];
        
    }
    else if (indexPath.row == 5){
        static DirectoryViewController *directoryViewCtl = nil ;
        if (directoryViewCtl == nil) {
            directoryViewCtl = [[DirectoryViewController alloc]init];
        }
        [self.navigationController pushViewController:directoryViewCtl animated:YES];
        
    }
}
#pragma mark----------------------------------检测新版本----------------------------------
- (void)checkVersionToServer
{
    [super showHUD:@"正在检测" isDim:YES];
    [[MKNetWork shareMannger]startNetworkWithNeedCommand:@"2079" andNeedUserId:USER_ID AndNeedBobyArrKey:@[@"req_id" , @"type" , @"ver_num"] andNeedBobyArrValue:@[@"-1" , @"1" , VER_NUM] needCacheData:NO needFininshBlock:^(id result){
        NSLog(@"自动检查——ok");
        [super hideHUD];
        if ([result isKindOfClass:[CheckVervsionClass class]]) {
            CheckVervsionClass *model = result ;
            int versionInt = [model.ver_num intValue];
            int suggestInt = [model.suggest intValue];
            int curInt = [VER_NUM intValue];
            NSString *descript = [[NSString alloc]decodeBase64:model.descript] ;
            _trackViewUrl = model.url ;
            if (descript.length == 0) {
                descript = @"发现新版本请升级" ;
            }
            if (suggestInt == 1) {
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"升级通知" message:descript delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
                alertView.tag = 11 ;
                [alertView show];
            }
            else if(versionInt > curInt && suggestInt == 0){
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"升级通知" message:descript delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                alertView.tag = 12 ;
                [alertView show];
            }
            else{
                NSString *info = [NSString stringWithFormat:@"您当前为最新版本%0.1d" , versionInt];
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:info delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                [alertView show];
            }
            
        }
    }needFailBlock:^(id fail){
        [super showHUDComplete:@"已是最新版"isSuccess:YES];
       
        NSLog(@"自动检查——fail");
        
    }];
    
}

#pragma mark----
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if (alertView.tag == 11) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:_trackViewUrl]];
    }else if (alertView.tag == 12){
        if (buttonIndex == 1) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:_trackViewUrl]];
        }
    }
}

@end
