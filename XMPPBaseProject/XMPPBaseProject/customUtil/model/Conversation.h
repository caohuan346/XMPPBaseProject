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

@property (nonatomic, assign) int intField;
@property (nonatomic, assign) NSInteger NSIntegerField;
@property (nonatomic, assign) long longField;
@property (nonatomic, assign) long long longlongField;
@property (nonatomic, assign) unsigned long unsignedLongField;
@property (nonatomic, assign) BOOL boolField;
@property (nonatomic, assign) double doubleField;
@property (nonatomic, copy) NSString *nsstringField;
@property (nonatomic, strong) NSDate *nsdateField;
@property (nonatomic, strong) NSData *nsdataField;

/*
T@"NSString",C,N,V_nsstringField
T@"NSDate",&,N,V_nsdateField
T@"NSData",&,N,V_nsdataField
T@"NSNumber",&,N,V_unreadCount
TI,N,V_type
TI,N,V_detailType
Ti,N,V_intField
Ti,N,V_NSIntegerField
Tl,N,V_longField
Tq,N,V_longlongField
TL,N,V_unsignedLongField
Tc,N,V_boolField
Td,N,V_doubleField
 */

@end
