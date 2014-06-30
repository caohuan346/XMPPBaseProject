//
//  SessionService.m
//  XMPPBaseProject
//
//  Created by hc on 14-6-30.
//  Copyright (c) 2014年 hc. All rights reserved.
//

#import "SessionService.h"
#import "SessionDao.h"

@interface SessionService ()

@property (nonatomic)SessionDao *dao;

@end

@implementation SessionService

#pragma mark - init
-(id)init{
    if (self = [super init]) {
        self.dao = [SessionDao sharedInstance];
    }
    return self;
}

#pragma mark - singleton
SYNTHESIZE_SINGLETON_FOR_CLASS(SessionService)


@end
