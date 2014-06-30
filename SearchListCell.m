//
//  RestaurantCell.m
//  PPW
//
//  Created by xiabing on 13-3-5.
//
//

#import "SearchListCell.h"
#import "UIImageView+WebCache.h"
#import "UITools.h"


@implementation SearchListCell

- (void)awakeFromNib
{
    self.addButton.layer.borderWidth = 1.0 ;
    self.addButton.layer.borderColor =  [UIColor colorWithRed:125/255.0 green:214/255.9 blue:208/255.0 alpha:1.0].CGColor;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}


// 用数据填充界面
- (void)updateCellWithData:(FriendInfoModel *)friendInfo
{
    [self.avatarImageView setImageWithURL:[NSURL URLWithString:friendInfo.pic_url]
                         placeholderImage:[UIImage imageNamed:@"default_friend_avatar"]];
    self.nameLabel.text = [UITools decodeBase64:friendInfo.name];
    self.sexLabel.text = [UITools sexDescription:[friendInfo.sex integerValue]];
    self.cityLabel.text = [UITools decodeBase64:friendInfo.city];
}


- (IBAction)handleAddFriendsAction:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(addFriendButtonDidTouchedWithTag:)])
    {
        [self.delegate addFriendButtonDidTouchedWithTag:self.tag];
    }
}

@end
