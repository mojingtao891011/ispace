//
//  HomecViewController.h
//  Home
//
//  Created by bear on 14-5-11.
//  Copyright (c) 2014年 莫景涛. All rights reserved.
//

#import "BaseViewController.h"
#import "AlarmClock.h"
#import "AlarmClockBgView.h"
#import "BaseTableView.h"


@interface HomeViewController : BaseViewController<UITableViewDataSource , UITableViewDelegate , UIAlertViewDelegate , RefreshProptor , UIScrollViewDelegate>

@property(nonatomic , retain)NSMutableArray *cellArr ;
@property(nonatomic , retain)NSMutableArray *heightRowArr ;
@property(nonatomic , retain)NSMutableArray *devicesTotalArr ;
@property(retain, nonatomic)NSArray *clockArr ;
@property(retain, nonatomic)NSArray *clockLabelArr ;
@property(retain, nonatomic)NSArray *clockBgViewArr ;
@property(retain, nonatomic)NSArray *colorArr;
@property(retain , nonatomic)NSMutableArray *alarmInfoArr ;
@property(nonatomic , copy)NSString *devicesCity ;
@property(nonatomic , assign)BOOL isSwithDevice ;
@property(nonatomic ,retain)MJRefreshBaseView *refreshView ;
@property(nonatomic , assign)CGFloat otherDeviceHeight ;
//@property(nonatomic , assign)NSInteger otherDeviceMoveHeight ;
@property(nonatomic , assign)NSInteger closeClockIndex ;
@property(nonatomic  , copy)NSString  *selectedDev_sn ;
@property(nonatomic , copy)NSString *app_url ;

@property (weak, nonatomic) IBOutlet BaseTableView *homeTableView;
@property (strong, nonatomic) IBOutlet UITableViewCell *iSpaceNameCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *iSpaceWeathCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *iSpaceClockCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *iSpaceOtherCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *noWIFICell;
@property (strong, nonatomic) IBOutlet UIView *noDeviceView;
@property (weak, nonatomic) IBOutlet UILabel *alertInfoLabel;


@property (weak, nonatomic) IBOutlet UILabel *nowifiDate;
@property (weak, nonatomic) IBOutlet UILabel *nowifiWeek;
@property (weak, nonatomic) IBOutlet UIImageView *nowifiBT;

@property (weak, nonatomic) IBOutlet AlarmClockBgView *clock1BgView;
@property (weak, nonatomic) IBOutlet AlarmClockBgView *clock2BgView;
@property (weak, nonatomic) IBOutlet AlarmClockBgView *clock3BgView;
@property (weak, nonatomic) IBOutlet AlarmClockBgView *clock4BgView;

@property (weak, nonatomic) IBOutlet AlarmClock *clock1;
@property (weak, nonatomic) IBOutlet AlarmClock *clock2;
@property (weak, nonatomic) IBOutlet AlarmClock *clock3;
@property (weak, nonatomic) IBOutlet AlarmClock *clock4;
@property (weak, nonatomic) IBOutlet UILabel *label1;
@property (weak, nonatomic) IBOutlet UILabel *label2;
@property (weak, nonatomic) IBOutlet UILabel *label3;
@property (weak, nonatomic) IBOutlet UILabel *label4;
@property (weak, nonatomic) IBOutlet UILabel *devicesName;
@property (nonatomic , assign)int deviceIndex ;
@property (weak, nonatomic) IBOutlet UILabel *devicesTime;

@property (weak, nonatomic) IBOutlet UILabel *devicesCityLabel;
@property (weak, nonatomic) IBOutlet UILabel *TemperatureLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *weekLabel;
@property (weak, nonatomic) IBOutlet UIImageView *weatherImg;
@property (weak, nonatomic) IBOutlet UILabel *weatherStatus;
@property (weak, nonatomic) IBOutlet UILabel *AverageTemp;
@property (weak, nonatomic) IBOutlet UIImageView *devicesOnlineStaut;
@property (weak, nonatomic) IBOutlet UIImageView *devicesBT;
@property (nonatomic , retain)NSMutableArray *weatherImgArr ;
@property (nonatomic , retain)NSArray *weatherStautArr ;

@property (weak, nonatomic) IBOutlet UISwitch *switchClock1;
@property (weak, nonatomic) IBOutlet UISwitch *switchClock2;
@property (weak, nonatomic) IBOutlet UISwitch *switchClock3;
@property (weak, nonatomic) IBOutlet UISwitch *switchClock4;
@property(nonatomic , retain)NSArray *switchClockArr ;
@property(nonatomic , assign)BOOL  isStop_setting ;

- (IBAction)clickAlarmClockAction:(UIButton *)sender;

- (IBAction)changeDevicesAction:(UIButton *)sender;

- (IBAction)tapView:(UITapGestureRecognizer *)sender;

- (IBAction)swipAction:(UISwipeGestureRecognizer *)sender;

- (IBAction)panAction:(UIPanGestureRecognizer *)sender;

- (IBAction)switchAction:(UISwitch *)sender;

@end
