//
//  DateTimePicker.h
//  iSpace
//
//  Created by CC on 14-5-23.
//  Copyright (c) 2014年 xiabing. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DateTimePickerDelegate;


@interface DateTimePicker : UIView <UIPickerViewDataSource,UIPickerViewDelegate>
{
    
}

@property (nonatomic, retain) UIPickerView* yearPicker;     // 年
@property (nonatomic, retain) UIPickerView* monthPicker;    // 月
@property (nonatomic, retain) UIPickerView* dayPicker;      // 日
@property (nonatomic, retain) UIPickerView* hourPicker;     // 时
@property (nonatomic, retain) UIPickerView* minutePicker;   // 分

@property (nonatomic, retain) NSDate*   date;       // 当前date
@property (nonatomic, retain) UIToolbar*    toolBar;        // 工具条
@property (nonatomic, retain) UILabel*      hintsLabel;     // 提示信息
@property (nonatomic, retain) NSMutableArray* yearArray;
@property (nonatomic, retain) NSMutableArray* monthArray;
@property (nonatomic, retain) NSMutableArray* dayArray;
@property (nonatomic, retain) NSMutableArray* hourArray;
@property (nonatomic, retain) NSMutableArray* minuteArray;

@property (nonatomic, assign) NSUInteger yearValue;
@property (nonatomic, assign) NSUInteger monthValue;
@property (nonatomic, assign) NSUInteger dayValue;
@property (nonatomic, assign) NSUInteger hourValue;
@property (nonatomic, assign) NSUInteger minuteValue;


// 设置默认值为当前时间
-(void)resetDateToCurrentDate;

// 设置提示信息
-(void)setHintsText:(NSString*)hints;

@property (nonatomic, assign) id<DateTimePickerDelegate> delegate;

@end



// DateTimePickerDelegate
@protocol DateTimePickerDelegate <NSObject>

// 点击确定后的事件
@optional

-(void)DateTimePickerDelegateEnterActionWithDataPicker:(DateTimePicker*)picker;

@end


