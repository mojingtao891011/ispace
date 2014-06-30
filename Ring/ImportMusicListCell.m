//
//  RestaurantCell.m
//  PPW
//
//  Created by xiabing on 13-3-5.
//
//

#import "ImportMusicListCell.h"
#import "Tools.h"


@implementation ImportMusicListCell


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


// "导入本地音乐"按钮事件
- (IBAction)handleImportMusic:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(importLocalMusicAtIndexPath:)])
    {
        [self.delegate importLocalMusicAtIndexPath:self.indexPath];
    }
}


@end
