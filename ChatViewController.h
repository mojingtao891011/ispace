//
//  ChatViewController.h
//  iSpace
//
//  Created by CC on 14-5-7.
//  Copyright (c) 2014年 xiabing. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "BaseViewController.h"
#import "DevicesInfoModel.h"
#import "MessageListCellDelegate.h"
#import "DateTimePicker.h"
#import "AsyncFileDownloader.h"


@interface ChatViewController : BaseViewController <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, NSFetchedResultsControllerDelegate, AVAudioPlayerDelegate, MessageListCellDelegate>
{
    CGPoint _startPoint;                // 长按起始点位置
    
    NSTimer *_updateMetersTimer;
    NSTimeInterval _beginRecordTime;
    NSTimeInterval _recordTime;
    
    BOOL _isSendCanceled;
    BOOL _isShowingDatetimePicker;
    
    AsyncFileDownloader *_fileRequest;  // 异步文件下载
}

@property (strong, nonatomic) DevicesInfoModel *currentDeviceInfo;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic, strong) IBOutlet UIView *maskView;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UIButton *speakButton;
@property (nonatomic, strong) IBOutlet UIView *speakTipView;
@property (nonatomic, strong) IBOutlet UILabel *speakTipLabel;
@property (nonatomic, strong) IBOutlet UILabel *speakTipRemainTimeLabel;
@property (nonatomic, strong) IBOutlet UIImageView *speakTipImageView;
@property (nonatomic, strong) IBOutlet UIView *datetimePickerView;
@property (nonatomic, strong) IBOutlet DateTimePicker *datetimePicker;


@end
