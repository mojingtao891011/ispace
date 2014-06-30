//
//  iSpaceApp.h
//  iSpace
//
//  Created by CC on 14-5-26.
//  Copyright (c) 2014年 xiabing. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface iSpaceApp : NSObject
{
}

@property (nonatomic, assign) BOOL isLogined;               // 是否已经登录
@property (nonatomic, assign) BOOL isRecordRingChanged;     // 录音文件改变

+ (iSpaceApp *)defaultInstance;

- (void)initApp;
- (void)uninitApp;
- (void)start;
- (void)stop;
- (void)pause;
- (void)resume;

// 用户是否第一次使用
- (BOOL)isFirstUseOnPhone;
- (void)setAlreadyUsedOnPhone;

@end
