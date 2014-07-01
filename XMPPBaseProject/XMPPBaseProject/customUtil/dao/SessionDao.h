//
//  SessionService.h
//  BaseProject
//
//  Created by caohuan on 13-12-23.
//  Copyright (c) 2013年 ch. All rights reserved.
//

#import "BaseDao.h"

//会话列表服务类
@class Session;
@interface SessionDao : BaseDao

//singleton
SYNTHESIZE_SINGLETON_FOR_HEADER(SessionDao)

//新增或更新session，存在更新、不存在插入
+(BOOL)insertOrUpdateSession:(Session *)aSession;

@end