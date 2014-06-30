//
//  HomecViewController.h
//  Home
//
//  Created by bear on 14-5-11.
//  Copyright (c) 2014年 莫景涛. All rights reserved.
//

#import "RBCustomDatePickerView.h"

@interface RBCustomDatePickerView()
{
    UIView                      *timeBroadcastView;//定时播放显示视图
    MXSCycleScrollView          *yearScrollView;//年份滚动视图
    MXSCycleScrollView          *monthScrollView;//月份滚动视图
    MXSCycleScrollView          *dayScrollView;//日滚动视图
    MXSCycleScrollView          *hourScrollView;//时滚动视图
    MXSCycleScrollView          *minuteScrollView;//分滚动视图
    MXSCycleScrollView          *secondScrollView;//秒滚动视图
   
}
@end

@implementation RBCustomDatePickerView

- (id)initWithFrame:(CGRect)frame andTime:(NSString*)time
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.curTime = time ;
        [self setTimeBroadcastView:frame andTime:time];
    }
    return self;
}

#pragma mark -custompicker
//设置自定义datepicker界面
- (void)setTimeBroadcastView:(CGRect)frame andTime:(NSString*)time;
{
    NSString *dateString = nil ;
    if (time != nil) {
        
        NSString *timeStr = [[NSString alloc]stringFromFomate:[NSDate date] formate:@"yyyyMMddHHmmss"];
        NSMutableString *mutableStr = [NSMutableString stringWithFormat:@"%@" , timeStr];
        [mutableStr replaceCharactersInRange:NSMakeRange(8, 4) withString:time];
        [mutableStr replaceCharactersInRange:NSMakeRange(10, 1) withString:@""];
        dateString = [mutableStr copy];
       
    }else {
        NSDate *now = [NSDate date];
         NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
        dateString = [dateFormatter stringFromDate:now];
    }
       
    NSString *weekString = [self fromDateToWeek:dateString];
    NSInteger monthInt = [dateString substringWithRange:NSMakeRange(4, 2)].integerValue;
    NSInteger dayInt = [dateString substringWithRange:NSMakeRange(6, 2)].integerValue;
    
    self.selectTimeString = [NSString stringWithFormat:@" %@:%@",[dateString substringWithRange:NSMakeRange(8, 2)],[dateString substringWithRange:NSMakeRange(10, 2)]];
    
    
    self.selectTimeSet = @[ [dateString substringWithRange:NSMakeRange(0, 4)] , [NSNumber numberWithInteger:monthInt] , [NSNumber numberWithInteger:dayInt] , weekString , [dateString substringWithRange:NSMakeRange(8, 2)],[dateString substringWithRange:NSMakeRange(10, 2)],[dateString substringWithRange:NSMakeRange(12, 2)]];
    //NSLog(@">>%@" , self.selectTimeSet);
    
    timeBroadcastView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    timeBroadcastView.layer.masksToBounds = YES;
    [self addSubview:timeBroadcastView];
    
    UIView *beforeSepLine = [[UIView alloc] initWithFrame:CGRectMake(0, 73, frame.size.width, 1.5)];
    [beforeSepLine setBackgroundColor:RGBA(237.0, 237.0, 237.0, 1.0)];
    [timeBroadcastView addSubview:beforeSepLine];
    
//    UIView *middleSepView = [[UIView alloc] initWithFrame:CGRectMake(0, 75, frame.size.width, 38)];
//    [middleSepView setBackgroundColor:RGBA(249.0, 138.0, 20.0, 1.0)];//249.0, 138.0, 20.0, 1.0
//    [timeBroadcastView addSubview:middleSepView];
    
    UIView *bottomSepLine = [[UIView alloc] initWithFrame:CGRectMake(0, 114, frame.size.width, 1.5)];
    [bottomSepLine setBackgroundColor:RGBA(237.0, 237.0, 237.0, 1.0)];
    [timeBroadcastView addSubview:bottomSepLine];
    
    
}
//设置年月日时分的滚动视图
- (void)setYearScrollView:(CGFloat)pointX andPonitY:(CGFloat)pointY andWith:(CGFloat)with andHeight:(CGFloat)height
{
    yearScrollView = [[MXSCycleScrollView alloc] initWithFrame:CGRectMake(pointX , pointY, with, height)];
    NSInteger yearint = [self setNowTimeShow:0];
    [yearScrollView setCurrentSelectPage:(yearint-2002)];
    yearScrollView.delegate = self;
    yearScrollView.datasource = self;
    [self setAfterScrollShowView:yearScrollView andCurrentPage:1];
    [timeBroadcastView addSubview:yearScrollView];
}
//设置年月日时分的滚动视图
- (void)setMonthScrollView:(CGFloat)pointX andPonitY:(CGFloat)pointY andWith:(CGFloat)with andHeight:(CGFloat)height
{
    monthScrollView = [[MXSCycleScrollView alloc] initWithFrame:CGRectMake(pointX , pointY, with, height)];
    NSInteger monthint = [self setNowTimeShow:1];
    [monthScrollView setCurrentSelectPage:(monthint-3)];
    monthScrollView.delegate = self;
    monthScrollView.datasource = self;
    [self setAfterScrollShowView:monthScrollView andCurrentPage:1];
    [timeBroadcastView addSubview:monthScrollView];
}
//设置年月日时分的滚动视图
- (void)setDayScrollView:(CGFloat)pointX andPonitY:(CGFloat)pointY andWith:(CGFloat)with andHeight:(CGFloat)height
{
    dayScrollView = [[MXSCycleScrollView alloc] initWithFrame:CGRectMake(pointX , pointY, with, height)];
    NSInteger dayint = [self setNowTimeShow:2];
    [dayScrollView setCurrentSelectPage:(dayint-3)];
    dayScrollView.delegate = self;
    dayScrollView.datasource = self;
    [self setAfterScrollShowView:dayScrollView andCurrentPage:1];
    [timeBroadcastView addSubview:dayScrollView];
}
//设置年月日时分的滚动视图
- (void)setHourScrollView:(CGFloat)pointX andPonitY:(CGFloat)pointY andWith:(CGFloat)with andHeight:(CGFloat)height
{
    hourScrollView = [[MXSCycleScrollView alloc] initWithFrame:CGRectMake(pointX , pointY, with, height)];
    NSInteger hourint = [self setNowTimeShow:3];
    [hourScrollView setCurrentSelectPage:(hourint-2)];
    hourScrollView.delegate = self;
    hourScrollView.datasource = self;
    [self setAfterScrollShowView:hourScrollView andCurrentPage:1];
    [timeBroadcastView addSubview:hourScrollView];
}
//设置年月日时分的滚动视图
- (void)setMinuteScrollView:(CGFloat)pointX andPonitY:(CGFloat)pointY andWith:(CGFloat)with andHeight:(CGFloat)height
{
    minuteScrollView = [[MXSCycleScrollView alloc] initWithFrame:CGRectMake(pointX , pointY, with, height)];
    NSInteger minuteint = [self setNowTimeShow:4];
    [minuteScrollView setCurrentSelectPage:(minuteint-2)];
    minuteScrollView.delegate = self;
    minuteScrollView.datasource = self;
    [self setAfterScrollShowView:minuteScrollView andCurrentPage:1];
    [timeBroadcastView addSubview:minuteScrollView];
}
//设置年月日时分的滚动视图
- (void)setSecondScrollView:(CGFloat)pointX andPonitY:(CGFloat)pointY andWith:(CGFloat)with andHeight:(CGFloat)height
{
    secondScrollView = [[MXSCycleScrollView alloc] initWithFrame:CGRectMake(pointX , pointY, with, height)];
    NSInteger secondint = [self setNowTimeShow:5];
    [secondScrollView setCurrentSelectPage:(secondint-2)];
    secondScrollView.delegate = self;
    secondScrollView.datasource = self;
    [self setAfterScrollShowView:secondScrollView andCurrentPage:1];
    [timeBroadcastView addSubview:secondScrollView];
}
- (void)setAfterScrollShowView:(MXSCycleScrollView*)scrollview  andCurrentPage:(NSInteger)pageNumber
{
    UILabel *oneLabel = [[(UILabel*)[[scrollview subviews] objectAtIndex:0] subviews] objectAtIndex:pageNumber];
    [oneLabel setFont:[UIFont systemFontOfSize:14]];
    [oneLabel setTextColor:RGBA(186.0, 186.0, 186.0, 1.0)];
    UILabel *twoLabel = [[(UILabel*)[[scrollview subviews] objectAtIndex:0] subviews] objectAtIndex:pageNumber+1];
    [twoLabel setFont:[UIFont systemFontOfSize:16]];
    [twoLabel setTextColor:RGBA(113.0, 113.0, 113.0, 1.0)];
    
    UILabel *currentLabel = [[(UILabel*)[[scrollview subviews] objectAtIndex:0] subviews] objectAtIndex:pageNumber+2];
    [currentLabel setFont:[UIFont systemFontOfSize:22]];
    [currentLabel setTextColor:ORANGECOLOR];
    
    UILabel *threeLabel = [[(UILabel*)[[scrollview subviews] objectAtIndex:0] subviews] objectAtIndex:pageNumber+3];
    [threeLabel setFont:[UIFont systemFontOfSize:16]];
    [threeLabel setTextColor:RGBA(113.0, 113.0, 113.0, 1.0)];
    UILabel *fourLabel = [[(UILabel*)[[scrollview subviews] objectAtIndex:0] subviews] objectAtIndex:pageNumber+4];
    [fourLabel setFont:[UIFont systemFontOfSize:14]];
    [fourLabel setTextColor:RGBA(186.0, 186.0, 186.0, 1.0)];
}
#pragma mark mxccyclescrollview delegate
#pragma mark mxccyclescrollview databasesource
- (NSInteger)numberOfPages:(MXSCycleScrollView*)scrollView
{
    if (scrollView == yearScrollView) {
        return 99;
    }
    else if (scrollView == monthScrollView)
    {
        return 12;
    }
    else if (scrollView == dayScrollView)
    {
        return 31;
    }
    else if (scrollView == hourScrollView)
    {
        return 24;
    }
    else if (scrollView == minuteScrollView)
    {
        return 60;
    }
    return 60;
}

- (UIView *)pageAtIndex:(NSInteger)index andScrollView:(MXSCycleScrollView *)scrollView
{
    UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, scrollView.bounds.size.width, scrollView.bounds.size.height/5)];
    l.tag = index+1;
    if (scrollView == yearScrollView) {
        l.text = [NSString stringWithFormat:@"%d年",1900+index];
    }
    else if (scrollView == monthScrollView)
    {
        l.text = [NSString stringWithFormat:@"%d月",1+index];
    }
    else if (scrollView == dayScrollView)
    {
        l.text = [NSString stringWithFormat:@"%d日",1+index];
    }
    else if (scrollView == hourScrollView)
    {
      
        if (index < 10) {
            
                l.text = [NSString stringWithFormat:@"0%d",index];
            
        }
        else{
              l.text = [NSString stringWithFormat:@"%d",index];
        }
        
        
    }
    else if (scrollView == minuteScrollView)
    {
        if (index < 10) {
            l.text = [NSString stringWithFormat:@"0%d",index];
            
        }
        else
            l.text = [NSString stringWithFormat:@"%d",index];
    }
    else
        if (index < 10) {
            l.text = [NSString stringWithFormat:@"0%d",index];
        }
        else
            l.text = [NSString stringWithFormat:@"%d",index];
    
    l.font = [UIFont systemFontOfSize:12];
   // NSLog(@"....>>>%@" , l.text);
    l.textAlignment = NSTextAlignmentCenter;
    l.backgroundColor = [UIColor clearColor];
    //myCode
    if (scrollView.currentPage < 0) {
        scrollView.currentPage =  scrollView.currentPage + [self numberOfPages:scrollView];
    }
    if (index == -2) {
        l.text = [NSString stringWithFormat:@"%d",[self numberOfPages:scrollView]-2]; ;
    }

    return l;
}
//设置现在时间
- (NSInteger)setNowTimeShow:(NSInteger)timeType
{    
    
    NSString *dateString = nil ;
    if (time != nil) {
        
        NSString *timeStr = [[NSString alloc]stringFromFomate:[NSDate date] formate:@"yyyyMMddHHmmss"];
        NSMutableString *mutableStr = [NSMutableString stringWithFormat:@"%@" , timeStr];
        [mutableStr replaceCharactersInRange:NSMakeRange(8, 4) withString:self.curTime];
        [mutableStr replaceCharactersInRange:NSMakeRange(10, 1) withString:@""];
        dateString = [mutableStr copy];
        
    }else {
        NSDate *now = [NSDate date];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
        dateString = [dateFormatter stringFromDate:now];
    }

    
    switch (timeType) {
        case 0:
        {
            NSRange range = NSMakeRange(0, 4);
            NSString *yearString = [dateString substringWithRange:range];
            return yearString.integerValue;
        }
            break;
        case 1:
        {
            NSRange range = NSMakeRange(4, 2);
            NSString *yearString = [dateString substringWithRange:range];
            return yearString.integerValue;
        }
            break;
        case 2:
        {
            NSRange range = NSMakeRange(6, 2);
            NSString *yearString = [dateString substringWithRange:range];
            return yearString.integerValue;
        }
            break;
        case 3:
        {
            NSRange range = NSMakeRange(8, 2);
            NSString *yearString = [dateString substringWithRange:range];
            return yearString.integerValue;
        }
            break;
        case 4:
        {
            NSRange range = NSMakeRange(10, 2);
            NSString *yearString = [dateString substringWithRange:range];
            return yearString.integerValue;
        }
            break;
        case 5:
        {
            NSRange range = NSMakeRange(12, 2);
            NSString *yearString = [dateString substringWithRange:range];
            return yearString.integerValue;
        }
            break;
        default:
            break;
    }
    return 0;
}
//滚动时上下标签显示(当前时间和是否为有效时间)
- (void)scrollviewDidChangeNumber
{
    UILabel *yearLabel = [[(UILabel*)[[yearScrollView subviews] objectAtIndex:0] subviews] objectAtIndex:3];
    UILabel *monthLabel = [[(UILabel*)[[monthScrollView subviews] objectAtIndex:0] subviews] objectAtIndex:3];
    UILabel *dayLabel = [[(UILabel*)[[dayScrollView subviews] objectAtIndex:0] subviews] objectAtIndex:3];
    UILabel *hourLabel = [[(UILabel*)[[hourScrollView subviews] objectAtIndex:0] subviews] objectAtIndex:3];
    UILabel *minuteLabel = [[(UILabel*)[[minuteScrollView subviews] objectAtIndex:0] subviews] objectAtIndex:3];
    UILabel *secondLabel = [[(UILabel*)[[secondScrollView subviews] objectAtIndex:0] subviews] objectAtIndex:3];
    
    NSInteger yearInt = yearLabel.tag + 1999;
    NSInteger monthInt = monthLabel.tag;
    NSInteger dayInt = dayLabel.tag;
    NSInteger hourInt = hourLabel.tag - 1;
    NSInteger minuteInt = minuteLabel.tag - 1;
    NSInteger secondInt = secondLabel.tag - 1;
    
    self.selectTimeString = [NSString stringWithFormat:@"%02d:%02d",hourInt,minuteInt];
    
    self.selectTimeSet = @[ [NSNumber numberWithInteger:yearInt] ,  [NSNumber numberWithInteger:monthInt] , [NSNumber numberWithInteger:dayInt] , [NSNumber numberWithInteger:hourInt] , [NSNumber numberWithInteger:minuteInt] , [NSNumber numberWithInteger:secondInt] ];
    //NSLog(@">>>%@" , self.selectTimeString);
    
}
//通过日期求星期
- (NSString*)fromDateToWeek:(NSString*)selectDate
{
    NSInteger yearInt = [selectDate substringWithRange:NSMakeRange(0, 4)].integerValue;
    NSInteger monthInt = [selectDate substringWithRange:NSMakeRange(4, 2)].integerValue;
    NSInteger dayInt = [selectDate substringWithRange:NSMakeRange(6, 2)].integerValue;
    int c = 20;//世纪
    int y = yearInt -1;//年
    int d = dayInt;
    int m = monthInt;
    int w =(y+(y/4)+(c/4)-2*c+(26*(m+1)/10)+d-1)%7;
    NSString *weekDay = @"";
    switch (w) {
        case 0:
            weekDay = @"周日";
            break;
        case 1:
            weekDay = @"周一";
            break;
        case 2:
            weekDay = @"周二";
            break;
        case 3:
            weekDay = @"周三";
            break;
        case 4:
            weekDay = @"周四";
            break;
        case 5:
            weekDay = @"周五";
            break;
        case 6:
            weekDay = @"周六";
            break;
        default:
            break;
    }
    return weekDay;
}

@end
