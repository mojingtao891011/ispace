//
//  EmailLookPassWordViewController.h
//  BedsideTreasure
//
//  Created by 莫景涛 on 14-4-5.
//  Copyright (c) 2014年 莫景涛. All rights reserved.
//

#import "BaseViewController.h"
#import "UserInfoModel.h"

@interface LookStyleViewController : BaseViewController<UITextFieldDelegate , UIAlertViewDelegate , UITableViewDataSource , UITableViewDelegate>

@property(nonatomic , copy)NSString *email ;
@property(nonatomic , copy)NSString *account ;
@property(nonatomic , retain)UserInfoModel  *userInfoModel ;
@property(nonatomic , copy)NSString *searchStyle ; //0代表手机方式 、 1代表邮箱方式
@property(nonatomic , retain)NSArray *cellArr ;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UITableViewCell *firstCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *sencondCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *threeCell;

@property (weak, nonatomic) IBOutlet UILabel *searchStyleName;
@property (weak, nonatomic) IBOutlet UILabel *showLabel;
@property (weak, nonatomic) IBOutlet UITextField *captchaTextfield;

- (IBAction)enterAction:(id)sender;
- (IBAction)sendCaptchaAction:(id)sender;

@end
