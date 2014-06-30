//
//  DeviceSettingViewController.m
//  iSpace
//
//  Created by bear on 14-6-12.
//  Copyright (c) 2014年 莫景涛. All rights reserved.
//

#import "DeviceSettingViewController.h"
#import "DevicesInfoModel.h"
#import "OtherDeviceListView.h"

@interface DeviceSettingViewController ()

@end

@implementation DeviceSettingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.titleLabel.text = @"设备设置" ;
        [self.titleLabel sizeToFit];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.sectionArr = @[@"当前设备:" , @"屏幕亮度模式" ,@"睡眠模式" , @"日间模式" , @"晚间模式" , @"设备音量调节" , @"设备网络检测"];
   
    [self setExtraCellLineHidden:_deviceTableview];
    self.firstRowHeight = 55.0 ;
    
    
    UIView *footView =  [[NSBundle mainBundle]loadNibNamed:@"DeviceCell" owner:self options:nil][3];
    _deviceTableview.tableFooterView = footView ;
    UIButton *saveButton = (UIButton*)[footView viewWithTag:40];
    [saveButton addTarget:self action:@selector(saveSettingInfo:) forControlEvents:UIControlEventTouchUpInside];
 
    //推送网络速度
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(netSpeed:) name:NM_SERVER_PUSH_MSG_9 object:nil];
    
}
- (void)viewWillAppear:(BOOL)animated
{
     [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(changeDeviceNote:) name:SWITCHDEVICENOTE_SETTING object:nil];
    self.deviceTotalArr = [DevicesInfoModel shareManager].devicesTotalArr ;
    self.curModel = _deviceTotalArr[0];
    if (![_curModel.vol isEqualToString:@"-1"]) {
        self.VolValue = _curModel.vol ;
    }else{
        self.VolValue = @"7";
    }
    if (![_curModel.led isEqualToString:@"-1"]) {
        self.selectedModel = [_curModel.led integerValue];
    }else{
        self.selectedModel = 2 ; //日间模式
    }
    [_deviceTableview reloadData];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (self.isMovingFromParentViewController || self.isBeingDismissed)
    {
         [[NSNotificationCenter defaultCenter]removeObserver:self];
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
   
}
#pragma mark-----UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return _sectionArr.count + 1;
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"cellID" ;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        if (indexPath.row <2 || indexPath.row == 5 || indexPath.row == 7) {
            cell = [[NSBundle mainBundle]loadNibNamed:@"DeviceCell" owner:self options:nil][0];
        }else if (indexPath.row == 6)
        {
             cell = [[NSBundle mainBundle]loadNibNamed:@"DeviceCell" owner:self options:nil][2];
        }
        else{
            cell = [[NSBundle mainBundle]loadNibNamed:@"DeviceCell" owner:self options:nil][1];
        }
    }
    UILabel *titleLabel =(UILabel*)[cell.contentView viewWithTag:10];
    UILabel *deviceName = (UILabel*)[cell.contentView viewWithTag:12];
    UIImageView *moreImg = (UIImageView*)[cell.contentView viewWithTag:11];
    self.redioImgView = (UIImageView*)[cell.contentView viewWithTag:20];
    UILabel *modeLabel = (UILabel*)[cell.contentView viewWithTag:21];
    UISlider *volSlider = (UISlider*)[cell.contentView viewWithTag:31];
    
    [volSlider setValue:self.VolValue.floatValue animated:YES];
    [volSlider addTarget:self action:@selector(changeVolValue:) forControlEvents:UIControlEventValueChanged];
    if (indexPath.row == 0) {
        moreImg.hidden = NO ;
        deviceName.hidden = NO;
        DevicesInfoModel *model = self.deviceTotalArr[0];
        if (model.dev_name.length == 0) {
            deviceName.text = model.dev_sn ;
        }else{
            deviceName.text = [[NSString alloc]decodeBase64:model.dev_name ];
        }
        
    }
    else{
        moreImg.hidden = YES ;
        deviceName.hidden = YES ;
    }
    if (indexPath.row <2 || indexPath.row == 5 ){
         titleLabel.text = self.sectionArr[indexPath.row];
    }
    else if (indexPath.row == 7){
        titleLabel.text = @"设备网络检测";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator ;
        cell.selectionStyle = UITableViewCellSelectionStyleBlue ;
    }
    else if (indexPath.row >1 && indexPath.row < 5){
        modeLabel.text = self.sectionArr[indexPath.row];
        if (indexPath.row == _selectedModel + 1) {
            self.redioImgView.highlighted = YES ;
        }else{
            self.redioImgView.highlighted = NO ;
        }
    }
    return cell ;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   
    if (indexPath.row == 0) {
        if (!_isShow) {
            self.firstRowHeight = 140.0 ;
            
        }else{
            self.firstRowHeight = 55.0 ;
        }
        _isShow = !_isShow ;
        //[_deviceTableview reloadData];
        [_deviceTableview reloadRowsAtIndexPaths:nil withRowAnimation:UITableViewRowAnimationAutomatic];
        
        //选中的
         UITableViewCell *selectCell = [tableView cellForRowAtIndexPath:indexPath] ;
        static UILabel *alertLabel = nil ;
        static OtherDeviceListView *otherDeviceView = nil ;
        if (_isShow) {
            if (self.deviceTotalArr.count < 2) {
                if (alertLabel == nil) {
                    alertLabel = [[UILabel alloc]initWithFrame:CGRectMake(50, 80, 250, 20)];
                }
                alertLabel.text = @"亲~您当前没有可切换的设备";
                [selectCell.contentView addSubview:alertLabel];
            }
            else{
                if (otherDeviceView == nil) {
                    otherDeviceView = [[OtherDeviceListView alloc]initWithFrame:CGRectMake(0, 40, ScreenWidth, 100)];
                }
                
                otherDeviceView.devicesTotalArr = [DevicesInfoModel shareManager].devicesTotalArr;
                [ selectCell.contentView addSubview:otherDeviceView];
                [otherDeviceView.tableView reloadData];
            }
        }else
            {
                [alertLabel removeFromSuperview];
                [otherDeviceView removeFromSuperview];
            }
        
    }
    if (indexPath.row == 2 || indexPath.row == 3 || indexPath.row == 4 ) {
        self.selectedModel = indexPath.row - 1 ;
        _isShow = NO , self.firstRowHeight = 55.0 ;
        [_deviceTableview reloadData];
       
    }
    if (indexPath.row == 7) {
      
        [self startCheckNet];
    }
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.row == 0 ) {
        return _firstRowHeight ;
    }
    return 44 ;
}
#pragma mark------customAction
- (void)changeVolValue:(UISlider*)slider
{
    self.VolValue = [NSString stringWithFormat:@"%0.0f" , slider.value];
    
}
- (void)saveSettingInfo:(UIButton*)saveButton
{
    [super showHUD:@"正在设置"isDim:YES];
    _curModel = self.deviceTotalArr[0];
     NSString *ledModel = @"2";
    switch (self.selectedModel) {
        case 1:
            ledModel = @"0";
            break;
        case 2:
            ledModel = @"2";
            break;
        case 3:
            ledModel = @"1";
            break;
        default:
            break;
    }
    //NSLog(@"%@ , %@ , %@" , _curModel.dev_sn , _VolValue , ledModel);
    
    [[MKNetWork shareMannger] startNetworkWithNeedCommand:@"2095" andNeedUserId:USER_ID AndNeedBobyArrKey:@[@"sn" , @"vol" , @"led"] andNeedBobyArrValue:@[_curModel.dev_sn , _VolValue , ledModel] needCacheData:NO needFininshBlock:^(id result){
        NSString *error = [result copy] ;
        if ([error isEqualToString:@"0"]) {
            
            [super showHUDComplete:@"设置完成" isSuccess:YES];
            _curModel.vol = _VolValue ;
            _curModel.led = ledModel ;
            
        }else{
            
             [super showHUDComplete:@"设置失败" isSuccess:NO];
            
        }
        
    }needFailBlock:^(id fail){
         
         [super showHUDComplete:@"设置失败" isSuccess:NO];
    }];
}
//UITableView隐藏多余的分割线
- (void)setExtraCellLineHidden: (UITableView *)tableView
{
    UIView *view =[ [UIView alloc]init];
    view.backgroundColor = [UIColor clearColor];
    [tableView setTableFooterView:view];
    [tableView setTableHeaderView:view];
}
#pragma mark------选择设备通知
- (void)changeDeviceNote:(NSNotification*)note
{
    NSInteger  selectedIndex = [[note object] integerValue];
    _isShow = NO ;
    self.firstRowHeight = 55.0 ;

    [_deviceTotalArr exchangeObjectAtIndex:0 withObjectAtIndex:selectedIndex];
    [_deviceTableview reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
    
    
}
#pragma mark------检查网络的推送消息
- (void)netSpeed:(NSNotification*)speedNote
{
    [super showHUDComplete:@"检测成功" isSuccess:YES];
    [_timer invalidate];
    
    //
    [_checkNetView setFrame:CGRectMake(0, ScreenHeight, ScreenWidth, 200)];
    [self.view addSubview:_checkNetView];
    [UIView animateWithDuration:0.5 animations:^{
        int height = 264 ;
        if (Version >= 7.0 && Version < 7.1) {
            height = 200 ;
        }
        [_checkNetView setFrame:CGRectMake(0, ScreenHeight - height, ScreenWidth, 200)];
    }];

    NSDictionary *speedDict = [speedNote userInfo];
    //NSString *curDev_sn = speedDict[@"arg2"];
    NSString *curDev_de = speedDict[@"arg3"];
    NSString *curDev_sp = speedDict[@"arg4"];
    _speedLabel.text = [NSString stringWithFormat:@"%@KB/S" , curDev_sp] ;
    int netLevelInt = [curDev_de intValue];
    if (netLevelInt == 1) {
        _netDescriptionLabel.text = @"设备联网状态不良请检查网络" ;
    }else if (netLevelInt == 2){
        _netDescriptionLabel.text =@"设备联网状态良好";
    }else if (netLevelInt == 3){
        _netDescriptionLabel.text = @"设备联网状态较好" ;
    }
    
}
- (void)startTimer
{
    _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(startCount) userInfo:nil repeats:YES];
}
- (void)startCount
{
    static int count = 0 ;
    if (count == 60) {
        [super showHUDComplete:@"检测失败" isSuccess:NO];
        [_timer invalidate];
    }
   
    count++ ;
}
#pragma mark------检查网络
- (void)startCheckNet
{
    
    [super showHUD:@"正在检测" isDim:YES];
    [[MKNetWork shareMannger]startNetworkWithNeedCommand:@"2101" andNeedUserId:USER_ID AndNeedBobyArrKey:@[@"sn"] andNeedBobyArrValue:@[DEV_SN] needCacheData:NO needFininshBlock:^(id result){
        [self startTimer];
    }needFailBlock:^(id fail){
        
    }];
}
- (IBAction)checkNetAction:(UIButton *)sender {
    
    [UIView animateWithDuration:0.5 animations:^{
        [_checkNetView setFrame:CGRectMake(0, ScreenHeight , ScreenWidth, 200)];
    }];
}

- (IBAction)swipeAction:(UISwipeGestureRecognizer *)sender {
    
    [UIView animateWithDuration:0.5 animations:^{
        [_checkNetView setFrame:CGRectMake(0, ScreenHeight , ScreenWidth, 200)];
    }];
}
@end
