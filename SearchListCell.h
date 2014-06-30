//
//  RestaurantCell.h
//  PPW
//
//  Created by xiabing on 13-3-5.
//
//

#import <UIKit/UIKit.h>
#import "FriendInfoModel.h"


@protocol SearchListCellDelegate;

@interface SearchListCell : UITableViewCell
{

}

@property (nonatomic, weak) IBOutlet UIImageView *avatarImageView;
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *sexLabel;
@property (nonatomic, weak) IBOutlet UILabel *cityLabel;
@property (nonatomic, weak) IBOutlet UIButton *addButton;
@property (nonatomic, weak) id <SearchListCellDelegate> delegate;

- (void)updateCellWithData:(FriendInfoModel *)friendInfo;

@end



// SearchListCellDelegate
@protocol SearchListCellDelegate <NSObject>

@optional
- (void)addFriendButtonDidTouchedWithTag:(long)tag;

@end