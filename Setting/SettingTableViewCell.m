//
//  SettingTableViewCell.m
//  iSpace
//
//  Created by 莫景涛 on 14-4-21.
//  Copyright (c) 2014年 莫景涛. All rights reserved.
//

#import "SettingTableViewCell.h"

@implementation SettingTableViewCell

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)layoutSubviews
{
     [self.titleLabel sizeToFit];
}
@end
