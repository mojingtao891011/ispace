//
//  RestaurantCell.h
//  iSpace
//
//  Created by xiabing on 13-3-5.
//
//

#import <UIKit/UIKit.h>
#import "FriendInfoModel.h"


typedef NS_ENUM(NSInteger, FriendsListCellStyle)
{
    FriendsListCellStyleNormal,             // 正常状态
    FriendsListCellStyleDelete,             // 删除状态
    FriendsListCellStyleLinked,             // 已连接设备状态
    FriendsListCellStyleUnlinked,           // 未连接设备状态
};


@protocol FriendsListCellDelegate;


@interface FriendsListCell : UITableViewCell
{
    FriendsListCellStyle _lastCellStyle;
    FriendsListCellStyle _cellStyle;
}

@property (nonatomic, weak) IBOutlet UIImageView *tipImageView;
@property (nonatomic, weak) IBOutlet UIImageView *avatarImageView;
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *sexLabel;
@property (nonatomic, weak) IBOutlet UILabel *cityLabel;
@property (nonatomic, weak) IBOutlet UIButton *button;

@property (nonatomic, weak) id <FriendsListCellDelegate> delegate;


- (void)setFriendsListCellStyle:(FriendsListCellStyle)style;                // 设置Cell样式
- (void)updateCellWithData:(FriendInfoModel *)friendInfo;                  // 更新Cell界面


@end



// FriendsListCellDelegate
@protocol FriendsListCellDelegate <NSObject>

@optional
- (void)friendsListCell:(FriendsListCell *)cell deleteButtonDidTouchedWithTag:(long)tag;             // delete按钮被按下
- (void)friendsListCell:(FriendsListCell *)cell linkButtonDidTouchedWithTag:(long)tag;               // link按钮被按下
- (void)friendsListCell:(FriendsListCell *)cell delinkButtonDidTouchedWithTag:(long)tag;             // delink按钮被按下

@end