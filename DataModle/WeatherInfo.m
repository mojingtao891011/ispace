//
//  WeatherInfo.m
//  iSpace
//
//  Created by bear on 14-5-16.
//  Copyright (c) 2014年 莫景涛. All rights reserved.
//

#import "WeatherInfo.h"

@implementation WeatherInfo
+(WeatherInfo*)shareManager
{
    static WeatherInfo *shareManager = nil ;
    static dispatch_once_t once ;
    dispatch_once(&once , ^{
        shareManager = [[self alloc]init ];
    });
    return shareManager ;
}
- (void)creatWeatherModel:(id)result
{
    
    NSDictionary *dict = result[@"message_body"];
    NSString *error = dict[@"error"];
    if ([error isEqualToString:@"0"]) {
        WeatherInfo *model = [[WeatherInfo alloc]initWithDataDic:dict];
        [MKNetWork shareMannger].fininshBlock(model);
       
    }else{
        [MKNetWork shareMannger].fininshBlock(error);
        
    }
    
}
- (NSDictionary*)attributeMapDictionary
{
    NSDictionary *dict = @{
                           @"ac_temp" : @"ac_temp" ,
                           @"datetime" : @"datetime" ,
                           @"error" : @"error" ,
                           @"temp" : @"temp" ,
                           @"weather" : @"weather" ,
                           @"wind" : @"wind"
                           };
    
    return dict ;
}
- (void)setAttributes:(NSDictionary *)dataDic
{
    [super setAttributes:dataDic];
    //GTMBase64解密
    _temp = [[NSString alloc]decodeBase64:dataDic[@"temp"]];
    _wind = [[NSString alloc]decodeBase64:dataDic[@"wind"]];
    _ac_temp = [NSString stringWithFormat:@"%@℃",_ac_temp];
}
@end
