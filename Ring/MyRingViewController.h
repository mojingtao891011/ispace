//
//  MyRingViewController.h
//  iSpace
//
//  Created by CC on 14-6-9.
//  Copyright (c) 2014年 xiabing. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "BaseViewController.h"
#import "RingCellDelegate.h"
#import "OnlineRingListCell.h"
#import "FavoriteRingListCell.h"
#import "RecordRingListCell.h"
#import "MusicRingListCell.h"
#import "FMRingListCell.h"
#import "RecordListCell.h"
#import "ImportMusicListCell.h"
#import "LoadMoreListCell.h"
#import "RefreshFMListCell.h"
#import "MyUploadListCell.h"
#import "RingUploader.h"


@interface MyRingViewController : BaseViewController <UITableViewDelegate, UITableViewDataSource, AVAudioRecorderDelegate, AVAudioPlayerDelegate, UIActionSheetDelegate, RingCellDelegate, RingUploaderDelegate>
{
    NSMutableArray *_onlineRingArr;             // 在线铃音
    NSMutableArray *_myFavoriteRingArr;         // 我收藏的铃音
    NSMutableArray *_myRecordRingArr;           // 我录制的铃音
    NSMutableArray *_musicRingArr;              // 本地音乐
    NSMutableArray *_fmRingArr;                 // FM
    NSMutableArray *_myUploadRingArr;           // 我上传的铃音
    
    BOOL _isSectionExpanded[5];             // 分组展开状态
    BOOL _isSectionDataLoaded[5];           // 分组数据是否已加载标志
    BOOL _isMyRecordDataLoaded;             // 第二组数据有两块:收藏的在线铃音+本地录音
    BOOL _isMyFavoriteDataLoaded;           // 第二组数据有两块:收藏的在线铃音+本地录音
    NSString *_sectionTitles[5];            // 分组标题
    
    NSInteger _totalOfOnlineRing;           // 在线铃音总数
    
    NSString *_currentDeviceSerial;         // 当前设备序列号
    NSIndexPath *_lastPlayRingIndexPath;    // 上一次播放的项
    
    NSTimer *_updateMetersTimer;            // 录音定时器
    NSTimeInterval _beginRecordTime;
    NSTimeInterval _recordTime;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIView *recordView;
@property (strong, nonatomic) IBOutlet UIView *saveView;
@property (strong, nonatomic) IBOutlet UIView *renameView;
@property (strong, nonatomic) IBOutlet UILabel *speakTipRemainTimeLabel;
@property (strong, nonatomic) IBOutlet UITextField *fileNameTextField;
@property (strong, nonatomic) IBOutlet UITextField *renameFileNameTextField;


@end
