//
//  NSDictionary+Additions.m
//  iSpace
//
//  Created by CC on 14-6-6.
//  Copyright (c) 2014年 xiabing. All rights reserved.
//

#import "NSDictionary+Additions.h"

@implementation NSDictionary (Additions)


- (NSString *)getString:(NSString *)key
{
    NSString *value = [self valueForKey:key];
    return value;
}


- (NSNumber *)getNumber:(NSString *)key
{
    NSString *value = [self valueForKey:key];
    NSNumber *number = [NSNumber numberWithInteger:[value integerValue]];
    return number;
}


- (NSInteger)getInteger:(NSString *)key
{
    NSString *value = [self valueForKey:key];
    return [value integerValue];
}


- (NSDictionary *)getDictionary:(NSString *)key
{
    id value = [self valueForKey:key];
    if ([value isKindOfClass:[NSDictionary class]])
    {
        return value;
    }
    
    return nil;
}


- (NSArray *)getArray:(NSString *)key
{
    id value = [self valueForKey:key];
    if ([value isKindOfClass:[NSArray class]])
    {
        return value;
    }
    
    return nil;
}


@end
