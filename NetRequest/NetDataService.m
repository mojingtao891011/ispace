//
//  WWXSGetNetData.m
//  MJTNet
//
//  Created by 莫景涛 on 14-4-30.
//  Copyright (c) 2014年 莫景涛. All rights reserved.
//

#import "NetDataService.h"
#import "NetRequest.h"

@implementation NetDataService


+(NSMutableDictionary*)needCommand:(NSString*)command andNeedUserId:(NSString*)userId AndNeedBobyArrKey:(NSArray*)bobyArrkey andNeedBobyArrValue:(NSArray*)bobyArrValue
{
    //请求头
    NSMutableArray *headKey = [NSMutableArray arrayWithObjects:@"flag" , @"protocol" , @"sequence" , @"timestamp" , @"command" , @"user_id" ,nil] ;
    NSMutableArray *headValue = [NSMutableArray arrayWithObjects:@"0" , @"1" , @"0" , @"0", command , userId , nil] ;
//    for (int i = 0; i < headValue.count; i++) {
//        NSLog(@"%@=====%@" , headKey[i] , headValue[i]);
//    }
    NSMutableDictionary *headDic =[NSMutableDictionary dictionaryWithObjects:headValue forKeys:headKey];
    
    //请求体、把请求体的headKey和headValue装进字典里
    NSMutableDictionary *bobyDic =[NSMutableDictionary dictionaryWithObjects:bobyArrValue forKeys:bobyArrkey];
    //NSLog(@"====%@" , bobyDic);
    //把请求体与 请求头装进字典里
    NSMutableDictionary *Dict =[[NSMutableDictionary alloc]init];
    [Dict setObject:headDic forKey:@"message_head"] ;
    [Dict setObject:bobyDic forKey:@"message_body"] ;
    
    return Dict ;
}

+ (void)requestWithUrl:(NSString *)urlString
            dictParams:(NSMutableDictionary *)dictparams
            httpMethod:(NSString *)httpMethod
     AndisWaitActivity:(BOOL)isWaitActivity
  AndWaitActivityTitle:(NSString*) waitTitle
            andViewCtl:(UIViewController*)viewCtl
         completeBlock:(completion)completionblock
{
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictparams options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonstr = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    jsonstr = [jsonstr stringByReplacingOccurrencesOfString:@"\\/" withString:@"/"];
    NSData *data = [jsonstr dataUsingEncoding:NSUTF8StringEncoding];
    
    NSURL *url = [NSURL URLWithString:urlString];
    NetRequest *request = [NetRequest requestWithURL:url];
    [request setHTTPMethod:httpMethod];
    [request setHTTPBody:data];
    [request setTimeoutInterval:60];
    request.block = ^(NSData *data){
        id result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        completionblock(result);
      
    };
    
    [request startAsynrc:isWaitActivity AndWaitActivityTitle:waitTitle andViewCtl:viewCtl];
}


//上传
+(void)requestWithUrl:(NSString *)urlStrings
             postData:(NSData*)data
           httpMethod:(NSString *)httpMethods
    AndisWaitActivity:(BOOL)isWaitActivitys
 AndWaitActivityTitle:(NSString*) waitTitles
          andViewCtls:(UIViewController*)viewCtl
        completeBlock:(completion)completionblocks
{
    NSURL *url = [NSURL URLWithString:urlStrings];
    NetRequest *request = [NetRequest requestWithURL:url];
    [request setHTTPMethod:httpMethods];
    [request setHTTPBody:data];
    [request setTimeoutInterval:60];
    request.block = ^(NSData *data){
        id result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        completionblocks(result);
        
    };
    [request startAsynrc:YES AndWaitActivityTitle:waitTitles andViewCtl:viewCtl];
}


// Xiabing
+ (void)requestWithUrl:(NSString *)urlString
           dictParams:(NSMutableDictionary *)dictparams
           httpMethod:(NSString *)httpMethod
    andisWaitActivity:(BOOL)isWaitActivity
 andWaitActivityTitle:(NSString*) waitTitle
           andViewCtl:(UIViewController*)viewCtl
        isShowWaiting:(BOOL)waiting
          failedBlock:(netfailed)failedblock
        completeBlock:(completion)completionblock
{
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictparams options:NSJSONWritingPrettyPrinted error:nil];
    
    NSURL *url = [NSURL URLWithString:urlString];
    NetRequest *request = [NetRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:jsonData];
    [request setTimeoutInterval:60];
    request.block = ^(NSData *data){
        id result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        completionblock(result);
        
    };
    request.failedBlock = ^() {
        if (failedblock)
        {
            failedblock();
        }
    };
    
    [request startAsynrc:waiting AndWaitActivityTitle:waitTitle andViewCtl:viewCtl];
    
}

@end
