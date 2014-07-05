//
//  SessionService.m
//  XMPPBaseProject
//
//  Created by hc on 14-6-30.
//  Copyright (c) 2014年 hc. All rights reserved.
//

#import "ConversationManager.h"
#import "ConversationDao.h"
#import "Conversation.h"
@interface ConversationManager ()

@property (nonatomic)ConversationDao *dao;

@end

@implementation ConversationManager

#pragma mark - init
-(id)init{
    if (self = [super init]) {
        self.dao = [ConversationDao sharedInstance];
    }
    return self;
}

#pragma mark - singleton
SYNTHESIZE_SINGLETON_FOR_CLASS(ConversationManager)


-(NSArray *) conversations{
    return [_dao query2ObjectArrayWithConditionObject:[[Conversation alloc] init]];
}

@end
