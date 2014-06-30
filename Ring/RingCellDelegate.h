//
//  RingCellDelegate.h
//  iSpace
//
//  Created by CC on 14-6-12.
//  Copyright (c) 2014年 xiabing. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol RingCellDelegate <NSObject>

@optional
- (void)playRingAtIndexPath:(NSIndexPath *)indexPath;
- (void)pauseRingAtIndexPath:(NSIndexPath *)indexPath;
- (void)stopRingAtIndexPath:(NSIndexPath *)indexPath;
- (void)downloadRingAtIndexPath:(NSIndexPath *)indexPath;

- (void)loadMoreItemAtIndexPath:(NSIndexPath *)indexPath;       // 加载更多项
- (void)refreshFMAtIndexPath:(NSIndexPath *)indexPath;          // 刷新FM
- (void)startRecordAtIndexPath:(NSIndexPath *)indexPath;        // 开始录音

- (void)deleteItemAtIndexPath:(NSIndexPath *)indexPath;         // 删除按钮
- (void)moreActionAtIndexPath:(NSIndexPath *)indexPath;         // 更多按钮

- (void)importLocalMusicAtIndexPath:(NSIndexPath *)indexPath;   // 导入本地音乐

@end
