//
//  RepeatButton.m
//  iSpace
//
//  Created by 莫景涛 on 14-5-18.
//  Copyright (c) 2014年 莫景涛. All rights reserved.
//

#import "RepeatButton.h"

@implementation RepeatButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setProperty];
    }
    return self;
}

- (void)setProperty
{
    //self.layer.cornerRadius = 5.0 ;
    self.layer.borderWidth = 1.0 ;
    self.layer.borderColor = [UIColor lightGrayColor].CGColor ;
    self.clipsToBounds = YES ;

}
- (void)awakeFromNib
{
     [self setProperty];
}
@end
