//
//  RestaurantCell.m
//  PPW
//
//  Created by xiabing on 13-3-5.
//
//

#import "DeviceListCell.h"
#import "UITools.h"
#import "UIImage+Additions.h"


@implementation DeviceListCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        // Initialization code
    }
    return self;
}


- (void)awakeFromNib
{
    [super awakeFromNib];
    
    // 高亮时背景
    UIColor *buttonBackground = [UIColor colorWithRed:236.0f/255.0f green:250.0f/255.0f blue:245.0f/255.0f alpha:1.0f];
    [self.backgroundButton setBackgroundImage:[UIImage imageWithColor:buttonBackground]
                                     forState:UIControlStateHighlighted];
    
    // 设备列表长按事件
    UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                                      action:@selector(handleButtonLongPress:)];
    longPressRecognizer.minimumPressDuration = 0.8f;     // 定义长按时间
    [self.backgroundButton addGestureRecognizer:longPressRecognizer];
}


// 长按事件
- (void)handleButtonLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan)
    {
        if ([self.delegate respondsToSelector:@selector(deviceNameDidLongTouchedWithTag:)])
        {
            [self.delegate deviceNameDidLongTouchedWithTag:self.tag];
        }
    }
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


// 进入聊天界面
- (IBAction)handleEnterChatAction:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(enterChatButtonDidTouchedWithTag:)])
    {
        [self.delegate enterChatButtonDidTouchedWithTag:self.tag];
    }
}


// 进入好友界面
- (IBAction)handleEnterFriendsAction:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(enterFriendsButtonDidTouchedWithTag:)])
    {
        [self.delegate enterFriendsButtonDidTouchedWithTag:self.tag];
    }
}



@end
