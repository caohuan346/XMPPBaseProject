//
//  ChatMessage.h
//  XMPPBaseProject
//
//  Created by hc on 14-7-10.
//  Copyright (c) 2014年 hc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBModelProtocol.h"

@interface ChatMessage : NSObject<DBModelProtocol>

/**
 *	消息id
 */
@property (nonatomic, assign) NSInteger msgId;

@property (nonatomic, copy) NSString *senderId;

@property (nonatomic, copy) NSString *receiverId;

@property (nonatomic, copy) NSString *msgContent;

@property (nonatomic, strong) NSDate *sendTime;

@property (nonatomic, assign) MessageContentType contentType;

@property (nonatomic, assign) NSInteger *msgState;


@end
