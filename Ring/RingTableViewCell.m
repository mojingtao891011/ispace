//
//  RingTableViewCell.m
//  iSpace
//
//  Created by CC on 14-6-12.
//  Copyright (c) 2014年 xiabing. All rights reserved.
//

#import "RingTableViewCell.h"

@implementation RingTableViewCell

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
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


@end
