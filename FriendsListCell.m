//
//  RestaurantCell.m
//  PPW
//
//  Created by xiabing on 13-3-5.
//
//

#import "FriendsListCell.h"
#import "UIImageView+WebCache.h"
#import "UITools.h"


@implementation FriendsListCell


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
    
    // 初始化时, tipImageView和button都是隐藏的。
    _cellStyle = FriendsListCellStyleNormal;
    _lastCellStyle = FriendsListCellStyleNormal;
    
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
    if (_cellStyle != FriendsListCellStyleDelete)
    {
        _lastCellStyle = _cellStyle;
        [self setFriendsListCellStyle:FriendsListCellStyleDelete];
    }
}


// 处理向右滑动手势
- (void)handleRightSwipeGestureRecognizer:(UISwipeGestureRecognizer *)recognizer
{
    if (_cellStyle == FriendsListCellStyleDelete)
    {
        [self setFriendsListCellStyle:_lastCellStyle];
    }
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
    if (selected)
    {
        self.selectedBackgroundView = [[UIView alloc] initWithFrame:self.frame];
        self.selectedBackgroundView.backgroundColor = [UIColor colorWithRed:230.0f/255.0f green:249.0f/255.0f blue:243.0f/255.0f alpha:1.0f];
    }
    else
    {
        self.selectedBackgroundView = [[UIView alloc] initWithFrame:self.frame];
        self.selectedBackgroundView.backgroundColor = [UIColor whiteColor];
    }
}


// 设置Cell样式
- (void)setFriendsListCellStyle:(FriendsListCellStyle)style
{
    _cellStyle = style;
    if (_cellStyle == FriendsListCellStyleNormal)            // 正常状态
    {
        self.tipImageView.hidden = TRUE;
        self.button.hidden = TRUE;
    }
    else
    {
        self.tipImageView.hidden = FALSE;
        self.button.hidden = FALSE;
        
        if (_cellStyle == FriendsListCellStyleDelete)           // 删除状态
        {
            self.tipImageView.backgroundColor = [UIColor colorWithRed:245.0f/255.0f green:102.f/255.0f blue:69.0f/255.0f alpha:1.0f];
            [self.button setImage:[UIImage imageNamed:@"friend_list_item_delete"] forState:UIControlStateNormal];
        }
        else if (_cellStyle == FriendsListCellStyleLinked)      // 已经和设备邦定状态
        {
            self.tipImageView.backgroundColor = [UIColor colorWithRed:121.0f/255.0f green:222.0f/255.0f blue:188.0f/255.0f alpha:1.0f];
            [self.button setImage:[UIImage imageNamed:@"friend_list_item_link"] forState:UIControlStateNormal];
        }
        else if (_cellStyle == FriendsListCellStyleUnlinked)    // 没有和设备邦定状态
        {
            self.tipImageView.backgroundColor = [UIColor colorWithRed:121.0f/255.0f green:222.0f/255.0f blue:188.0f/255.0f alpha:1.0f];
            [self.button setImage:[UIImage imageNamed:@"friend_list_item_delink"] forState:UIControlStateNormal];
        }
    }
}


// 更新Cell界面
- (void)updateCellWithData:(FriendInfoModel *)friendInfo
{
    [self.avatarImageView setImageWithURL:[NSURL URLWithString:friendInfo.pic_url]
                         placeholderImage:[UIImage imageNamed:@"ic_test_head"]];
    self.nameLabel.text = [UITools decodeBase64:friendInfo.name];
    self.sexLabel.text = [UITools sexDescription:[friendInfo.sex integerValue]];
    self.cityLabel.text = [UITools decodeBase64:friendInfo.city];
}


// 处理按钮按下事件
- (IBAction)handleButtonAction:(id)sender
{
    if (_cellStyle == FriendsListCellStyleDelete)           // 删除状态
    {
        // delete按钮被按下
        if ([self.delegate respondsToSelector:@selector(friendsListCell:deleteButtonDidTouchedWithTag:)])
        {
            [self.delegate friendsListCell:self deleteButtonDidTouchedWithTag:self.tag];
        }
    }
    else if (_cellStyle == FriendsListCellStyleLinked)      // 已经和设备邦定状态
    {
        // delink按钮被按下
        if ([self.delegate respondsToSelector:@selector(friendsListCell:linkButtonDidTouchedWithTag:)])
        {
            [self.delegate friendsListCell:self linkButtonDidTouchedWithTag:self.tag];
        }
    }
    else if (_cellStyle == FriendsListCellStyleUnlinked)    // 没有和设备邦定状态
    {
        // link按钮被按下
        if ([self.delegate respondsToSelector:@selector(friendsListCell:delinkButtonDidTouchedWithTag:)])
        {
            [self.delegate friendsListCell:self delinkButtonDidTouchedWithTag:self.tag];
        }
    }
}

@end
