//
//  ARCSingletonTemplate.h
//  XMPPBaseProject
//
//  Created by hc on 14-6-27.
//  Copyright (c) 2014年 hc. All rights reserved.
//

#define SYNTHESIZE_SINGLETON_FOR_HEADER(className) \
\
+ (className *) sharedInstance;


#define SYNTHESIZE_SINGLETON_FOR_CLASS(className) \
\
+ (className *)sharedInstance { \
    static className *sharedInstance = nil; \
    static dispatch_once_t onceToken; \
    dispatch_once(&onceToken, ^{ \
        sharedInstance = [[self alloc] init]; \
    }); \
    return sharedInstance; \
}

/*
#define SYNTHESIZE_SINGLETON_FOR_HEADER(className) \
\
+ (className *)shared##className;


#define SYNTHESIZE_SINGLETON_FOR_CLASS(className) \
\
+ (className *)shared##className { \
    static className *shared##className = nil; \
    static dispatch_once_t onceToken; \
    dispatch_once(&onceToken, ^{ \
        shared##className = [[self alloc] init]; \
    }); \
    return shared##className; \
}
 */
