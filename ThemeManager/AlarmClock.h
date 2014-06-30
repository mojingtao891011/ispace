//
//  Clock.h
//  testClock
//
//  Created by 莫景涛 on 14-4-5.
//  Copyright (c) 2014年 莫景涛. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface AlarmClock : UIButton
{
    UIColor *_borderColor ;
}
@property (nonatomic, retain) NSCalendar *calendar;

@property (nonatomic, retain) NSDate *time;

- (id)initWithFrame:(CGRect)frame andColor:(UIColor*)color andDate:(NSDate*)date;

@end
