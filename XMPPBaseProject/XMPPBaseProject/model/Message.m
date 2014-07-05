//
//  Message.m
//  BaseProject
//
//  Created by caohuan on 13-12-19.
//  Copyright (c) 2013年 ch. All rights reserved.
//

#import "Message.h"

#pragma mark - implementation chat Message
@implementation Message

#pragma mark - db model protocol
-(NSString *)tableName {
    return @"t_message";
}

-(NSString *)primaryKey{
    return @"oid";
}

@end

#pragma mark - implementation chat Message
@implementation XMPPMsg


@end
