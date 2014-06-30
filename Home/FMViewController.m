//
//  FMViewController.m
//  iSpace
//
//  Created by bear on 14-5-26.
//  Copyright (c) 2014年 莫景涛. All rights reserved.
//

#import "FMViewController.h"

@interface FMViewController ()

@end

@implementation FMViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.titleLabel.text = @"广播列表" ;
        [self.titleLabel sizeToFit];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _fmArr = [[NSMutableArray alloc]initWithCapacity:20];
    [self setExtraCellLineHidden:_fmTableView];
    
//    selectedButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [selectedButton setFrame:CGRectMake(10, ScreenHeight - 50, ScreenWidth-20, 40)];
//    selectedButton.backgroundColor = buttonBackgundColor;
//    [selectedButton setTitle:@"确定" forState:UIControlStateNormal];
//    [selectedButton addTarget:self action:@selector(selectedMusic) forControlEvents:UIControlEventTouchUpInside];
//    selectedButton.hidden = YES ;
//    [self.view addSubview:selectedButton];

    
    _fmTableView.isComeInRefresh = YES ;
    _fmTableView.isNeedPullRefresh = YES ;
    _fmTableView.isNeedPullDownRefresh = YES ;
    _fmTableView.dele = self ;
    [_fmTableView awakeFromNib];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
   

}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark-------UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _fmArr.count ;
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"cellID" ;
    UITableViewCell *fmCell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (fmCell == nil) {
        fmCell = [[NSBundle mainBundle]loadNibNamed:@"ListCell" owner:self options:nil][0];
    }
    UIImageView *radioView = (UIImageView*)[fmCell.contentView viewWithTag:1];
    UILabel *nameLabel = (UILabel*)[fmCell.contentView viewWithTag:2];
    if (radioView.highlighted) {
        radioView.image = [UIImage imageNamed:@"bt_radio_pressed.png"];
    }else{
        radioView.image = [UIImage imageNamed:@"bt_radio_normal.png"];
    }
    NSString *str =  _fmArr[indexPath.row];
    NSString *fmInfo = [NSString stringWithFormat:@"%0.1f" , str.intValue*0.1];
    nameLabel.text = fmInfo;
    return fmCell ;
}
//UITableView隐藏多余的分割线
- (void)setExtraCellLineHidden: (UITableView *)tableView
{
    UIView *view =[ [UIView alloc]init];
    view.backgroundColor = [UIColor clearColor];
    [tableView setTableFooterView:view];
    [tableView setTableHeaderView:view];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    //取消上次选中的
    //    NSIndexPath *lastIndex = [NSIndexPath indexPathForRow:_index inSection:0];
    //    UITableViewCell *lastCell = [tableView cellForRowAtIndexPath:lastIndex];
    //    lastCell.accessoryType = UITableViewCellAccessoryNone ;
    
    //选中的
    //UITableViewCell *selectCell = [tableView cellForRowAtIndexPath:indexPath] ;
    //发送选中通知
    [[NSNotificationCenter defaultCenter]postNotificationName:@"postFMlist" object:_fmArr[indexPath.row]];
}
#pragma mark-------------------------ProtocolDelegate-------------------------
- (void)refreshFethNetData:(MJRefreshBaseView *)refreshView
{
    [_fmArr removeAllObjects];
    [self getFMInfo];
    self.refreshView = refreshView ;
}

#pragma mark-----------------------------------NetRequset-----------------------------------
#pragma mark----------获取FM信息
- (void)getFMInfo
{
    //获取FM
    [[MKNetWork shareMannger]startNetworkWithNeedCommand:@"2053" andNeedUserId:USER_ID AndNeedBobyArrKey:@[@"dev_sn"] andNeedBobyArrValue:@[DEV_SN] needCacheData:NO needFininshBlock:^(id result){
        
        [self.refreshView endRefreshing];
        if ([result isKindOfClass:[NSMutableArray class]]) {
            self.fmArr = result ;
            [_fmTableView reloadData];
        }

    }needFailBlock:^(id fail){
        [self.refreshView endRefreshing];
    }];
    
        
}
@end
