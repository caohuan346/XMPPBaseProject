//
//  Session.h
//  BaseProject
//
//  Created by caohuan on 13-12-13.
//  Copyright (c) 2013年 ch. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Session : NSObject

@property (nonatomic,retain)    NSNumber *oid;
@property (nonatomic,copy)      NSString *sessionId;        //id：如聊天对象的id，系统消息的id（各自主键）
@property (nonatomic,retain)    NSDate   *lastestMsgTime;   //最近一条消息的时间
@property (nonatomic,retain)    NSString *sessionType;      //会话类型 用户、群、讨论组、系统..
@property (nonatomic,copy)      NSString *lastMsg;          //消息内容
@property (nonatomic,retain)    NSNumber *unreadNum;        //未读消息个数
@property (nonatomic,copy)      NSString *detailType;       //详细消息类型：如会话的文字、图片、语音消息，好友相关的请求、同意、不同意等
@property (nonatomic,copy)      NSString *senderId;         //发送者ID

- (id)initWithMsgDic:(NSDictionary *)msgDic;

@end
