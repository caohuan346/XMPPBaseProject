//
//  DBCenter.h
//  KuaiKuai
//
//  Created by Andy on 13-9-11.
//  Copyright (c) 2013年 MONTNETS. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"
#import "FMDatabaseQueue.h"
#import "Globals.h"
#import "BaseDao.h"

@class BaseDao;
@interface DataBaseHandler : NSObject
{
    BOOL	state;
	Globals	*globals;
    
    FMDatabase *database;
    FMDatabaseQueue  *fmdbQueue;
    
    NSOperationQueue  *queue;

}

@property (nonatomic,assign)  BOOL state;
@property (nonatomic,readonly) FMDatabase *database;
@property (nonatomic,readonly) FMDatabaseQueue  *fmdbQueue;
@property (nonatomic,readonly) BaseDao   *baseDBManager;

//开启数据服务，并返回成功信息
- (BOOL)createDb;
//开启后台同步线程
- (void)beginSync;
//关闭后台同步线程
- (void)stopSync;

-(void)clearOnMemoryWarning;

@end