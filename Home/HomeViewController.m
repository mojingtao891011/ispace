//
//  HomecViewController.m
//  Home
//
//  Created by bear on 14-5-11.
//  Copyright (c) 2014年 莫景涛. All rights reserved.
//

#import "HomeViewController.h"
#import "DevicesInfoModel.h"
#import "SetColckViewController.h"
#import "WeatherInfo.h"
#import "OtherDeviceListView.h"
#import "CacheHandle.h"
#import "MKNetWork.h"
#import "CheckVervsionClass.h"

@interface HomeViewController ()
@end

@implementation HomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.titleLabel.text = @"主页" ;
        [self.titleLabel sizeToFit];
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];

    [self loadInfo];
   
    //闹钟被设置通知改变标题
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(settingSuccess:) name:SETTING_ISSUCCESS object:nil];
    //修改设备名
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(modifyDeviceName:) name:NM_DEVICE_INFO_CHANGED object:nil];
    //服务器push成功信息
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(setSuccess:) name:NM_SERVER_PUSH_MSG_7 object:nil];
    //登陆成功通知
    [[ NSNotificationCenter defaultCenter]postNotificationName:NM_USER_LOGIN_SUCCEEDED object:nil];
    //删除设备通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(removeDevice:) name:NM_DEVICE_REMOVED object:nil];
    //停用闹钟通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(stopAlermNote:) name:STOP_ALERM_NOTE object:nil];
    
    //检查版本
    [NSThread detachNewThreadSelector:@selector(checkVersion) toTarget:self withObject:nil];
    
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //删除启动图片通知
    [[NSNotificationCenter defaultCenter]postNotificationName:REMORESTARIMG object:nil userInfo:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //切换设备通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(selectedDeviceNote:) name:SWITCHDEVICENOTE object:nil];
    
    self.navigationController.navigationBarHidden = YES ;
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO ;
    [[NSNotificationCenter defaultCenter]removeObserver:self name:SWITCHDEVICENOTE object:nil];
    if (self.isSwithDevice) {
        [self changeDevicesAction:nil];
    }

}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    // Dispose of any resources that can be recreated.
}
#pragma mark-----------------------------UITableViewDataSource-----------------------------
#pragma mark-----UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _cellArr.count ;
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *homeCell = _cellArr[indexPath.row];
    return homeCell ;
}
#pragma mark-----------------------------UITableViewDelegate-----------------------------
#pragma mark-----UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return [_heightRowArr[indexPath.row] floatValue];
}
#pragma mark-----------------------------CoustomAction-----------------------------
#pragma mark------登陆成功自动检查版本
- (void)checkVersion
{
    [[MKNetWork shareMannger]startNetworkWithNeedCommand:@"2079" andNeedUserId:USER_ID AndNeedBobyArrKey:@[@"req_id" , @"type" , @"ver_num"] andNeedBobyArrValue:@[@"-1" , @"1" , VER_NUM] needCacheData:NO needFininshBlock:^(id result){
        NSLog(@"自动检查——ok");
        if ([result isKindOfClass:[CheckVervsionClass class]]) {
            CheckVervsionClass *model = result ;
            int versionInt = [model.ver_num intValue];
            int suggestInt = [model.suggest intValue];
            int curInt = [VER_NUM intValue];
            NSString *descript = [[NSString alloc]decodeBase64:model.descript] ;
            _app_url = model.url ;
            if (descript.length == 0) {
                descript = @"发现新版本请升级" ;
            }
            if (suggestInt == 1) {
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"升级通知" message:descript delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
                alertView.tag = 50 ;
                [alertView show];
            }
            else if(versionInt > curInt && suggestInt == 0){
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"升级通知" message:descript delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                alertView.tag = 51 ;
                [alertView show];
            }
            else{
                NSString *info = [NSString stringWithFormat:@"您当前为最新版本%0.1d" , versionInt];
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:info delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                [alertView show];
            }
            
        }
    }needFailBlock:^(id fail){
        NSLog(@"自动检查——fail");
        
    }];
    
}
- (void)loadInfo
{
    NSArray *cellArr = @[_iSpaceNameCell , _noWIFICell , _iSpaceClockCell ];
    _cellArr = [NSMutableArray arrayWithArray:cellArr];
    NSArray *heightRowArr = @[@"110" , @"90" , @"140" , @"60"];
   // _otherDeviceMoveHeight = 400 ;
    _heightRowArr = [NSMutableArray arrayWithArray:heightRowArr];
    _homeTableView.tableFooterView =  _iSpaceOtherCell ;
    
    //在设备WiFi不在线时只显示日期和星期
    NSArray *dateWithWeekArr = [self getDateAndWeekInNoWifiStaut];
    _nowifiDate.text = dateWithWeekArr[0];
    _nowifiWeek.text = dateWithWeekArr[1];
    
    //闹钟UI
    _devicesTotalArr = [[NSMutableArray alloc]initWithCapacity:4];
    _clockArr = @[_clock1 , _clock2 , _clock3 , _clock4];
    _clockLabelArr = @[_label1 , _label2 , _label3 , _label4];
    self.clockBgViewArr = @[_clock1BgView , _clock2BgView , _clock3BgView , _clock4BgView];
    
    UIColor *clock1Color = [UIColor colorWithRed:247/255.0 green:101/255.0 blue:62/255.0 alpha:1.0];
    UIColor *clock2Color = [UIColor colorWithRed:117/255.0 green:223/255.0 blue:187/255.0 alpha:1.0];
    UIColor *clock3Color = [UIColor colorWithRed:96/255.0 green:203/255.0 blue:223/255.0 alpha:1.0];
    UIColor *clock4Color = [UIColor colorWithRed:96/255.0 green:203/255.0 blue:223/255.0 alpha:1.0];
    _colorArr = @[clock1Color , clock2Color , clock3Color , clock4Color];
    
    self.switchClockArr = @[_switchClock1 , _switchClock2 , _switchClock3 , _switchClock4] ;
    
    //状态栏
    [super showStatus];
    
     //天气
    for (int i =1 ; i < 19; i++) {
        if (_weatherImgArr == nil) {
            _weatherImgArr = [[NSMutableArray alloc]initWithCapacity:18];
        }
        NSString *imgName = [NSString stringWithFormat:@"%d.png" , i];
        [_weatherImgArr addObject:imgName];
    }
    self.weatherStautArr = @[@"晴",@"多云",@"阵雨",@"大雾",@"晴雾天",@"阴雾天",@"阴天",@"小雨",@"中雨",@"大雨",@"雷",@"雷雨",@"小雪",@"中雪",@"大雪",@"雨加雪",@"大风",@"夜晚"];
    
    if (Version < 7.0) {
        
        UIFont *secondFont = [UIFont fontWithName: @"HelveticaNeue-UltraLight" size: 60.0];
        self.devicesTime.font = secondFont ;
        
    }
    
    //一开始就刷新
    _homeTableView.dele = self ;
    _homeTableView.isNeedPullRefresh = YES ;
    _homeTableView.isComeInRefresh = YES ;
    [_homeTableView awakeFromNib];

}
#pragma mark-----更新闹钟信息
- (void)updateAlertInfo
{
    
    if (_devicesTotalArr.count != 0) {
        DevicesInfoModel *devicesModel = _devicesTotalArr[0];
         self.devicesCity = devicesModel.dev_city ;
        //设备名
        if (devicesModel.dev_name.length == 0) {
            //如果设备名为空则显示设备序列号
            self.devicesName.text = devicesModel.dev_sn ;
        }
        else{
            self.devicesName.text = [[NSString alloc]decodeBase64:devicesModel.dev_name] ;
        }
        //设备时间
        self.devicesTime.text = [[NSString alloc]stringFromFomate:[NSDate date] formate:@"HH : mm"];
        [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTime:) userInfo:nil repeats:YES];
        //wifi状态
        if (![devicesModel.dev_online isEqualToString:@"0"]) {
            _devicesOnlineStaut.highlighted = YES ;
            [_cellArr replaceObjectAtIndex:1 withObject:_iSpaceWeathCell];
            [_heightRowArr replaceObjectAtIndex:1 withObject:@"130"];
            [_homeTableView reloadData];
            //如果设备WIFI在线才获取天气
            [self getWeatherInfo];
//            self.otherDeviceMoveHeight = 440 ;
        }else{
            _devicesOnlineStaut.highlighted = NO ;
            [_cellArr replaceObjectAtIndex:1 withObject:_noWIFICell];
            [_heightRowArr replaceObjectAtIndex:1 withObject:@"90"];
            [_homeTableView reloadData];
            //self.otherDeviceMoveHeight = 400 ;
        }
        //BT状态
        if (![devicesModel.bt_state isEqualToString:@"0"]) {
            self.devicesBT.highlighted = YES ;
            self.nowifiBT.highlighted = YES ;
        }else{
            self.devicesBT.highlighted = NO ;
            self.nowifiBT.highlighted = NO ;
        }
        //保存设备索引
        [[NSUserDefaults standardUserDefaults] setObject:devicesModel.dev_sn forKey:@"dev_sn"];
        [[NSUserDefaults standardUserDefaults]  synchronize];
        
        //闹钟
        _alarmInfoArr = [devicesModel.alermInfoArr mutableCopy];
        for (int j = 0; j < 4; j++) {
            AlarmClock *clock = _clockArr[j];
            UIView *bgView = _clockBgViewArr[j];
            UILabel *timeLabel = _clockLabelArr[j];
            UISwitch *colse_switch = _switchClockArr[j];
            UIColor *closeColor = [UIColor colorWithRed:229/255.0 green:229/255.0 blue:229/255.0 alpha:1.0];
            clock.backgroundColor = closeColor;
            bgView.backgroundColor = closeColor;
            timeLabel.text = @"未设置" ;
            colse_switch.on = NO ;
            [clock setNeedsDisplay];
            [clock awakeFromNib];
        }
        for (int i = 0; i < _alarmInfoArr.count; i++) {
            if (i > 3) {
                return ;
            }
            AlarmInfoModel *alermInfoModel = _alarmInfoArr[i];
            //NSLog(@"%@ , %@" , alermInfoModel.state , alermInfoModel.flag);
            if (alermInfoModel.index != NULL) {
                int index = [alermInfoModel.index intValue];
                if (index >3) {
                    index = 3 ;
                }
                AlarmClock *clock = _clockArr[index];
                UIView *bgView = _clockBgViewArr[index];
                UILabel *timeLabel = _clockLabelArr[index];
                UIColor *clockColor = _colorArr[index] ;
                UISwitch *colse_switch = _switchClockArr[index];
                if ([alermInfoModel.flag isEqualToString:@"0" ] && [alermInfoModel.state isEqualToString:@"1"] ) {
                    clock.backgroundColor = clockColor ;
                    bgView.backgroundColor = clockColor ;
                    
                }else{
                    UIColor *closeColor = [UIColor colorWithRed:229/255.0 green:229/255.0 blue:229/255.0 alpha:1.0];
                    clock.backgroundColor = closeColor ;
                    bgView.backgroundColor = closeColor ;
                }
                if ([alermInfoModel.state isEqualToString:@"1"]) {
                    colse_switch.on = YES ;
                }else{
                    colse_switch.on = NO ;
                }

               
                NSString *hour = alermInfoModel.hour ;
                NSString *minute = alermInfoModel.minute ;
                if (hour.intValue < 10) {
                    hour = [NSString stringWithFormat:@"0%@" , hour];
                }
                if (minute.intValue < 10) {
                    minute = [NSString stringWithFormat:@"0%@" , minute];
                }
                NSString *timeStr = [NSString stringWithFormat:@"%@:%@",hour , minute];
                //把NSString转化为NSDate
                NSDate* date = [[NSString alloc]dateFromFomate:timeStr formate:@"HH:mm"];
                timeLabel.text = timeStr ;
                clock.time = date ;
                [clock setNeedsDisplay];
                [clock awakeFromNib];
            }
        }
        
    }
    else{
        [_homeTableView awakeFromNib];
    }
}
#pragma mark------updateTime
- (void)updateTime:(NSTimer*)timer
{
    self.devicesTime.text = [[NSString alloc]stringFromFomate:[NSDate date] formate:@"HH : mm"];
}
#pragma mark------在设备没有WiFi的状态下不显示天气（获取时间和星期）
- (NSArray*)getDateAndWeekInNoWifiStaut
{
    NSDate *nowDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMdd"];
    NSString *dateString = [dateFormatter stringFromDate:nowDate];
    
    NSInteger yearInt = [dateString substringWithRange:NSMakeRange(0, 4)].integerValue;
    NSInteger monthInt = [dateString substringWithRange:NSMakeRange(4, 2)].integerValue;
    NSInteger dayInt = [dateString substringWithRange:NSMakeRange(6, 2)].integerValue;
    NSString *monthStr = [NSString stringWithFormat:@"%d" , monthInt];
    NSString *dayStr = [NSString stringWithFormat:@"%d" , dayInt];
    if (monthInt < 10) {
        monthStr = [NSString stringWithFormat:@"0%d" , monthInt];
    }
    if (dayInt < 10) {
        dayStr = [NSString stringWithFormat:@"0%d" , dayInt];
    }
    NSString *now_date = [NSString stringWithFormat:@"%d/%@/%@" , yearInt , monthStr , dayStr];
    NSString *week = [[NSString alloc]fromDateToWeek:dateString];
    NSArray *dateAndWeekArr = @[now_date , week];
    
    return dateAndWeekArr ;
}

#pragma mark-----点击闹钟进入闹钟设置界面
- (IBAction)clickAlarmClockAction:(UIButton *)sender
{
    
    if (_devicesTotalArr.count == 0) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"友情提示" message:@"您还未绑定设备不能设置闹钟" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alertView show];
        
        return ;
    }
    DevicesInfoModel *devicesModel = _devicesTotalArr[0];
    NSMutableArray *alermArr = devicesModel.alermInfoArr ;
    SetColckViewController *setClockViewCtl = [[SetColckViewController alloc]init];
    for (int i = 0; i < alermArr.count; i++) {
        AlarmInfoModel *model = alermArr[i];
        int index = [model.index intValue];
        int temp = sender.tag - 1 ;
        if (temp == index) {
            setClockViewCtl.alarmInfoModel = model ;
            setClockViewCtl.isWifiOnline = devicesModel.dev_online ;
        }
    }
    setClockViewCtl.clockButtonTag = sender.tag ;
    UILabel *label = _clockLabelArr[sender.tag - 1];
    if ([label.text isEqualToString:@"未设置"]) {
        NSString *nowDateStr = [[NSString alloc]stringFromFomate:[NSDate date] formate:@"HH:mm"];
        setClockViewCtl.time = nowDateStr ;
    }else{
        setClockViewCtl.time = label.text ;
    }
    
    [self.navigationController pushViewController:setClockViewCtl animated:YES];
}
#pragma mark-----切换设备动作
- (IBAction)changeDevicesAction:(UIButton *)sender
{
    self.isSwithDevice = !self.isSwithDevice ;
    __block int i = 0 ;
    if (self.devicesTotalArr.count < 2 )
    {
        if (_isSwithDevice) {
            
            if (self.devicesTotalArr.count == 0) {
                self.alertInfoLabel.text = @"亲~您还没有绑定设备哦，赶紧绑定吧!" ;
            }else{
                self.alertInfoLabel.text = @"亲~您当前没有可切换的设备" ;
            }
            [self.view addSubview:_noDeviceView];
            self.noDeviceView.top = ScreenHeight ;
            [UIView animateWithDuration:0.5 animations:^{
                self.noDeviceView.top = ScreenHeight - 149 ;
                i = _homeTableView.tableFooterView.bottom - (ScreenHeight - 149);
                if (Version < 7.0) {
                    self.noDeviceView.top = ScreenHeight - 169 ;
                    i =   _homeTableView.tableFooterView.bottom - (ScreenHeight  - 169);
                }
                self.noDeviceView.left = 0 ;
                if (i > 0 ) {
                    [_homeTableView setContentOffset:CGPointMake(0,abs(i)) animated:YES];
                }
                
            }];
            
            return ;
        }
        else{
            
            [UIView animateWithDuration:0.5 animations:^{
                self.noDeviceView.top = ScreenHeight ;
                self.noDeviceView.left = 0 ;
                if (Version >= 7.0) {
                    i = i - 20 ;
                }
                
                [_homeTableView setContentOffset:CGPointMake(0,-abs(i)) animated:YES];
            }completion:^(BOOL flash){
                [_noDeviceView removeFromSuperview];
            }];
            return ;
            
        }
    }
    
    
    //////////////////////////////////////////////////////////////有两个设备以上//////////////////////////////////////////////////////////////
    static OtherDeviceListView *otherDeviceView = nil ;
    if (otherDeviceView == nil) {
        
        otherDeviceView = [[OtherDeviceListView alloc]initWithFrame:CGRectMake(0, ScreenHeight, ScreenWidth, 100)];
        otherDeviceView.isHomeSwitch = YES ;
        [self.view addSubview:otherDeviceView];
    }
    
    otherDeviceView.devicesTotalArr = self.devicesTotalArr ;
    
    [otherDeviceView.tableView reloadData];
    [self updateAlertInfo];
    if (self.isSwithDevice) {
        [UIView animateWithDuration:0.5 animations:^{
            otherDeviceView.frame =CGRectMake(0, ScreenHeight - 149, ScreenWidth, 100);
            i = _homeTableView.tableFooterView.bottom - (ScreenHeight - 149);
            if (i > 0) {
                [_homeTableView setContentOffset:CGPointMake(0,abs(i)) animated:YES];
            }
        }];
    }
    else
    {
        //NSLog(@">>%f , %f" , ScreenHeight-149 , _homeTableView.tableFooterView.bottom);
        [UIView animateWithDuration:0.5 animations:^{
            otherDeviceView.frame =CGRectMake(0, ScreenHeight , ScreenWidth, 100);
            if (Version >= 7.0) {
                i = i -20 ;
            }
            [_homeTableView setContentOffset:CGPointMake(0,-abs(i)) animated:YES];
        }];
        
    }
    
}

- (IBAction)tapView:(UITapGestureRecognizer *)sender {
    
    if (self.isSwithDevice) {
        [self changeDevicesAction:nil];
    }
    
}

- (IBAction)swipAction:(UISwipeGestureRecognizer *)sender {
    self.isSwithDevice = YES ;
    [self changeDevicesAction:nil];
}

- (IBAction)panAction:(UIPanGestureRecognizer *)sender {
    ///
    if (_devicesTotalArr.count == 0) {
        return ;
    }
    DevicesInfoModel *devices_model = _devicesTotalArr[0];
    NSMutableArray *alarm_arr = devices_model.alermInfoArr ;
    
    self.closeClockIndex = sender.view.tag - 10 ;
    for (int i = 0; i < alarm_arr.count; i++) {
        AlarmInfoModel *alarm_model = alarm_arr[i];
        int index = [alarm_model.index intValue];
        
        if (index == _closeClockIndex) {
            
            UIView *bgView = _clockBgViewArr[_closeClockIndex];
            if (Version >= 7.0) {
                UISwitch *closeSwitch = _switchClockArr[_closeClockIndex];
                CGPoint centerPoint = bgView.center ;
                closeSwitch.left = centerPoint.x - closeSwitch.width/2;
            }
            CGPoint point = [sender translationInView: bgView];
            
            if (point.y < 0) {
                [UIView animateWithDuration:0.2 animations:^{
                    bgView.top = -25 ;
                }];
                
            }else{
                [UIView animateWithDuration:0.2 animations:^{
                    bgView.top = 10 ;
                }];
            }
        }
    }
}

- (IBAction)switchAction:(UISwitch *)sender {
//    NSLog(@"%d" , sender.on);
    _isStop_setting = NO ;
    _closeClockIndex = sender.tag - 20 ;
    if (sender.on == NO) {
        //NSLog(@"on");
        //关闭闹钟
        [self submitAlarmInfoToServer:YES];
    }else{
        //NSLog(@"off");
        //打开闹钟
        [self submitAlarmInfoToServer:NO];
    }
    
    UIView *bgView = _clockBgViewArr[_closeClockIndex];
    
    [UIView animateWithDuration:0.2 animations:^{
        bgView.top = 10 ;
    }];

}


#pragma mark-----------------------------NSNotification-----------------------------
#pragma mark-----选中了设备的通知
- (void)selectedDeviceNote:(NSNotification*)selectedDeviceNote
{
    int index = [[selectedDeviceNote object]integerValue];
    [_devicesTotalArr exchangeObjectAtIndex:0 withObjectAtIndex:index];
     //记住选中设备的索引号
    DevicesInfoModel *model = _devicesTotalArr[0];
    self.selectedDev_sn = model.dev_sn ;
    self.isSwithDevice = YES ;
    [self changeDevicesAction:nil];
    [self updateAlertInfo];

}
- (void)modifyDeviceName:(NSNotification*)note
{
    NSDictionary *noteDict = [note object];
    NSString *dev_name = noteDict[@"dev_name"];
    NSString *dev_sn = noteDict[@"dev_sn"];
    for (DevicesInfoModel *model in _devicesTotalArr) {
        if ([model.dev_sn isEqualToString:dev_sn]) {
            self.devicesName.text = [[NSString alloc]decodeBase64:dev_name] ;
        }
    }
    
}
- (void)setSuccess:(NSNotification*)successNote
{
   // NSLog(@"successNote = %@" , [successNote userInfo]);
    [super showStatusTip:NO andTitle:@"闹钟设置成功"] ;
}
- (void)removeDevice:(NSNotification*)removeDeviceNote
{
    
    NSString *remove_devSn = [removeDeviceNote object][@"dev_sn"];
    for (int i = 0; i < _devicesTotalArr.count; i++) {
        DevicesInfoModel *model = _devicesTotalArr[i];
        if ([remove_devSn isEqualToString:model.dev_sn]) {
            [_devicesTotalArr removeObjectAtIndex:i];
        }
    }
    [self updateAlertInfo];

}
#pragma mark-----闹钟设置成功通知
- (void)settingSuccess:(NSNotification*)successNote
{
    NSArray *arr = [successNote object];
    int indexs = [arr[0] intValue];
    NSString *s_hour = arr[1] ;
    NSString *s_min = arr[2] ;
    int success_hour = [arr[1] integerValue];
    int success_min = [arr[2] integerValue];
    BOOL isSettingSuccess = [arr[3] boolValue];
    if (success_hour < 10) {
        s_hour = [NSString stringWithFormat:@"%02d" , success_hour];
    }
    if (success_min < 10) {
        s_min = [NSString stringWithFormat:@"%02d" , success_min];
    }
    NSString *timeStr = [NSString stringWithFormat:@"%@:%@",s_hour , s_min];
    //把NSString转化为NSDate
    NSDate* date = [[NSString alloc]dateFromFomate:timeStr formate:@"HH:mm"];
    
    AlarmClock *clock = _clockArr[indexs];
    UIView *bgView = _clockBgViewArr[indexs];
    clock.time = date ;
    
    
    UILabel *timeLabel = _clockLabelArr[indexs] ;
    timeLabel.text = timeStr;
    
    UISwitch *switchClose = _switchClockArr[indexs];
    switchClose.on = YES ;
    
    if (isSettingSuccess) {
        clock.backgroundColor = _colorArr[indexs];
        bgView.backgroundColor = _colorArr[indexs];
        [clock setNeedsDisplay];
        [clock awakeFromNib];
    }else{
        UIColor *closeColor = [UIColor colorWithRed:229/255.0 green:229/255.0 blue:229/255.0 alpha:1.0];
        clock.backgroundColor = closeColor;
        bgView.backgroundColor = closeColor;
        [clock setNeedsDisplay];
        [clock awakeFromNib];

    }

}
#pragma mark-----闹钟停用通知
- (void)stopAlermNote:(NSNotification*)stopNote
{
    _isStop_setting = YES ;
    NSArray *arr = [stopNote object];
    _closeClockIndex = [arr[0] integerValue];
    [self submitAlarmInfoToServer:[arr[1] boolValue]];
   //[self changeBgViewColor:YES];
    
}
#pragma mark-----后台更新设备完成后反馈回来的数据
- (void)updateDevicesComplete:(int)infoInt
{
   
    if (_devicesTotalArr.count!= 0) {
        for (int i = 0; i < _devicesTotalArr.count; i++) {
            DevicesInfoModel *model = _devicesTotalArr[i];
            if ([_selectedDev_sn isEqualToString:model.dev_sn]) {
                [_devicesTotalArr exchangeObjectAtIndex:0 withObjectAtIndex:i];
            }
        }
        [self updateAlertInfo];
    }
}
#pragma mark------设备天气页面
- (void)weatherMain:(id)weatherData
{
    if (![weatherData isKindOfClass:[WeatherInfo class]]) {
        return;
    }
    WeatherInfo *weatherInfoModel = weatherData ;
    _devicesCityLabel.text = [[NSString alloc]decodeBase64:_devicesCity];
    _TemperatureLabel.text = weatherInfoModel.temp ;
    _AverageTemp.text = weatherInfoModel.ac_temp ;
    int index = [weatherInfoModel.weather intValue];
    _weatherImg.image = [UIImage imageNamed:_weatherImgArr[index-1]];
    _weatherStatus.text = _weatherStautArr[index-1];
    
    NSArray *dateAndWeekArr = [self getDateAndWeekInNoWifiStaut];
    _dateLabel.text = dateAndWeekArr[0];
    _weekLabel.text = dateAndWeekArr[1]  ;
}
#pragma mark------- 关闭或打开闹钟后改变背景色
- (void)changeBgViewColor:(BOOL)state
{
    if (state) {
        AlarmClock *clock = _clockArr[_closeClockIndex];
        UIView *bgView = _clockBgViewArr[_closeClockIndex];
        UIColor *closeColor = [UIColor colorWithRed:229/255.0 green:229/255.0 blue:229/255.0 alpha:1.0];
        clock.backgroundColor = closeColor;
        bgView.backgroundColor = closeColor;
        [clock setNeedsDisplay];
        [clock awakeFromNib];
    }else
    {
        AlarmClock *clock = _clockArr[_closeClockIndex];
        clock.backgroundColor = _colorArr[_closeClockIndex];
        UIView *bgView = _clockBgViewArr[_closeClockIndex];
        bgView.backgroundColor = _colorArr[_closeClockIndex];
        [clock setNeedsDisplay];
        [clock awakeFromNib];
        
    }
}
#pragma mark-----------------------------Netrequest-----------------------------
#pragma mark----------更新设备
- (void)updateDevicesInfo:(BOOL)isReadCacheData
{

    [[MKNetWork shareMannger]startNetworkWithNeedCommand:@"2051" andNeedUserId:USER_ID AndNeedBobyArrKey:@[@"dev_type"] andNeedBobyArrValue:@[@"-1"]needCacheData:NO  needFininshBlock:^(id result){
        
        self.devicesTotalArr = result ;
        [self updateDevicesComplete:0];
        [_refreshView endRefreshing];
        
    }needFailBlock:^(id fail){
         [_refreshView endRefreshing];
    }];
}
#pragma mark-----获取天气信息
- (void)getWeatherInfo
{
    DevicesInfoModel *model = self.devicesTotalArr[0];
    [[MKNetWork shareMannger]startNetworkWithNeedCommand:@"2076" andNeedUserId:USER_ID AndNeedBobyArrKey:@[@"req_id" , @"city" ] andNeedBobyArrValue:@[@"-1" , model.dev_city]needCacheData:YES  needFininshBlock:^(id result){
        [self weatherMain:result];
        [_refreshView endRefreshing];
    }needFailBlock:^(id fail){
         [_refreshView endRefreshing];
    }];

}
#pragma mark------打开或关闭闹钟
- (void)submitAlarmInfoToServer:(BOOL)isclose
{
    static NSString *state ;
    if (isclose) {
        state = @"0" ;
        if (!_isStop_setting) {
            [super showHUD:@"正在停用" isDim:YES];
        }

    }else{
        state = @"1" ;
        if (!_isStop_setting) {
            [super showHUD:@"正在打开" isDim:YES];
        }

    }
    DevicesInfoModel *model = _devicesTotalArr[0];
    NSMutableArray *alerm_arr = model.alermInfoArr ;
    AlarmInfoModel *alerinfoModel = nil ;
    for (AlarmInfoModel *alerinfo_Model in alerm_arr) {
        int index = [alerinfo_Model.index intValue];
        if (index == _closeClockIndex) {
            alerinfoModel = alerinfo_Model ;
        }
    }
    //把设置信息保存到网络
    NSDictionary *dic = @{
                          @"index": alerinfoModel.index,        //闹钟的索引值
                          @"state":state ,                 //闹钟的开关状态 0 关闭  、 1 开启
                          @"frequency":alerinfoModel.frequency ,       //频率
                          @"sleep_times":alerinfoModel.sleep_times ,     //睡眠次数
                          @"sleep_gap": alerinfoModel.sleep_gap ,      //睡眠间隔
                          @"hour":alerinfoModel.hour ,                //时
                          @"minute": alerinfoModel.minute ,       //分
                          @"vol_level":alerinfoModel.vol_level ,  //音量
                          @"vol_type": alerinfoModel.vol_type ,         //铃音类型0 为语音;1 为音乐;2 为 FM;3 为系统
                          @"fm_chnl":alerinfoModel.fm_chnl,           //FM频道
                          @"file_path":alerinfoModel.file_path,          //音源路径
                          @"file_id" :  alerinfoModel.file_id                     //音源 ID
                          
                          };
    //NSLog(@"%@" , dic);
    [[MKNetWork shareMannger]startNetworkWithNeedCommand:@"2052" andNeedUserId:USER_ID AndNeedBobyArrKey:@[@"dev_sn" , @"alarm_info"]  andNeedBobyArrValue:@[DEV_SN , dic] needCacheData:NO needFininshBlock:^(id result){
        
        int errorInt = [result intValue];
        if (errorInt == 0) {
            NSString *alerInfo ;
            if (isclose) {
                alerInfo = @"停用完成" ;
            }else{
                alerInfo = @"打开完成" ;
            }
            if (!_isStop_setting) {
                 [super showHUDComplete:alerInfo isSuccess:YES];
            }else{
                NSArray *stopArr = @[alerInfo  , [NSNumber numberWithBool:YES]];
                [[NSNotificationCenter defaultCenter]postNotificationName:FEEKBACK_STOP_ALERM_ISSUCCESS object:stopArr userInfo:nil];
            }
            //改变背景色
            [self changeBgViewColor:isclose];

        }
        else{
            NSString *alertInfo ;
            if (isclose) {
                alertInfo = @"停用失败" ;
            }else{
                alertInfo = @"打开失败" ;
            }
            if (!_isStop_setting) {
                [super showHUDComplete:alertInfo isSuccess:NO] ;
            }else{
                NSArray *stopArr = @[alertInfo  , [NSNumber numberWithBool:NO]];
                [[NSNotificationCenter defaultCenter]postNotificationName:FEEKBACK_STOP_ALERM_ISSUCCESS object:stopArr userInfo:nil];
            }
            
            UISwitch *switchClose = _switchClockArr[_closeClockIndex] ;
            if (isclose) {
                switchClose.on = YES ;
            }else{
                switchClose.on = NO ;
            }
            
        }
        
    }needFailBlock:^(id fail){
        NSString *alertInfo ;
        if (isclose) {
            alertInfo = @"停用失败" ;
        }else{
            alertInfo = @"打开失败" ;
        }
        if (!_isStop_setting) {
            [super showHUDComplete:alertInfo isSuccess:NO] ;
        }else{
            NSArray *stopArr = @[alertInfo  , [NSNumber numberWithBool:NO]];
            [[NSNotificationCenter defaultCenter]postNotificationName:FEEKBACK_STOP_ALERM_ISSUCCESS object:stopArr userInfo:nil];
        }
        
        UISwitch *switchClose = _switchClockArr[_closeClockIndex] ;
        if (isclose) {
            switchClose.on = YES ;
        }else{
            switchClose.on = NO ;
        }

    }];
        
}
#pragma mark-----------------------------Delegate-----------------------------
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 50) {
         [[UIApplication sharedApplication] openURL:[NSURL URLWithString:_app_url]];
    }else if (alertView.tag == 51&& buttonIndex == 1){
         [[UIApplication sharedApplication] openURL:[NSURL URLWithString:_app_url]];
    }
}
#pragma mark-----上拉刷新
- (void)refreshFethNetData:(MJRefreshBaseView *)refreshView
{
    static BOOL flag = YES ;
    [self updateDevicesInfo:flag];
    self.refreshView = refreshView ;
    flag = NO ;
}
@end
