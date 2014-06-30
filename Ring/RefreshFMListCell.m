//
//  RestaurantCell.m
//  PPW
//
//  Created by xiabing on 13-3-5.
//
//

#import "RefreshFMListCell.h"
#import "Tools.h"


@implementation RefreshFMListCell



- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}


- (void)awakeFromNib
{
    [super awakeFromNib];
    
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


// "刷新FM"按钮事件
- (IBAction)handleRefreshFM:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(refreshFMAtIndexPath:)])
    {
        [self.delegate refreshFMAtIndexPath:self.indexPath];
    }
}


@end
