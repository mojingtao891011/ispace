//
//  RestaurantCell.h
//  PPW
//
//  Created by xiabing on 13-3-5.
//
//

#import <UIKit/UIKit.h>
#import "MessageListCellDelegate.h"


@interface MessageFromFriendListCell : UITableViewCell
{
}

@property (nonatomic, retain) IBOutlet UIImageView *stateImageView;
@property (nonatomic, retain) IBOutlet UILabel *durationLabel;
@property (nonatomic, retain) IBOutlet UILabel *dateTimeLabel;
@property (nonatomic, weak) id <MessageListCellDelegate> delegate;

- (void)setNormalState;
- (void)setPlayingState;

@end
