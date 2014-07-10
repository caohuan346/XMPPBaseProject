//
//  ChatMessage.m
//  XMPPBaseProject
//
//  Created by hc on 14-7-10.
//  Copyright (c) 2014年 hc. All rights reserved.
//

#import "ChatMessage.h"

@implementation ChatMessage

-(NSString *)tableName {
    return @"t_chatMessage";
}

-(NSString *)primaryKey{
    return @"msgId";
}

@end
