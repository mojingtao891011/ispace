//
//  RestaurantCell.h
//  PPW
//
//  Created by xiabing on 13-3-5.
//
//

#import <UIKit/UIKit.h>
#import "RingTableViewCell.h"


@interface FavoriteRingListCell : RingTableViewCell
{
}

@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet UILabel *useByAlarmLabel;
@property (assign, nonatomic, setter=setRingCellStyle:) RingListCellStyle ringCellstyle;

@end
