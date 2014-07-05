//
//  Conversation.m
//  XMPPBaseProject
//
//  Created by hc on 14-7-2.
//  Copyright (c) 2014年 hc. All rights reserved.
//

#import "Conversation.h"

@implementation Conversation

#pragma mark - db model protocol
-(NSString *)tableName {
    return @"t_conversation";
}

-(NSString *)primaryKey{
    return @"oid";
}

@end
