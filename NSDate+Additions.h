//
//  NSDate+Additions.h
//  iSpace
//
//  Created by CC on 14-5-23.
//  Copyright (c) 2014年 xiabing. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Additions)

+ (NSDate *)dateFromString:(NSString *)string withFormat:(NSString *)format;

- (NSUInteger)getYear;
- (NSUInteger)getMonth;
- (NSUInteger)getDay;
- (NSUInteger)getHours;
- (NSUInteger)getMinutes;

@end
