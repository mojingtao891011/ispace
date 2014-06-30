//
//  DirectoryViewController.h
//  iSpace
//
//  Created by bear on 14-6-30.
//  Copyright (c) 2014年 莫景涛. All rights reserved.
//

#import "BaseViewController.h"

#define ABOUTISPACE_URL @"http://www.momoda.com/help/html/versionIntroduce.html"
#define USERAGREEMENT_URL  @"http://www.momoda.com/help/html/userProtocol.html"
@interface DirectoryViewController : BaseViewController<UITableViewDataSource , UITableViewDelegate>
{
    NSArray *_titleArr ;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end
