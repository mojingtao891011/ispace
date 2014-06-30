//
//  SetColckViewControllers.h
//  iSpace
//
//  Created by 莫景涛 on 14-4-24.
//  Copyright (c) 2014年 莫景涛. All rights reserved.
//

#import "BaseViewController.h"
#import "AlarmInfoModel.h"
#import "RBCustomDatePickerView.h"
#import "UploadModel.h"

@class RecordModel ;

@interface SetColckViewController : BaseViewController<UITableViewDataSource , UITableViewDelegate>
{
    RBCustomDatePickerView *pickerView ;
    UIButton *barButton ;
    NSInteger alermState ;
}

@property (weak, nonatomic) IBOutlet UITableView *setAlarmTabelView;
@property(nonatomic , assign)NSInteger clockButtonTag ;
@property(nonatomic , retain)AlarmInfoModel *alarmInfoModel ;
@property(nonatomic , retain)NSMutableArray *frequencyArr ;
@property(nonatomic , copy)NSString *isWifiOnline ;
@property(nonatomic , copy)NSString *time ;
@property (strong, nonatomic) IBOutlet UITableViewCell *alermInfoCell;
@property (nonatomic , assign)BOOL isKeepLastSet ;

//重复
@property (weak, nonatomic) IBOutlet UIView *repeatViewBg;
@property(nonatomic , assign)int repeatDates ;

//响铃方式
@property (weak, nonatomic) IBOutlet UIView *styleView;
@property (weak, nonatomic) IBOutlet UIButton *showButton;
@property (weak, nonatomic) IBOutlet UIButton *recordButton;
@property (weak, nonatomic) IBOutlet UIButton *fmButton;
@property (weak, nonatomic) IBOutlet UILabel *showTitle;
@property(nonatomic , copy)NSString *RingStyleTitleStr ;
@property(nonatomic , assign)BOOL isOpenRingType ;

//音量
@property(nonatomic , copy)NSString *sound ;
@property (weak, nonatomic) IBOutlet UIButton *vol_levelButton;
@property (weak, nonatomic) IBOutlet UIButton *frequencyButton;
@property (weak, nonatomic) IBOutlet UILabel *frequencyLabel;
@property (weak, nonatomic) IBOutlet UISlider *frequencySlider;
@property (weak, nonatomic) IBOutlet UILabel *alartLabel;

//提交信息
@property(nonatomic , copy)NSString         *hour ;
@property(nonatomic , copy)NSString         *minute ;
@property(nonatomic , copy)NSString         *frequency ;       //频率
@property(nonatomic , copy)NSString         *vol_level ;        //音量
@property(nonatomic , copy)NSString          *sleep_gap ;      //睡眠间隔
@property(nonatomic , copy)NSString         *fm_chnl ;          //fm频道
@property(nonatomic , copy)NSString         *file_path ;        //音乐URL
@property(nonatomic , copy)NSString         *file_id ;          //音乐ID
@property(nonatomic , copy)NSString         *vol_type ;     //响铃方式

//上传
@property(nonatomic , copy)NSString *localMusicName ;
@property(nonatomic , copy)NSString*appendUrl ;
@property(nonatomic , retain)RecordModel *SelectedCollectModel ;
@property(nonatomic , copy)NSString *selectedRecordName ;
@property(nonatomic , assign)BOOL isSelectedRecord ;
@property(nonatomic , assign)BOOL isWav ;
@property(nonatomic , assign)BOOL isMyUpload ;
@property(nonatomic ,retain)UploadModel *selectedUploadModel ;

- (IBAction)selectRingStyleAction:(id)sender;
- (IBAction)ringSoundButtonActin:(UIButton *)sender;
- (IBAction)alarmFrequency:(UIButton *)sender;
- (IBAction)FrequencyValue:(UISlider *)sender;

- (IBAction)saveAlarmSetInfoAction:(id)sender;
- (IBAction)setRepeatDate:(id)sender;
- (IBAction)pushRingList:(id)sender;
@end
