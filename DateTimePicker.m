//
//  DateTimePicker.m
//  iSpace
//
//  Created by CC on 14-5-23.
//  Copyright (c) 2014年 xiabing. All rights reserved.
//

#import "DateTimePicker.h"
#import "NSDate+Additions.h"


typedef enum
{
    ePickerViewTagYear = 2012,
    ePickerViewTagMonth,
    ePickerViewTagDay,
    ePickerViewTagHour,
    ePickerViewTagMinute
} PickViewTag;


@interface DateTimePicker (Private)

// 创建数据源
- (void)createDataSource;

// create month Arrays

- (void)createMonthArrayWithYear:(NSInteger)yearInt month:(NSInteger)monthInt;

@end



@implementation DateTimePicker


#pragma mark -

- (void)dealloc
{
    self.delegate = nil;
}



#pragma mark -

- (void)awakeFromNib
{
    [self setBackgroundColor:[UIColor whiteColor]];
    
    NSMutableArray* tempArray1 = [[NSMutableArray alloc] initWithCapacity:0];
    NSMutableArray* tempArray2 = [[NSMutableArray alloc] initWithCapacity:0];
    NSMutableArray* tempArray3 = [[NSMutableArray alloc] initWithCapacity:0];
    NSMutableArray* tempArray4 = [[NSMutableArray alloc] initWithCapacity:0];
    NSMutableArray* tempArray5 = [[NSMutableArray alloc] initWithCapacity:0];
    
    [self setYearArray:tempArray1];
    [self setMonthArray:tempArray2];
    [self setDayArray:tempArray3];
    [self setHourArray:tempArray4];
    [self setMinuteArray:tempArray5];
    
    // 更新数据源
    [self createDataSource];
    
    int top = 4;
    int height = self.bounds.size.height;
    
    // 初始化各个视图
    UIPickerView* yearPickerTemp = [[UIPickerView alloc] initWithFrame:CGRectMake(0, top, 80, height)];
    [self setYearPicker:yearPickerTemp];
    [self.yearPicker setFrame:CGRectMake(0, top, 80, height)];
    
    UIPickerView* monthPickerTemp = [[UIPickerView alloc] initWithFrame:CGRectMake(81, top, 60, height)];
    [self setMonthPicker:monthPickerTemp];
    [self.monthPicker setFrame:CGRectMake(80, top, 61, height)];
    
    UIPickerView* dayPickerTemp = [[UIPickerView alloc] initWithFrame:CGRectMake(141, top, 60, height)];
    [self setDayPicker:dayPickerTemp];
    [self.dayPicker setFrame:CGRectMake(141, top, 59, height)];
    
    UIPickerView* hourPickerTemp = [[UIPickerView alloc] initWithFrame:CGRectMake(201, top, 60, height)];
    [self setHourPicker:hourPickerTemp];
    [self.hourPicker setFrame:CGRectMake(201, top, 60, height)];
    
    UIPickerView* minutesPickerTemp = [[UIPickerView alloc] initWithFrame:CGRectMake(261, top, 60, height)];
    [self setMinutePicker:minutesPickerTemp];
    [self.minutePicker setFrame:CGRectMake(261, top, 60, height)];
    
    [self.yearPicker setDataSource:self];
    [self.monthPicker setDataSource:self];
    [self.dayPicker setDataSource:self];
    [self.hourPicker setDataSource:self];
    [self.minutePicker setDataSource:self];
    [self.yearPicker setDelegate:self];
    [self.monthPicker setDelegate:self];
    [self.dayPicker setDelegate:self];
    [self.hourPicker setDelegate:self];
    [self.minutePicker setDelegate:self];
    
    [self.yearPicker setTag:ePickerViewTagYear];
    [self.monthPicker setTag:ePickerViewTagMonth];
    [self.dayPicker setTag:ePickerViewTagDay];
    [self.hourPicker setTag:ePickerViewTagHour];
    [self.minutePicker setTag:ePickerViewTagMinute];
    
    [self addSubview:self.yearPicker];
    [self addSubview:self.monthPicker];
    [self addSubview:self.dayPicker];
    [self addSubview:self.hourPicker];
    [self addSubview:self.minutePicker];
    
    [self.yearPicker setShowsSelectionIndicator:YES];
    [self.monthPicker setShowsSelectionIndicator:YES];
    [self.dayPicker setShowsSelectionIndicator:YES];
    [self.hourPicker setShowsSelectionIndicator:YES];
    [self.minutePicker setShowsSelectionIndicator:YES];
    
    [self resetDateToCurrentDate];


}

//- (id)initWithFrame:(CGRect)frame
//{
//    self = [super initWithFrame:CGRectMake(0, 0, 320, 260)];
//    
//    if (self)
//    {
//        // Initialization code
//        
//        [self setBackgroundColor:[UIColor blackColor]];
//        
//        NSMutableArray* tempArray1 = [[NSMutableArray alloc] initWithCapacity:0];
//        NSMutableArray* tempArray2 = [[NSMutableArray alloc] initWithCapacity:0];
//        NSMutableArray* tempArray3 = [[NSMutableArray alloc] initWithCapacity:0];
//        NSMutableArray* tempArray4 = [[NSMutableArray alloc] initWithCapacity:0];
//        NSMutableArray* tempArray5 = [[NSMutableArray alloc] initWithCapacity:0];
//        
//        [self setYearArray:tempArray1];
//        [self setMonthArray:tempArray2];
//        [self setDayArray:tempArray3];
//        [self setHourArray:tempArray4];
//        [self setMinuteArray:tempArray5];
//        
//        // 更新数据源
//        [self createDataSource];
//        
////        // 创建 toolBar & hintsLabel & enter button
////        
////        UIToolbar* tempToolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
////        
////        [self setToolBar:tempToolBar];
////        
////        [tempToolBar release];
////        
////        [self addSubview:self.toolBar];
////        
////        //        [toolBar setTintColor:[UIColor lightTextColor]];
////        
////        
////        
////        UILabel* tempHintsLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, 250, 34)];
////        
////        [self setHintsLabel:tempHintsLabel];
////        
////        [tempHintsLabel release];
////        
////        [self.hintsLabel setBackgroundColor:[UIColor clearColor]];
////        
////        [self addSubview:self.hintsLabel];
////        
////        [self.hintsLabel setFont:[UIFont systemFontOfSize:24.0f]];
////        
////        [self.hintsLabel setTextColor:[UIColor whiteColor]];
//        
//        
//        
//        
//        
////        UIButton* tempBtn = [UIButton buttonWithType:UIButtonTypeCustom];
////        
////        [tempBtn setBackgroundImage:[UIImage imageNamed:@"Resourse.bundle/btnNormal.png"] forState:UIControlStateNormal];
////        
////        [tempBtn setBackgroundImage:[UIImage imageNamed:@"Resourse.bundle/btnPressed.png"] forState:UIControlStateNormal];
////        
////        [tempBtn setTitle:@"确定" forState:UIControlStateNormal];
////        
////        [tempBtn sizeToFit];
////        
////        [self addSubview:tempBtn];
////        
////        [tempBtn setCenter:CGPointMake(320-15-tempBtn.frame.size.width*.5, 22)];
////        
////        [tempBtn addTarget:self action:@selector(actionEnter:) forControlEvents:UIControlEventTouchUpInside];
//        
//        
//        
//        
//        
//        // 初始化各个视图
//        UIPickerView* yearPickerTemp = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 44, 80, 216)];
//        [self setYearPicker:yearPickerTemp];
//        [self.yearPicker setFrame:CGRectMake(0, 44, 80, 216)];
//        
//        UIPickerView* monthPickerTemp = [[UIPickerView alloc] initWithFrame:CGRectMake(81, 44, 60, 216)];
//        [self setMonthPicker:monthPickerTemp];
//        [self.monthPicker setFrame:CGRectMake(80, 44, 61, 216)];
//        
//        UIPickerView* dayPickerTemp = [[UIPickerView alloc] initWithFrame:CGRectMake(141, 44, 60, 216)];
//        [self setDayPicker:dayPickerTemp];
//        [self.dayPicker setFrame:CGRectMake(141, 44, 59, 216)];
//        
//        UIPickerView* hourPickerTemp = [[UIPickerView alloc] initWithFrame:CGRectMake(201, 44, 60, 216)];
//        [self setHourPicker:hourPickerTemp];
//        [self.hourPicker setFrame:CGRectMake(201, 44, 60, 216)];
//        
//        UIPickerView* minutesPickerTemp = [[UIPickerView alloc] initWithFrame:CGRectMake(261, 44, 60, 216)];
//        [self setMinutePicker:minutesPickerTemp];
//        [self.minutePicker setFrame:CGRectMake(261, 44, 60, 216)];
//        
//        [self.yearPicker setDataSource:self];
//        [self.monthPicker setDataSource:self];
//        [self.dayPicker setDataSource:self];
//        [self.hourPicker setDataSource:self];
//        [self.minutePicker setDataSource:self];
//        [self.yearPicker setDelegate:self];
//        [self.monthPicker setDelegate:self];
//        [self.dayPicker setDelegate:self];
//        [self.hourPicker setDelegate:self];
//        [self.minutePicker setDelegate:self];
//        
//        [self.yearPicker setTag:ePickerViewTagYear];
//        [self.monthPicker setTag:ePickerViewTagMonth];
//        [self.dayPicker setTag:ePickerViewTagDay];
//        [self.hourPicker setTag:ePickerViewTagHour];
//        [self.minutePicker setTag:ePickerViewTagMinute];
//        
//        [self addSubview:self.yearPicker];
//        [self addSubview:self.monthPicker];
//        [self addSubview:self.dayPicker];
//        [self addSubview:self.hourPicker];
//        [self addSubview:self.minutePicker];
//        
//        [self.yearPicker setShowsSelectionIndicator:YES];
//        [self.monthPicker setShowsSelectionIndicator:YES];
//        [self.dayPicker setShowsSelectionIndicator:YES];
//        [self.hourPicker setShowsSelectionIndicator:YES];
//        [self.minutePicker setShowsSelectionIndicator:YES];
//
//        [self resetDateToCurrentDate];
//    }
//    
//    return self;
//}


#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}


//- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component{

//    if (ePickerViewTagYear ==  pickerView.tag) {

//        return 60.0f;

//    } else {

//        return 40.0f;

//    }

//}



- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (ePickerViewTagYear == pickerView.tag)
    {
        return [self.yearArray count];
    }
    
    if (ePickerViewTagMonth == pickerView.tag)
    {
        return [self.monthArray count];
    }
    
    if (ePickerViewTagDay == pickerView.tag)
    {
        return [self.dayArray count];
    }
    
    if (ePickerViewTagHour == pickerView.tag)
    {
        return [self.hourArray count];
    }
    
    if (ePickerViewTagMinute == pickerView.tag)
    {
        return [self.minuteArray count];
    }
    
    return 0;
}


#pragma makr - UIPickerViewDelegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (ePickerViewTagYear == pickerView.tag)
    {
        return [self.yearArray objectAtIndex:row];
    }

    if (ePickerViewTagMonth == pickerView.tag)
    {
        return [self.monthArray objectAtIndex:row];
    }

    if (ePickerViewTagDay == pickerView.tag)
    {
        return [self.dayArray objectAtIndex:row];
    }
    
    if (ePickerViewTagHour == pickerView.tag)
    {
        return [self.hourArray objectAtIndex:row];
    }
    
    if (ePickerViewTagMinute == pickerView.tag)
    {
        return [self.minuteArray objectAtIndex:row];
    }
    
    return @"";
}


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (ePickerViewTagYear == pickerView.tag)
    {
        self.yearValue = [[self.yearArray objectAtIndex:row] intValue];
        
    }
    else if(ePickerViewTagMonth == pickerView.tag)
    {
        self.monthValue = [[self.monthArray objectAtIndex:row] intValue];
        
    }
    else if(ePickerViewTagDay == pickerView.tag)
    {
        self.dayValue = [[self.dayArray objectAtIndex:row]intValue];
        
    }
    else if(ePickerViewTagHour == pickerView.tag)
    {
        self.hourValue = [[self.hourArray objectAtIndex:row]intValue];
        
    }
    else if(ePickerViewTagMinute == pickerView.tag)
    {
        self.minuteValue = [[self.minuteArray objectAtIndex:row] intValue];
    }
    
    if (ePickerViewTagMonth == pickerView.tag || ePickerViewTagYear == pickerView.tag)
    {
        [self createMonthArrayWithYear:self.yearValue month:self.monthValue];
        [self.dayPicker reloadAllComponents];
    }
    
    NSString* str = [NSString stringWithFormat:@"%04tu%02tu%02tu%02tu%02tu", self.yearValue, self.monthValue, self.dayValue, self.hourValue, self.minuteValue];
    [self setDate:[NSDate dateFromString:str withFormat:@"yyyyMMddHHmm"]];
}


#pragma mark - 年月日闰年＝情况分析


// 创建数据源
- (void)createDataSource
{
    // 年
    NSInteger yearInt = [[NSDate date] getYear];
    [self.yearArray removeAllObjects];
    for (NSUInteger i = yearInt; i <= yearInt + 5; i++)
    {
        [self.yearArray addObject:[NSString stringWithFormat:@"%tu", i]];
    }
    
    // 月
    [self.monthArray removeAllObjects];
    for (int i=1; i<=12; i++)
    {
        [self.monthArray addObject:[NSString stringWithFormat:@"%d",i]];
    }
    
    NSInteger month = [[NSDate date] getMonth];
    [self createMonthArrayWithYear:yearInt month:month];
    
    // 时
    [self.hourArray removeAllObjects];
    for(int i=0; i<24; i++)
    {
        [self.hourArray addObject:[NSString stringWithFormat:@"%02d",i]];
    }
    
    // 分
    [self.minuteArray removeAllObjects];
    for(int i=0; i<60; i++)
    {
        [self.minuteArray addObject:[NSString stringWithFormat:@"%02d",i]];
    }
}

#pragma mark -

-(void)resetDateToCurrentDate
{
    NSDate* nowDate = [NSDate date];
    
    [self.yearPicker selectRow:0 inComponent:0 animated:YES];
    [self.monthPicker selectRow:[nowDate getMonth]-1 inComponent:0 animated:YES];
    [self.dayPicker selectRow:[nowDate getDay]-1 inComponent:0 animated:YES];
    [self.hourPicker selectRow:[nowDate getHours] inComponent:0 animated:YES];
    [self.minutePicker selectRow:[nowDate getMinutes] inComponent:0 animated:YES];
    
    [self setYearValue:[nowDate getYear]];
    [self setMonthValue:[nowDate getMonth]];
    [self setDayValue:[nowDate getDay]];
    [self setHourValue:[nowDate getHours]];
    [self setMinuteValue:[nowDate getMinutes]];
    
    NSString* str = [NSString stringWithFormat:@"%04d%02d%02d%02d%02d",self.yearValue, self.monthValue, self.dayValue, self.hourValue, self.minuteValue];
    [self setDate:[NSDate dateFromString:str withFormat:@"yyyyMMddHHmm"]];
}


#pragma mark - 

- (void)createMonthArrayWithYear:(NSInteger)yearInt month:(NSInteger)monthInt
{
    int endDate = 0;
    
    switch (monthInt)
    {
        case 1:
        case 3:
        case 5:
        case 7:
        case 8:
        case 10:
        case 12:
            endDate = 31;
            break;
        case 4:
        case 6:
        case 9:
        case 11:
            endDate = 30;
            break;
        case 2:
            // 是否为闰年
            if (yearInt % 400 == 0)
            {
                endDate = 29;
                
            }
            else
            {
                if (yearInt % 100 != 0 && yearInt %4 ==4)
                {
                    endDate = 29;
                }
                else
                {
                    endDate = 28;
                }
            }
            break;
        default:
            break;
    }
    
    if (self.dayValue > endDate)
    {
        self.dayValue = endDate;
    }
    
    // 日
    [self.dayArray removeAllObjects];
    for (int i=1; i<=endDate; i++)
    {
        [self.dayArray addObject:[NSString stringWithFormat:@"%d",i]];
    }
}


#pragma mark - 点击确定按钮

- (IBAction)actionEnter:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(DateTimePickerDelegateEnterActionWithDataPicker:)])
    {
        [self.delegate DateTimePickerDelegateEnterActionWithDataPicker:self];
    }
}


#pragma mark - 设置提示信息

-(void)setHintsText:(NSString*)hints
{
    [self.hintsLabel setText:hints];
}


#pragma mark -

-(void)removeFromSuperview
{
    self.delegate = nil;
    
    [super removeFromSuperview];
}

@end
