//
//  MKNetWork.h
//  net
//
//  Created by 莫景涛 on 14-6-8.
//  Copyright (c) 2014年 莫景涛. All rights reserved.
//

#import <Foundation/Foundation.h>
#import"MKNetworkOperation.h"

typedef void (^NetworkFininshBlock)(id);
typedef void (^NetworkFailBlock)(id);

@interface MKNetWork : NSObject

@property(nonatomic , copy)NetworkFininshBlock fininshBlock ;
@property(nonatomic , copy)NetworkFailBlock failBlock ;
@property(nonatomic , copy)MKNetworkOperation *operation ;

+ (MKNetWork*)shareMannger ;

- (void)cancelNetwork;

- (void)startNetworkWithNeedCommand:(NSString*)command andNeedUserId:(NSString*)userId AndNeedBobyArrKey:(NSArray*)bobyArrkey andNeedBobyArrValue:(NSArray*)bobyArrValue needCacheData:(BOOL)isCache needFininshBlock:(NetworkFininshBlock)fininshBlock needFailBlock:(NetworkFailBlock)failBlock;
//上传
- (void)startPostFileToHostName:(NSString*)hostName andServerPath:(NSString*)serverPath andFileName:(NSString*)fileName andFilePath:(NSString*)filePath andPostFininshBlock:(NetworkFininshBlock)postFininshBlock andPostFailBlock:(NetworkFailBlock)postFailBlock;

- (void)test:(NSString*)urlStr andPath:(NSString*)path ;
@end
