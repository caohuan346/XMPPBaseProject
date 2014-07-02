//
//  SessionService.h
//  XMPPBaseProject
//
//  Created by hc on 14-6-30.
//  Copyright (c) 2014年 hc. All rights reserved.
//

#import "BaseManager.h"

@class ConversationDao;
@interface ConversationManager : BaseManager

//singleton
SYNTHESIZE_SINGLETON_FOR_HEADER(ConversationManager)

@property (nonatomic, readonly)ConversationDao *dao;

/**
 *  获取会话列表
 *
 *  @return 会话列表
 */
-(NSArray *) conversations;

@end
