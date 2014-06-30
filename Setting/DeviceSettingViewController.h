//
//  DeviceSettingViewController.h
//  iSpace
//
//  Created by bear on 14-6-12.
//  Copyright (c) 2014年 莫景涛. All rights reserved.
//

#import "BaseViewController.h"
#import "DevicesInfoModel.h"

@interface DeviceSettingViewController : BaseViewController<UITableViewDataSource , UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *deviceTableview;
@property (nonatomic , retain)NSArray *sectionArr ;
@property(nonatomic , retain)NSMutableArray *deviceTotalArr ;
@property(nonatomic , assign)CGFloat  firstRowHeight ;
@property(nonatomic , copy)NSString *VolValue ;
@property(nonatomic , retain)UIImageView *redioImgView ;
@property(nonatomic ,assign)NSInteger  selectedModel ;
@property(nonatomic , retain)DevicesInfoModel *curModel ;
@property(nonatomic , assign)BOOL isShow ;
@property (strong, nonatomic) IBOutlet UIView *checkNetView;
@property (weak, nonatomic) IBOutlet UILabel *speedLabel;
@property (weak, nonatomic) IBOutlet UILabel *netDescriptionLabel;
@property(nonatomic , retain)NSTimer *timer ;

- (IBAction)checkNetAction:(UIButton *)sender;
- (IBAction)swipeAction:(UISwipeGestureRecognizer *)sender;


@end
