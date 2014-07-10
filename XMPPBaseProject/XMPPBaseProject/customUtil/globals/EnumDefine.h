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

//聊天类型
typedef NS_ENUM(NSUInteger, MessageContentType){
    MessageContentType_Text = 1,    //文本
    MessageContentType_Image,       //图片
    MessageContentType_Video,       //视频
    MessageContentType_Location,    //位置
    MessageContentType_Voice,       //语音
    MessageContentType_File,        //文件
    MessageContentType_Command      //命令
};

//消息状态
typedef NS_ENUM(NSUInteger, MessageState) {
    MessageState_Fail = 1,      //失败
    MessageState_Success,       //成功：发送到服务器了
    MessageState_Arrived,       //到达目标用户
    MessageState_HaveRead,      //用户已读
    MessageState_Unknown        //unknown
};

//聊天状态
typedef NS_ENUM(NSUInteger,  ChatState) {
    ChatStateUnknown   = 0,     //未知
    ChatStateActive    = 1,     //active
    ChatStateComposing = 2,
    ChatStatePaused    = 3,
    ChatStateInactive  = 4,
    ChatStateGone      = 5
};

//群/私消息
typedef enum {
	MessageType_User = 0,
	MessageType_Group = 1,
} MessageType;

typedef NS_ENUM(NSUInteger, ConversationType) {
    ConversationTypePersonalChat = 1,    //个人会话
    ConversationTypeGroupChat = 2,       //群组会话
    ConversationTypeSystem = 3,          //系统消息
    ConversationTypeSubscription=4       //订阅相关消息，如加为好友,删除好友等
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
