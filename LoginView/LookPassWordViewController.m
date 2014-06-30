//
//  LookPassWordViewController.m
//  BedsideTreasure
//
//  Created by 莫景涛 on 14-4-5.
//  Copyright (c) 2014年 莫景涛. All rights reserved.
//

#import "LookPassWordViewController.h"
#import "LookStyleViewController.h"

@interface LookPassWordViewController ()

@end

@implementation LookPassWordViewController

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
    _titleArr = @[@"使用手机号重设密码" , @"使用邮箱地址重设密码"] ;
    
    [self setExtraCellLineHidden:_lookPassWordTableView];
    
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
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
   
}
- (void)backAction
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark-----UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _titleArr.count ;
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"cellID" ;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        cell.backgroundColor = [UIColor clearColor];
        cell.accessoryType =  UITableViewCellAccessoryDisclosureIndicator ;
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 13, 0, 20)];
        titleLabel.tag = 11 ;
        [cell.contentView addSubview:titleLabel];
    }
    UILabel *label = (UILabel*)[cell viewWithTag:11];
    label.text = _titleArr[indexPath.row] ;
    [label sizeToFit];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor lightGrayColor];
    return cell ;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    LookStyleViewController *lookStyleViewCtl = [[LookStyleViewController alloc]init];
    lookStyleViewCtl.userInfoModel = _userInfoModel ;
    lookStyleViewCtl.searchStyle = [NSString stringWithFormat:@"%d" , indexPath.row] ;
    [self.navigationController pushViewController:lookStyleViewCtl animated:YES];

   
}
//UITableView隐藏多余的分割线
- (void)setExtraCellLineHidden: (UITableView *)tableView{
    UIView *view =[ [UIView alloc]init];
    view.backgroundColor = [UIColor clearColor];
    [tableView setTableFooterView:view];
    [tableView setTableHeaderView:view];
}

#pragma mark-----customAction
#pragma mark------UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self.navigationController popViewControllerAnimated:YES];
}
@end
