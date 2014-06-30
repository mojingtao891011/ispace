//
//  WWXSGetNetData.h
//  MJTNet
//
//  Created by 莫景涛 on 14-4-30.
//  Copyright (c) 2014年 莫景涛. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^completion)(id);
typedef void (^netfailed)();

@interface NetDataService : NSObject

+(NSMutableDictionary*)needCommand:(NSString*)command
                     andNeedUserId:(NSString*)userId
                 AndNeedBobyArrKey:(NSArray*)bobyArrkey
               andNeedBobyArrValue:(NSArray*)bobyArrValue  ;


+(void)requestWithUrl:(NSString *)urlString
           dictParams:(NSMutableDictionary *)dictparams
           httpMethod:(NSString *)httpMethod
    AndisWaitActivity:(BOOL)isWaitActivity
 AndWaitActivityTitle:(NSString*) waitTitle
           andViewCtl:(UIViewController*)viewCtl
        completeBlock:(completion)completionblock ;


+(void)requestWithUrl:(NSString *)urlStrings
             postData:(NSData*)data
           httpMethod:(NSString *)httpMethods
    AndisWaitActivity:(BOOL)isWaitActivitys
 AndWaitActivityTitle:(NSString*) waitTitles
          andViewCtls:(UIViewController*)viewCtl
        completeBlock:(completion)completionblocks;


// xiabing

+ (void)requestWithUrl:(NSString *)urlString
           dictParams:(NSMutableDictionary *)dictparams
           httpMethod:(NSString *)httpMethod
    andisWaitActivity:(BOOL)isWaitActivity
 andWaitActivityTitle:(NSString*) waitTitle
           andViewCtl:(UIViewController*)viewCtl
        isShowWaiting:(BOOL)waiting
          failedBlock:(netfailed)failedblock
        completeBlock:(completion)completionblock;

@end
