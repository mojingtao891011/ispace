//
//  DirectoryViewController.m
//  iSpace
//
//  Created by bear on 14-6-30.
//  Copyright (c) 2014年 莫景涛. All rights reserved.
//

#import "DirectoryViewController.h"
#import "AboutIspaceViewController.h"

@interface DirectoryViewController ()

@end

@implementation DirectoryViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.titleLabel.text = @"关于床头宝" ;
        [self.titleLabel sizeToFit];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _titleArr = @[@"床头宝V1.0" ,@"版本介绍" , @"用户协议"];
    [self setExtraCellLineHidden:_tableView];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//UITableView隐藏多余的分割线
- (void)setExtraCellLineHidden: (UITableView *)tableView
{
    UIView *view =[ [UIView alloc]init];
    view.backgroundColor = [UIColor clearColor];
    [tableView setTableFooterView:view];
    [tableView setTableHeaderView:view];
}

#pragma mark---------
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
        UILabel *titleLabel =[[UILabel alloc]initWithFrame:CGRectMake(10, 5, 100,30)];
        titleLabel.tag = 10 ;
        [cell.contentView addSubview:titleLabel];
    }
    UILabel *nameLabel = (UILabel*)[cell.contentView viewWithTag:10];
    if (indexPath.row == 0) {
        nameLabel.center = cell.center ;
        cell.accessoryType = UITableViewCellAccessoryNone ;
        cell.selectionStyle = UITableViewCellSelectionStyleNone ;
    }else{
        [nameLabel setFrame:CGRectMake(10, 5, 100,30)];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator ;
        cell.selectionStyle = UITableViewCellSelectionStyleGray ;
    }
    nameLabel.text = _titleArr[indexPath.row];
    return cell ;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    if (indexPath.row == 0) {
        return ;
    }
    NSArray *urlArr = @[ABOUTISPACE_URL , USERAGREEMENT_URL];

    AboutIspaceViewController *aboutIspaceViewCtl  = [[AboutIspaceViewController alloc]init];
    if (indexPath.row == 1) {
        aboutIspaceViewCtl.direction = versionAbout ;
    }else if (indexPath.row == 2){
        aboutIspaceViewCtl.direction = userAgreement ;
    }
    aboutIspaceViewCtl.urlStr = urlArr[indexPath.row - 1];
    [self.navigationController pushViewController:aboutIspaceViewCtl animated:YES];
}
@end
