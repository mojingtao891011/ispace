//
//  HttpAsyncSocket.h
//  iSpace
//
//  Created by CC on 14-5-19.
//  Copyright (c) 2014年 xiabing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncSocket.h"


@protocol FileUploaderDelegate;


@interface MessageReceiver : NSObject
{
    NSMutableData *_dataOfReceived;     // 接收到的数据
    
    NSString *_host;
    NSInteger _port;
    GCDAsyncSocket *_asyncSocket;
    
    BOOL _isStarted;                // 是否已启动
    BOOL _isConnected;              // 是否已连接
    BOOL _isSendingHeartPackage;    // 是否正在发送心跳包
    BOOL _isReadingPackage;         // 是否正在读数据
    
    NSTimer *_heartTimer;           // 心跳包定时器

}

@property (weak, nonatomic) id <FileUploaderDelegate> delegate;

- (id)initWithHost:(NSString *)host andPort:(NSInteger)port;

- (void)start;
- (void)stop;

+ (MessageReceiver *)defaultInstance;

@end


// HttpAsyncSocketDelegate

@protocol FileUploaderDelegate <NSObject>

@optional

- (void)uploadFileSucceeded;
- (void)uploadFileFailed;

@end
