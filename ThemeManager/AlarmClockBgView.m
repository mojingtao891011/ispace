//
//  ClockBgView.m
//  Home
//
//  Created by bear on 14-5-12.
//  Copyright (c) 2014年 莫景涛. All rights reserved.
//

#import "AlarmClockBgView.h"

@implementation AlarmClockBgView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self _initSubView];
    }
    return self;
}
- (void)_initSubView
{
    self.layer.cornerRadius = 5.0;
}
- (void)awakeFromNib
{
    [self _initSubView];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
