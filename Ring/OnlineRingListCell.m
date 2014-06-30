//
//  RestaurantCell.m
//  PPW
//
//  Created by xiabing on 13-3-5.
//
//

#import "OnlineRingListCell.h"
#import "Tools.h"


@interface OnlineRingListCell ()

@property (nonatomic, retain) IBOutlet UIButton *playButton;

@end


@implementation OnlineRingListCell


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


// 设置行样式, 播放或暂停状态
- (void)setRingCellStyle:(RingListCellStyle)style
{
    _ringCellstyle = style;
    
    if (self.ringCellstyle == RingListCellStyleNormal)
    {
        [self.playButton setImage:[UIImage imageNamed:@"ring_play_normal"] forState:UIControlStateNormal];
        [self.playButton setImage:[UIImage imageNamed:@"ring_play_highlight"] forState:UIControlStateHighlighted];
    }
    else if (self.ringCellstyle == RingListCellStylePlaying)
    {
        [self.playButton setImage:[UIImage imageNamed:@"ring_pause"] forState:UIControlStateNormal];
    }
}


// 播放或暂停按钮事件
- (IBAction)playButtonDidTouch:(id)sender
{
    if (self.ringCellstyle == RingListCellStyleNormal)
    {
        if ([self.delegate respondsToSelector:@selector(playRingAtIndexPath:)])
        {
            [self.delegate playRingAtIndexPath:self.indexPath];
        }
    }
    else if (self.ringCellstyle == RingListCellStylePlaying)
    {
        if ([self.delegate respondsToSelector:@selector(pauseRingAtIndexPath:)])
        {
            [self.delegate pauseRingAtIndexPath:self.indexPath];
        }
    }
}


// 下载按钮事件
- (IBAction)downloadButtonDidTouch:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(downloadRingAtIndexPath:)])
    {
        [self.delegate downloadRingAtIndexPath:self.indexPath];
    }
}

@end
