//
//  PushNotificationManager.h
//  iSpace
//
//  Created by CC on 14-5-10.
//  Copyright (c) 2014年 xiabing. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface APNSManager : NSObject
{
}

+ (APNSManager *)defaultInstance;

- (void)initAPNSManager;
- (void)uninitAPNSManager;

@end
