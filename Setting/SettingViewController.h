//
//  SettingViewController.h
//  BedsideTreasure
//
//  Created by 莫景涛 on 14-4-1.
//  Copyright (c) 2014年 莫景涛. All rights reserved.
//

 
#import "BaseViewController.h"

#define CHECKVERSION  @"http://itunes.apple.com/lookup?id=662004496"
#define APP_DownloadURL @"http://itunes.apple.com/app/id483504146?mt=8" //换成你自己的APP地址

@interface SettingViewController : BaseViewController<UITableViewDataSource , UITableViewDelegate , NSURLConnectionDataDelegate , UIAlertViewDelegate>
{
    NSString *_trackViewUrl ;
}
@property (weak, nonatomic) IBOutlet UITableView *settingTableView;
@property (retain, nonatomic) NSArray *dataSourceArr ;
@property (nonatomic , retain)NSArray *imgameArr ;
@property(nonatomic , retain)NSMutableData *appData ;

@end
