//
//  VerifiedViewController.h
//  iSpace
//
//  Created by 莫景涛 on 14-5-6.
//  Copyright (c) 2014年 莫景涛. All rights reserved.
//

#import "BaseViewController.h"

@interface VerifiedViewController : BaseViewController<UIAlertViewDelegate>

@property(nonatomic , copy)NSString *phoneNumber ;
@property (weak, nonatomic) IBOutlet UITextField *captcha;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property(nonatomic , retain)NSArray *cellArr ;
@property (strong, nonatomic) IBOutlet UITableViewCell *firstCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *sencondCell;
@property (nonatomic , assign)BOOL isSuccess ;

- (IBAction)submitCaptcha:(UIButton *)sender;



@end
