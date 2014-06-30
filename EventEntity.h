//
//  EventEntity.h
//  iSpace
//
//  Created by CC on 14-6-26.
//  Copyright (c) 2014年 莫景涛. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


#define kEventFromSystem        1
#define kEventFromApp           2
#define kEventFromDevice        3


@interface EventEntity : NSManagedObject

@property (nonatomic, retain) NSString * alarm_description;
@property (nonatomic, retain) NSNumber * alarm_index;
@property (nonatomic, retain) NSNumber * alarm_result;
@property (nonatomic, retain) NSNumber * alarm_state;
@property (nonatomic, retain) NSString * alarm_timestamp;
@property (nonatomic, retain) NSData * audio_amr_data;
@property (nonatomic, retain) NSString * audio_duration;
@property (nonatomic, retain) NSNumber * audio_readed;
@property (nonatomic, retain) NSNumber * audio_saved;
@property (nonatomic, retain) NSNumber * audio_sended;
@property (nonatomic, retain) NSString * audio_url;
@property (nonatomic, retain) NSData * audio_wav_data;
@property (nonatomic, retain) NSString * event_device;
@property (nonatomic, retain) NSString * event_id;
@property (nonatomic, retain) NSNumber * event_timestamp;
@property (nonatomic, retain) NSNumber * event_type;
@property (nonatomic, retain) NSString * event_user_id;
@property (nonatomic, retain) NSString * audio_file_id;

@end
