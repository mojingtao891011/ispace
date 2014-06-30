//
//  RestaurantCell.m
//  PPW
//
//  Created by xiabing on 13-3-5.
//
//

#import "RecordRingListCell.h"
#import "Tools.h"


@interface RecordRingListCell ()

@property (nonatomic, retain) IBOutlet UIButton *playButton;

@end


@implementation RecordRingListCell

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
    
    // 添加左右滑动手势支持
    UISwipeGestureRecognizer *leftSwipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                              action:@selector(handleLeftSwipeGestureRecognizer:)];
    [leftSwipeRecognizer setDirection:(UISwipeGestureRecognizerDirectionLeft)];
    [self addGestureRecognizer:leftSwipeRecognizer];
    
    UISwipeGestureRecognizer *rightSwipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                               action:@selector(handleRightSwipeGestureRecognizer:)];
    [rightSwipeRecognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [self addGestureRecognizer:rightSwipeRecognizer];
}



// 处理向左滑动手势
- (void)handleLeftSwipeGestureRecognizer:(UISwipeGestureRecognizer *)recognizer
{
    if (self.buttonContainerView.hidden)
    {
        self.buttonContainerView.hidden = FALSE;
        self.buttonContainerView.alpha = 0.0f;
        
        [UIView beginAnimations:@"RecordRingListCell_ShowButton" context:nil];
        [UIView setAnimationCurve:UIViewAnimationCurveLinear];
        [UIView setAnimationDuration:0.3f];
        self.buttonContainerView.alpha = 1.0;
        [UIView commitAnimations];
    }
}


// 处理向右滑动手势
- (void)handleRightSwipeGestureRecognizer:(UISwipeGestureRecognizer *)recognizer
{
    if (!self.buttonContainerView.hidden)
    {
        [UIView beginAnimations:@"RecordRingListCell_HideButton" context:nil];
        [UIView setAnimationCurve:UIViewAnimationCurveLinear];
        [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDuration:0.3f];
        self.buttonContainerView.alpha = 0.0f;
        [UIView commitAnimations];
    }
}


// UIView动画完成通知
- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    if ([animationID isEqualToString:@"RecordRingListCell_HideButton"])
    {
        self.buttonContainerView.hidden = TRUE;
    }
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


// 删除按钮事件
- (IBAction)deleteButtonDidTouch:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(deleteItemAtIndexPath:)])
    {
        [self.delegate deleteItemAtIndexPath:self.indexPath];
    }
}


// 更多功能按钮事件
- (IBAction)moreActionButtonDidTouch:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(moreActionAtIndexPath:)])
    {
        [self.delegate moreActionAtIndexPath:self.indexPath];
    }
}


@end
