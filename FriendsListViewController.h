//
//  FriendsViewController.h
//  iSpace
//
//  Created by CC on 14-5-7.
//  Copyright (c) 2014年 xiabing. All rights reserved.
//

#import "BaseViewController.h"
#import "FriendsListCell.h"
#import "DevicesInfoModel.h"
#import "FriendInfoModel.h"
#import "MessageReceiver.h"


@interface FriendsListViewController : BaseViewController <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, FriendsListCellDelegate>
{
    FriendInfoModel *_friendInfoOfDeleting;
    FriendInfoModel *_friendInfoOfUpdating;
    
    BOOL _isLoadingFrinedInfo;
}

@property (nonatomic, strong) DevicesInfoModel *currentDeviceInfo;
@property (nonatomic, strong) NSMutableArray *friends;
@property (nonatomic, weak) IBOutlet UITableView *friendsTableView;


@end
