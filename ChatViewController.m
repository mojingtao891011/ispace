//
//  ChatViewController.m
//  iSpace
//
//  Created by CC on 14-5-7.
//  Copyright (c) 2014年 xiabing. All rights reserved.
//

#import "ChatViewController.h"
#import "UITools.h"
#import "Tools.h"
#import "Constants.h"
#import "MBProgressHUD.h"
#import "UIView+Additions.h"
#import "UIImage+Additions.h"
#import "VoiceConverter.h"
#import "MessageFromFriendListCell.h"
#import "MessageFromMeListCell.h"
#import "MessageFromSystemListCell.h"
#import "MessageSender.h"
#import "MessageReceiver.h"
#import "EventEntity.h"
#import "DateTimePicker.h"
#import "CoreDataManager.h"
#import "MessageManager.h"
#import "NSDictionary+Additions.h"
#import "iSpaceApp.h"


#define kRecordActionSheet          0x100       // 录音操作表
#define kAudioMessageActionSheet    0x200       // 消息操作表


static NSString * const kMessageFromFriendListCellNibName = @"MessageFromFriendListCell";
static NSString * const kMessageFromFriendListCellIdentifier = @"MessageFromFriendListCell";
static NSString * const kMessageFromMeListCellNibName = @"MessageFromMeListCell";
static NSString * const kMessageFromMeListCellIdentifier = @"MessageFromMeListCell";
static NSString * const kMessageFromSystemListCellNibName = @"MessageFromSystemListCell";
static NSString * const kMessageFromSystemListCellIdentifier = @"MessageFromSystemListCell";


@interface ChatViewController () <AVAudioRecorderDelegate>

@property (strong, nonatomic) AVAudioRecorder *recorder;
@property (strong, nonatomic) AVAudioPlayer *player;
@property (assign, nonatomic) NSInteger playingIndex;      // 正在播放的索引
@property (copy, nonatomic) NSString *wavFilePath;
@property (copy, nonatomic) NSString *amrFilePath;
@property (copy, nonatomic) NSString *recordFileName;

@property (strong, nonatomic) UIActionSheet *recordActionSheet;
@property (strong, nonatomic) UIActionSheet *audioMessageActionSheet;
@property (strong, nonatomic) UIActionSheet *systemMessageActionSheet;

@end



@implementation ChatViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.titleLabel.text = NSLocalizedString(@"Chat View Title", nil);
        [self.titleLabel sizeToFit];
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.playingIndex = -1;
    [self.speakTipView setRounderWithRadius:10.0f];
    
    // 初始化TableView相关
    UINib *nib1 = [UINib nibWithNibName:kMessageFromFriendListCellNibName bundle:nil];
    [self.tableView registerNib:nib1 forCellReuseIdentifier:kMessageFromFriendListCellIdentifier];

    UINib *nib2 = [UINib nibWithNibName:kMessageFromMeListCellNibName bundle:nil];
    [self.tableView registerNib:nib2 forCellReuseIdentifier:kMessageFromMeListCellIdentifier];

    UINib *nib3 = [UINib nibWithNibName:kMessageFromSystemListCellNibName bundle:nil];
    [self.tableView registerNib:nib3 forCellReuseIdentifier:kMessageFromSystemListCellIdentifier];
    
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    [UITools turnOffTableViewSeperatorIndent:self.tableView];       // 关闭iOS7下的表格自动缩进
    [UITools setExtraCellLineHidden:self.tableView];                // 隐藏无内容的表格分隔线条
    
    // 清除聊天内容按钮
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 23, 23)];
    [button setImage:[UIImage imageNamed:@"chat_clear_message"]
            forState:UIControlStateNormal];
    [button addTarget:self
               action:@selector(handleClearMessages:)
     forControlEvents:UIControlEventTouchUpInside];
    [button setContentEdgeInsets:UIEdgeInsetsMake(0, -5, 0, 5)];
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.rightBarButtonItem = addButton;
    
    // 长按按钮事件初始化
    self.speakButton.exclusiveTouch = TRUE;
    UILongPressGestureRecognizer *longRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                                 action:@selector(handleLongPress:)];
    longRecognizer.minimumPressDuration = 0.1f;
    longRecognizer.allowableMovement = 20.0f;
    [self.speakButton addGestureRecognizer:longRecognizer];
    
    // 复位未读消息数量
    [[MessageManager defaultInstance] resetUnreadMessageForDevice:self.currentDeviceInfo.dev_sn];
    [[MessageManager defaultInstance] setMessageReaderState:kMessageReaderStateOpened];
    
    // 设置APP音频会话类型
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    
    // 增加录音音量
    UInt32 doChangeDefault = 1;
    AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryDefaultToSpeaker, sizeof(doChangeDefault), &doChangeDefault);
    
    // 监听与设备关联状态变更通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleDeviceRelationshipChanged:)
                                                 name:NM_SERVER_PUSH_MSG_2065
                                               object:nil];
}



// 监听我与设备关联状态变更通知
- (void)handleDeviceRelationshipChanged:(NSNotification *)notification
{
    NSDictionary *msgDict = [notification userInfo];
    NSDictionary *msgBody = [msgDict getDictionary:@"message_body"];
    NSInteger action = [msgBody getInteger:@"action"];
    NSString *deviceSerial = [msgBody getString:@"dev_sn"];
    
    // action: 0表示解除授权; 1表示授权;
    if (action == 0)
    {
        if ([deviceSerial isEqualToString:self.currentDeviceInfo.dev_sn])
        {
            [self stopPlay];
            [self.navigationController popViewControllerAnimated:TRUE];
        }
    }
}



// 视图即将隐藏
- (void)viewWillDisappear:(BOOL)animated
{
    [self setCellNormalState:self.playingIndex];
    [self stopPlay];
    
    if (self.isMovingFromParentViewController || self.isBeingDismissed)
    {
        if (_isShowingDatetimePicker)
        {
            [self dissDatePick];
        }
        
        [[MessageManager defaultInstance] setMessageReaderState:kMessageReaderStateClosed];
    }
}


// 聊天按钮长按
- (void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan)
    {
        _isSendCanceled = FALSE;
        _startPoint = [gestureRecognizer locationInView:self.view];
        
        self.speakTipView.hidden = FALSE;
        self.speakTipLabel.text = @"松开手指发送";
        self.speakTipImageView.image = [UIImage imageNamed:@"chat_tip_speak"];
        
        [self.speakButton setTitleColor:[UIColor colorWithRed:122.0f/255.0f green:222.0f/255.0f blue:188.0f/255.0f alpha:1.0f]
                               forState:UIControlStateNormal];
        [self setCellNormalState:self.playingIndex];
        [self stopPlay];
        [self initRecorder];
        [self startRecorder];
    }
    else if (gestureRecognizer.state == UIGestureRecognizerStateChanged)
    {
        CGPoint _currentPoint = [gestureRecognizer locationInView:self.view];
        CGFloat offset = _currentPoint.y - _startPoint.y;
        if (ABS(offset) > 80.0f)
        {
            self.speakTipLabel.text = @"松开手指取消发送";
            self.speakTipImageView.image = [UIImage imageNamed:@"chat_tip_cancel"];
            _isSendCanceled = TRUE;
        }
        else
        {
            self.speakTipLabel.text = @"松开手指发送";
            self.speakTipImageView.image = [UIImage imageNamed:@"chat_tip_speak"];
            _isSendCanceled = FALSE;
        }
    }
    else if (gestureRecognizer.state == UIGestureRecognizerStateEnded)
    {
        self.speakTipView.hidden = TRUE;
        [self.speakButton setTitleColor:[UIColor colorWithRed:150.0f/255.0f green:150.0f/255.0f blue:150.0f/255.0f alpha:1.0f]
                               forState:UIControlStateNormal];

        [self stopRecorder];
        [self stopUpdateMetersTimer];
        
        if (!_isSendCanceled)           // 没有被取消
        {
            [self showRecordActionSheet];
        }
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



// 发送录音文件到床头宝
- (void)sendMessage:(BOOL)ifTimer andUTS:(NSString *)uts
{
    [self showWaiting];

    self.amrFilePath = [self recordAmrFilePath];
    if (![self convertWav:self.wavFilePath toAmr:self.amrFilePath])
    {
        NSLog(@"转换文件格式失败");
        [self hideWaiting];
        return;
    }
    
    NSData *amrData = [[NSData alloc] initWithContentsOfFile:self.amrFilePath];
    MessageSender *sender = [MessageSender defaultInstance];
    [sender sendMessage:self.recordFileName
               fileType:@".amr"
               fileData:amrData
           fileDuration:[NSString stringWithFormat:@"%.0f", fmax(1.0f, _recordTime)]
               toDevice:self.currentDeviceInfo.dev_sn
            aboutFriend:nil
                ifTimer:ifTimer
                 andUTS:uts
    withSucceededNotify:^(SendMessageRequest *request)
    {
        [self saveMessageToHistory:request];
        [self hideWaiting];
    }
       withFailedNotify:^()
    {
        [self hideWaiting];
        [UITools showMessage:@"发送失败"];
    }];
}


// 保存已发送的消息
- (void)saveMessageToHistory:(SendMessageRequest *)request
{
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
    
    EventEntity *eventInfo = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
    eventInfo.event_device = request.deviceSerial;
    eventInfo.event_user_id = USER_ID;
    eventInfo.event_type = [NSNumber numberWithInteger:kEventFromApp];        // 用户发送的消息
    eventInfo.event_timestamp = [NSNumber numberWithInteger:[request.timestamp integerValue]];
    eventInfo.audio_url = request.fileUrl;
    eventInfo.audio_file_id = request.fileId;
    eventInfo.audio_duration = request.fileDuration;
    eventInfo.audio_amr_data = request.data;
    eventInfo.audio_wav_data = [[NSData alloc] initWithContentsOfFile:self.wavFilePath];
    
    // Save the context.
    [[CoreDataManager defaultInstance] saveContext];
}


// 转换WAV文件为AMR文件
- (BOOL)convertWav:(NSString *)wavFilePath toAmr:(NSString *)amrFilePath
{
    // 转格式
    int result = [VoiceConverter wavToAmr:wavFilePath amrSavePath:amrFilePath];
    return (result == 0);
}


// 转换AMR文件为WAV文件
- (BOOL)convertAmr:(NSString *)amrFilePath toWav:(NSString *)wavFilePath
{
    int result = [VoiceConverter amrToWav:amrFilePath wavSavePath:wavFilePath];
    return (result == 0);
}


#pragma mark - 录音相关

- (void)initRecorder
{
    //设置文件名和录音路径
    self.wavFilePath = [self recordWavFilePath];
    self.recordFileName = [self newRecordFileName];
    
    //初始化录音
    self.recorder = [[AVAudioRecorder alloc] initWithURL:[NSURL URLWithString:self.wavFilePath]
                                                settings:[self audioRecorderSetting]
                                                   error:nil];
    self.recorder.delegate = self;
    self.recorder.meteringEnabled = YES;
}


- (void)startRecorder
{
    // 开始录音
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];

    UInt32 doChangeDefault = 1;
    AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryDefaultToSpeaker, sizeof(doChangeDefault), &doChangeDefault);
    
    [self.recorder prepareToRecord];
    [self.recorder record];
    [self startUpdateMetersTimer];
    
    _beginRecordTime = self.recorder.currentTime;
}


// 停止录音
- (void)stopRecorder
{
    [self.recorder stop];
    [self stopUpdateMetersTimer];
}


// 获取录音设置
- (NSDictionary*)audioRecorderSetting
{
    NSDictionary *recordSetting = [[NSDictionary alloc] initWithObjectsAndKeys:
                                   [NSNumber numberWithFloat: 8000.0], AVSampleRateKey,             // 采样率
                                   [NSNumber numberWithInt: kAudioFormatLinearPCM], AVFormatIDKey,
                                   [NSNumber numberWithInt:16], AVLinearPCMBitDepthKey,             // 采样位数 默认 16
                                   [NSNumber numberWithInt: 1], AVNumberOfChannelsKey,              // 通道的数目
                                   // [NSNumber numberWithBool:NO],AVLinearPCMIsBigEndianKey,//大端还是小端 是内存的组织方式
                                   // [NSNumber numberWithBool:NO],AVLinearPCMIsFloatKey,//采样信号是整数还是浮点数
                                   // [NSNumber numberWithInt: AVAudioQualityMedium],AVEncoderAudioQualityKey,//音频编码质量
                                   nil];
    return recordSetting;
}


// 创建新的录音文件名
- (NSString *)newRecordFileName
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
    NSString *string = [dateFormatter stringFromDate:[NSDate date]];
    
    return string;
}


// 生成录音文件存放路径
- (NSString*)fileSavePathForName:(NSString *)fileName andType:(NSString *)fileType
{
    NSString *documentsPath = [Tools applicationDocumentDirectory];
    NSString *recordFilePath = [documentsPath stringByAppendingPathComponent: [NSString stringWithFormat:@"%@/Record", USERNAME]];
    NSFileManager *manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:recordFilePath])
    {
        [manager createDirectoryAtPath:recordFilePath withIntermediateDirectories:TRUE attributes:nil error:NULL];
    }
    recordFilePath = [recordFilePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", fileName, fileType]];

    return recordFilePath;
}


// WAV文件放置路径
- (NSString *)recordWavFilePath
{
    NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:USER_ID];
    NSFileManager *manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:path])
    {
        [manager createDirectoryAtPath:path withIntermediateDirectories:TRUE attributes:nil error:NULL];
    }
    path = [path stringByAppendingPathComponent:@"chat_record.wav"];
    
    return path;
}


// AMR文件放置路径
- (NSString *)recordAmrFilePath
{
    NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:USER_ID];
    NSFileManager *manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:path])
    {
        [manager createDirectoryAtPath:path withIntermediateDirectories:TRUE attributes:nil error:NULL];
    }
    path = [path stringByAppendingPathComponent:@"chat_record.amr"];
    
    return path;
}


// 创建新的录音文件名
- (NSString *)newSaveFileName
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd-HHmmss"];
    NSString *string = [dateFormatter stringFromDate:[NSDate date]];
    
    return string;
}


#pragma mark - 定时器相关

// 更新剩余录音时间定时器
- (void)startUpdateMetersTimer
{
    _updateMetersTimer = [NSTimer scheduledTimerWithTimeInterval:0.1f
                                                          target:self
                                                        selector:@selector(updateMeters:)
                                                        userInfo:nil
                                                         repeats:YES];
}


// 停止定时器
- (void)stopUpdateMetersTimer
{
    if (_updateMetersTimer &&
        _updateMetersTimer.isValid)
    {
        [_updateMetersTimer invalidate];
        _updateMetersTimer = nil;
    }
}


// 更新剩余时间
- (void)updateMeters:(NSTimer *)aTimer
{
    if (self.recorder.isRecording)
    {
        _recordTime = self.recorder.currentTime - _beginRecordTime;
        NSTimeInterval remainTime = MAX_SECONDS_OF_RECORD - _recordTime;
        if (remainTime < 0.0f)
        {
            [self stopRecorder];
            [self stopUpdateMetersTimer];
        }
        
        [self updateRemainTimeTip:remainTime];
    }
}


- (void)updateRemainTimeTip:(NSTimeInterval)remainTime
{
    NSString *message = [[NSString alloc] initWithFormat:@"剩余%.1f秒", fmax(0,remainTime)];
    self.speakTipRemainTimeLabel.text = message;
}



#pragma mark - 录音代理

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag
{
}


- (void)audioRecorderBeginInterruption:(AVAudioRecorder *)recorder
{
    self.speakTipView.hidden = TRUE;
    
    [self stopRecorder];
    [self stopUpdateMetersTimer];
    
    if (!_isSendCanceled)           // 没有被取消
    {
        [self showRecordActionSheet];
    }
}


- (void)audioRecorderEndInterruption:(AVAudioRecorder *)recorder withOptions:(NSUInteger)flags
{
}



#pragma mark - UI事件处理

- (IBAction)handleClearMessages:(id)sender
{
    [self stopPlay];
    [self clearAllMessages];
}


// 清除所有聊天记录
- (void)clearAllMessages
{
    [[CoreDataManager defaultInstance] deleteRecordOfDevice:_currentDeviceInfo.dev_sn andUser:USER_ID];
    
    [self deleteChatMessage:nil forDevice:_currentDeviceInfo.dev_sn];
}


// 显示等待框
- (void)showWaiting
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeCustomView;
}


// 关闭等待框
- (void)hideWaiting
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}


// 显示录音完成后的选择菜单
- (void)showRecordActionSheet
{
    NSString *cannelText = NSLocalizedString(@"Cancel Text", nil);
    NSString *item1 = @"立即发送";
    NSString *item2 = @"定时发送";
    NSString *item3 = @"保存在本地";
    
    self.recordActionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                         delegate:self
                                                cancelButtonTitle:cannelText
                                           destructiveButtonTitle:nil
                                                otherButtonTitles:item1, item2, item3, nil];
    self.recordActionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [self.recordActionSheet showFromTabBar:self.tabBarController.tabBar];
}


// 录音完成后菜单对应的操作
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet == self.recordActionSheet)
    {
        if (buttonIndex == 0)           // 立即发送
        {
            [self sendMessage:FALSE andUTS:@"-1"];
        }
        else if (buttonIndex == 1)      // 定时发送
        {
            [self showDatePick];
            _isShowingDatetimePicker = TRUE;
        }
        else if (buttonIndex == 2)      // 保存到本地
        {
            NSData *data = [[NSData alloc] initWithContentsOfFile:self.wavFilePath];
            if ([self saveAudioToLocal:data])
            {
                [UITools showMessage:@"保存成功"];
            }
            else
            {
                [UITools showMessage:@"保存失败"];
            }
        }
    }
    else if (actionSheet == self.audioMessageActionSheet)
    {
        if (buttonIndex == 0)       // 存储到本地
        {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:actionSheet.tag inSection:0];
            EventEntity *eventInfo = [self.fetchedResultsController objectAtIndexPath:indexPath];
            if (eventInfo.audio_wav_data)        // 已有WAV数据则直接播放
            {
                if ([self saveAudioToLocal:eventInfo.audio_wav_data])
                {
                    [UITools showMessage:@"保存成功"];
                }
                else
                {
                    [UITools showMessage:@"保存失败"];
                }
            }
            else if (eventInfo.audio_amr_data)  // 没有WAV数据, 但有AMR数据, 则转换AMR为WAV后再播放
            {
                BOOL saveSucceeded = FALSE;
                NSString *amrFilePath = [self recordAmrFilePath];
                if ([eventInfo.audio_amr_data writeToFile:amrFilePath atomically:TRUE])
                {
                    NSString *wavFilePath = [self recordWavFilePath];
                    if ([self convertAmr:amrFilePath toWav:wavFilePath])
                    {
                        NSData *wavData = [[NSData alloc] initWithContentsOfFile:wavFilePath];
                        if ([self saveAudioToLocal:wavData])
                        {
                            saveSucceeded = TRUE;
                            eventInfo.audio_wav_data = wavData;
                            [[CoreDataManager defaultInstance] saveContext];
                        }
                    }
                }
                
                if (saveSucceeded)
                {
                    [UITools showMessage:@"保存成功"];
                }
                else
                {
                    [UITools showMessage:@"保存失败"];
                }
            }
            else if (eventInfo.audio_url)   // 既没有WAV数据, 也没有AMR数据, 但有连接, 则下载后再播放
            {
                __weak typeof(self) selfRef = self;
                
                _fileRequest = [[AsyncFileDownloader alloc] init];
                _fileRequest.failedBlock = ^(NSString *url)
                {
                    [UITools showMessage:@"保存失败"];
                };
                _fileRequest.succeededBlock = ^(NSData *fileData, NSString *url)
                {
                    BOOL saveSucceeded = FALSE;

                    NSString *amrFilePath = [selfRef recordAmrFilePath];
                    if ([fileData writeToFile:amrFilePath atomically:TRUE])         // 保存成功
                    {
                        NSString *wavFilePath = [selfRef recordWavFilePath];
                        if ([selfRef convertAmr:amrFilePath toWav:wavFilePath])     // 转换成功
                        {
                            NSData *wavData = [[NSData alloc] initWithContentsOfFile:wavFilePath];
                            if ([selfRef saveAudioToLocal:wavData])
                            {
                                saveSucceeded = TRUE;
                                eventInfo.audio_wav_data = wavData;
                                [[CoreDataManager defaultInstance] saveContext];
                            }
                        }
                    }
                    
                    if (saveSucceeded)
                    {
                        [UITools showMessage:@"保存成功"];
                    }
                    else
                    {
                        [UITools showMessage:@"保存失败"];
                    }
                };
                [_fileRequest downloadFileWithUrl:eventInfo.audio_url];
            }
        }
        else if (buttonIndex == 1)      // 删除
        {
            EventEntity *eventInfo = [self eventInfoAtRow:actionSheet.tag];
            [self deleteMessageOnLocal:eventInfo];
            [self deleteChatMessage:eventInfo.audio_file_id forDevice:_currentDeviceInfo.dev_sn];
        }
    }
    else if (actionSheet == self.systemMessageActionSheet)
    {
        EventEntity *eventInfo = [self eventInfoAtRow:actionSheet.tag];
        [self deleteMessageOnLocal:eventInfo];
    }
}


// 存储语音文件到本地录音目录
- (BOOL)saveAudioToLocal:(NSData *)data
{
    NSString *fileName = [UITools encodeBase64:[self newSaveFileName]];
    NSString *filePath = [self fileSavePathForName:fileName andType:@"wav"];
    BOOL result = [data writeToFile:filePath atomically:TRUE];
    if (result)
    {
        [iSpaceApp defaultInstance].isRecordRingChanged = TRUE;
    }
    
    return result;
}


// 删除指定聊天记录
- (void)deleteMessageOnLocal:(EventEntity *)eventInfo
{
    [[CoreDataManager defaultInstance] deleteObject:eventInfo];
}


// 获取指定行的数据对象
- (EventEntity *)eventInfoAtRow:(NSInteger )row
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
    EventEntity *eventInfo = [self.fetchedResultsController objectAtIndexPath:indexPath];
    return eventInfo;
}


#pragma mark - 表格代理函数

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController sections] count];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EventEntity *eventInfo = [self.fetchedResultsController objectAtIndexPath:indexPath];
    if ([eventInfo.event_type integerValue] == kEventFromSystem)        // 系统消息
    {
        MessageFromSystemListCell *cell = [tableView dequeueReusableCellWithIdentifier:kMessageFromSystemListCellIdentifier
                                                                          forIndexPath:indexPath];
        cell.tag = indexPath.row;
        [self configSystemInfoCell:cell withEventInfo:eventInfo];
        
        return cell;

    }
    else if ([eventInfo.event_type integerValue] == kEventFromApp)      // 用户发出的消息
    {
        MessageFromMeListCell *cell = [tableView dequeueReusableCellWithIdentifier:kMessageFromMeListCellIdentifier
                                                                      forIndexPath:indexPath];
        cell.tag = indexPath.row;
        [self configMyAudioInfoCell:cell withEventInfo:eventInfo];

        return cell;
        
    }
    else if ([eventInfo.event_type integerValue] == kEventFromDevice)   // 床头宝发出的消息
    {
        MessageFromFriendListCell *cell = [tableView dequeueReusableCellWithIdentifier:kMessageFromFriendListCellIdentifier
                                                                          forIndexPath:indexPath];
        cell.tag = indexPath.row;
        [self configDeviceAudioInfoCell:cell withEventInfo:eventInfo];
        
        return cell;
    }
    
    return nil;
}


// 返回表格行高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EventEntity *eventInfo = [self.fetchedResultsController objectAtIndexPath:indexPath];
    if ([eventInfo.event_type integerValue] == kEventFromSystem)
    {
        return 92;
    }
    
    return 82;
}


// 配置系统信息表格行
- (void)configSystemInfoCell:(MessageFromSystemListCell *)cell withEventInfo:(EventEntity *)eventInfo
{
    cell.label.text = [NSString stringWithFormat:@"%@", eventInfo.alarm_description];
    cell.timeLabel.text = [Tools stringOfTimestamp:eventInfo.event_timestamp];
}


// 配置我的语音信息表格行
- (void)configMyAudioInfoCell:(MessageFromMeListCell *)cell withEventInfo:(EventEntity *)eventInfo
{
    cell.delegate = self;
    cell.durationLabel.text = [NSString stringWithFormat:@"%@''", eventInfo.audio_duration];
    cell.dateTimeLabel.text = [Tools stringOfTimestamp:eventInfo.event_timestamp];
    if (self.playingIndex == cell.tag)
    {
        [cell setPlayingState];
    }
    else
    {
        [cell setNormalState];
    }
}


// 配置设备的语音信息表格行
- (void)configDeviceAudioInfoCell:(MessageFromFriendListCell *)cell withEventInfo:(EventEntity *)eventInfo
{
    cell.delegate = self;
    cell.durationLabel.text = [NSString stringWithFormat:@"%@''", eventInfo.audio_duration];
    cell.dateTimeLabel.text = [Tools stringOfTimestamp:eventInfo.event_timestamp];
    if (self.playingIndex == cell.tag)
    {
        [cell setPlayingState];
    }
    else
    {
        [cell setNormalState];
    }
}


#pragma mark - 播放语音相关

- (void)playMessageButtonDidTouch:(NSInteger)tag
{
    if (tag == self.playingIndex)           // 点击正在播放的条目
    {
        [self setCellNormalState:tag];
        [self stopPlay];
    }
    else
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:tag inSection:0];
        EventEntity *eventInfo = [self.fetchedResultsController objectAtIndexPath:indexPath];
        if (eventInfo.audio_wav_data)        // 已有WAV数据则直接播放
        {
            [self setCellNormalState:self.playingIndex];
            [self stopPlay];

            self.playingIndex = tag;
            [self setCellPlayingState:tag];
            [self playMessage:eventInfo.audio_wav_data];
        }
        else if (eventInfo.audio_amr_data)  // 没有WAV数据, 但有AMR数据, 则转换AMR为WAV后再播放
        {
            NSString *amrFilePath = [self recordAmrFilePath];
            if ([eventInfo.audio_amr_data writeToFile:amrFilePath atomically:TRUE])
            {
                NSString *wavFilePath = [self recordWavFilePath];
                if ([self convertAmr:amrFilePath toWav:wavFilePath])
                {
                    NSData *wavData = [[NSData alloc] initWithContentsOfFile:wavFilePath];
                    eventInfo.audio_wav_data = wavData;
                    [[CoreDataManager defaultInstance] saveContext];
                    
                    // 停止先前的播放
                    [self setCellNormalState:self.playingIndex];
                    [self stopPlay];
                    
                    // 播放
                    [self playMessage:eventInfo.audio_wav_data];
                    self.playingIndex = tag;
                    [self setCellPlayingState:tag];
                }
            }
        }
        else if (eventInfo.audio_url)   // 既没有WAV数据, 也没有AMR数据, 但有连接, 则下载后再播放
        {
            __weak typeof(self) weakSelf = self;

            _fileRequest = [[AsyncFileDownloader alloc] init];
            _fileRequest.failedBlock = ^(NSString *url)
            {
                weakSelf.playingIndex = -1;
                [UITools showMessage:@"播放失败"];
            };
            _fileRequest.succeededBlock = ^(NSData *fileData, NSString *url)
            {
                
                NSString *amrFilePath = [weakSelf recordAmrFilePath];
                if ([fileData writeToFile:amrFilePath atomically:TRUE])
                {
                    NSString *wavFilePath = [weakSelf recordWavFilePath];
                    if ([weakSelf convertAmr:amrFilePath toWav:wavFilePath])
                    {
                        NSData *wavData = [[NSData alloc] initWithContentsOfFile:wavFilePath];
                        eventInfo.audio_wav_data = wavData;
                        [[CoreDataManager defaultInstance] saveContext];
                        
                        // 停止先前的播放
                        [weakSelf setCellNormalState:weakSelf.playingIndex];
                        [weakSelf stopPlay];
                        
                        // 播放
                        [weakSelf playMessage:eventInfo.audio_wav_data];
                        weakSelf.playingIndex = tag;
                        [weakSelf setCellPlayingState:tag];
                    }
                }
            };
            [_fileRequest downloadFileWithUrl:eventInfo.audio_url];
        }
    }
}


// 播放声音(WAV格式)
- (void)playMessage:(NSData *)data
{
    self.player = [[AVAudioPlayer alloc] initWithData:data error:nil];
    self.player.delegate = self;
    [self.player play];
}


// 停止播放
- (void)stopPlay
{
    [self.player stop];
    self.player = nil;
    self.playingIndex = -1;
}


#pragma mark - 音步播放代理

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [self setCellNormalState:self.playingIndex];
    [self stopPlay];
}


- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error
{
    [self setCellNormalState:self.playingIndex];
    [self stopPlay];
    
    [UITools showMessage:@"无法播放文件"];
}


// 设置表格行为正常状态
- (void)setCellNormalState:(NSInteger)row
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:row inSection:0];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    if ([cell isKindOfClass:[MessageFromFriendListCell class]])
    {
        MessageFromFriendListCell *messageCell = (MessageFromFriendListCell *)cell;
        [messageCell setNormalState];
    }
    else if ([cell isKindOfClass:[MessageFromMeListCell class]])
    {
        MessageFromMeListCell *messageCell = (MessageFromMeListCell *)cell;
        [messageCell setNormalState];
    }
}


// 设置表格行为播放状态
- (void)setCellPlayingState:(NSInteger)row
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:row inSection:0];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    if ([cell isKindOfClass:[MessageFromFriendListCell class]])
    {
        MessageFromFriendListCell *messageCell = (MessageFromFriendListCell *)cell;
        [messageCell setPlayingState];
    }
    else if ([cell isKindOfClass:[MessageFromMeListCell class]])
    {
        MessageFromMeListCell *messageCell = (MessageFromMeListCell *)cell;
        [messageCell setPlayingState];
    }
}


#pragma mark - 保存语音记录为本地录音

// 长按
- (void)messageListCellDidLongPress:(NSInteger)tag
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:tag inSection:0];
    EventEntity *eventInfo = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    if ([eventInfo.event_type integerValue] == kEventFromSystem)
    {
        NSString *cannelText = NSLocalizedString(@"Cancel Text", nil);
        NSString *item1 = @"删除";
        
        self.systemMessageActionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                    delegate:self
                                                           cancelButtonTitle:cannelText
                                                      destructiveButtonTitle:nil
                                                           otherButtonTitles:item1, nil];
        self.systemMessageActionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
        self.systemMessageActionSheet.tag = tag;
        [self.systemMessageActionSheet showFromTabBar:self.tabBarController.tabBar];

    }
    else
    {
        NSString *cannelText = NSLocalizedString(@"Cancel Text", nil);
        NSString *item1 = @"保存在本地";
        NSString *item2 = @"删除";
        
        self.audioMessageActionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                   delegate:self
                                                          cancelButtonTitle:cannelText
                                                     destructiveButtonTitle:nil
                                                          otherButtonTitles:item1, item2, nil];
        self.audioMessageActionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
        self.audioMessageActionSheet.tag = tag;
        [self.audioMessageActionSheet showFromTabBar:self.tabBarController.tabBar];
    }
}
        

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil)
    {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"EventEntity"
                                              inManagedObjectContext:[CoreDataManager defaultInstance].managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // 设置过滤条件
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"event_device == %@ AND event_user_id == %@",
                              _currentDeviceInfo.dev_sn, USER_ID];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setFetchBatchSize:20];    // Set the batch size to a suitable number.
    
    // 设置排序条件
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"event_timestamp" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *fetchedController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                                        managedObjectContext:[CoreDataManager defaultInstance].managedObjectContext
                                                                                          sectionNameKeyPath:nil
                                                                                                   cacheName:nil];
    fetchedController.delegate = self;
    self.fetchedResultsController = fetchedController;

    NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error])
    {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return _fetchedResultsController;
}


- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type)
    {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    
    switch(type)
    {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
//            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
    
    // 滚动到表格底部
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][0];
    NSInteger count = [sectionInfo numberOfObjects];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(count - 1) inSection:0];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:TRUE];
}



 // Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed.
 
// - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
// {
//     // In the simplest, most efficient, case, reload the table view.
//     [self.tableView reloadData];
// }


- (void)configureCell:(MessageFromFriendListCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    //ChatMessageInfo *messageInfo = [self.fetchedResultsController objectAtIndexPath:indexPath];
    //cell.label.text = [[object valueForKey:@"timeStamp"] description];
}



#pragma mark - 网络请求

// 删除聊天记录(messageId为空时删除所有)
-(void)deleteChatMessage:(NSString *)messageId forDevice:(NSString *)deviceSerial
{
    // 请求体
    NSMutableDictionary *params;
    if ([messageId length] > 0)
    {
        params = [NetDataService needCommand:@"2090"
                               andNeedUserId:USER_ID
                           AndNeedBobyArrKey:@[@"dev_sn", @"type", @"fid"]
                         andNeedBobyArrValue:@[deviceSerial, @"1", messageId]];
    }
    else
    {
        params = [NetDataService needCommand:@"2090"
                               andNeedUserId:USER_ID
                           AndNeedBobyArrKey:@[@"dev_sn", @"type", @"fid"]
                         andNeedBobyArrValue:@[deviceSerial, @"0", @"-1"]];
    }
    
    // 请求网络
    [NetDataService requestWithUrl:SVR_URL
                        dictParams:params
                        httpMethod:@"POST"
                 andisWaitActivity:YES
              andWaitActivityTitle:nil
                        andViewCtl:self
                     isShowWaiting:FALSE
                       failedBlock:NULL
                     completeBlock:^(id result)
     {
         dispatch_async(dispatch_get_main_queue(), ^{
             [self handleDeleteChatMessageResult:result];
         });
     }];
}


// 处理删除聊天信息结果
- (void)handleDeleteChatMessageResult:(id)result
{
//    NSDictionary *msgBody = result[@"message_body"];
//    NSNumber *errorCode = msgBody[@"error"];
//    if ([errorCode integerValue]== 0)         // 如果等于0说明有绑定设备
//    {
//        NSMutableArray *devices = [[NSMutableArray alloc] initWithCapacity:0];
//        
//        NSDictionary *dev_list = msgBody[@"dev_list"];
//        NSArray *listArr = dev_list[@"list"];
//        for (NSDictionary *deviceDict in listArr)
//        {
//            DevicesInfoModel *deviceInfo = [[DevicesInfoModel alloc] initWithDataDic:deviceDict];
//            [devices addObject:deviceInfo];
//        }
//        
//        self.devices = devices;
//        [self.devicesTableView reloadData];
//    }
//    
//    [self switchUICase];
    NSLog(@"%@", result);
}


#pragma mark - 定时发送相关

// 显示选择日期视图
-(void)showDatePick
{
    self.maskView.hidden = FALSE;
    
	if (self.datetimePickerView.superview == nil)
	{
		[self.view.window addSubview: self.datetimePickerView];
	}
	CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
	CGSize pickerSize = [self.datetimePickerView sizeThatFits:CGSizeZero];
	CGRect startRect = CGRectMake(0.0,
								  screenRect.origin.y + screenRect.size.height,
								  pickerSize.width, pickerSize.height);
	self.datetimePickerView.frame = startRect;
	CGRect pickerRect = CGRectMake(0.0,
								   screenRect.origin.y + screenRect.size.height - pickerSize.height,
								   pickerSize.width,
								   pickerSize.height);
    
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.3];
	[UIView setAnimationDelegate:self];
	self.datetimePickerView.frame = pickerRect;
	CGRect newFrame = self.view.frame;
	newFrame.size.height -= self.datetimePickerView.frame.size.height;
	self.view.frame = newFrame;
	[UIView commitAnimations];
}


// 关闭选择日期视图
- (void)dissDatePick
{
    self.maskView.hidden = TRUE;
    
	CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
	CGRect endFrame = self.datetimePickerView.frame;
	endFrame.origin.y = screenRect.origin.y + screenRect.size.height;
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.3];
	[UIView setAnimationDelegate:self];
	self.datetimePickerView.frame = endFrame;
	[UIView commitAnimations];
	CGRect newFrame = self.view.frame;
	newFrame.size.height += self.datetimePickerView.frame.size.height;
	self.view.frame = newFrame;
}


// 选定日期后, 确定按钮处理
- (IBAction)handlePickerDateTime:(id)sender
{
    NSDate *after5MinutesDate = [[NSDate date] dateByAddingTimeInterval:60*5];  // 5分钟后的时间
    NSDate *pickerDate = self.datetimePicker.date;
    if ([pickerDate compare:after5MinutesDate] == NSOrderedAscending)           // 选取的时间在5分钟前
    {
        [UITools showMessage:@"必须选择5分钟之后的时间"];
    }
    else
    {
        [self dissDatePick];
        _isShowingDatetimePicker = FALSE;

        [self sendMessage:TRUE
                   andUTS:[NSString stringWithFormat:@"%.0f", [pickerDate timeIntervalSince1970]]];
    }
}

@end
