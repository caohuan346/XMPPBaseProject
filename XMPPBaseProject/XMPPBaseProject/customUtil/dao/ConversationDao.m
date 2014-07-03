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
    queryBean.conversationType = aSession.conversationType;
    NSArray *sessionArray = [[BaseDao sharedInstance] queryDbToObjectArray:[Session class] withConditionObject: queryBean];
    
    BOOL optFlag;
    
    //存在则替换
    if (sessionArray) {
        Session *oldSession = (Session *)[sessionArray objectAtIndex:0];
        aSession.unreadNum = [NSNumber numberWithInt:[oldSession.unreadNum intValue] +1];
        optFlag = [[BaseDao sharedInstance] updateRecordWithClazz:[Session class] withModifiedBean:aSession withConditionObject:queryBean];
    }else{//不存在则添加
        optFlag = [[BaseDao sharedInstance] insertObject:aSession];
    }
    return optFlag;
}

@end
