//
//  SessionService.m
//  BaseProject
//
//  Created by caohuan on 13-12-23.
//  Copyright (c) 2013年 ch. All rights reserved.
//

#import "ConversationDao.h"
#import "Session.h"
#import "AppDelegate.h"

@implementation ConversationDao

#pragma mark - singleton
SYNTHESIZE_SINGLETON_FOR_CLASS(ConversationDao)


+(BOOL)insertOrUpdateSession:(Session *)aSession{
    //查询会话记录
    Session *queryBean = [[Session alloc] init];
    queryBean.sessionType = aSession.sessionType;
    NSArray *sessionArray = [SharedAppDelegate.databaseService.baseDBManager queryDbToObjectArray:[Session class] withConditionObject: queryBean];
    
    BOOL optFlag;
    
    //存在则替换
    if (sessionArray) {
        Session *oldSession = (Session *)[sessionArray objectAtIndex:0];
        aSession.unreadNum = [NSNumber numberWithInt:[oldSession.unreadNum intValue] +1];
        optFlag = [SharedAppDelegate.databaseService.baseDBManager updateRecordWithClazz:[Session class] withModifiedBean:aSession withConditionObject:queryBean];
    }else{//不存在则添加
        optFlag = [SharedAppDelegate.databaseService.baseDBManager insertObject:aSession];
    }
    return optFlag;
}

@end
