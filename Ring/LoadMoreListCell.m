//
//  RestaurantCell.m
//  PPW
//
//  Created by xiabing on 13-3-5.
//
//

#import "LoadMoreListCell.h"
#import "Tools.h"


@implementation LoadMoreListCell

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


// "加载更多"按钮事件
- (IBAction)handleLoadMore:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(loadMoreItemAtIndexPath:)])
    {
        [self.delegate loadMoreItemAtIndexPath:self.indexPath];
    }
}

@end
