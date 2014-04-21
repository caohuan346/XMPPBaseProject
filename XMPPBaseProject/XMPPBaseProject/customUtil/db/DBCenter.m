//
//  DBCenter.m
//  KuaiKuai
//
//  Created by Andy on 13-9-11.
//  Copyright (c) 2013年 MONTNETS. All rights reserved.
//

#import "DBCenter.h"

#import "AppDelegate.h"
#import "Globals.h"
#import "PathService.h"
#import "Session.h"
#import "User.h"
#import "Message.h"

@implementation DBCenter
@synthesize state;
@synthesize database;
@synthesize fmdbQueue;

- (id)init{
	if ((self = [super init])) {
        
        globals = [SharedAppDelegate globals];
        
		state = FALSE;
        database = nil;
        
        queue=[[NSOperationQueue alloc] init];
        queue.maxConcurrentOperationCount=1;
        
        _baseDBManager = [[BaseDBManager alloc] initWithDBCenter:self];
	}
	return self;
}

- (BOOL)createDb {
    
    /*
	if (state == TRUE) {
		return TRUE;
	}
    NSString *filePath = [PathService pathForUserDataBaseFileOfUser:[NSString stringWithFormat:@"%d",1]];
    
    if (fmdbQueue) {
        [fmdbQueue release];
    }
    if (database) {
        [database release];
    }
    
    fmdbQueue=[[FMDatabaseQueue alloc] initWithPath:filePath];
    database = [[FMDatabase alloc]initWithPath:filePath];
    
    if ([database open]) {
        [database setShouldCacheStatements:YES];
        NSLog(@"Open success db !");
    }else {
        NSLog(@"Failed to open db!");
    }
    //1.DEPINFO 机构信息表
	NSString *sqlStr  = @"create table if not exists DEPINFO(DEPID integer, DEPNAME text,CORPCODE text, PARENTID integer, SMSBALANCE integer, MMSBALANCE integer,TIMEFAG double, primary key(DEPID));";
	if (![database tableExists:@"DEPINFO"]) {
        BOOL result = [database executeUpdate:sqlStr];
        if (result) {
            
            NSLog(@"create DEPINFO success");
        }
    }
    NSLog(@"DEPINFO exists!");
    [database close];
     
     */
    
    //创建数据库
    NSString *filePath = [PathService pathForUserDataBaseFileOfUser:globals.userId];
    
    fmdbQueue=[[FMDatabaseQueue alloc] initWithPath:filePath];
    database = [[FMDatabase alloc]initWithPath:filePath];
    if ([database open]) {
        [database setShouldCacheStatements:YES];
        NSLog(@"Open success db !");
    }else {
        NSLog(@"Failed to open db!");
    }
    
    //创建session表
    BOOL tUserFlag = [_baseDBManager createTableWithPKByClass:[User class]];
    
    //创建session表
    BOOL tSessionFlag = [_baseDBManager createTableWithPKByClass:[Session class]];
    
    //创建session表
    BOOL tMsgFlag = [_baseDBManager createTableWithPKByClass:[Message class]];
    
	return tUserFlag && tSessionFlag && tMsgFlag;
}

+ (NSString *)currentVersion {
	//当前数据库的版本号，每次更改库结构时必须修正此版本号
	return @"1.0";
}

#pragma mark customized: Public (Syncronization)
-(void)requestDidFailed{
    NSLog(@"Sync failed");
}

- (void)beginSync{
    
}

//关闭后台同步线程
- (void)stopSync {
	
}

-(void)clearOnMemoryWarning{
  
}

@end
