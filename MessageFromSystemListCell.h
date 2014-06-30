//
//  RestaurantCell.h
//  PPW
//
//  Created by xiabing on 13-3-5.
//
//

#import <UIKit/UIKit.h>
#import "MessageListCellDelegate.h"


@interface MessageFromSystemListCell : UITableViewCell
{

}

@property (nonatomic, retain) IBOutlet UILabel *label;
@property (nonatomic, retain) IBOutlet UILabel *timeLabel;
@property (nonatomic, weak) id <MessageListCellDelegate> delegate;


@end
