//
//  FriendsViewController.h
//  BedsideTreasure
//
//  Created by xiabing on 14-4-1.
//  Copyright (c) 2014年 xiabing. All rights reserved.
//

#import "BaseViewController.h"
#import "DeviceListCell.h"
#import "FriendInfoModel.h"


@interface DeviceHomeViewController : BaseViewController <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, UIAlertViewDelegate, DeviceListCellDelegate>
{
    NSString *_newDeviceNameOfUpdating;
    DevicesInfoModel *_deviceOfUpdating;
    DevicesInfoModel *_deviceOfDeleting;
}

@property (nonatomic, strong) IBOutlet UIView *noDevicesView;
@property (nonatomic, strong) IBOutlet UIView *noDevicesSubView;

@property (nonatomic, strong) IBOutlet UIButton *systemMessageButton;
@property (nonatomic, strong) IBOutlet UITableView *devicesTableView;

@property (nonatomic, strong) IBOutlet UIImageView *friendAvatarImageView;
@property (nonatomic, strong) IBOutlet UILabel *friendNameLabel;
@property (nonatomic, strong) IBOutlet UILabel *messageLabel;

@property (strong, nonatomic) IBOutlet UIView *addDeviceTipView;
@property (strong, nonatomic) IBOutlet UIView *addDeviceTipSubView;
@property (strong, nonatomic) IBOutlet UIView *addDeviceTipSubBackgroundView;

@property (nonatomic, strong) IBOutlet UIView *responseAddFriendView;
@property (nonatomic, strong) IBOutlet UIView *responseAddFriendSubView;
@property (nonatomic, strong) IBOutlet UIView *responseAddFriendSubBackgroundView;


@end



// AddFriendRequestInfo
@interface AddFriendRequestInfo : NSObject

@property (nonatomic, strong) FriendInfoModel *friendInfo;
@property (nonatomic, strong) NSString *explain;

@end