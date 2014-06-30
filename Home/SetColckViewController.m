//
//  SetColckViewControllers.m
//  iSpace
//
//  Created by 莫景涛 on 14-4-24.
//  Copyright (c) 2014年 莫景涛. All rights reserved.
//

#import "SetColckViewController.h"
#import "RecordModel.h"
#import "MBProgressHUD.h"
#import "RepeatButton.h"
#import "AddMusicViewController.h"
#import "RecordViewController.h"
#import "FMViewController.h"
#import "VoiceConverter.h"

@interface SetColckViewController ()
@end

@implementation SetColckViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.titleLabel.text = @"设置闹钟" ;
        [self.titleLabel sizeToFit];
    }
    return self;
}
- (void)viewDidLoad
{
    

    [super viewDidLoad];
    
    [self addPickerView];
    [self setCell];
    [self showAlarmInfo];
    
    //
    if (_alarmInfoModel != NULL) {
        //alermState = [_alarmInfoModel.state integerValue];
        barButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [barButton setFrame:CGRectMake(0, 0, 100, 44)];
        barButton.backgroundColor = [UIColor clearColor];
        if ([_alarmInfoModel.state isEqualToString:@"1"]) {
            [barButton setTitle:@"         停用" forState:UIControlStateNormal];
            barButton.tag = 11 ;
        }else if ([_alarmInfoModel.state isEqualToString:@"0"]){
            [barButton setTitle:@"         启用" forState:UIControlStateNormal];
            barButton.tag = 10 ;
        }
        barButton.titleLabel.textAlignment = NSTextAlignmentRight ;
        [barButton addTarget:self action:@selector(stopAlarm:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc]initWithCustomView:barButton];
        self.navigationItem.rightBarButtonItem = barButtonItem ;
    }
   
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    _isWav = NO ;
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(getSelectedOnlineCollectInfo:) name:@"postRecordModel" object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(getSelectedRecordFileName:) name:@"postRecordName" object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(getSelectedFmInfo:) name:@"postFMlist" object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(getSelectedLocalMusicInfo:) name:@"postMusicModel" object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(getMyUploadMusicModel:) name:@"postMyUploadModel" object:nil];
    
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    [pickerView removeObserver:self forKeyPath:@"selectTimeString"];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    
}
#pragma mark-----UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1 ;
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *cellID = @"cellID" ;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = _alermInfoCell;
    }
    
    return cell ;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 350.0 ;
}
#pragma mark-----------------------------------CustomAction-----------------------------------
#pragma mark------停用闹钟
- (void)stopAlarm:(UIButton*)button
{
    if (_alarmInfoModel == NULL) {
        [super showHUDComplete:@"还未设置" isSuccess:NO];
        return ;
    }
    NSNumber *boolNumber ;
    if ([_alarmInfoModel.state isEqualToString:@"0"]) {
        
         [super showHUD:@"正在开启" isDim:YES];
        boolNumber = [NSNumber numberWithBool:NO];
        
    }else if ([_alarmInfoModel.state isEqualToString:@"1"]){
        [super showHUD:@"正在停用" isDim:YES];
        boolNumber = [NSNumber numberWithBool:YES];
    }
    NSString *stop_index = [NSString stringWithFormat:@"%d" , _clockButtonTag - 1];
    NSArray *arr = @[stop_index , boolNumber];
    [[NSNotificationCenter defaultCenter]postNotificationName:STOP_ALERM_NOTE object:arr userInfo:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(isStopAlermSuccess:) name:FEEKBACK_STOP_ALERM_ISSUCCESS object:nil];
    
    
}

#pragma mark----------添加时间选择器
- (void)addPickerView
{
    //自定义日期选择器

    pickerView = [[RBCustomDatePickerView alloc] initWithFrame:CGRectMake(0, 0, 320, 190)andTime:_time];//_time
    [pickerView setHourScrollView:100 andPonitY:0 andWith:60 andHeight:190];
    [pickerView setMinuteScrollView:160 andPonitY:0 andWith:60 andHeight:190];
    
    [pickerView addObserver:self forKeyPath:@"selectTimeString" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:nil];
    
    pickerView.userInteractionEnabled = YES ;
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panAction:)];
    [pickerView addGestureRecognizer:pan];
    
    //以":"切割（时间）
    NSArray *dateArr = [ pickerView.selectTimeString componentsSeparatedByString:@":"];
    self.hour = dateArr[0];
    self.minute = dateArr[1];
    self.setAlarmTabelView.tableHeaderView = pickerView ;

}
- (void)panAction:(UIPanGestureRecognizer*)pan
{
    
}
#pragma mark----------设置Cell
- (void)setCell
{
    //给重复视图添加圆角和边框
    _repeatViewBg.layer.cornerRadius = 5.0 ;
    _repeatViewBg.layer.borderWidth = 1.0 ;
    _repeatViewBg.layer.borderColor = [UIColor lightGrayColor].CGColor ;
    _repeatViewBg.clipsToBounds = YES ;
    
    //默认是首选“音乐”响铃方式
    _RingStyleTitleStr = @"音乐" ;

    self.styleView.height = 30 ;
    _styleView.clipsToBounds = YES ;
    
}
#pragma mark----------根据响铃方式标题对应相应列表
- (void)titleCorrespondList:(NSString*)title
{
    
    if ([title isEqualToString:@"音乐"]) {
        if (self.localMusicName != nil && _localMusicName.length != 0) {
            _showTitle.text = _localMusicName ;
        }else{
            _showTitle.text = @"点击进入音乐列表" ;
        }
        
    }else if ([title isEqualToString:@"广播"]){
        if (self.fm_chnl != nil && ![self.fm_chnl isEqualToString:@"-1"]) {
            _showTitle.text = [NSString stringWithFormat:@"%0.1f" , [_fm_chnl floatValue]/10] ;
        }else{
            _showTitle.text = @"点击进入广播列表" ;
        }
        
    }else if ([title isEqualToString:@"语音"]){
        if (self.selectedRecordName != nil &&self.selectedRecordName.length > 0) {
            if (!_isKeepLastSet) {
                _showTitle.text = _selectedRecordName;
                
                return ;
            }
            NSArray *separatedArr = [_selectedRecordName componentsSeparatedByString:@"."];
            NSString *showName = [NSString stringWithFormat:@"%@.%@" ,[[NSString alloc]initWithData:[GTMBase64 decodeString:separatedArr[0]] encoding:NSUTF8StringEncoding] , separatedArr[1] ];
            _showTitle.text =  showName;
        }else{
            _showTitle.text = @"点击进入语音列表" ;
        }
        
    }
    
}
#pragma mark----------重复－－点击时的背景色
-(UIImage *)imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    
    return image;
}
#pragma mark----------显示原本设置的信息
- (void)showAlarmInfo
{
    if (self.alarmInfoModel == nil) {
        [self titleCorrespondList:@"音乐"];
        _isKeepLastSet = YES ;
        return ;
    }

    //时间
    self.hour = _alarmInfoModel.hour ;
    self.minute = _alarmInfoModel.minute ;
    self.vol_level = _alarmInfoModel.vol_level ;
    
//重复
    int frequency = _alarmInfoModel.frequency.intValue;
    int remainder = 0 ;  //余数
    while (frequency > 0) {
        remainder = frequency % 2 ;
        frequency = frequency / 2 ;
        NSNumber *flag = nil ;
        if (remainder == 1) {
            flag = [NSNumber numberWithBool:YES];
        }else{
            flag = [NSNumber numberWithBool:NO];
        }
        
        if (self.frequencyArr == nil) {
            self.frequencyArr = [[NSMutableArray alloc]initWithCapacity:7];
        }
        [self.frequencyArr addObject:flag];
    }
    
    for ( int indexs = 0 ; indexs < _frequencyArr.count ; indexs++ ) {
        BOOL flag = [self.frequencyArr[indexs]boolValue];
        if (flag) {
            RepeatButton *btn = (RepeatButton*)[_repeatViewBg viewWithTag:indexs + 1];
            [btn setBackgroundImage:[self imageWithColor:ORANGECOLOR] forState:UIControlStateSelected];
            [self setRepeatDate:btn];
        }
    }

//响铃方式 0 为语音;1 为音乐;2 为 FM;3 为系统。vol_type
    int vol_type = [_alarmInfoModel.vol_type intValue];
    switch (vol_type) {
        case 0:
            self.file_path = _alarmInfoModel.file_path ;
            self.file_id = _alarmInfoModel.file_id ;
            self.selectedRecordName= [[NSString alloc]decodeBase64:_alarmInfoModel.name];
            self.isKeepLastSet = NO ;
            
            [self titleCorrespondList:@"语音"];
            [_showButton setTitle:@"语音" forState:0];
            [_recordButton setTitle:@"音乐" forState:0];
            break;
        case 1:
            self.file_path = _alarmInfoModel.file_path ;
            self.file_id = _alarmInfoModel.file_id ;
            self.localMusicName= [[NSString alloc]decodeBase64:_alarmInfoModel.name];
            self.isKeepLastSet = NO ;

            [self titleCorrespondList:@"音乐"];
            break;
        case 2:
             _fm_chnl = _alarmInfoModel.fm_chnl ;
            self.isKeepLastSet = YES ;
            [self titleCorrespondList:@"广播"];
            [_showButton setTitle:@"广播" forState:0];
            [_fmButton setTitle:@"音乐" forState:0];
           
            
            break;
        default:
            break;
    }
    
 //音量 vol_level
    _vol_level = _alarmInfoModel.vol_level ;
    if ( [_vol_level isEqualToString:@"255"]) {
        [self ringSoundButtonActin:nil];
    }
//睡眠间隔
    self.sleep_gap = _alarmInfoModel.sleep_gap  ;
    if (![_sleep_gap isEqualToString:@"-1" ]) {
        _frequencyButton.selected = YES ;
        _alartLabel.alpha = 0.0 ;
        _frequencySlider.alpha = 1.0 ;
        _frequencySlider.value = [_sleep_gap floatValue];
        _frequencyLabel.text = [NSString stringWithFormat:@"%@分钟" , _sleep_gap] ;
    }
    
}
#pragma mark----------响铃方式（音乐、语音、FM）
- (IBAction)selectRingStyleAction:(UIButton*)sender
{
    if (!_isOpenRingType) {
        [UIView animateWithDuration:0.5 animations:^{
            _styleView.height = 90 ;
        }];
        
    }else{
        [UIView animateWithDuration:0.5 animations:^{
            _styleView.height = 30 ;
        }];
    }
    if (sender.tag == 1) {
        _isOpenRingType = !_isOpenRingType ;
        return ;
    }
    //更换标题
    _RingStyleTitleStr = [sender titleForState:UIControlStateNormal];
    NSString *changeTitle = [_showButton titleForState:UIControlStateNormal];
    [_showButton setTitle:_RingStyleTitleStr forState:UIControlStateNormal];
    [sender setTitle:changeTitle forState:UIControlStateNormal];
    
    _isOpenRingType = !_isOpenRingType ;
    
    //kvo 来监听响铃方式改变时对应列表也跟着变
    [self titleCorrespondList:_RingStyleTitleStr];

}
#pragma mark----------闹钟音量是否渐渐加大
- (IBAction)ringSoundButtonActin:(UIButton*)sender
{
    
    self.vol_levelButton.selected = !self.vol_levelButton.selected ;
    if (self.vol_levelButton.selected) {
        _vol_level = @"255" ;
    }else{
        _vol_level = @"5" ;
    }

}
#pragma mark----------二次闹钟
- (IBAction)alarmFrequency:(UIButton *)sender {
    
    self.frequencyButton.selected = !self.frequencyButton.selected ;
    if (self.frequencyButton.selected) {
        [UIView animateWithDuration:0.2 animations:^{
            self.frequencySlider.alpha = 1.0 ;
            self.frequencyLabel.alpha = 1.0 ;
            self.alartLabel.alpha = 0.0 ;
        }];
        
    }else{
        [UIView animateWithDuration:0.2 animations:^{
            self.frequencySlider.alpha = 0.0 ;
            self.frequencyLabel.alpha = 0.0 ;
            self.alartLabel.alpha = 1.0 ;
        }];

    }
    
}
#pragma mark----------二次闹钟间隔时间
- (IBAction)FrequencyValue:(UISlider *)sender {
    
    self.sleep_gap = [NSString stringWithFormat:@"%0.0f" , sender.value] ;
    self.frequencyLabel.text = [NSString stringWithFormat:@"%0.0f分钟" ,sender.value ];
    
    
}
#pragma mark----------点确定按钮获取闹钟设置信息
- (IBAction)saveAlarmSetInfoAction:(id)sender
{
   
    [super showHUD:@"正在设置" isDim:YES];
    //频率（重复日期）
    self.frequency = [NSString stringWithFormat:@"%d" , _repeatDates];
    
    //音量
    if (self.vol_level == nil) {
        self.vol_level = @"5" ;
    }
 
    //响铃方式
    NSString *ringStyleStr =  [_showButton titleForState:UIControlStateNormal];
    if ([ringStyleStr isEqualToString:@"广播"]) {
        self.vol_type = @"2" ;
        self.file_path = @"" ;
        self.file_id = @"-1" ;
         if (self.fm_chnl == nil || [self.fm_chnl  isEqualToString:@"-1"]) {
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"温情提示" message:@"亲~您好像没有选频道哦" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
            [alertView show];
             [super hideHUD];
            return ;
         }
    }
    else if ([ringStyleStr isEqualToString:@"音乐"]){
        _vol_type = @"1" ;
        _fm_chnl = @"-1" ;
        
        //上传音乐
        if (!_isKeepLastSet ) {
            
            if (_file_path.length == 0 || _file_path == nil) {
                [super hideHUD];
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:@"亲~您还未选择音乐哦" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
                [alertView show];
                return ;
            }

             [self submitAlarmInfoToServer];
            
             return ;
        }
        else{
            [self startPostFileToServer:YES needFileName:_localMusicName];
            return ;
        }
       
    }
    else if ([ringStyleStr isEqualToString:@"语音"]){
        _vol_type = @"0" ;
        _fm_chnl = @"-1" ;
        if (!_isKeepLastSet ) {
            if (_file_path.length == 0 || _file_path == nil) {
                [super hideHUD];
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:@"亲~您还未选择语音哦" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
                [alertView show];
                return ;
            }
            [self submitAlarmInfoToServer];
            return ;
        }
        
        //上传语音
        if (_isSelectedRecord) {
            [self startPostFileToServer:NO needFileName:_selectedRecordName];
            return ;
        }
        //我的上传
        if (_isMyUpload) {
            _file_path = _selectedUploadModel.url ;
            _file_id = _selectedUploadModel.fid ;
        }else{//收藏的语音
       
            _file_path = _SelectedCollectModel.recordUrl ;
            _file_id = _SelectedCollectModel.recordId ;
            if (_file_id == nil || _file_path == nil) {
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"温情提示" message:@"亲~您好像没有选语音哦" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
                [alertView show];
                [super hideHUD];
                return ;
            }
        }
    }
    
    [self submitAlarmInfoToServer];
}
#pragma mark----------设置重复的日期
- (IBAction)setRepeatDate:(UIButton*)sender
{
    
    NSArray *frequencyArr = @[ @"1" , @"2" ,@"4" , @"8" , @"16" , @"32" , @"64"];
    NSString *strInt = frequencyArr[sender.tag - 1];
    sender.selected = !sender.selected ;
    if (sender.selected) {
        sender.backgroundColor = [UIColor colorWithPatternImage:[self imageWithColor:ORANGECOLOR]];
        _repeatDates = _repeatDates + strInt.intValue;
    }else{
        sender.backgroundColor = [UIColor clearColor];
        _repeatDates = _repeatDates - strInt.intValue;
    }
    //NSLog(@"%d , %d" , sender.tag , _repeatDates);
}
#pragma mark----------ring列表
- (IBAction)pushRingList:(id)sender
{
    _RingStyleTitleStr =  [_showButton titleForState:UIControlStateNormal];
    
    if ([_RingStyleTitleStr isEqualToString:@"音乐"])  {
        static AddMusicViewController *addLocalMusicCtl = nil ;
        if (addLocalMusicCtl == nil) {
            addLocalMusicCtl = [[AddMusicViewController alloc]init];
        }
        [self.navigationController pushViewController:addLocalMusicCtl animated:YES];
        
    }
    else if ([_RingStyleTitleStr isEqualToString:@"广播"])  {
        static FMViewController *fmViewCtl = nil;
        if (fmViewCtl == nil) {
            fmViewCtl = [[FMViewController alloc]init];
        }
        
        [self.navigationController pushViewController:fmViewCtl animated:YES];
    }
    else if ([_RingStyleTitleStr isEqualToString:@"语音"])  {
        static RecordViewController *listViewCtl = nil;
        if (listViewCtl == nil) {
            listViewCtl = [[RecordViewController alloc]init];
        }
        
        [self.navigationController pushViewController:listViewCtl animated:YES];
    }
    

}
#pragma mark-------获取文件属性（如：大小、文件名……）
- (NSMutableArray*)getFilePropertyNeedFileName:(NSString*)fileName needBool:(BOOL)isLocalMusic
{
    if (fileName == nil ) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"温情提示" message:@"亲~您好像还没选好音乐哦" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alertView show];
        [super hideHUD];
        return nil;
    }
     //@"filename" , @"type" , @"size" ,@"md5" , @"req_id" , @"set" @"filePath"
    NSMutableArray *propertyArr = [[NSMutableArray alloc]initWithCapacity:5];
    
    //文件名、文件类型（格式)
    
    NSString *name = [fileName stringByDeletingPathExtension];
    NSString *type = [NSString stringWithFormat:@".%@" , [fileName pathExtension]];
    
    //NSArray *separatedArr = [fileName componentsSeparatedByString:@"."];
    
    if (isLocalMusic) {
        NSString *base64Name = [[NSString alloc]encodeBase64:name];
        [propertyArr addObject:base64Name];
        if ([type isEqualToString:@".wav"]) {
            self.isWav = YES ;
        }
        [propertyArr addObject:type];
        
    }else{
         [propertyArr addObject:name];
         [propertyArr addObject:type];
    }
   
    
    //工程的document目录
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *document = [paths objectAtIndex:0];
    
    //如果是音乐
    if (isLocalMusic) {
        //文件保存的目录
        NSString *musicPath = [NSString stringWithFormat:@"%@/%@/%@/%@" , document , USERNAME , @"WIFIMusic" , fileName];
        
        if (_isWav) {
            /*
            //转化wav——amr
            NSString *amrPath = [NSString stringWithFormat:@"%@/%@/%@/%@" , document , USERNAME , @"WIFIMusic" , @"wavToamr.amr"];
            int i = [VoiceConverter wavToAmr:musicPath amrSavePath:amrPath];
            
            NSLog(@"+++++---===--==%d" , i ) ;
            if (i == 0) {
                musicPath = [amrPath copy];
                [propertyArr replaceObjectAtIndex:1 withObject:@".amr"];
            }
            else{
                self.isWav = NO ;
            }

            */
            self.isWav = NO ;
        }
        
        NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:musicPath];
        
        //文件大小
        NSInteger size = [fileHandle availableData].length ;
        if (size  > 4.0 * 1024 *1024) {
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"温情提示" message:@"上传的音乐文件不能大于4M" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
            [alertView show];
            [super hideHUD];
            return nil;
        }
        NSString *fileSize = [NSString stringWithFormat:@"%d" , size ];
        [propertyArr addObject:fileSize];
        
        //文件的MD5值
        NSData *fileData = [fileHandle availableData] ;
        NSString *fileStr = [[NSString alloc]initWithData:fileData encoding:NSUTF8StringEncoding];
        [propertyArr addObject:[[NSString alloc]md5:fileStr]];
        
        //req_id , set
        [propertyArr addObject:@"-1"];
        [propertyArr addObject:@"4"];
        
        //文件路径
        [propertyArr addObject:musicPath];
        
        [fileHandle closeFile] ;
        
        return propertyArr ;
    }
    else//语音
    {
        //文件保存的目录
        NSString *recordPath = [NSString stringWithFormat:@"%@/%@/%@/%@" , document , USERNAME , @"Record" , fileName];
        
        //转化wav——amr
        NSString *amrPath = [NSString stringWithFormat:@"%@/%@/%@/%@" , document , USERNAME , @"Record" , @"wavToamr.amr"];
        int i = [VoiceConverter wavToAmr:recordPath amrSavePath:amrPath];
        NSLog(@"+++++---===--==-%d" , i ) ;
        if (i == 0) {
            recordPath = [amrPath copy];
             [propertyArr replaceObjectAtIndex:1 withObject:@".amr"];
        }
        
        NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:recordPath];
        
        //文件大小
        NSInteger size = [fileHandle availableData].length ;
        if (size  > 4 *1024 * 1024) {
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"温情提示" message:@"上传的语音文件不能大于4M" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
            [alertView show];
            [super hideHUD];
            return nil;
        }
        NSString *fileSize = [NSString stringWithFormat:@"%d" , size ];
        [propertyArr addObject:fileSize];
        
        //文件的MD5值
        NSData *fileData = [fileHandle availableData] ;
        NSString *fileStr = [[NSString alloc]initWithData:fileData encoding:NSUTF8StringEncoding];
        [propertyArr addObject: [[NSString alloc]md5:fileStr]];
        
        //req_id , set
        [propertyArr addObject:@"-1"];
        [propertyArr addObject:@"2"];
        
        //文件路径
        [propertyArr addObject:recordPath];
        
        
        [fileHandle closeFile] ;
        return propertyArr ;
    }
    return nil ;
}

#pragma mark-----------------------------------NSNotification-----------------------------------
- (void)getSelectedOnlineCollectInfo:(NSNotification*)selectedOnlineCollectNote
{
    _SelectedCollectModel = [selectedOnlineCollectNote object];
    _showTitle.text = [[NSString alloc]decodeBase64:_SelectedCollectModel.recordName] ;
    _isSelectedRecord = NO ;
    _isKeepLastSet = YES ;
}
- (void)getSelectedRecordFileName:(NSNotification*)selectedRecordFileNote
{
    NSString *recordName = [selectedRecordFileNote object] ;
    NSString *dec_recordName = [[NSString alloc]decodeBase64:[recordName stringByDeletingPathExtension]];
    NSString *showRecordName =[NSString stringWithFormat:@"%@.%@" , dec_recordName , [recordName pathExtension]];
    _showTitle.text = showRecordName ;
    
    _selectedRecordName = [selectedRecordFileNote object];
    _isSelectedRecord = YES ;
    _isMyUpload = NO ;
    _isKeepLastSet = YES ;
}
- (void)getSelectedFmInfo:(NSNotification*)selectedFmInfoNote
{
    NSString *str = [selectedFmInfoNote object];
    NSString *showStr = [NSString stringWithFormat:@"%0.1f" , str.floatValue*0.1];
    _showTitle.text = showStr;
    
    _fm_chnl = [selectedFmInfoNote object];
}
- (void)getSelectedLocalMusicInfo:(NSNotification*)selectedLocalMusicNote
{
    _showTitle.text = [selectedLocalMusicNote object];
    _localMusicName = [selectedLocalMusicNote object];
    _isKeepLastSet = YES ;
}
- (void)getMyUploadMusicModel:(NSNotification*)myUploadNote
{
    _selectedUploadModel = [myUploadNote object];
    _showTitle.text = [[NSString alloc]decodeBase64:_selectedUploadModel.name];
    _isSelectedRecord = NO ;
    _isMyUpload = YES ;
    _isKeepLastSet = YES ;
}
#pragma mark-----主页界面发送过来是否停用成功
- (void)isStopAlermSuccess:(NSNotification*)stopAlermInfo
{
    NSArray *stopArr = [stopAlermInfo object];
    NSString *alertInfo = stopArr[0];
    BOOL isSuccess = [stopArr[1] boolValue];
    if (isSuccess) {
        if ([_alarmInfoModel.state isEqualToString:@"0"]) {
            [barButton setTitle:@"         停用" forState:UIControlStateNormal];
            _alarmInfoModel.state = @"1" ;
        }else if ([_alarmInfoModel.state isEqualToString:@"1"]){
             [barButton setTitle:@"         启用" forState:UIControlStateNormal];
            _alarmInfoModel.state = @"0" ;
        }
    }
    [super showHUDComplete:alertInfo isSuccess:isSuccess];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:FEEKBACK_STOP_ALERM_ISSUCCESS object:nil];
}
#pragma mark-----接收通知
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    //以":"切割（时间）
    NSArray *dateArr = [ change[@"new"] componentsSeparatedByString:@":"];
    self.hour = dateArr[0];
    self.minute = dateArr[1];
    
}
#pragma mark-----------------------------------NetRequset-----------------------------------
#pragma mark------------提交设置闹钟信息到服务器
- (void)submitAlarmInfoToServer
{
    //NSLog(@"%d ,%@ , %@ ,%@ ,%@, %@ , %@ , %@ ,%@ , %@" ,_clockButtonTag , _hour , _minute , _frequency , _sleep_gap,_vol_level , _vol_type , _fm_chnl , _file_path , _file_id );
    //提交之前检查包
    if (_frequency.length == 0) {
        _frequency = @"0";
    }
    if (_sleep_gap.length == 0) {
        _sleep_gap = @"10" ;
    }
    if (_hour.length == 0) {
        _hour = @"8";
    }
    if (_minute.length == 0) {
        _minute = @"0";
    }
    if (_vol_level.length == 0) {
        _vol_level = @"5" ;
    }
    if (_vol_type.length == 0) {
        _vol_type = @"3" ;
    }
    if (_fm_chnl.length == 0) {
        _fm_chnl = @"-1";
    }
    if (_file_path.length == 0) {
        _file_path = @"" ;
    }
    if (_file_id.length == 0){
        _file_id = @"-1";
    }
        
    //把设置信息保存到网络
    NSDictionary *dic = @{
                          @"index": [NSString stringWithFormat:@"%d" , _clockButtonTag-1],        //闹钟的索引值
                          @"state":@"1" ,                 //闹钟的开关状态
                          @"frequency": _frequency ,       //频率
                          @"sleep_times":@"0" ,     //睡眠次数
                          @"sleep_gap": _sleep_gap ,      //睡眠间隔
                          @"hour":_hour ,                //时
                          @"minute": _minute ,       //分
                          @"vol_level":_vol_level ,  //音量
                          @"vol_type": _vol_type ,         //铃音类型0 为语音;1 为音乐;2 为 FM;3 为系统
                          @"fm_chnl":_fm_chnl,           //FM频道
                          @"file_path":_file_path,          //音源路径
                          @"file_id" : _file_id             //音源 ID
                          
                          };
   // NSLog(@"post = %@" , dic);
    
    [[MKNetWork shareMannger]startNetworkWithNeedCommand:@"2052" andNeedUserId:USER_ID AndNeedBobyArrKey:@[@"dev_sn" , @"alarm_info"]  andNeedBobyArrValue:@[DEV_SN , dic] needCacheData:NO needFininshBlock:^(id result){
        
        int errorInt = [result intValue];
        
        if (errorInt == 0) {
            NSArray *succussArr = @[ [NSString stringWithFormat:@"%d" , _clockButtonTag-1] , _hour , _minute , [NSNumber numberWithBool:YES]];
            [[NSNotificationCenter defaultCenter]postNotificationName:SETTING_ISSUCCESS object:succussArr];
            [super showHUDComplete:@"设置完成" isSuccess:YES];
           
            [self.navigationController popViewControllerAnimated:YES];
            
        }else
        {
            [super hideHUD];
            UIAlertView *alertView =[ [UIAlertView alloc]initWithTitle:nil message:@"闹钟设置失败，您的闹钟可能离线" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil] ;
            [alertView show];
            
            NSArray *succussArr = @[ [NSString stringWithFormat:@"%d" , _clockButtonTag-1] , _hour , _minute , [NSNumber numberWithBool:NO]];
            [[NSNotificationCenter defaultCenter]postNotificationName:SETTING_ISSUCCESS object:succussArr];
        }

    }needFailBlock:^(id fail){
        [super hideHUD] ;
    }];
    
}
#pragma mark---------获取上传URL
- (void)startPostFileToServer:(BOOL)isMusicFile needFileName:(NSString*)fileName
{
    NSMutableArray *musicPropertyArr= [self getFilePropertyNeedFileName:fileName needBool:isMusicFile];
    if (musicPropertyArr.count == 0 || musicPropertyArr == nil) {
        return ;
    }
    __unsafe_unretained SetColckViewController *weakSelf = self ;
    [[MKNetWork shareMannger]startNetworkWithNeedCommand:@"2056" andNeedUserId:USER_ID AndNeedBobyArrKey:@[@"filename" , @"type" , @"size" ,@"md5" , @"req_id" , @"set"]  andNeedBobyArrValue:@[ musicPropertyArr[0], musicPropertyArr[1] , musicPropertyArr[2] , musicPropertyArr[3] ,musicPropertyArr[4] , musicPropertyArr[5] ] needCacheData:NO needFininshBlock:^(id result){
        
        NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:musicPropertyArr[6]];
        NSData *recordData = [fileHandle availableData];
        [weakSelf uploadFile:recordData toHost:result[0] atPort:result[1] withParams:result[2] andIsmusic:isMusicFile andRecordPath:musicPropertyArr[6]];
      
        
    }needFailBlock:^(id fail){
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:@"上传音乐失败" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alertView show];
        [super hideHUD] ;
    }];
    
}
#pragma mark --------上传文件
// 发送上传文件请求
-(void)uploadFile:(NSData *)data toHost:(NSString *)host atPort:(NSString *)port withParams:(NSString *)params andIsmusic:(BOOL)isMusicFile andRecordPath:(NSString*)filePath
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    NSString *url = [[NSString alloc] initWithFormat:@"http://%@:%@/iSpaceSvr/?%@", host, port, params];
    NSString *contentLength = [[NSString alloc] initWithFormat:@"%d", [data length]];
    
    [request setURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"POST"];
    [request setValue:contentLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"binary/octet-stream" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:data];
    [request setTimeoutInterval:60];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
     {
         NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
         
      
         NSString *error = dict[@"message_body"][@"error"];
         if ([error isEqualToString:@"0"]) {
             self.file_path = dict[@"message_body"][@"url"];
             self.file_id = dict[@"message_body"][@"fileid"];
         }
         dispatch_async(dispatch_get_main_queue(), ^{
             //删除wavToamr.amr
            if (!isMusicFile || _isWav) {
                        NSFileManager *fileManger = [NSFileManager defaultManager];
                        [fileManger removeItemAtPath:filePath error:nil];
                
                }
             
             [self submitAlarmInfoToServer];
         });
         
    }];
}

//- (void)getUrlAfterPostFileNeedUrl:(NSArray*)paramArr needFileName:(NSString*)fileName needFilePath:(NSString*)filePath isMusicFile:(BOOL)isMusicFile
//{
//    
//    
//    [[MKNetWork shareMannger] startPostFileToHostName:paramArr[0] andServerPath:paramArr[1] andFileName:fileName andFilePath:filePath andPostFininshBlock:^(id result){
//        if ([result isKindOfClass:[NSArray class]]) {
//            _file_path = result[0];
//            _file_id = result[1];
//            //删除wav_amr.amr
//            if (!isMusicFile) {
//                NSFileManager *fileManger = [NSFileManager defaultManager];
//                [fileManger removeItemAtPath:filePath error:nil];
//            }
//            [self submitAlarmInfoToServer];
//        }else
//        {
//            [_HUD hide:YES];
//        }
//    }andPostFailBlock:^(id fail){
//        [_HUD hide:YES];
//    }];
//    
//        
//}

@end
