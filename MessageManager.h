//
//  MessageManager.h
//  iSpace
//
//  Created by CC on 14-6-3.
//  Copyright (c) 2014年 xiabing. All rights reserved.
//

#import <Foundation/Foundation.h>


#define kMessageReaderStateClosed       0       // 消息阅读器关闭
#define kMessageReaderStateOpened       1       // 消息阅读器打开


@interface MessageManager : NSObject
{
    NSInteger _messageReaderState;          // 消息阅读器状态,默认关闭
    NSMutableDictionary *_deviceUnreadMessageCounter;   // 设备未读消息
}


+ (MessageManager *)defaultInstance;

- (void)start;
- (void)stop;

- (void)setMessageReaderState:(NSInteger )state;    // 设置消息阅读器状态
- (NSInteger)messageReaderState;                    // 返回消息阅读器状态

- (NSInteger)unreadMessageForDevice:(NSString *)deviceSerial;       // 返回某个设备的未读消息数量
- (void)incrementUnreadMessageForDevice:(NSString *)deviceSerial;   // 递增未读消息数量
- (void)resetUnreadMessageForDevice:(NSString *)deviceSerial;       // 复位某个设备的未读消息数量为0

- (BOOL)hasUnreadMessageForApp;                     // APP是否有未读消息

@end
