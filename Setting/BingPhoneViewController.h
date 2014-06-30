//
//  BingViewController.h
//  iSpace
//
//  Created by 莫景涛 on 14-4-30.
//  Copyright (c) 2014年 莫景涛. All rights reserved.
//

#import "BaseViewController.h"

@interface BingPhoneViewController : BaseViewController<UITableViewDataSource , UITableViewDelegate , UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITableView *bingTabelView;
@property (nonatomic , retain)UITextField *phoneNunber ;
@end
