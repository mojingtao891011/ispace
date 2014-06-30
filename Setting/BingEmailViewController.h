//
//  BingEmailViewController.h
//  iSpace
//
//  Created by 莫景涛 on 14-5-1.
//  Copyright (c) 2014年 莫景涛. All rights reserved.
//

#import "BaseViewController.h"

@interface BingEmailViewController : BaseViewController<UITableViewDataSource , UITableViewDelegate , UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property(nonatomic , retain)NSArray *cellArr ;
@property (strong, nonatomic) IBOutlet UITableViewCell *firstCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *sencondCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *threeCell;
@property (weak, nonatomic) IBOutlet UITextField *emailAddress;
@property (weak, nonatomic) IBOutlet UITextField *verifiedInfo;
@property (nonatomic , assign)BOOL isSuccess ;

- (IBAction)sendVerified:(UIButton *)sender;
- (IBAction)enterChange:(UIButton *)sender;
@end
