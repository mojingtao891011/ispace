//
//  RestaurantCell.m
//  PPW
//
//  Created by xiabing on 13-3-5.
//
//

#import "RecordListCell.h"
#import "Tools.h"


@implementation RecordListCell


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


// "录音"按钮事件
- (IBAction)handleStartRecord:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(startRecordAtIndexPath:)])
    {
        [self.delegate startRecordAtIndexPath:self.indexPath];
    }
}

@end
