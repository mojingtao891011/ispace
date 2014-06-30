//
//  HttpAsyncSocket.m
//  iSpace
//
//  Created by CC on 14-5-19.
//  Copyright (c) 2014年 xiabing. All rights reserved.
//

#import "MessageReceiver.h"
#import "Constants.h"
#import "NSDictionary+Additions.h"


#define kHeartPackageTag        0x100
#define kReadPackageTag         0x200

#define kIntervalOfHeartTimer   60                  // 秒


static MessageReceiver *_defaultInstance = nil;


@interface MessageReceiver ()

@end


@implementation MessageReceiver

+ (MessageReceiver *)defaultInstance
{
	@synchronized(self)
	{
		if (_defaultInstance == nil)
		{
			_defaultInstance = [[MessageReceiver alloc] initWithHost:kHostOfPush andPort:kPortOfPush];
		}
	}
	return _defaultInstance;
}


- (id)initWithHost:(NSString *)host andPort:(NSInteger)port
{
    self = [super init];
    if (self)
    {
        _host = host;
        _port = port;
        _dataOfReceived = [[NSMutableData alloc] initWithCapacity:1024*4];
    }
    
    return self;
}


// 连接到服务器
- (void)connectToHost
{
    NSError *error = nil;
    _asyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
	if (![_asyncSocket connectToHost:_host onPort:_port error:&error])
	{
        NSLog(@"Cannot connect to server");
    }
    else
    {
        NSLog(@"Connecting to server...");
    }
}


// 返回连接状态
- (BOOL)isConnected
{
    return _isConnected;
}


// 断开连接
- (void)disconnect
{
    _asyncSocket.delegate = nil;
    _asyncSocket = nil;
    _isConnected = FALSE;
}


// 启动接收器
- (void)start
{
    if (_isStarted)
    {
        return;
    }
    
    _isStarted = TRUE;
    [self connectToHost];
    [self startHeartTimer];
}


// 关闭接收器
- (void)stop
{
    if (_isConnected)
    {
        _asyncSocket.delegate = nil;
        [_asyncSocket disconnect];
        _asyncSocket = nil;
        _isConnected = FALSE;
    }
    
    _isStarted = FALSE;
    _isSendingHeartPackage = FALSE;
    _isReadingPackage = FALSE;
    
    [self stopHeartTimer];
}


// 读包
- (void)readPackage
{
    if (_isStarted &&
        _isConnected &&
        !_isReadingPackage)
    {
        [_asyncSocket readDataWithTimeout:-1 tag:kReadPackageTag];
        _isReadingPackage = TRUE;
    }
}


#pragma mark - 心跳包处理

// 启动发送心跳包定时器
- (void)startHeartTimer
{
    if (!_heartTimer)
    {
        _heartTimer = [NSTimer scheduledTimerWithTimeInterval:kIntervalOfHeartTimer
                                                       target:self
                                                     selector:@selector(handleHeartTimer:)
                                                     userInfo:nil
                                                      repeats:TRUE];
    }
}


// 停止心跳定时器
- (void)stopHeartTimer
{
    if (_heartTimer)
    {
        [_heartTimer invalidate];
        _heartTimer = nil;
    }
}


// 定时发送心跳定
- (void)handleHeartTimer:(NSTimer *)aTimer
{
    if (_isStarted &&
        !_isSendingHeartPackage)
    {
        if (_isConnected)
        {
            [self performSelectorOnMainThread:@selector(sendHeartPackage) withObject:nil waitUntilDone:FALSE];
        }
        else
        {
            [self connectToHost];
        }
    }
}


// 发送心跳包到服务器
- (void)sendHeartPackage
{
    _isSendingHeartPackage = TRUE;

    NSMutableDictionary *msgHeader = [[NSMutableDictionary alloc] initWithCapacity:6];
    [msgHeader setObject:@"0" forKey:@"flag"];
    [msgHeader setObject:@"1" forKey:@"protocol"];
    [msgHeader setObject:@"0" forKey:@"sequence"];
    [msgHeader setObject:@"0" forKey:@"timestamp"];
    [msgHeader setObject:@"16000" forKey:@"command"];
    [msgHeader setObject:USER_ID forKey:@"user_id"];
    
    NSMutableDictionary *bodyDict = [[NSMutableDictionary alloc] init];
    [bodyDict setObject:msgHeader forKey:@"message_head"];
    [bodyDict setObject:@"" forKey:@"message_body"];
    
    // 转字典为JSON字符串
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:bodyDict
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    NSString *body = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    // 组HTTP协议
    NSMutableString *headers = [[NSMutableString alloc] initWithCapacity:0];
    [headers appendString:@"POST /iSpaceSvr/ios HTTP/1.1\r\n"];
    [headers appendFormat:@"HOST: %@:%zd\r\n", _host, _port];
    [headers appendFormat:@"Content-Length:%tu\r\n", [body length]];
    [headers appendString:@"Content-Type: application/json\r\n"];

    NSMutableString *package = [[NSMutableString alloc] initWithCapacity:0];
    [package appendString:headers];
    [package appendString:@"\r\n"];
    [package appendString:body];
    
    NSData *dataForSend = [package dataUsingEncoding:NSUTF8StringEncoding];

    [_asyncSocket writeData:dataForSend withTimeout:-1 tag:kHeartPackageTag];
}


#pragma mark - <GCDAsyncSocketDelegate> Functions

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
    _isConnected = TRUE;
    [self sendHeartPackage];
    [self readPackage];
    
    NSLog(@"connected");
}


- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    _isConnected = FALSE;
    _asyncSocket.delegate = nil;
    _asyncSocket = nil;
    _isReadingPackage = FALSE;
    _isSendingHeartPackage = FALSE;
    
    NSLog(@"disconnected:%@", err);
}



// 发送数据通知
- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    if (tag == kHeartPackageTag)
    {
        _isSendingHeartPackage = FALSE;
        NSLog(@"Did Send Heart Package");
    }
}


// 接收到数据通知
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    _isReadingPackage = FALSE;

    if (tag == kReadPackageTag)
    {
        [_dataOfReceived appendData:data];
    
        NSString *httpMessage = [[NSString alloc] initWithData:_dataOfReceived encoding:NSUTF8StringEncoding];
        NSString *messageBody = [self messageBody:httpMessage];
        if (messageBody)
        {
            [self handleMessage:messageBody];
        }

        [self readPackage];         // 循环读取
    }
}



#pragma mark - 辅助函数

// 如果是完整的消息，则返回消息体，否则返回nil
- (NSString *)messageBody:(NSString *)httpMessage
{
    NSArray *msgTokens = [httpMessage componentsSeparatedByString:@"\r\n\r\n"];
    if ([msgTokens count] < 2)      // 一个完整的Http消息应该包括头和体两部分
    {
        return nil;
    }
    
    // 找出Content-Length长度值
    NSInteger contentLength = -1;
    NSArray *headerTokens = [[msgTokens objectAtIndex:0] componentsSeparatedByString:@"\r\n"];
    for (NSString *line in headerTokens)
    {
        NSArray *tokens = [line componentsSeparatedByString:@":"];
        if ([tokens count] >= 2 &&
            [[tokens objectAtIndex:0] isEqualToString:@"Content-Length"])
        {
            contentLength = [[tokens objectAtIndex:1] integerValue];
        }
    }
    
    // 消息体的长度应该大于或等于Content-Length的长度
    if (contentLength != -1 &&
        [[msgTokens objectAtIndex:1] length] < contentLength)
    {
        return nil;
    }
    
    // 清除该部分的缓存数据
    NSRange range = NSMakeRange(0, [[msgTokens objectAtIndex:0] length] + [@"\r\n\r\n" length] + contentLength);
    [_dataOfReceived replaceBytesInRange:range withBytes:NULL length:0];
    
    NSString *httpMessageBody = [[msgTokens objectAtIndex:1] substringToIndex:contentLength];       // 要返回的字符串
    return httpMessageBody;
}


// 处理接收到的消息
- (void)handleMessage:(NSString *)message
{
    NSError *error = nil;
    NSData *messageData = [message dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *messageDict = [NSJSONSerialization JSONObjectWithData:messageData
                                                                options:NSJSONReadingMutableContainers
                                                                  error:&error];
    NSDictionary *msgHead = [messageDict getDictionary:@"message_head"];
    NSInteger command = [msgHead getInteger:@"command"] & ~0x80000000;
    if (command == 16000)             // 心跳
    {
        // 心跳回复, 丢弃
    }
    else if (command == 2065)         // 权限变更通知
    {
        NSNotification *notification = [NSNotification notificationWithName:NM_SERVER_PUSH_MSG_2065
                                                                     object:nil
                                                                   userInfo:messageDict];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
    }
    else if (command == 2073)         // 好友变更消息
    {
        NSNotification *notification = [NSNotification notificationWithName:NM_SERVER_PUSH_MSG_2073
                                                                     object:nil
                                                                   userInfo:messageDict];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
    }
    else if (command == 2083)         // 服务器推送消息
    {
        NSNotification *notification = [NSNotification notificationWithName:NM_SERVER_PUSH_MSG_2083
                                                                     object:nil
                                                                   userInfo:messageDict];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
    }
}

@end
