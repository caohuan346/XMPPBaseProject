//
//  MessageService.m
//  XMPPBaseProject
//
//  Created by hc on 14-6-30.
//  Copyright (c) 2014年 hc. All rights reserved.
//

#import "MessageService.h"
#import "MessageDao.h"

@interface MessageService ()

@property (nonatomic)MessageDao *dao;

@end

@implementation MessageService

#pragma mark - init
-(id)init{
    if (self = [super init]) {
        self.dao = [MessageDao sharedInstance];
    }
    return self;
}

#pragma mark - singleton
SYNTHESIZE_SINGLETON_FOR_CLASS(MessageService)


@end
