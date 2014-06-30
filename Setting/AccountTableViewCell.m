//
//  AccountTableViewCell.m
//  BedsideTreasure
//
//  Created by 莫景涛 on 14-4-6.
//  Copyright (c) 2014年 莫景涛. All rights reserved.
//

#import "AccountTableViewCell.h"


@implementation AccountTableViewCell

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
    [super layoutSubviews];
    
    if ([_selectedSex isEqualToString:@"0"]) {
        self.radioButton_b.selected = YES ;
        self.radioButton.selected = NO ;
    }else if ([_selectedSex isEqualToString:@"1"]){
        self.radioButton.selected = YES ;
        self.radioButton_b.selected = NO ;
    }

}
- (IBAction)selectedAction:(UIButton *)sender {
    if (sender.tag == 1 || sender.tag == 3) {
        [[NSNotificationCenter defaultCenter]postNotificationName:@"selectedSexNote" object:@"1"];
    }else{
        [[NSNotificationCenter defaultCenter]postNotificationName:@"selectedSexNote" object:@"0"];
    }
    
}
@end
