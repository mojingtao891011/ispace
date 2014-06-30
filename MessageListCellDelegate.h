//
//  MessageListCellDelegate.h
//  iSpace
//
//  Created by CC on 14-5-22.
//  Copyright (c) 2014年 xiabing. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol MessageListCellDelegate <NSObject>

@optional
- (void)playMessageButtonDidTouch:(NSInteger)tag;
- (void)messageListCellDidLongPress:(NSInteger)tag;

@end
