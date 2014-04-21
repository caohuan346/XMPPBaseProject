//
//  XMPPHelper.h
//  BaseProject
//
//  Created by Huan Cho on 13-8-6.
//  Copyright (c) 2013年 ch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Session.h"

@class Session;
@class XMPPMsg;
@class User;
@interface XMPPHelper : NSObject

//查询名册
+(void)xmppQueryRoster;
//获取用户头像
+(UIImage *)xmppUserPhotoForJID:(XMPPJID *)jid;
//发起添加好友请求
+(void)xmppBuddyAddWithUserName:(NSString *)userName;
//删除好友
+(void)xmppDeleteBuddyWithUserId:(NSString *)userId;
//收到好友添加请求
+(void)xmppDidReceiveSubscribeRequest:(NSString *)userName type:(XMPPType)type;
//登录房间
+(void)xmppLoginRoomWithName:(NSString *)roomName;
//发送xmpp消息
+(void)xmppSendMessage:(XMPPMsg *)xmppMsg;
//注册
+(void)xmppRegisterWithUser:(User *)user;

@end
