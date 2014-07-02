//
//  DBCenter.m
//  KuaiKuai
//
//  Created by Andy on 13-9-11.
//  Copyright (c) 2013年 MONTNETS. All rights reserved.
//

#import "DataBaseHandler.h"

#import "AppDelegate.h"
#import "Globals.h"
#import "PathService.h"
#import "Session.h"
#import "User.h"
#import "Message.h"

@implementation DataBaseHandler

#pragma mark - singleton
SYNTHESIZE_SINGLETON_FOR_CLASS(DataBaseHandler)

- (id)init{
	if ((self = [super init])) {
        
        globals = [SharedAppDelegate globals];
        
		self.state = FALSE;
        //database = nil;
        
        NSString *filePath = [PathService pathOfDataBaseFileForCurrentUser:globals.userId];
        
        self.fmdbQueue=[[FMDatabaseQueue alloc] initWithPath:filePath];
        self.database = [[FMDatabase alloc]initWithPath:filePath];
        
        self.queue=[[NSOperationQueue alloc] init];
        self.queue.maxConcurrentOperationCount=1;
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
    /*
    //create db
    NSString *filePath = [PathService pathOfDataBaseFileForCurrentUser:globals.userId];
    
    self.fmdbQueue=[[FMDatabaseQueue alloc] initWithPath:filePath];
    self.database = [[FMDatabase alloc]initWithPath:filePath];
     
     */
    
    if ([self.database open]) {
        [self.database setShouldCacheStatements:YES];
        NSLog(@"Open success db !");
    }else {
        NSLog(@"Failed to open db!");
    }
    
    //User
    BOOL tUserFlag = [_baseDBManager createTableWithPKByClass:[User class]];
    //session
    BOOL tSessionFlag = [_baseDBManager createTableWithPKByClass:[Session class]];
    //Message
    BOOL tMsgFlag = [_baseDBManager createTableWithPKByClass:[Message class]];
    
	return tUserFlag && tSessionFlag && tMsgFlag;
}

#pragma mark Customized:General
//local db update handle
- (void)handleDbUpdate {
    
	NSString *allConfigFilePath = [PathService pathForAllConfigFile];
    
	if ([[NSFileManager defaultManager] fileExistsAtPath:allConfigFilePath]) {
		NSMutableDictionary *allConfigDictionary = [[NSMutableDictionary alloc]
							   initWithContentsOfFile:allConfigFilePath];
        //sandbox中数据库版本
		NSString *lastDBVersion = [allConfigDictionary objectForKey:@"dbVersion"];
        
        //如果sandbox中存在数据库版本大于等于目标版本，不需要更新
		if ([lastDBVersion compare:KNextDBVersion] != NSOrderedAscending) {
			NSLog(@"save db ver, do nothing.");
		}
        //change db
        else{
            
        }
	}

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
