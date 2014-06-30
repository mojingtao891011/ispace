//
//  WWXSRequest.h
//  MJTNet
//
//  Created by 莫景涛 on 14-4-30.
//  Copyright (c) 2014年 莫景涛. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^FinishLoadBlock)(NSData*);
typedef void (^FailedLoadBlock)();


@interface NetRequest : NSMutableURLRequest<NSURLConnectionDelegate>

@property(nonatomic , retain)NSMutableData *data ;
@property(nonatomic , retain)NSURLConnection *connection ;
@property(nonatomic , copy) FinishLoadBlock block ;
@property(nonatomic , copy) FailedLoadBlock failedBlock ;
@property(nonatomic , retain)UIViewController *showWaitActivityCtl ;

- (void)startAsynrc:(BOOL)isWaitActivity AndWaitActivityTitle:(NSString*) waitTitle andViewCtl:(UIViewController*)viewCtl;

@end
