//
//  Conversation.h
//  XMPPBaseProject
//
//  Created by hc on 14-7-2.
//  Copyright (c) 2014年 hc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBModelProtocol.h"

@interface Conversation : NSObject<DBModelProtocol>

/**
 *  oid
 */
@property (nonatomic, copy) NSString *oid;

/**
 *  发送者ID
 */
@property (nonatomic, copy) NSString *senderId;

/**
 *  最近一条消息的时间
 */
@property (nonatomic, strong) NSDate *time;

/**
 *  消息内容
 */
@property (nonatomic, copy) NSString *msgContent;

/**
 *  未读消息个数
 */
@property (nonatomic, strong) NSNumber *unreadCount;

/**
 *  消息类型 用户、群、讨论组、系统..
 */
@property (nonatomic, assign) ConversationType type;

/**
 *  详细消息类型：如会话的文字、图片、语音消息
 */
@property (nonatomic, assign) MessageContentType detailType;


@end
