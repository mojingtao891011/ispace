//
//  RingTableViewCell.h
//  iSpace
//
//  Created by CC on 14-6-12.
//  Copyright (c) 2014年 xiabing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RingCellDelegate.h"


// 铃音类表格行样式
typedef NS_ENUM(NSInteger, RingListCellStyle)
{
    RingListCellStyleNormal,        // 正常状态
    RingListCellStylePlaying,       // 播放状态
    RingListCellStylePause          // 暂停状态
};


@interface RingTableViewCell : UITableViewCell
{
    
}

@property (copy, nonatomic) NSIndexPath *indexPath;
@property (weak, nonatomic) id <RingCellDelegate> delegate;

@end
