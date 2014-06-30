//
//  LookPassWordViewController.h
//  BedsideTreasure
//
//  Created by 莫景涛 on 14-4-5.
//  Copyright (c) 2014年 莫景涛. All rights reserved.
//

#import "BaseViewController.h"
#import "UserInfoModel.h"

@interface LookPassWordViewController : BaseViewController<UITableViewDataSource , UITableViewDelegate , UIAlertViewDelegate>
{
    NSArray *_titleArr ;
}
@property(nonatomic , retain)UserInfoModel *userInfoModel ;
@property (weak, nonatomic) IBOutlet UITableView *lookPassWordTableView;
@end
