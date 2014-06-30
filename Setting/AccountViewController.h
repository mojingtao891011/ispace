//
//  AccountViewController.h
//  BedsideTreasure
//
//  Created by 莫景涛 on 14-4-6.
//  Copyright (c) 2014年 莫景涛. All rights reserved.
//

#import "BaseViewController.h"
#import "UserInfoModel.h"

@interface AccountViewController : BaseViewController<UITableViewDataSource , UITableViewDelegate , UIActionSheetDelegate , UIActionSheetDelegate , UINavigationControllerDelegate , UIImagePickerControllerDelegate>

@property(nonatomic , copy) NSString *lastName  ;
@property(nonatomic , retain)NSArray *dataSourceArr ;
@property(nonatomic , retain)NSMutableArray *userInfoArr;
@property(nonatomic , retain)UserInfoModel *userInfoModel ;
@property(nonatomic , copy)NSString *sex ;
@property(nonatomic , copy)NSString *birthday ;
@property(nonatomic , copy)NSString *city ;
@property(nonatomic , retain)UIImage *userImage ;
@property(nonatomic , copy)NSString *pic_url ;
@property(nonatomic , copy)NSString *pic_id ;
@property(nonatomic , copy)NSString *appendUrl ;
@property(nonatomic , retain)MBProgressHUD *HUD ;
@property (weak, nonatomic) IBOutlet UIView *markView;

@property (weak, nonatomic) IBOutlet UIView *dateBgView;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
- (IBAction)EnterDateAction:(id)sender;
- (IBAction)cancelDateAction:(id)sender;


@property (weak, nonatomic) IBOutlet UITableView *accountTableView;
@property (strong, nonatomic) IBOutlet UITableViewCell *exitButtonCell;
- (IBAction)exitLand:(id)sender;

@end
