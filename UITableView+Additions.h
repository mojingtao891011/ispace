//
//  UITableView+Additions.h
//  iSpace
//
//  Created by CC on 14-6-10.
//  Copyright (c) 2014年 xiabing. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableView (Additions)

// 隐藏UITableView多余的分割线
- (void)hideExtraSeparatorLine;

// 关闭iOS7下UITableView的分隔线自动缩进功能
- (void)closeSeparatorLineIndent;

@end
