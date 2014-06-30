//
//  NSDate+Additions.m
//  iSpace
//
//  Created by CC on 14-5-23.
//  Copyright (c) 2014年 xiabing. All rights reserved.
//

#import "NSDate+Additions.h"


@implementation NSDate (Additions)

+ (NSDate *)dateFromString:(NSString *)string withFormat:(NSString *)format
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone:[NSTimeZone localTimeZone]];
    [formatter setDateFormat:format];
    NSDate *date = [formatter dateFromString:string];
    return date;
}


- (NSUInteger)getYear
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSYearCalendarUnit;
    NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:self];
    NSUInteger year = dateComponent.year;
    
    return year;
}


- (NSUInteger)getMonth
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSMonthCalendarUnit;
    NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:self];
    NSUInteger month = dateComponent.month;
    
    return month;
}


- (NSUInteger)getDay
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSDayCalendarUnit;
    NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:self];
    NSUInteger day = dateComponent.day;
    
    return day;
}


- (NSUInteger)getHours
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSHourCalendarUnit;
    NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:self];
    NSUInteger hour = dateComponent.hour;
    
    return hour;
}


- (NSUInteger)getMinutes
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSSecondCalendarUnit;
    NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:self];
    NSUInteger second = dateComponent.second;
    
    return second;
}



@end
