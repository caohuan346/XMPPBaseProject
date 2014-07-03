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
	Globals	*globals;
}

@property (nonatomic, assign) BOOL state;
@property (nonatomic, strong) FMDatabase *database;
@property (nonatomic, strong) FMDatabaseQueue  *fmdbQueue;
@property (nonatomic, strong) NSOperationQueue  *queue;

//singleton
SYNTHESIZE_SINGLETON_FOR_HEADER(DataBaseHandler)

//开启数据服务，并返回成功信息
- (BOOL)createDb;
//开启后台同步线程
- (void)beginSync;
//关闭后台同步线程
- (void)stopSync;

-(void)clearOnMemoryWarning;

@end
