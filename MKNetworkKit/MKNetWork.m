//
//  MKNetWork.m
//  net
//
//  Created by 莫景涛 on 14-6-8.
//  Copyright (c) 2014年 莫景涛. All rights reserved.
//

#import "MKNetWork.h"
#import "MKNetworkEngine.h"
#import "HandleRequestData.h"
#import "CacheHandle.h"

@implementation MKNetWork
+(MKNetWork*)shareMannger
{
    static MKNetWork *shareManager = nil ;
    static dispatch_once_t once ;
    dispatch_once(&once , ^{
        shareManager = [[self alloc]init];
    });
    return shareManager ;
}

- (void)cancelNetwork
{
    if (_operation != nil) {
        [_operation cancel];
    }
}
-  (void)startNetworkWithNeedCommand:(NSString*)command andNeedUserId:(NSString*)userId AndNeedBobyArrKey:(NSArray*)bobyArrkey andNeedBobyArrValue:(NSArray*)bobyArrValue needCacheData:(BOOL)isCache needFininshBlock:(NetworkFininshBlock)fininshBlock needFailBlock:(NetworkFailBlock)failBlock
{
    
    self.fininshBlock = ^(id result){
        fininshBlock(result);
    };
    self.failBlock = ^(id fail){
        failBlock(fail);
    };

    //请求头
    NSMutableArray *headKey = [NSMutableArray arrayWithObjects:@"flag" , @"protocol" , @"sequence" , @"timestamp" , @"command" , @"user_id" ,nil] ;
    NSMutableArray *headValue = [NSMutableArray arrayWithObjects:@"0" , @"1" , @"0" , @"0", command , userId , nil] ;
    NSMutableDictionary *headDic =[NSMutableDictionary dictionaryWithObjects:headValue forKeys:headKey];
    
    //请求体、把请求体的headKey和headValue装进字典里
    NSMutableDictionary *bobyDic =[NSMutableDictionary dictionaryWithObjects:bobyArrValue forKeys:bobyArrkey];
    //把请求体与 请求头装进字典里
    NSMutableDictionary *Dict =[[NSMutableDictionary alloc]init];
    [Dict setObject:headDic forKey:@"message_head"] ;
    [Dict setObject:bobyDic forKey:@"message_body"] ;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:Dict options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonstr = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    jsonstr = [jsonstr stringByReplacingOccurrencesOfString:@"\\/" withString:@"/"];
    
    NSDictionary *paramDict = [NSJSONSerialization JSONObjectWithData:[jsonstr dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
    
  ////////////////////////////////////////////////////////////////////////////////////////////////////
    //#define  SVR_URL  @"http://115.29.199.95:21000/iSpaceSvr/ios"//115.29.199.95:21000
    MKNetworkEngine* engine = [[MKNetworkEngine alloc] initWithHostName:HOSTNAME customHeaderFields:nil];
   // [engine useCache];
    
    _operation = [engine operationWithPath:@"/iSpaceSvr/ios" params:paramDict httpMethod:@"POST"];
    //operation.postDataEncoding = MKNKPostDataEncodingTypeJSON ;
    
    _operation.postDataEncoding = MKNKPostDataEncodingTypeCustom;
    
    [_operation setCustomPostDataEncodingHandler:^NSString *(NSDictionary *postDataDict) {
        return jsonstr;
    } forType:@"application/json"];

    
    [_operation addCompletionHandler:^(MKNetworkOperation *completedOperation)
     {
         NSString *responseString = [completedOperation responseJSON];
         
         [[HandleRequestData shareManager] handleDate:command andResult:responseString];
//         if (isCache) {
//             [CacheHandle saveCache:command andString:responseString];
//         }
     }errorHandler:^(MKNetworkOperation *errorOp, NSError* error) {
         UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:@"网络不给力" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
         [alertView show];
         failBlock(@"error");
     }];
    
       
    [engine enqueueOperation:_operation];

    
}
- (void)startPostFileToHostName:(NSString*)hostName andServerPath:(NSString*)serverPath andFileName:(NSString*)fileName andFilePath:(NSString*)filePath andPostFininshBlock:(NetworkFininshBlock)postFininshBlock andPostFailBlock:(NetworkFailBlock)postFailBlock
{

    MKNetworkEngine *engine = [[MKNetworkEngine alloc]initWithHostName:hostName];
    MKNetworkOperation *op = [engine operationWithPath:serverPath params:nil httpMethod:@"POST"];
    
    NSFileHandle *filehandle = [NSFileHandle fileHandleForReadingAtPath:filePath];
    NSData *data = [filehandle availableData];
    [op addData:data forKey:fileName];
    //[filehandle closeFile];
    [op addCompletionHandler:^(MKNetworkOperation *ope){
        
        NSDictionary *returnDict = [ope responseJSON];
        NSString *error = returnDict[@"message_body"][@"error"];
        if ([error isEqualToString:@"0"]) {
            NSString *file_url = returnDict[@"message_body"][@"url"];
            NSString *file_id = returnDict[@"message_body"][@"fileid"];
            NSArray *fileArr = @[file_url , file_id];
            postFininshBlock(fileArr);
        }
        else{
            postFininshBlock(error);
        }
    }errorHandler:^(MKNetworkOperation *errorOp , NSError *error){
        postFailBlock(error);
    }];
    [engine enqueueOperation:op];

}
#pragma mark 使用MKNetworkKit 上传图片和数据
- (void)test:(NSString*)urlStr andPath:(NSString*)path
{

    MKNetworkEngine* engine = [[MKNetworkEngine alloc]init];
    NSDictionary* postvalues = [NSDictionary dictionaryWithObjectsAndKeys:@"mknetwork",@"name",nil];
    MKNetworkOperation* op = [engine operationWithURLString:urlStr params:postvalues httpMethod:@"POST"];
    [op addFile:path forKey:@"img"];
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSLog(@"%@",completedOperation.responseString);
    }errorHandler:^(MKNetworkOperation *completedOperation,NSError *error) {
        NSLog(@"mknetwork error : %@",error.debugDescription);
    }];
    [engine enqueueOperation:op];
}
@end
