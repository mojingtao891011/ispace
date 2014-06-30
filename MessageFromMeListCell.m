//
//  RestaurantCell.m
//  PPW
//
//  Created by xiabing on 13-3-5.
//
//

#import "MessageFromMeListCell.h"
#import "Tools.h"

@interface MessageFromMeListCell ()

@property (strong, nonatomic) IBOutlet UIButton *playButton;

@end


@implementation MessageFromMeListCell

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
    
    // 设备列表长按事件
    UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                                      action:@selector(handleButtonLongPress:)];
    longPressRecognizer.minimumPressDuration = 0.8f;     // 定义长按时间
    [self.playButton addGestureRecognizer:longPressRecognizer];
}


// 长按事件
- (void)handleButtonLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan)
    {
        if ([self.delegate respondsToSelector:@selector(messageListCellDidLongPress:)])
        {
            [self.delegate messageListCellDidLongPress:self.tag];
        }
    }
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)setNormalState
{
    self.stateImageView.image = [UIImage imageNamed:@"message_play"];
}


- (void)setPlayingState
{
    self.stateImageView.image = [UIImage imageNamed:@"message_pause"];
}


- (IBAction)handlePlayButtonDidTouch:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(playMessageButtonDidTouch:)])
    {
        [self.delegate playMessageButtonDidTouch:self.tag];
    }
}

@end
