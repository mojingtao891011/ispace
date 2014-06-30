//
//  CoreDataManager.h
//  iSpace
//
//  Created by CC on 14-5-26.
//  Copyright (c) 2014年 xiabing. All rights reserved.
//

#import <Foundation/Foundation.h>


#define kiSpaceCoreDataEntityName        @"EventEntity"


@interface CoreDataManager : NSObject
{
    
}


@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (CoreDataManager *)defaultInstance;

- (void)saveContext;
- (void)deleteObject:(NSManagedObject *)object;
- (void)clearAllData;
- (void)deleteRecordOfDevice:(NSString *)deviceSerial andUser:(NSString *)userId;

@end
