//
//  BuddyService.m
//  XMPPBaseProject
//
//  Created by hc on 14-6-30.
//  Copyright (c) 2014年 hc. All rights reserved.
//

#import "BuddyService.h"
#import "BuddyDao.h"

@interface BuddyService ()

@property (nonatomic)BuddyDao *dao;

@end

@implementation BuddyService

#pragma mark - init
-(id)init{
    if (self = [super init]) {
        self.dao = [BuddyDao sharedInstance];
    }
    return self;
}

//singleton
SYNTHESIZE_SINGLETON_FOR_CLASS(BuddyService)


@end
