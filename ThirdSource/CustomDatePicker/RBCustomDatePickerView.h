//
//  HomecViewController.h
//  Home
//
//  Created by bear on 14-5-11.
//  Copyright (c) 2014年 莫景涛. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MXSCycleScrollView.h"

@interface RBCustomDatePickerView : UIView <MXSCycleScrollViewDatasource,MXSCycleScrollViewDelegate>

@property(nonatomic , copy)NSString *selectTimeString ;
@property(nonatomic , retain)NSArray *selectTimeSet ;
@property(nonatomic , copy)NSString *curTime ;

- (id)initWithFrame:(CGRect)frame andTime:(NSString*)time ;
//设置年的滚动视图
- (void)setYearScrollView:(CGFloat)pointX andPonitY:(CGFloat)pointY andWith:(CGFloat)with andHeight:(CGFloat)height ;
//设置月的滚动视图
- (void)setMonthScrollView:(CGFloat)pointX andPonitY:(CGFloat)pointY andWith:(CGFloat)with andHeight:(CGFloat)height ;
//设置日的滚动视图
- (void)setDayScrollView:(CGFloat)pointX andPonitY:(CGFloat)pointY andWith:(CGFloat)with andHeight:(CGFloat)height ;
//设置时的滚动视图
- (void)setHourScrollView:(CGFloat)pointX andPonitY:(CGFloat)pointY andWith:(CGFloat)with andHeight:(CGFloat)height ;
//设置分的滚动视图
- (void)setMinuteScrollView:(CGFloat)pointX andPonitY:(CGFloat)pointY andWith:(CGFloat)with andHeight:(CGFloat)height ;
//设置秒的滚动视图
- (void)setSecondScrollView:(CGFloat)pointX andPonitY:(CGFloat)pointY andWith:(CGFloat)with andHeight:(CGFloat)height ;
@end
