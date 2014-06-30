//
//  ChangePasswordViewController.h
//  iSpace
//
//  Created by 莫景涛 on 14-5-1.
//  Copyright (c) 2014年 莫景涛. All rights reserved.
//

#import "BaseViewController.h"

@interface ChangePasswordViewController : BaseViewController<UITableViewDataSource , UITableViewDelegate , UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *oldPassword;
@property (weak, nonatomic) IBOutlet UITextField *Password;
@property (weak, nonatomic) IBOutlet UITextField *againPassword;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property(nonatomic , retain)NSArray *cellArr ;
@property (strong, nonatomic) IBOutlet UITableViewCell *firstCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *sencondCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *threeCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *fourCell;
@property(nonatomic , assign)BOOL  isSuccess ;

- (IBAction)submitChange:(id)sender;
@end
