//
//  UITableView+Additions.m
//  iSpace
//
//  Created by CC on 14-6-10.
//  Copyright (c) 2014年 xiabing. All rights reserved.
//

#import "UITableView+Additions.h"

@implementation UITableView (Additions)

// 隐藏UITableView多余的分割线
- (void)hideExtraSeparatorLine
{
    UIView *view =[ [UIView alloc]init];
    view.backgroundColor = [UIColor clearColor];
    [self setTableFooterView:view];
    [self setTableHeaderView:view];
}


// 关闭iOS7下UITableView的分隔线自动缩进功能
- (void)closeSeparatorLineIndent
{
    if ([self respondsToSelector:@selector(setSeparatorInset:)])
    {
        self.separatorInset = UIEdgeInsetsZero;
    }
}

@end
