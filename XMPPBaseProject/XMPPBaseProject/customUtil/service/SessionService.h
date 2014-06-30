//
//  SessionService.h
//  XMPPBaseProject
//
//  Created by hc on 14-6-30.
//  Copyright (c) 2014年 hc. All rights reserved.
//

#import "BaseService.h"

@class SessionDao;
@interface SessionService : BaseService

//singleton
SYNTHESIZE_SINGLETON_FOR_HEADER(SessionService)

@property (nonatomic, readonly)SessionDao *dao;

@end
