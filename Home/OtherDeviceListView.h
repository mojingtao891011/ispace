//
//  OtherDeviceListView.h
//  iSpace
//
//  Created by bear on 14-5-30.
//  Copyright (c) 2014年 莫景涛. All rights reserved.
//

#import <UIKit/UIKit.h>

#define SWITCHDEVICENOTE @"switchDeviceNote"
#define SWITCHDEVICENOTE_SETTING @"switchDeviceNote_setting"

@interface OtherDeviceListView : UIView<UITableViewDataSource , UITableViewDelegate>
{
    CGRect _subViewFrame ;
}
@property(nonatomic , retain)NSMutableArray *devicesTotalArr ;
@property(nonatomic , assign)BOOL isHomeSwitch ;
@property(nonatomic , retain)UITableView *tableView ;
@end
