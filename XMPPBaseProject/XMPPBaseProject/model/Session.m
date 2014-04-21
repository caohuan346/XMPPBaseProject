//
//  Session.m
//  BaseProject
//
//  Created by caohuan on 13-12-13.
//  Copyright (c) 2013年 ch. All rights reserved.
//

#import "Session.h"

@implementation Session


- (id)initWithMsgDic:(NSDictionary *)msgDic{
    if (self =  [self init]) {
        self.sessionId = [msgDic objectForKey:@"sessionId"];
        self.lastestMsgTime = [msgDic objectForKey:@"lastestMsgTime"];
        self.sessionType = [msgDic objectForKey:@"sessionType"];
        self.lastMsg = [msgDic objectForKey:@"lastMsg"];
        self.unreadNum = [msgDic objectForKey:@"unreadNum"];
        self.detailType = [msgDic objectForKey:@"msgType"];
        self.senderId =[msgDic objectForKey:@"senderId"];
    }
    return  self;
}

@end
