//
//  MyRingViewController.m
//  iSpace
//
//  Created by CC on 14-6-9.
//  Copyright (c) 2014年 xiabing. All rights reserved.
//

#import "MyRingViewController.h"
#import "UITools.h"
#import "Tools.h"
#import "Constants.h"
#import "UITableView+Additions.h"
#import "UIViewController+Additions.h"
#import "NSDictionary+Additions.h"
#import "UIView+Additions.h"
#import "iSpaceRing.h"
#import "OnlineRing.h"
#import "FavoriteRing.h"
#import "RecordRing.h"
#import "MusicRing.h"
#import "FMRing.h"
#import "MyUploadRing.h"
#import "AudioStreamer.h"
#import "RingUploader.h"
#import "VoiceConverter.h"
#import "WifiViewController.h"
#import "AsyncFileDownloader.h"
#import "iSpaceApp.h"



#define kSectionCount               5       // 表格分组数量
#define kOnlineRingIndex            0
#define kRecordRingIndex            1
#define kMusicRingIndex             2
#define kFMRingIndex                3
#define kMyUploadRingIndex          4
#define kRowPerPageOfOnlineRing     7      // 在线铃音每页的行数


static NSString * const kOnlineRingCellNibName = @"OnlineRingListCell";
static NSString * const kOnlineRingCellIdentifier = @"OnlineRingListCell";
static NSString * const kFavoriteRingCellNibName = @"FavoriteRingListCell";
static NSString * const kFavoriteRingCellIdentifier = @"FavoriteRingListCell";
static NSString * const kRecordRingCellNibName = @"RecordRingListCell";
static NSString * const kRecordRingCellIdentifier = @"RecordRingListCell";
static NSString * const kMusicRingCellNibName = @"MusicRingListCell";
static NSString * const kMusicRingCellIdentifier = @"MusicRingListCell";
static NSString * const kFMRingCellNibName = @"FMRingListCell";
static NSString * const kFMRingCellIdentifier = @"FMRingListCell";
static NSString * const kRecordCellNibName = @"RecordListCell";
static NSString * const kRecordCellIdentifier = @"RecordListCell";
static NSString * const kImportMusicCellNibName = @"ImportMusicListCell";
static NSString * const kImportMusicCellIdentifier = @"ImportMusicListCell";
static NSString * const kLoadMoreCellNibName = @"LoadMoreListCell";
static NSString * const kLoadMoreCellIdentifier = @"LoadMoreListCell";
static NSString * const kRefreshFMCellNibName = @"RefreshFMListCell";
static NSString * const kRefreshFMCellIdentifier = @"RefreshFMListCell";
static NSString * const kMyUploadCellNibName = @"MyUploadListCell";
static NSString * const kMyUploadCellIdentifier = @"MyUploadListCell";


@interface MyRingViewController ()

@property (nonatomic, strong) NSMutableArray *myFavoriteAndRecordRingArr;
@property (strong, nonatomic) AVAudioRecorder *recorder;
@property (strong, nonatomic) AVAudioPlayer *player;
@property (strong, nonatomic) AudioStreamer *streamPlayer;
@property (strong, nonatomic) NSString *recorderFilePath;
@property (strong, nonatomic) iSpaceRing *playingRing;
@property (assign, nonatomic) BOOL isPlaying;
@property (strong, nonatomic) OnlineRing *favoritingRing;
@property (strong, nonatomic) iSpaceRing *editingRing;
@property (strong, nonatomic) RingUploader *ringUploader;
@property (strong, nonatomic) WifiViewController *importMusicController;
@property (strong, nonatomic) NSArray *allAlarmInfoArray;           // 包含的元素是字典
@property (strong, nonatomic) AsyncFileDownloader *asyncFileDownloader;
@property (strong, nonatomic) NSIndexPath *lastPlayRingIndexPath;

@property (strong, nonatomic) UIActionSheet *uploadActionSheet;       // 包含有"上传"的操作表
@property (strong, nonatomic) UIActionSheet *renameActionSheet;       // 不包含有"上传"的操作表

//@property (assign, nonatomic) BOOL isReloadMusicSectionWhenAppear;


@end



@implementation MyRingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.titleLabel.text = @"铃声";
        [self.titleLabel sizeToFit];
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // 初始化数据
    _sectionTitles[0] = @"推荐铃声";
    _sectionTitles[1] = @"我的语音";
    _sectionTitles[2] = @"本地音乐";
    _sectionTitles[3] = @"FM电台";
    _sectionTitles[4] = @"我的上传";
    
    [self initData];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    
    // 初始化界面
    [self.recordView setRounderWithRadius:16.0f];
    //[self.recordView setShadowWithColor:[UIColor blackColor]];
    
    // 初始化UITableView相关
    UINib *nib1 = [UINib nibWithNibName:kOnlineRingCellNibName bundle:nil];
    UINib *nib2 = [UINib nibWithNibName:kFavoriteRingCellNibName bundle:nil];
    UINib *nib3 = [UINib nibWithNibName:kRecordRingCellNibName bundle:nil];
    UINib *nib4 = [UINib nibWithNibName:kMusicRingCellNibName bundle:nil];
    UINib *nib5 = [UINib nibWithNibName:kFMRingCellNibName bundle:nil];
    UINib *nib6 = [UINib nibWithNibName:kRecordCellNibName bundle:nil];
    UINib *nib7 = [UINib nibWithNibName:kImportMusicCellNibName bundle:nil];
    UINib *nib8 = [UINib nibWithNibName:kLoadMoreCellNibName bundle:nil];
    UINib *nib9 = [UINib nibWithNibName:kRefreshFMCellNibName bundle:nil];
    UINib *nib10 = [UINib nibWithNibName:kMyUploadCellNibName bundle:nil];
    
    [self.tableView registerNib:nib1 forCellReuseIdentifier:kOnlineRingCellIdentifier];
    [self.tableView registerNib:nib2 forCellReuseIdentifier:kFavoriteRingCellIdentifier];
    [self.tableView registerNib:nib3 forCellReuseIdentifier:kRecordRingCellIdentifier];
    [self.tableView registerNib:nib4 forCellReuseIdentifier:kMusicRingCellIdentifier];
    [self.tableView registerNib:nib5 forCellReuseIdentifier:kFMRingCellIdentifier];
    [self.tableView registerNib:nib6 forCellReuseIdentifier:kRecordCellIdentifier];
    [self.tableView registerNib:nib7 forCellReuseIdentifier:kImportMusicCellIdentifier];
    [self.tableView registerNib:nib8 forCellReuseIdentifier:kLoadMoreCellIdentifier];
    [self.tableView registerNib:nib9 forCellReuseIdentifier:kRefreshFMCellIdentifier];
    [self.tableView registerNib:nib10 forCellReuseIdentifier:kMyUploadCellIdentifier];

    [self.tableView closeSeparatorLineIndent];              // 关闭iOS7下的表格自动缩进
    [self.tableView hideExtraSeparatorLine];                // 隐藏无内容的表格分隔线条
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    
    // 设置APP音频会话类型
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    
    // 增加录音音量
    UInt32 doChangeDefault = 1;
    AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryDefaultToSpeaker, sizeof(doChangeDefault), &doChangeDefault);
    
    // 监听AudioStreamer状态改变
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleAudioStreamerState:)
                                                 name:ASStatusChangedNotification
                                               object:nil];
    
//    // 监听导入本地音乐完成事件
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(handleImportMusicDone:)
//                                                 name:UPLOADEND
//                                               object:nil];
    
    // 获取设备信息(使用设备的闹铃信息)
    [self fetchDeviceInfo];
    [self showWaiting];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - 辅助函数

- (void)initData
{
    if (!_onlineRingArr)             // 在线铃音
    {
        _onlineRingArr = [[NSMutableArray alloc] init];
    }
    if (!_myFavoriteRingArr)         // 我收藏的铃音
    {
        _myFavoriteRingArr = [[NSMutableArray alloc] init];
    }
    if (!_myRecordRingArr)           // 我录制的铃音
    {
        _myRecordRingArr = [[NSMutableArray alloc] init];
    }
    if (!_musicRingArr)              // 本地音乐
    {
        _musicRingArr = [[NSMutableArray alloc] init];
    }
    if (!_fmRingArr)                 // FM
    {
        _fmRingArr = [[NSMutableArray alloc] init];
    }
    if (!_myUploadRingArr)           // 我上传的铃音
    {
        _myUploadRingArr = [[NSMutableArray alloc] init];
    }
    
    if (!_currentDeviceSerial)
    {
        _currentDeviceSerial = DEV_SN;
    }
    
    // 创建存放音乐目录
    NSString *documentPath = [Tools applicationDocumentDirectory];
    NSString *musicPath = [NSString stringWithFormat:@"%@/%@/%@", documentPath, USERNAME, @"WIFIMusic"];
    [[NSFileManager defaultManager] createDirectoryAtPath:musicPath withIntermediateDirectories:TRUE attributes:nil error:nil];
}


- (IBAction)textFieldDidEndOnExit:(id)sender
{
    [sender resignFirstResponder];
}


#pragma mark - UIViewController 生命周期

- (void)viewWillAppear:(BOOL)animated
{
    if (DEV_SN &&
        ![_currentDeviceSerial isEqualToString:DEV_SN])
    {
        if (_isSectionDataLoaded[kFMRingIndex])        // FM信息已经加载过
        {
            if (_isSectionExpanded[kFMRingIndex])      // 如果FM信息块正打开着, 则立即请求数据
            {
                _currentDeviceSerial = DEV_SN;
                _fmRingArr = [[NSMutableArray alloc] init];
                [self fetchDeviceFM:_currentDeviceSerial];
            }
            else            // 如果FM块没有展开, 则等到展开时才请求信息
            {
                _isSectionDataLoaded[kFMRingIndex] = FALSE;
                _fmRingArr = [[NSMutableArray alloc] init];
            }
        }
    }
    
    if (_isSectionExpanded[kMusicRingIndex])
    {
//        self.isReloadMusicSectionWhenAppear = FALSE;
        
        [self loadLocalMusicRing];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:kMusicRingIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    
    if ([iSpaceApp defaultInstance].isRecordRingChanged)
    {
        [iSpaceApp defaultInstance].isRecordRingChanged = FALSE;
        if (_isSectionExpanded[kRecordRingIndex])
        {
            [self loadLocalRecordRing];
        }
    }
}


// 视图即将隐藏
- (void)viewWillDisappear:(BOOL)animated
{
    [self pauseRingAtIndexPath:self.lastPlayRingIndexPath];
    //    if (self.isMovingFromParentViewController || self.isBeingDismissed)
    //    {
    //        if (_isShowingDatetimePicker)
    //        {
    //            [self dissDatePick];
    //        }
    //    }
}


#pragma mark - <UITableViewDataSource> Functions

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return kSectionCount;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self isSectionExpanded:section])
    {
        if (section == kOnlineRingIndex)       // 在线铃音
        {
            NSInteger count = [_onlineRingArr count];
            if (count > 0 && [self hasMoreOnlineRing])
            {
                count += 1;          // +1是Load More按钮
            }
            return count;
        }
        else if (section == kRecordRingIndex)  // 我的语音
        {
            return [_myFavoriteRingArr count] + [_myRecordRingArr count] + 1;   // 加1是录音按钮
        }
        else if (section == kMusicRingIndex)  // 本地音乐
        {
            return [_musicRingArr count] + 1;       // +1是从本地加载文件按钮
        }
        else if (section == kFMRingIndex)  // FM信息
        {
            return [_fmRingArr count] + 1;          // 第一行是刷新按钮
        }
        else if (section == kMyUploadRingIndex)     // 我的上传
        {
            return [_myUploadRingArr count];
        }
    }
    
    return 0;
}


- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    if (section == kOnlineRingIndex)       // 在线铃音
    {
        NSInteger count = [_onlineRingArr count];
        if ([self hasMoreOnlineRing] &&
            row == count)           // 最后一行:Load More...
        {
            LoadMoreListCell *cell = [tableView dequeueReusableCellWithIdentifier:kLoadMoreCellIdentifier forIndexPath:indexPath];
            cell.indexPath = indexPath;
            cell.delegate = self;
            return cell;
        }
        else
        {
            OnlineRingListCell *cell = [tableView dequeueReusableCellWithIdentifier:kOnlineRingCellIdentifier forIndexPath:indexPath];
            cell.indexPath = indexPath;
            cell.delegate = self;

            OnlineRing *ring = [_onlineRingArr objectAtIndex:row];
            [self configOnlineRingListCell:cell withRing:ring];
            
            return cell;
        }
    }
    else if (section == kRecordRingIndex)  // 我的语音
    {
        if (row == 0)       // 录音
        {
            RecordListCell *cell = [tableView dequeueReusableCellWithIdentifier:kRecordCellIdentifier forIndexPath:indexPath];
            cell.indexPath = indexPath;
            cell.delegate = self;
            return cell;
        }
        else
        {
            id ring = [self.myFavoriteAndRecordRingArr objectAtIndex:row - 1];    // 第一行是"录音"按钮
            if ([ring isKindOfClass:[FavoriteRing class]])
            {
                FavoriteRingListCell *cell = [tableView dequeueReusableCellWithIdentifier:kFavoriteRingCellIdentifier forIndexPath:indexPath];
                cell.indexPath = indexPath;
                cell.delegate = self;
                
                FavoriteRing *ring = [_myFavoriteRingArr objectAtIndex:row - 1];
                [self configFavoriteRingListCell:cell withRing:ring];

                return cell;
            }
            else if ([ring isKindOfClass:[RecordRing class]])
            {
                RecordRingListCell *cell = [tableView dequeueReusableCellWithIdentifier:kRecordRingCellIdentifier forIndexPath:indexPath];
                cell.indexPath = indexPath;
                cell.delegate = self;
                
                RecordRing *ring = [_myRecordRingArr objectAtIndex:row - [_myFavoriteRingArr count] - 1];
                [self configRecordRingListCell:cell withRing:ring];
                
                return cell;
            }
        }
    }
    else if (section == kMusicRingIndex)  // 本地音乐
    {
        if (row == 0)       // 从本地导入文件
        {
            ImportMusicListCell *cell = [tableView dequeueReusableCellWithIdentifier:kImportMusicCellIdentifier forIndexPath:indexPath];
            cell.indexPath = indexPath;
            cell.delegate = self;
            return cell;
        }
        else
        {
            MusicRingListCell *cell = [tableView dequeueReusableCellWithIdentifier:kMusicRingCellIdentifier forIndexPath:indexPath];
            cell.indexPath = indexPath;
            cell.delegate = self;
            
            MusicRing *ring = [_musicRingArr objectAtIndex:row - 1];
            [self configMusicRingListCell:cell withRing:ring];
            
            return cell;
        }
    }
    else if (section == kFMRingIndex)           // FM信息
    {
        if (row == 0)
        {
            RefreshFMListCell *cell = [tableView dequeueReusableCellWithIdentifier:kRefreshFMCellIdentifier forIndexPath:indexPath];
            cell.indexPath = indexPath;
            cell.delegate = self;
            return cell;
        }
        else
        {
            FMRingListCell *cell = [tableView dequeueReusableCellWithIdentifier:kFMRingCellIdentifier forIndexPath:indexPath];
            FMRing *ring = [_fmRingArr objectAtIndex:row - 1];
            [self configFMRingListCell:cell withRing:ring];
            return cell;
        }
    }
    else if (section == kMyUploadRingIndex)     // 我的上传
    {
        MyUploadListCell *cell = [tableView dequeueReusableCellWithIdentifier:kMyUploadCellIdentifier forIndexPath:indexPath];
        cell.indexPath = indexPath;
        cell.delegate = self;
        
        MyUploadRing *ring = [_myUploadRingArr objectAtIndex:row];
        [self configMyUploadListCell:cell withRing:ring];
        
        return cell;
    }
    
    return nil;
}


#pragma mark - <UITableViewDelegate> Functions

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    if (section == kOnlineRingIndex)
    {
        if (row == [_onlineRingArr count])
        {
            [self showWaiting];
            [self requestNextPageOnlieRing];
        }
    }
}


- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"";
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 43;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    if (section == kOnlineRingIndex)
    {
//        if (row == [_onlineRingArr count])      // "加载更多"
//        {
//            return 62;
//        }
//        else
//        {
            return 62;
//        }
    }
    else if (section == kRecordRingIndex)
    {
        if (row == 0)           // "录音"按钮
        {
            return 92;
        }
        else
        {
            return 62;
        }
    }
    else if (section == kMusicRingIndex)
    {
        if (row == 0)       // 导入按钮
        {
            return 82;
        }
        else
        {
            return 62;
        }
    }
    else if (section == kFMRingIndex)
    {
        return 62;
    }
    else if (section == kMyUploadRingIndex)
    {
        return 62;
    }
    
    return 0;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    
    // UIButton
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.alpha = 0.8;
    button.frame = headView.frame;
    button.tag = section;
    [button addTarget:self action:@selector(expandedSectionButtonDidTouched:) forControlEvents:UIControlEventTouchUpInside];
    [headView addSubview:button];
    if ([self isSectionExpanded:section])
    {
        button.backgroundColor = [UIColor colorWithRed:101.0f/255.0f green:203.0f/255.0f blue:222.0f/255.0f alpha:1.0f];
    }
    else
    {
        button.backgroundColor = [UIColor colorWithRed:231.0f/255.0f green:247.0f/255.0f blue:250.0f/255.0f alpha:1.0f];
    }
    
    // 展开、收起图标
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(290, 10, 25, 25)];
    [imageView setContentMode:UIViewContentModeCenter];
    [headView addSubview:imageView];
    if ([self isSectionExpanded:section])
    {
        imageView.image = [UIImage imageNamed:@"arrow_up"];
    }
    else
    {
        imageView.image = [UIImage imageNamed:@"arrow_down"];
    }
    
    // 标签
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 100, 44)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font = [UIFont systemFontOfSize:16.0f];
    titleLabel.text = _sectionTitles[section];
    [headView addSubview:titleLabel];
    if ([self isSectionExpanded:section])
    {
        titleLabel.textColor = [UIColor whiteColor];
    }
    else
    {
        titleLabel.textColor = [UIColor colorWithRed:101.0f/255.0f green:203.0f/255.0f blue:222.0f/255.0f alpha:1.0f];
    }
    
    // 分隔行
    UIImageView *bottomLine = [[UIImageView alloc]initWithFrame:CGRectMake(0, 43, ScreenWidth, 1)];
    bottomLine.backgroundColor = [UIColor colorWithRed:210.0f/255.0f green:222.0f/255.0f blue:221.0f/255.0f alpha:1.0f];
    [headView addSubview:bottomLine];
    
    UIImageView *topLine = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 1)];
    topLine.backgroundColor = [UIColor colorWithRed:210.0f/255.0f green:222.0f/255.0f blue:221.0f/255.0f alpha:1.0f];
    [headView addSubview:topLine];
    
    return headView;
}


#pragma mark - 填充表格行

// 配置OnlineRingListCell
- (void)configOnlineRingListCell:(OnlineRingListCell *)cell withRing:(OnlineRing *)ring
{
    cell.nameLabel.text = [UITools decodeBase64:ring.name];
    if (self.isPlaying &&
        self.playingRing == ring)
    {
        [cell setRingCellStyle:RingListCellStylePlaying];
    }
    else
    {
        [cell setRingCellStyle:RingListCellStyleNormal];
    }
}


// 配置FavoriteRingListCell
- (void)configFavoriteRingListCell:(FavoriteRingListCell *)cell withRing:(FavoriteRing *)ring
{
    cell.nameLabel.text = [UITools decodeBase64:ring.name];
    cell.useByAlarmLabel.hidden = [self isRingUsedByAlarm:ring] ? FALSE : TRUE;
    if (self.isPlaying &&
        self.playingRing == ring)
    {
        [cell setRingCellStyle:RingListCellStylePlaying];
    }
    else
    {
        [cell setRingCellStyle:RingListCellStyleNormal];
    }
}


// 配置RecordRingListCell
- (void)configRecordRingListCell:(RecordRingListCell *)cell withRing:(RecordRing *)ring
{
    cell.nameLabel.text = [UITools decodeBase64:ring.name];
    cell.buttonContainerView.hidden = TRUE;
    cell.useByAlarmLabel.hidden = [self isRingUsedByAlarm:ring] ? FALSE : TRUE;
    cell.buttonContainerView.hidden = TRUE;
    if (self.isPlaying &&
        self.playingRing == ring)
    {
        [cell setRingCellStyle:RingListCellStylePlaying];
    }
    else
    {
        [cell setRingCellStyle:RingListCellStyleNormal];
    }
}


// 配置MusicRingListCell
- (void)configMusicRingListCell:(MusicRingListCell *)cell withRing:(MusicRing *)ring
{
    cell.nameLabel.text = ring.name;
    cell.buttonContainerView.hidden = TRUE;
    cell.useByAlarmLabel.hidden = [self isRingUsedByAlarm:ring] ? FALSE : TRUE;
    cell.buttonContainerView.hidden = TRUE;
    if (self.isPlaying &&
        self.playingRing == ring)
    {
        [cell setRingCellStyle:RingListCellStylePlaying];
    }
    else
    {
        [cell setRingCellStyle:RingListCellStyleNormal];
    }
}


// 配置FM表格
- (void)configFMRingListCell:(FMRingListCell *)cell withRing:(FMRing *)ring
{
    cell.nameLabel.text = ring.name;
    cell.useByAlarmLabel.hidden = [self isRingUsedByAlarm:ring] ? FALSE : TRUE;
}


// 配置 我的上传 表格
- (void)configMyUploadListCell:(MyUploadListCell *)cell withRing:(MyUploadRing *)ring
{
    cell.nameLabel.text = [UITools decodeBase64:ring.name];
    cell.useByAlarmLabel.hidden = [self isRingUsedByAlarm:ring] ? FALSE : TRUE;
    cell.buttonContainerView.hidden = TRUE;
    if (self.isPlaying &&
        self.playingRing == ring)
    {
        [cell setRingCellStyle:RingListCellStylePlaying];
    }
    else
    {
        [cell setRingCellStyle:RingListCellStyleNormal];
    }
}


// 检测铃声是否被某个闹钟使用
- (BOOL)isRingUsedByAlarm:(iSpaceRing *)ring
{
    for (NSDictionary *alarmInfo in self.allAlarmInfoArray)
    {
        NSInteger state = [alarmInfo getInteger:@"state"];
        if (state == 1)     // 闹铃打开
        {
            NSInteger volType = [alarmInfo getInteger:@"vol_type"];
            if (volType == 0)       // 语音
            {
                if ([ring isKindOfClass:[OnlineRing class]])
                {
                    NSInteger fileId = [alarmInfo getInteger:@"file_id"];
                    if (fileId == ring.ringId)
                    {
                        return TRUE;
                    }
                }
                else if ([ring isKindOfClass:[RecordRing class]])
                {
                    NSString *fileName = [alarmInfo getString:@"name"];
                    if ([fileName isEqualToString:ring.name])
                    {
                        return TRUE;
                    }
                }
            }
            else if (volType == 1)  // 音乐
            {
                NSString *fileName = [alarmInfo getString:@"name"];
                if ([fileName isEqualToString:ring.name])
                {
                    return TRUE;
                }
            }
            else if (volType == 2)  // FM
            {
                NSString *fmChannel = [alarmInfo getString:@"fm_chnl"];
                if ([fmChannel isEqualToString:ring.name])
                {
                    return TRUE;
                }
            }
        }
    }
    
    return FALSE;
}




#pragma mark - 音乐播放、暂停、下载事件

// 设某一行为正常状态
- (void)setNormalAtIndexPath:(NSIndexPath *)indexPath
{
    id cell = [self.tableView cellForRowAtIndexPath:indexPath];
    if ([cell respondsToSelector:@selector(setRingCellStyle:)])
    {
        [cell setRingCellStyle:RingListCellStyleNormal];
    }
}


// 设某一行为播放状态
- (void)setPlayingAtIndexPath:(NSIndexPath *)indexPath
{
    id cell = [self.tableView cellForRowAtIndexPath:indexPath];
    if ([cell respondsToSelector:@selector(setRingCellStyle:)])
    {
        [cell setRingCellStyle:RingListCellStylePlaying];
    }
}


// 播放事件
- (void)playRingAtIndexPath:(NSIndexPath *)indexPath
{
    [self setNormalAtIndexPath:self.lastPlayRingIndexPath];
    [self setPlayingAtIndexPath:indexPath];

    // 如果这次一播放的是上次播放的,直接恢复播放
    if ([indexPath compare:self.lastPlayRingIndexPath] == NSOrderedSame)
    {
        [self resumeRing];
    }
    else        // 不是上一次暂停的条目
    {
        [self stopRing];            // 停止先前的播放
        self.lastPlayRingIndexPath = indexPath;
        
        NSInteger section = indexPath.section;
        NSInteger row = indexPath.row;
        if (section == kOnlineRingIndex)
        {
            iSpaceRing *ring = [_onlineRingArr objectAtIndex:row];
            [self playRing:ring];
        }
        else if (section == kRecordRingIndex)
        {
            iSpaceRing *ring = [_myFavoriteAndRecordRingArr objectAtIndex:row - 1]; // 第一行是"录音"按钮, 所以我的收藏部分的索引号是从1开始.
            [self playRing:ring];
        }
        else if (section == kMusicRingIndex)
        {
            MusicRing *ring = [_musicRingArr objectAtIndex:row - 1];        // 第一行是"导入"按钮, 所以我的收藏部分的索引号是从1开始.
            [self playRing:ring];
        }
        else if (section == kMyUploadRingIndex)
        {
            iSpaceRing *ring = [_myUploadRingArr objectAtIndex:row];
            [self playRing:ring];
        }
    }
}


// 暂停事件
- (void)pauseRingAtIndexPath:(NSIndexPath *)indexPath
{
    [self setNormalAtIndexPath:indexPath];
    [self pauseRing];
}


// 下载事件
- (void)downloadRingAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    if (section == kOnlineRingIndex)
    {
        OnlineRing *onlineRing = [_onlineRingArr objectAtIndex:row];
        BOOL isFavorited = FALSE;
        for (FavoriteRing *ring in _myFavoriteRingArr)
        {
            if (ring.ringId == ring.ringId)
            {
                isFavorited = TRUE;
            }
        }
        if (isFavorited)
        {
            [UITools showMessage:@"已经收藏"];
        }
        else
        {
            self.favoritingRing = onlineRing;
            [self favoriteOnlineRing:[NSString stringWithFormat:@"%zd", self.favoritingRing.ringId]];
        }
    }
}


#pragma mark - 加载更多

- (void)loadMoreItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    if (section == kOnlineRingIndex)
    {
        if (row == [_onlineRingArr count])
        {
            [self showWaiting];
            [self requestNextPageOnlieRing];
        }
    }
}


#pragma mark - 刷新FM事件

- (void)refreshFMAtIndexPath:(NSIndexPath *)indexPath
{
    if (_currentDeviceSerial)
    {
        [self showWaiting];
        [self fetchDeviceFM:_currentDeviceSerial];
    }
}


#pragma mark - 加载本地音乐

- (void)importLocalMusicAtIndexPath:(NSIndexPath *)indexPath
{
    WifiViewController *importMusicController = [[WifiViewController alloc] init];
    [self.navigationController pushViewController:importMusicController animated:YES];
}


//// 导入音乐完成通知
//- (void)handleImportMusicDone:(NSNotification *)notification
//{
//    self.isReloadMusicSectionWhenAppear = TRUE;
//}


// 加载本地歌曲
- (void)loadLocalMusicRing
{
    NSString *documentPath = [Tools applicationDocumentDirectory];
    NSString *musicPath = [NSString stringWithFormat:@"%@/%@/%@", documentPath, USERNAME, @"WIFIMusic"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    NSArray *fileArr = [fileManager contentsOfDirectoryAtPath:musicPath error:&error];
    if (error)
    {
        [UITools showMessage:@"加载本地音乐失败"];
    }
    else
    {
        [_musicRingArr removeAllObjects];       // 清除原来的内容
        
        for (NSString *fileName in fileArr)
        {
            MusicRing *ring = [[MusicRing alloc] init];
            ring.name = [fileName stringByDeletingPathExtension];
            ring.fileExtension = [fileName pathExtension];
            ring.filePath = [musicPath stringByAppendingPathComponent:fileName];
            
            [_musicRingArr addObject:ring];
        }
    }
}


#pragma mark - 开始录音 事件

- (void)startRecordAtIndexPath:(NSIndexPath *)indexPath
{
    // 停止播放
    [self setNormalAtIndexPath:self.lastPlayRingIndexPath];
    [self stopRing];
    self.lastPlayRingIndexPath = nil;

    [self showRecordTipView];
    [self startRecorder];
    [self startUpdateMetersTimer];
}


// 显示录音提示视图
- (void)showRecordTipView
{
    [self.recordView setFrame:self.view.frame];
    [self.recordView setAlpha:0.0f];
    [self.view addSubview:self.recordView];
    
    [UIView beginAnimations:@"RecordViewAnimation_Show" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    [UIView setAnimationDuration:0.2f];
    [self.recordView setAlpha:1.0f];
    [UIView commitAnimations];
}


// 隐藏录音提示视图
- (void)hideRecordTipView
{
    [UIView beginAnimations:@"RecordViewAnimation_Hide" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.2f];
    [self.recordView setAlpha:0.0f];
    [UIView commitAnimations];
}


// UIView动画完成通知
- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    if ([animationID isEqualToString:@"RecordViewAnimation_Hide"])
    {
        [self.recordView removeFromSuperview];
    }
    else if ([animationID isEqualToString:@"SaveViewAnimation_Hide"])
    {
        [self.saveView removeFromSuperview];
    }
    else if ([animationID isEqualToString:@"RenameViewAnimation_Hide"])
    {
        [self.renameView removeFromSuperview];
    }
}


// 停止录音事件
- (IBAction)stopRecrod:(id)sender
{
    [self hideRecordTipView];
    [self stopRecorder];
    [self stopUpdateMetersTimer];
    [self showSaveView];
}



#pragma mark - 表格行删除、更多 事件

// 删除按钮
- (void)deleteItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    if (section == kRecordRingIndex)
    {
        RecordRing *ring = [_myRecordRingArr objectAtIndex:row - [_myFavoriteRingArr count] - 1];
        [self deleteFileAtPath:ring.filePath];
        
        [_myRecordRingArr removeObject:ring];
        [self combineMyFavoriteAndRecordRing];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    else if (section == kMusicRingIndex)
    {
        MusicRing *ring = [_musicRingArr objectAtIndex:row - 1];
        [self deleteFileAtPath:ring.filePath];
        
        [_musicRingArr removeObject:ring];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    else if (section == kMyUploadRingIndex)
    {
        self.editingRing = [_myUploadRingArr objectAtIndex:row];
        [self showWaiting];
        [self deleteRing:self.editingRing];
    }

}


// 更多按钮
- (void)moreActionAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    if (section == kRecordRingIndex)
    {
        self.editingRing = [_myFavoriteAndRecordRingArr objectAtIndex:row - 1];
        [self showUploadActionSheet];
    }
    else if (section == kMusicRingIndex)
    {
        self.editingRing = [_musicRingArr objectAtIndex:row - 1];
        [self showUploadActionSheet];
    }
    else if (section == kMyUploadRingIndex)
    {
        self.editingRing = [_myUploadRingArr objectAtIndex:row];
        [self showRenameActionSheet];
    }
}


// 删除文件
- (void)deleteFileAtPath:(NSString *)filePath
{
    [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
}



// 显示"我的录音" "本地音乐" 行操作列表
- (void)showUploadActionSheet
{
    NSString *cannelText = NSLocalizedString(@"Cancel Text", nil);
    NSString *item1 = @"上传";
    NSString *item2 = @"重命名";
    
    self.uploadActionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                         delegate:self
                                                cancelButtonTitle:cannelText
                                           destructiveButtonTitle:nil
                                                otherButtonTitles:item1, item2, nil];
    self.uploadActionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [self.uploadActionSheet showFromTabBar:self.tabBarController.tabBar];
}


// 显示"我的上传"行操作列表
- (void)showRenameActionSheet
{
    NSString *cannelText = NSLocalizedString(@"Cancel Text", nil);
    NSString *item1 = @"重命名";
    
    self.renameActionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                         delegate:self
                                                cancelButtonTitle:cannelText
                                           destructiveButtonTitle:nil
                                                otherButtonTitles:item1, nil];
    self.renameActionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [self.renameActionSheet showFromTabBar:self.tabBarController.tabBar];
}


// UIActionSheet代理
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet == self.uploadActionSheet)
    {
        if (buttonIndex == 0)           // 上传
        {
            [self uploadRing:self.editingRing];
        }
        else if (buttonIndex == 1)      // 重命名
        {
            [self showRenameView];
        }
    }
    else if (actionSheet == self.renameActionSheet)
    {
        if (buttonIndex == 0)           // 重命名
        {
            [self showRenameView];
        }
    }
}


#pragma mark - 上传语音文件

// 上传语音文件
- (void)uploadRing:(iSpaceRing *)ring
{
    NSString *fileName = @"";
    NSString *fileType = @"";
    NSString *uploadFilePath = [self tempPathOfUploadFile];
    if ([ring isKindOfClass:[RecordRing class]])
    {
        [self showWaiting];
        
        RecordRing *recordRing = (RecordRing *) ring;
        if (![self convertWav:recordRing.filePath toAmr:uploadFilePath])
        {
            [self hideWaiting];
            [UITools showMessage:@"转换文件格式失败"];
            return;
        }
        fileType = @".amr";
        fileName = recordRing.name;
    }
    else if ([ring isKindOfClass:[MusicRing class]])
    {
        MusicRing *musicRing = (MusicRing *) ring;
        NSString *fileExtension = [musicRing.filePath pathExtension];
        if (!([fileExtension isEqualToString:@"amr"] ||
              [fileExtension isEqualToString:@"mp3"] ||
              [fileExtension isEqualToString:@"wav"]))
        {
            [UITools showMessage:@"不支持的文件格式"];
            return;
        }
        fileType = [NSString stringWithFormat:@".%@", fileExtension];
        uploadFilePath = musicRing.filePath;
        fileName = [UITools encodeBase64:musicRing.name];
    }
    
    // 创建上传器
    if (!self.ringUploader)
    {
        self.ringUploader = [[RingUploader alloc] init];
        self.ringUploader.delegate = self;
    }
    
    [self showWaiting];
    NSData *armFileData = [[NSData alloc] initWithContentsOfFile:uploadFilePath];
    [self.ringUploader uploadFile:fileName fileType:fileType fileData:armFileData];
}


// 上传成功通知
- (void)uploadFileSucceeded:(RingUploader *)uploader
{
    MyUploadRing *ring = [[MyUploadRing alloc] init];
    ring.ringId = [uploader.fileId integerValue];
    ring.type = uploader.fileType;
    ring.ringUrl = uploader.fileUrl;
    ring.name = uploader.fileName;
    
    [_myUploadRingArr addObject:ring];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:kMyUploadRingIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    [self hideWaiting];
    [UITools showMessage:[NSString stringWithFormat:@"%@ 上传成功", [UITools decodeBase64:uploader.fileName]]];
}


// 上传文件失败通知
- (void)uploadFileFailed:(RingUploader *)uploader
{
    [self hideWaiting];
    [UITools showMessage:[NSString stringWithFormat:@"%@ 上传失败", [UITools decodeBase64:uploader.fileName]]];
}


// 上传文件临时存放路径
- (NSString *)tempPathOfUploadFile
{
    NSString *tempPath = [NSString stringWithFormat:@"%@/%@/%@", NSTemporaryDirectory(), USERNAME, @"Record"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:tempPath])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:tempPath withIntermediateDirectories:TRUE attributes:nil error:NULL];
    }
    tempPath = [tempPath stringByAppendingPathComponent:@"upload_file.amr"];
    
    return tempPath;
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


#pragma mark - 重命名录音文件


// 显示重命名框
- (void)showRenameView
{
    if ([self.editingRing isKindOfClass:[MusicRing class]])
    {
        _renameFileNameTextField.text = self.editingRing.name;
    }
    else
    {
        _renameFileNameTextField.text = [UITools decodeBase64:self.editingRing.name];
    }
    
    [self.renameView setFrame:self.view.frame];
    [self.renameView setAlpha:0.0f];
    [self.view addSubview:self.renameView];
    
    [UIView beginAnimations:@"RenameViewAnimation_Show" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    [UIView setAnimationDuration:0.2f];
    [self.renameView setAlpha:1.0f];
    [UIView commitAnimations];
    
}


// 隐藏重命名框
- (void)hideRenameView
{
    [UIView beginAnimations:@"RenameViewAnimation_Hide" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.2f];
    [self.renameView setAlpha:0.0f];
    [UIView commitAnimations];
}


// 取消重命名
- (IBAction)cancelRename:(id)sender
{
    [self hideRenameView];
}


// 重命名
- (IBAction)doRename:(id)sender
{
    NSString *newFileName = _renameFileNameTextField.text;
    if ([newFileName length] < 1)
    {
        [UITools showMessage:@"文件名不能为空"];
        return;
    }

    if ([self.editingRing isKindOfClass:[RecordRing class]])
    {
        newFileName = [UITools encodeBase64:_renameFileNameTextField.text];
        if ([self isFileNameExist:newFileName inArray:_myRecordRingArr])
        {
            [UITools showMessage:@"文件名已存在"];
            return;
        }

        RecordRing *recordRing = ((RecordRing *) self.editingRing);
        
        NSString *newFilePath = [self newSavePathForRecordFileName:newFileName];
        NSError *error = nil;
        BOOL result = [[NSFileManager defaultManager] moveItemAtPath:recordRing.filePath toPath:newFilePath error:&error];
        if (result && !error)
        {
            recordRing.name = newFileName;
            recordRing.filePath = newFilePath;
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:kRecordRingIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self hideRenameView];
            [UITools showMessage:@"重命名成功"];
        }
        else
        {
            [UITools showMessage:@"重命名失败"];
        }
    }
    else if ([self.editingRing isKindOfClass:[MusicRing class]])
    {
        if ([self isFileNameExist:newFileName inArray:_musicRingArr])
        {
            [UITools showMessage:@"文件名已存在"];
            return;
        }
        
        MusicRing *musicRing = ((MusicRing *) self.editingRing);
        
        NSString *fileExtension = [musicRing.filePath pathExtension];
        NSString *newFilePath = [self newSavePathForMusicFileName:newFileName andExtension:fileExtension];
        NSError *error = nil;
        BOOL result = [[NSFileManager defaultManager] moveItemAtPath:musicRing.filePath toPath:newFilePath error:&error];
        if (result && !error)
        {
            musicRing.name = newFileName;
            musicRing.filePath = newFilePath;
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:kMusicRingIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self hideRenameView];
            [UITools showMessage:@"重命名成功"];
        }
        else
        {
            [UITools showMessage:@"重命名失败"];
        }
    }
    else if ([self.editingRing isKindOfClass:[MyUploadRing class]])
    {
        newFileName = [UITools encodeBase64:_renameFileNameTextField.text];
        if ([self isFileNameExist:newFileName inArray:_myUploadRingArr])
        {
            [UITools showMessage:@"文件名已存在"];
            return;
        }
        
        [self showWaiting];
        [self renameRing:self.editingRing forNewName:[UITools encodeBase64:newFileName]];
    }
}


// 创建新的录音文件保存路径
- (NSString *)newSavePathForMusicFileName:(NSString *)fileName andExtension:(NSString *)fileExtension
{
    NSString *documentPath = [Tools applicationDocumentDirectory];
    NSString *userPath = [NSString stringWithFormat:@"%@/%@/%@", documentPath, USERNAME, @"WIFIMusic"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:userPath])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:userPath withIntermediateDirectories:TRUE attributes:nil error:NULL];
    }
    NSString *filePath = [userPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", fileName, fileExtension]];
    
    return filePath;
}



#pragma mark - 表格扩展收缩相关

- (BOOL)isSectionExpanded:(NSInteger)section
{
    return _isSectionExpanded[section];
}


- (void)switchSectionExpanded:(NSInteger)section
{
    _isSectionExpanded[section] = !_isSectionExpanded[section];
}


// 展开/收起按钮
- (void)expandedSectionButtonDidTouched:(UIButton *)sender
{
    NSInteger section = sender.tag;
    [self switchSectionExpanded:section];
    BOOL currSectionExpanded = [self isSectionExpanded:section];
    if (currSectionExpanded &&
        section == kRecordRingIndex)
    {
        if (!_isMyRecordDataLoaded)
        {
            [self loadLocalRecordRing];
        }
        if (!_isMyFavoriteDataLoaded)
        {
            [self fetchMyFavoriteOnlineRing];
        }
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    else if (section == kFMRingIndex)
    {
        if (currSectionExpanded &&              // 还没有加载数据, 说明是第一次展开
            !_isSectionDataLoaded[section])
        {
            [self loadDataForSection:section];
        }
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    else
    {
        if (currSectionExpanded &&              // 还没有加载数据, 说明是第一次展开
            !_isSectionDataLoaded[section])
        {
            [self loadDataForSection:section];
        }
        else
        {
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }
}


// 加载分块数据
- (void)loadDataForSection:(NSInteger)section
{
    if (section == kOnlineRingIndex)        // 在线铃音
    {
        [self showWaiting];
        [self requestNextPageOnlieRing];
    }
    else if (section == kRecordRingIndex)   // 我的语音
    {
        // 已在父函数中处理
    }
    else if (section == kMusicRingIndex)    // 本地音乐
    {
        // 由导入按钮触发
        [self loadLocalMusicRing];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    else if (section == kFMRingIndex)       // FM信息
    {
        if (_currentDeviceSerial)
        {
            [self showWaiting];
            [self fetchDeviceFM:_currentDeviceSerial];
        }
    }
    else if (section == kMyUploadRingIndex) // 我的上传
    {
        [self showWaiting];
        [self fetchMyUploadRing];
    }
}


#pragma mark - 在线铃音分页

// 测试是否还有在线铃音
- (BOOL)hasMoreOnlineRing
{
    return [_onlineRingArr count] < _totalOfOnlineRing;
}


// 请求下一页在线铃音
- (void)requestNextPageOnlieRing
{
    [self fetchOnlineRing:[NSString stringWithFormat:@"%zd", [_onlineRingArr count]]
                   number:[NSString stringWithFormat:@"%d", kRowPerPageOfOnlineRing]];
}


#pragma mark - 加载本地录音

// 加载本地录音文件
- (void)loadLocalRecordRing
{
    NSString *documentPath = [Tools applicationDocumentDirectory];
    NSString *recordPath = [NSString stringWithFormat:@"%@/%@/%@", documentPath, USERNAME, @"Record"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    NSArray *fileArr = [fileManager contentsOfDirectoryAtPath:recordPath error:&error];
    if (!error && [fileArr count] > 0)
    {
        [_myRecordRingArr removeAllObjects];
        
        for (NSString *fileName in fileArr)
        {
            RecordRing *ring = [[RecordRing alloc] init];
            ring.name = [fileName stringByDeletingPathExtension];
            ring.fileExtension = [fileName pathExtension];
            ring.filePath = [recordPath stringByAppendingPathComponent:fileName];
            
            [_myRecordRingArr addObject:ring];
        }
        
        // 组合起来
        [self combineMyFavoriteAndRecordRing];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:kRecordRingIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}


// 组合我的收藏和我的录音
- (void)combineMyFavoriteAndRecordRing
{
    self.myFavoriteAndRecordRingArr = [[NSMutableArray alloc] init];
    [self.myFavoriteAndRecordRingArr addObjectsFromArray:_myFavoriteRingArr];
    [self.myFavoriteAndRecordRingArr addObjectsFromArray:_myRecordRingArr];
}


#pragma mark - 铃声播放相关

// 播放
- (void)playRing:(iSpaceRing *)ring
{
    self.playingRing = ring;
    self.isPlaying = TRUE;
    
    if ([ring isKindOfClass:[MyUploadRing class]])
    {
        MyUploadRing *myUploadRing = (MyUploadRing *) ring;
        
        if ([ring.type isEqualToString:@".amr"])
        {
            [self downloadRingAndPlay:myUploadRing withSelf:self];
        }
        else
        {
            self.streamPlayer = [[AudioStreamer alloc] initWithURL:[NSURL URLWithString:myUploadRing.ringUrl]];
            [self.streamPlayer start];
        }
    }
    else if ([ring isKindOfClass:[OnlineRing class]])
    {
        OnlineRing *onlineRing = (OnlineRing *) ring;
        
        self.streamPlayer = [[AudioStreamer alloc] initWithURL:[NSURL URLWithString:onlineRing.ringUrl]];
        [self.streamPlayer start];
    }
    else if ([ring isKindOfClass:[RecordRing class]])
    {
        RecordRing *recordRing = (RecordRing *) ring;
        
        NSData *data = [[NSData alloc] initWithContentsOfFile:recordRing.filePath];
        NSError *error = nil;
        self.player = [[AVAudioPlayer alloc] initWithData:data error:&error];
        self.player.delegate = self;
        if (error)
        {
            [self setNormalAtIndexPath:self.lastPlayRingIndexPath];
            self.lastPlayRingIndexPath = nil;
            self.playingRing = nil;
            self.isPlaying = FALSE;
            
            [UITools showMessage:@"播放失败"];
        }
        else
        {
            [self.player play];
        }
    }
    else if ([ring isKindOfClass:[MusicRing class]])
    {
        MusicRing *musicRing = (MusicRing *) ring;
        
        NSString *playFilePath;
        if ([musicRing.fileExtension isEqualToString:@"amr"])
        {
            NSString *wavFilePath = [self tempPathOfRecorderFile];
            if ([self convertAmr:musicRing.filePath toWav:wavFilePath])
            {
                playFilePath = wavFilePath;
            }
        }
        else
        {
            playFilePath = musicRing.filePath;
        }
        
        if (playFilePath)
        {
            NSData *data = [[NSData alloc] initWithContentsOfFile:playFilePath];
            NSError *error = nil;
            self.player = [[AVAudioPlayer alloc] initWithData:data error:&error];
            self.player.delegate = self;
            if (error)
            {
                [self setNormalAtIndexPath:self.lastPlayRingIndexPath];
                self.lastPlayRingIndexPath = nil;
                self.playingRing = nil;
                self.isPlaying = FALSE;
                
                [UITools showMessage:@"播放失败"];
            }
            else
            {
                [self.player play];
            }
        }
        else
        {
            [self setNormalAtIndexPath:self.lastPlayRingIndexPath];
            self.lastPlayRingIndexPath = nil;
            self.playingRing = nil;
            self.isPlaying = FALSE;

            [UITools showMessage:@"播放失败"];
        }
    }
}


// 下载文件完成后再播放
- (void)downloadRingAndPlay:(MyUploadRing *)ring withSelf:(MyRingViewController *)controllerSelf
{
    [self.asyncFileDownloader cancel];
    
    self.asyncFileDownloader = [[AsyncFileDownloader alloc] init];
    self.asyncFileDownloader.failedBlock = ^(NSString *url)
    {
        [controllerSelf setNormalAtIndexPath:controllerSelf.lastPlayRingIndexPath];
        controllerSelf.lastPlayRingIndexPath = nil;
        controllerSelf.playingRing = nil;
        controllerSelf.isPlaying = FALSE;

        [UITools showMessage:@"播放失败"];
    };
    self.asyncFileDownloader.succeededBlock = ^(NSData *fileData, NSString *url)
    {
        NSString *amrFilePath = [controllerSelf tempPathOfARMFile];
        if ([fileData writeToFile:amrFilePath atomically:TRUE])
        {
            NSString *wavFilePath = [controllerSelf tempPathOfRecorderFile];
            if ([controllerSelf convertAmr:amrFilePath toWav:wavFilePath])
            {
                NSError *error = nil;
                controllerSelf.player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL URLWithString:wavFilePath] error:&error];
                controllerSelf.player.delegate = controllerSelf;
                if (error)
                {
                    [controllerSelf setNormalAtIndexPath:controllerSelf.lastPlayRingIndexPath];
                    controllerSelf.lastPlayRingIndexPath = nil;
                    controllerSelf.playingRing = nil;
                    controllerSelf.isPlaying = FALSE;

                    [UITools showMessage:@"播放失败"];
                }
                else
                {
                    [controllerSelf.player play];
                }
            }
        }
    };
    [self.asyncFileDownloader downloadFileWithUrl:ring.ringUrl];
}


// 录音ARM文件临时存放路径
- (NSString *)tempPathOfARMFile
{
    NSString *tempPath = [NSString stringWithFormat:@"%@/%@/%@", NSTemporaryDirectory(), USERNAME, @"Record"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:tempPath])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:tempPath withIntermediateDirectories:TRUE attributes:nil error:NULL];
    }
    tempPath = [tempPath stringByAppendingPathComponent:@"record_temp.arm"];
    
    return tempPath;
}


// 暂停当前播放
- (void)pauseRing
{
    self.isPlaying = FALSE;
    
    if ([self.playingRing isKindOfClass:[MyUploadRing class]])
    {
        MyUploadRing *myUploadRing = (MyUploadRing *) self.playingRing;
        if ([myUploadRing.type isEqualToString:@".amr"])
        {
            [self.player pause];
            [self.asyncFileDownloader cancel];
        }
        else
        {
            if (self.streamPlayer.state == AS_INITIALIZED ||
                self.streamPlayer.state == AS_WAITING_FOR_QUEUE_TO_START ||
                self.streamPlayer.state == AS_PLAYING)
            {
                [self.streamPlayer pause];
            }
        }
    }
    else if ([self.playingRing isKindOfClass:[OnlineRing class]])
    {
        if (self.streamPlayer.state == AS_INITIALIZED ||
            self.streamPlayer.state == AS_WAITING_FOR_QUEUE_TO_START ||
            self.streamPlayer.state == AS_PLAYING)
        {
            [self.streamPlayer pause];
        }
    }
    else if ([self.playingRing isKindOfClass:[RecordRing class]])
    {
        [self.player pause];
    }
    else if ([self.playingRing isKindOfClass:[MusicRing class]])
    {
        [self.player pause];
    }
}


// 恢复播放
- (void)resumeRing
{
    self.isPlaying = TRUE;
    
    if ([self.playingRing isKindOfClass:[MyUploadRing class]])
    {
        MyUploadRing *myUploadRing = (MyUploadRing *) self.playingRing;
        if ([myUploadRing.type isEqualToString:@".amr"])   // [ring.type isEqualToString:@"amr"]
        {
            [self downloadRingAndPlay:myUploadRing withSelf:self];
        }
        else
        {
            self.streamPlayer = [[AudioStreamer alloc] initWithURL:[NSURL URLWithString:myUploadRing.ringUrl]];
            [self.streamPlayer start];
        }
    }
    else if ([self.playingRing isKindOfClass:[OnlineRing class]])
    {
        [self.streamPlayer start];
    }
    else if ([self.playingRing isKindOfClass:[RecordRing class]])
    {
        [self.player play];
    }
    else if ([self.playingRing isKindOfClass:[MusicRing class]])
    {
        [self.player play];
    }
}


// 停止当前正在播放的铃声
- (void)stopRing
{
    self.isPlaying = FALSE;

    if ([self.playingRing isKindOfClass:[MyUploadRing class]])
    {
        MyUploadRing *myUploadRing = (MyUploadRing *) self.playingRing;
        if ([myUploadRing.type isEqualToString:@".amr"])
        {
            [self.player pause];
            [self.asyncFileDownloader cancel];
        }
        else
        {
            [self.streamPlayer pause];
        }
    }
    else if ([self.playingRing isKindOfClass:[OnlineRing class]])
    {
        [self.streamPlayer stop];
        self.streamPlayer = nil;
        self.playingRing = nil;
    }
    else if ([self.playingRing isKindOfClass:[RecordRing class]])
    {
        [self.player pause];
        self.player = nil;
        self.playingRing = nil;
    }
    else if ([self.playingRing isKindOfClass:[MusicRing class]])
    {
        [self.player pause];
        self.player = nil;
        self.playingRing = nil;
    }
}


#pragma mark - 音步播放相关代理

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [self setNormalAtIndexPath:self.lastPlayRingIndexPath];
    [self stopRing];
    self.lastPlayRingIndexPath = nil;
}


- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error
{
    [self setNormalAtIndexPath:self.lastPlayRingIndexPath];
    [self stopRing];
    self.lastPlayRingIndexPath = nil;

    [UITools showMessage:@"无法播放文件"];
}


// 处理AudioStreamer状态改变
- (void)handleAudioStreamerState:(NSNotification *)notification
{
    if (self.streamPlayer.errorCode != AS_NO_ERROR)
    {
        [self setNormalAtIndexPath:self.lastPlayRingIndexPath];
        [self stopRing];
        self.lastPlayRingIndexPath = nil;

        [UITools showMessage:@"播放文件出错"];
    }
    else if (self.streamPlayer.state == AS_STOPPED)
    {
        [self setNormalAtIndexPath:self.lastPlayRingIndexPath];
        [self stopRing];
        self.lastPlayRingIndexPath = nil;
    }
}


#pragma mark - 录音相关

// 开始录音
- (void)startRecorder
{
    if (!self.recorderFilePath)
    {
        self.recorderFilePath = [self tempPathOfRecorderFile];
    }
    
    // 设置APP音频会话类型
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    
    // 增加录音音量
    UInt32 doChangeDefault = 1;
    AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryDefaultToSpeaker, sizeof(doChangeDefault), &doChangeDefault);

    // 设置录音参数并开始录音
    self.recorder = [[AVAudioRecorder alloc] initWithURL:[NSURL URLWithString:self.recorderFilePath]
                                                settings:[self audioRecorderSetting]
                                                   error:nil];
    self.recorder.delegate = self;
    [self.recorder prepareToRecord];
    [self.recorder record];
    
    // 记录开始时间
    _beginRecordTime = self.recorder.currentTime;
}


// 停止录音
- (void)stopRecorder
{
    [self.recorder stop];
    [self stopUpdateMetersTimer];
    self.recorder = nil;
}


// 暂停录音
- (void)pauseRecorder
{
    [self.recorder pause];
}


// 恢复录音
- (void)resumeRecorder
{
    [self.recorder record];
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



// 录音文件临时存放路径
- (NSString *)tempPathOfRecorderFile
{
    NSString *tempPath = [NSString stringWithFormat:@"%@/%@/%@", NSTemporaryDirectory(), USERNAME, @"Record"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:tempPath])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:tempPath withIntermediateDirectories:TRUE attributes:nil error:NULL];
    }
    tempPath = [tempPath stringByAppendingPathComponent:@"record_temp.wav"];
    
    return tempPath;
}


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


// 定时器调用函数
- (void)updateMeters:(NSTimer *)aTimer
{
    if (self.recorder.isRecording)
    {
        _recordTime = self.recorder.currentTime - _beginRecordTime;
        NSTimeInterval remainTime = MAX_SECONDS_OF_RECORD - _recordTime;
        [self updateRemainTimeTip:remainTime];
        
        if (remainTime < 0.0f)
        {
            [self hideRecordTipView];
            [self stopRecorder];
            [self stopUpdateMetersTimer];
            [self showSaveView];
        }
    }
}


// 更新录音剩余时间
- (void)updateRemainTimeTip:(NSTimeInterval)remainTime
{
    NSString *message = [[NSString alloc] initWithFormat:@"00:%02zd", (int)_recordTime];
    self.speakTipRemainTimeLabel.text = message;
}


#pragma mark - 保存录音文件

// 显示保存录音框
- (void)showSaveView
{
    _fileNameTextField.text = [self newRecordFileName];
    
    [self.saveView setFrame:self.view.frame];
    [self.saveView setAlpha:0.0f];
    [self.view addSubview:self.saveView];
    
    [UIView beginAnimations:@"SaveViewAnimation_Show" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    [UIView setAnimationDuration:0.2f];
    [self.saveView setAlpha:1.0f];
    [UIView commitAnimations];

}


// 隐藏保存录音框
- (void)hideSaveView
{
    [UIView beginAnimations:@"SaveViewAnimation_Hide" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.2f];
    [self.saveView setAlpha:0.0f];
    [UIView commitAnimations];
}


// 取消保存录音
- (IBAction)cancelSave:(id)sender
{
    [self hideSaveView];
}


// 保存录音
- (IBAction)doSave:(id)sender
{
    NSString *fileName = [UITools encodeBase64:_fileNameTextField.text];
    if ([fileName length] < 1)
    {
        [UITools showMessage:@"文件名不能为空"];
        return;
    }
    
    if ([self isFileNameExist:fileName inArray:_myRecordRingArr])
    {
        [UITools showMessage:@"文件名已存在"];
        return;
    }
    
    NSString *filePath = [self newSavePathForRecordFileName:fileName];
    NSError *error = nil;
    BOOL result = [[NSFileManager defaultManager] moveItemAtPath:self.recorderFilePath toPath:filePath error:&error];
    if (result && !error)
    {
        [self addRecordRing:fileName andPath:filePath];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:kRecordRingIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self hideSaveView];
        [UITools showMessage:@"保存成功"];
    }
    else
    {
        [UITools showMessage:@"保存失败"];
    }
}


// 添加一条录音
- (void)addRecordRing:(NSString *)ringName andPath:(NSString *)filePath
{
    RecordRing *ring = [[RecordRing alloc] init];
    ring.name = ringName;
    ring.filePath = filePath;
    
    [_myRecordRingArr addObject:ring];
    [self combineMyFavoriteAndRecordRing];
}


// 创建新的录音文件名
- (NSString *)newRecordFileName
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd-HHmmss"];
    NSString *string = [dateFormatter stringFromDate:[NSDate date]];
    
    return string;
}


// 创建新的录音文件保存路径
- (NSString *)newSavePathForRecordFileName:(NSString *)fileName
{
    NSString *documentPath = [Tools applicationDocumentDirectory];
    NSString *userPath = [NSString stringWithFormat:@"%@/%@/%@", documentPath, USERNAME, @"Record"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:userPath])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:userPath withIntermediateDirectories:TRUE attributes:nil error:NULL];
    }
    NSString *filePath = [userPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.wav", fileName]];
    
    return filePath;
}



// 检查录音文件名是否已经存在
- (BOOL)isFileNameExist:(NSString *)fileName inArray:(NSArray *)array
{
    for (iSpaceRing *ring in array)
    {
        if ([ring.name isEqualToString:fileName])
        {
            return TRUE;
        }
    }
    
    return FALSE;
}




#pragma mark - 网络请求相关

// 获取在线铃音
- (void)fetchOnlineRing:(NSString *)start number:(NSString *)number
{
    NSMutableDictionary *params = [NetDataService needCommand:@"2074"
                                                andNeedUserId:USER_ID
                                            AndNeedBobyArrKey:@[@"req_id", @"start", @"num"]
                                          andNeedBobyArrValue:@[@"-1", start, number]];
    
    void (^failedBlock)() = ^()
    {
        [self hideWaiting];
    };
    
    void (^succeededBlock)(id result) = ^(id result)
    {
        [self hideWaiting];
        dispatch_async(dispatch_get_main_queue(),
                       ^{
                           [self handleOnlineRingResult:result];
                       });
    };
    
    [NetDataService requestWithUrl:SVR_URL
                        dictParams:params
                        httpMethod:@"POST"
                 andisWaitActivity:YES
              andWaitActivityTitle:nil
                        andViewCtl:self
                     isShowWaiting:TRUE
                       failedBlock:failedBlock
                     completeBlock:succeededBlock];
}



// 处理在线铃音数据
- (void)handleOnlineRingResult:(id)result
{
    NSDictionary *msgBody = [result getDictionary:@"message_body"];
    NSInteger errorCode = [msgBody getInteger:@"error"];
    if (errorCode == 0)
    {
        _isSectionDataLoaded[kOnlineRingIndex] = TRUE;         // 成功加载一次
        
        _totalOfOnlineRing = [msgBody getInteger:@"total"];
        NSArray *array = [msgBody getArray:@"info"];
        if ([array count] == 0)
        {
            [UITools showMessage:@"没有在线音乐"];
        }
        else
        {
            for (NSDictionary *dict in array)
            {
                OnlineRing *ring = [[OnlineRing alloc] init];
                ring.ringId = [dict getInteger:@"id"];
                ring.name = [dict getString:@"name"];
                ring.size = [dict getInteger:@"size"];
                ring.ringUrl = [dict getString:@"url"];
                
                [_onlineRingArr addObject:ring];
            }
        }
    }
    else if (errorCode == -25005)
    {
        [UITools showMessage:@"没有在线音乐"];
    }
    else
    {
        [UITools showError:errorCode];
    }
    
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:kOnlineRingIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
}


// 获取设备FM信息
- (void)fetchDeviceFM:(NSString *)deviceSerial
{
    NSMutableDictionary *params = [NetDataService needCommand:@"2053"
                                                andNeedUserId:USER_ID
                                            AndNeedBobyArrKey:@[@"dev_sn"]
                                          andNeedBobyArrValue:@[deviceSerial]];
    
    void (^failedBlock)() = ^()
    {
        [self hideWaiting];
    };
    
    void (^succeededBlock)(id result) = ^(id result)
    {
        _isSectionDataLoaded[kFMRingIndex] = TRUE;         // 成功加载一次
        [self hideWaiting];
        dispatch_async(dispatch_get_main_queue(),
                       ^{
                           [self handleFMResult:result];
                       });
    };
    
    [NetDataService requestWithUrl:SVR_URL
                        dictParams:params
                        httpMethod:@"POST"
                 andisWaitActivity:YES
              andWaitActivityTitle:nil
                        andViewCtl:self
                     isShowWaiting:TRUE
                       failedBlock:failedBlock
                     completeBlock:succeededBlock];
}


// 处理FM数据
- (void)handleFMResult:(id)result
{
    NSDictionary *msgBody = [result getDictionary:@"message_body"];
    NSInteger errorCode = [msgBody getInteger:@"error"];
    if (errorCode == 0)
    {
        [_fmRingArr removeAllObjects];      // 清除原有FM信息
        
        NSDictionary *fm = [msgBody getDictionary:@"fm_info"];
        NSArray *array = [fm getArray:@"list"];
        if ([array count] > 0)
        {
            for (NSString *string in array)
            {
                FMRing *ring = [[FMRing alloc] init];
                ring.name = string;
                
                [_fmRingArr addObject:ring];
            }
            
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:kFMRingIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }
    else
    {
        [UITools showError:errorCode];
    }
}



// 获取我收藏的在线铃音
- (void)fetchMyFavoriteOnlineRing
{
    NSMutableDictionary *params = [NetDataService needCommand:@"2075"
                                                andNeedUserId:USER_ID
                                            AndNeedBobyArrKey:@[@"req_id"]
                                          andNeedBobyArrValue:@[@"-1"]];
    
    void (^failedBlock)() = ^()
    {
        [self hideWaiting];
    };
    
    void (^succeededBlock)(id result) = ^(id result)
    {
        [self hideWaiting];
        dispatch_async(dispatch_get_main_queue(),
                       ^{
                           [self handleMyFavoriteOnlineRingResult:result];
                       });
    };
    
    [NetDataService requestWithUrl:SVR_URL
                        dictParams:params
                        httpMethod:@"POST"
                 andisWaitActivity:YES
              andWaitActivityTitle:nil
                        andViewCtl:self
                     isShowWaiting:TRUE
                       failedBlock:failedBlock
                     completeBlock:succeededBlock];
}


// 处理我收藏的在线铃音数据
- (void)handleMyFavoriteOnlineRingResult:(id)result
{
    NSDictionary *msgBody = [result getDictionary:@"message_body"];
    NSInteger errorCode = [msgBody getInteger:@"error"];
    if (errorCode == 0)
    {
        _isMyFavoriteDataLoaded = TRUE;         // 成功加载一次

        // 清除原来的数据
        [_myFavoriteRingArr removeAllObjects];
        
        NSArray *array = [msgBody getArray:@"info"];
        if ([array count] > 0)
        {
            for (NSDictionary *dict in array)
            {
                FavoriteRing *ring = [[FavoriteRing alloc] init];
                ring.ringId = [dict getInteger:@"id"];
                ring.name = [dict getString:@"name"];
                ring.size = [dict getInteger:@"size"];
                ring.ringUrl = [dict getString:@"url"];
                
                [_myFavoriteRingArr addObject:ring];
            }
            
            // 组合起来
            [self combineMyFavoriteAndRecordRing];
        }
    }
    else if (errorCode == -25005)
    {
        // 清除原来的数据
        [_myFavoriteRingArr removeAllObjects];

        // 组合起来
        [self combineMyFavoriteAndRecordRing];
    }
    else
    {
        [UITools showError:errorCode];
    }

    // 刷新
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:kRecordRingIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
}



// 收藏的在线铃音
- (void)favoriteOnlineRing:(NSString *)ringId
{
    NSMutableDictionary *params = [NetDataService needCommand:@"2086"
                                                andNeedUserId:USER_ID
                                            AndNeedBobyArrKey:@[@"file_id"]
                                          andNeedBobyArrValue:@[ringId]];
    
    void (^failedBlock)() = ^()
    {
        [self hideWaiting];
    };
    
    void (^succeededBlock)(id result) = ^(id result)
    {
        [self hideWaiting];
        dispatch_async(dispatch_get_main_queue(),
                       ^{
                           [self handleFavoriteOnlineRingResult:result];
                       });
    };
    
    [NetDataService requestWithUrl:SVR_URL
                        dictParams:params
                        httpMethod:@"POST"
                 andisWaitActivity:YES
              andWaitActivityTitle:nil
                        andViewCtl:self
                     isShowWaiting:TRUE
                       failedBlock:failedBlock
                     completeBlock:succeededBlock];
}


// 处理收藏的在线铃音结果
- (void)handleFavoriteOnlineRingResult:(id)result
{
    NSDictionary *msgBody = [result getDictionary:@"message_body"];
    NSInteger errorCode = [msgBody getInteger:@"error"];
    if (errorCode == 0)
    {
        FavoriteRing *ring = [[FavoriteRing alloc] init];
        ring.ringId = self.favoritingRing.ringId;
        ring.name = self.favoritingRing.name;
        ring.data = self.favoritingRing.data;
        ring.size = self.favoritingRing.size;
        ring.ringUrl = self.favoritingRing.ringUrl;
        
        [_myFavoriteRingArr addObject:ring];
        self.favoritingRing = nil;
        
        // 组合起来
        [self combineMyFavoriteAndRecordRing];

        // 刷新
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:kRecordRingIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        [UITools showMessage:@"收藏成功"];
    }
    else
    {
        [UITools showError:errorCode];
    }
}



// 获取我上传的铃音
- (void)fetchMyUploadRing
{
    NSMutableDictionary *params = [NetDataService needCommand:@"2096"
                                                andNeedUserId:USER_ID
                                            AndNeedBobyArrKey:@[@"req_id", @"start", @"num"]
                                          andNeedBobyArrValue:@[@"-1", @"0", @"10000"]];
    
    void (^failedBlock)() = ^()
    {
        [self hideWaiting];
    };
    
    void (^succeededBlock)(id result) = ^(id result)
    {
        [self hideWaiting];
        dispatch_async(dispatch_get_main_queue(),
                       ^{
                           [self handleMyUploadRingResult:result];
                       });
    };
    
    [NetDataService requestWithUrl:SVR_URL
                        dictParams:params
                        httpMethod:@"POST"
                 andisWaitActivity:YES
              andWaitActivityTitle:nil
                        andViewCtl:self
                     isShowWaiting:TRUE
                       failedBlock:failedBlock
                     completeBlock:succeededBlock];
}


// 处理我上传的铃音
- (void)handleMyUploadRingResult:(id)result
{
    NSDictionary *msgBody = [result getDictionary:@"message_body"];
    NSInteger errorCode = [msgBody getInteger:@"error"];
    if (errorCode == 0)
    {
        _isSectionDataLoaded[kMyUploadRingIndex] = TRUE;         // 成功加载一次
        [_myUploadRingArr removeAllObjects];
        
        NSArray *array = [msgBody getArray:@"list"];
        if ([array count] > 0)
        {
            for (NSDictionary *dict in array)
            {
                MyUploadRing *ring = [[MyUploadRing alloc] init];
                ring.ringId = [dict getInteger:@"fid"];
                ring.name = [dict getString:@"name"];
                ring.type = [dict getString:@"ext"];
                ring.ringUrl = [dict getString:@"url"];
                
                [_myUploadRingArr addObject:ring];
            }
        }
    }
    else if (errorCode == -25005)
    {
        [_myUploadRingArr removeAllObjects];
    }
    else
    {
        [UITools showError:errorCode];
    }
    
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:kMyUploadRingIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
}


// 请求获取设备信息
-(void)fetchDeviceInfo
{
    //请求体
    NSMutableDictionary *params = [NetDataService needCommand:@"2051"
                                                andNeedUserId:USER_ID
                                            AndNeedBobyArrKey:@[@"dev_type"]
                                          andNeedBobyArrValue:@[@"0"]];
    
    //请求网络
    [NetDataService requestWithUrl:SVR_URL
                        dictParams:params
                        httpMethod:@"POST"
                 andisWaitActivity:YES
              andWaitActivityTitle:nil
                        andViewCtl:self
                     isShowWaiting:TRUE
                       failedBlock:NULL
                     completeBlock:^(id result)
     {
         dispatch_async(dispatch_get_main_queue(), ^{
             [self handleDeviceInfo:result];
         });
     }];
}


// 处理获取设备信息结果
- (void)handleDeviceInfo:(id)result
{
    NSDictionary *msgBody = [result getDictionary:@"message_body"];
    NSInteger errorCode = [msgBody getInteger:@"error"];
    if (errorCode == 0)
    {
        NSMutableArray *allAlarmInfoArray = [[NSMutableArray alloc] init];
        
        NSDictionary *allDeviceDict = [msgBody getDictionary:@"dev_list"];
        NSArray *allDeviceArray = [allDeviceDict objectForKey:@"list"];
        for (NSDictionary *deviceInfo in allDeviceArray)
        {
            NSDictionary *alarmInfoDict = [deviceInfo getDictionary:@"alarm_info"];
            NSArray *alarmInfoArray = [alarmInfoDict getArray:@"list"];
            for (NSDictionary *alarmInfo in alarmInfoArray)
            {
                [allAlarmInfoArray addObject:alarmInfo];
            }
        }
        
        self.allAlarmInfoArray = allAlarmInfoArray;
        [self.tableView reloadData];
    }
}



// 修改我上传的文件的名称
- (void)renameRing:(iSpaceRing *)ring forNewName:(NSString *)name
{
    NSMutableDictionary *params = [NetDataService needCommand:@"2097"
                                                andNeedUserId:USER_ID
                                            AndNeedBobyArrKey:@[@"uid", @"fid", @"name"]
                                          andNeedBobyArrValue:@[USER_ID, [NSString stringWithFormat:@"%zd", ring.ringId], name]];
    
    void (^failedBlock)() = ^()
    {
        [self hideWaiting];
        [UITools showMessage:@"修改名称失败"];
    };
    
    void (^succeededBlock)(id result) = ^(id result)
    {
        [self hideWaiting];
        dispatch_async(dispatch_get_main_queue(),
                       ^{
                           [self handleRenameRingResult:result];
                       });
    };
    
    [NetDataService requestWithUrl:SVR_URL
                        dictParams:params
                        httpMethod:@"POST"
                 andisWaitActivity:YES
              andWaitActivityTitle:nil
                        andViewCtl:self
                     isShowWaiting:TRUE
                       failedBlock:failedBlock
                     completeBlock:succeededBlock];
}


// 处理修改名称结果
- (void)handleRenameRingResult:(id)result
{
    NSDictionary *msgBody = [result getDictionary:@"message_body"];
    NSInteger errorCode = [msgBody getInteger:@"error"];
    if (errorCode == 0)
    {
        self.editingRing.name = [UITools encodeBase64:_renameFileNameTextField.text];
        
        // 关闭更名视图
        [self hideRenameView];
        
        // 刷新
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:kMyUploadRingIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    else
    {
        [UITools showError:errorCode];
    }
}




// 删除我上传的文件
- (void)deleteRing:(iSpaceRing *)ring
{
    NSMutableDictionary *params = [NetDataService needCommand:@"2099"
                                                andNeedUserId:USER_ID
                                            AndNeedBobyArrKey:@[@"uid", @"fid"]
                                          andNeedBobyArrValue:@[USER_ID, [NSString stringWithFormat:@"%zd", ring.ringId]]];
    
    void (^failedBlock)() = ^()
    {
        [self hideWaiting];
        [UITools showMessage:@"删除文件失败"];
    };
    
    void (^succeededBlock)(id result) = ^(id result)
    {
        [self hideWaiting];
        dispatch_async(dispatch_get_main_queue(),
                       ^{
                           [self handleDeleteRingResult:result];
                       });
    };
    
    [NetDataService requestWithUrl:SVR_URL
                        dictParams:params
                        httpMethod:@"POST"
                 andisWaitActivity:YES
              andWaitActivityTitle:nil
                        andViewCtl:self
                     isShowWaiting:TRUE
                       failedBlock:failedBlock
                     completeBlock:succeededBlock];
}


// 处理删除上传的文件结果
- (void)handleDeleteRingResult:(id)result
{
    NSDictionary *msgBody = [result getDictionary:@"message_body"];
    NSInteger errorCode = [msgBody getInteger:@"error"];
    if (errorCode == 0)
    {
        [_myUploadRingArr removeObject:self.editingRing];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:kMyUploadRingIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    else
    {
        [UITools showError:errorCode];
    }
}


@end
