//
//  User.m
//  BaseProject
//
//  Created by caohuan on 13-12-19.
//  Copyright (c) 2013年 ch. All rights reserved.
//

#import "User.h"

@implementation User

#pragma mark - db model protocol
-(NSString *)tableName {
    return @"t_user";
}

-(NSString *)primaryKey{
    return @"oid";
}

@end

@implementation AppUser


@end


@implementation XmppUserInfo


@end
