//
//  WeatherInfo.h
//  iSpace
//
//  Created by bear on 14-5-16.
//  Copyright (c) 2014年 莫景涛. All rights reserved.
//

#import "WXBaseModel.h"

@interface WeatherInfo : WXBaseModel

@property (nonatomic , copy)NSString *ac_temp ;
@property (nonatomic , copy)NSString *datetime ;
@property (nonatomic , copy)NSString *error ;
@property (nonatomic , copy)NSString *temp ;
@property (nonatomic , copy)NSString *weather ;
@property (nonatomic , copy)NSString *wind ;

+(WeatherInfo*)shareManager ;
- (void)creatWeatherModel:(id)result ;

@end
