//
//  EnumDefine.h
//  BaseProject
//
//  Created by caohuan on 13-12-21.
//  Copyright (c) 2013年 ch. All rights reserved.
//

#ifndef BaseProject_EnumDefine_h
#define BaseProject_EnumDefine_h



#endif

//消息类型（文字，图片..）
typedef enum {
	ContentType_Text = 0,
    ContentType_Image = 1,
    ContentType_Audio = 2,
    ContentType_System = 3,
} ContentType;

//发送方向
typedef enum {
	SendType_Received = 0,
	SendType_Send = 1,
} SendType;

//群/私消息
typedef enum {
	MessageType_User = 0,
	MessageType_Group = 1,
} MessageType;

typedef NS_ENUM(NSUInteger, SessionType) {
    SessionTypePersonalChat = 1,    //个人会话
    SessionTypeGroupChat = 2,       //群组会话
    SessionTypeSystem = 3,          //系统消息
    SessionTypeSubscription=4       //订阅相关消息，如加为好友,删除好友等
};

typedef NS_ENUM(NSUInteger, SubscriptionType) {
    SubscriptionTypeSubscribe = 1,   //对方请求添加
    SubscriptionTypeSubscribed = 2,  //对方同意添加为好友
    SubscriptionTypeUnsubscribe = 3, //用户移除好友
    SubscriptionTypeUnsubscribed = 4 //对方拒绝添加或移除好友
};

typedef NS_ENUM(NSUInteger, XMPPType) {
    //Presence
    XMPPTypePresenceSubscribe = 1,      //对方请求添加
    XMPPTypePresenceSubscribed = 2,     //对方同意添加为好友
    XMPPTypePresenceUnsubscribe = 3,    //用户移除好友
    XMPPTypePresenceUnsubscribed = 4,   //对方拒绝添加或移除好友
    XMPPTypePresenceAvailable=5,        //用户上线
    XMPPTypePresenceUnavailable=6,      //用户下线
    //Message
    XMPPTypeMessageIsComposing = 7,     //用户正在输入
    XMPPTypeMessageHasPaused = 8,       //用户停止输入
    XMPPTypeMessagePersonalNormal = 9,  //收到个人普通消息
    XMPPTypeMessageGroupNormal = 10,    //收到群组普通消息
    
    //IQ
    XMPPTypeIQQueryResult = 11,          //查询名称结果
    //还有添加、修改、删除名册等...
    
    //注册
    XMPPTypeRegisterSuccess = 12,       //注册成功
    XMPPTypeRegisterError = 13          //注册失败
    
} ;
