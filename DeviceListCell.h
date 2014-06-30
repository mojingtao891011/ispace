//
//  RestaurantCell.h
//  PPW
//
//  Created by xiabing on 13-3-5.
//
//

#import <UIKit/UIKit.h>
#import "DevicesInfoModel.h"


@protocol DeviceListCellDelegate;


@interface DeviceListCell : UITableViewCell
{
}

@property (nonatomic, retain) IBOutlet UIButton *backgroundButton;
@property (nonatomic, retain) IBOutlet UIButton *listFriendButton;
@property (nonatomic, retain) IBOutlet UIImageView *linkStateImageView;
@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet UILabel *friendNameLabel;
@property (nonatomic, retain) IBOutlet UIView *bandNumberView;
@property (nonatomic, retain) IBOutlet UILabel *bandNumberLabel;


@property (nonatomic, weak) id <DeviceListCellDelegate> delegate;

@end



// DeviceListCellDelegate
@protocol DeviceListCellDelegate <NSObject>

@optional
- (void)deviceNameDidLongTouchedWithTag:(long)tag;
- (void)enterChatButtonDidTouchedWithTag:(long)tag;
- (void)enterFriendsButtonDidTouchedWithTag:(long)tag;

@end