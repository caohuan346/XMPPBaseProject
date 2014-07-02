//
//  XMPPHelper.m
//  BaseProject
//
//  Created by Huan Cho on 13-8-6.
//  Copyright (c) 2013年 ch. All rights reserved.
//

#import "XMPPHelper.h"
#import "XMPPServer+Add.h"
#import "AppDelegate.h"
#include "Session.h"
#import "Message.h"
#import "User.h"
#import "ConversationDao.h"

@implementation XMPPHelper
//http://pan.baidu.com/s/1pJ0j67D   r8h6
/*
 获取名册
 
     <iq type="get"
     　　from="xiaoming@example.com"
     　　to="example.com"
     　　id="1234567">
     　　<query xmlns="jabber:iq:roster"/>
     <iq />
     
     type 属性，说明了该 iq 的类型为 get，与 HTTP 类似，向服务器端请求信息
     from 属性，消息来源，这里是你的 JID
     to 属性，消息目标，这里是服务器域名
     id 属性，标记该请求 ID，当服务器处理完毕请求 get 类型的 iq 后，响应的 result 类型 iq 的 ID 与 请求 iq 的 ID 相同
     <query xmlns="jabber:iq:roster"/> 子标签，说明了客户端需要查询 roster

*/
+(void)xmppQueryRoster{
    NSXMLElement *queryElement = [NSXMLElement elementWithName:@"query" xmlns:@"jabber:iq:roster"];
    NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
    XMPPJID *myJID = [XMPPServer xmppStream].myJID;
    [iq addAttributeWithName:@"from" stringValue:myJID.description];
    [iq addAttributeWithName:@"to" stringValue:myJID.domain];
    [iq addAttributeWithName:@"id" stringValue:@"123456"];
    [iq addAttributeWithName:@"type" stringValue:@"get"];
    [iq addChild:queryElement];
    NSLog(@"组装后的xml:%@",iq);
    [[XMPPServer xmppStream] sendElement:iq];
}


//获取头像
+(UIImage *)xmppUserPhotoForJID:(XMPPJID *)jid{
    NSData *photoData = [[[XMPPServer sharedServer] xmppvCardAvatarModule] photoDataForJID:jid];
    return [UIImage imageWithData:photoData];
}

+(void)xmppDidReceiveSubscribeRequest:(NSString *)userName type:(XMPPType)type{
    Session *aSession = [[Session alloc] init];
    aSession.lastestMsgTime = [NSDate date];
    aSession.sessionType = [NSString stringWithFormat:@"%d",SessionTypeSubscription];
    aSession.detailType = [NSString stringWithFormat:@"%d",type];
    
    //对方请求添加
    if (type == XMPPTypePresenceSubscribe) {
        aSession.lastMsg = [NSString stringWithFormat:@"%@请求添加你为好友",userName];
        
        //保存用户消息
        User *aUser = [[User alloc] init];
        aUser.userId = userName;
        aUser.subscribe = @"from";
        [SharedAppDelegate.databaseService.baseDBManager insertObject:aUser];
    }
    //对方同意
    else if (type == XMPPTypePresenceSubscribed){
        aSession.lastMsg = [NSString stringWithFormat:@"%@同意添加你为好友",userName];
    }
    //对方不同意
    else if (type == XMPPTypePresenceUnsubscribe){
        aSession.lastMsg = [NSString stringWithFormat:@"%@拒绝添加你为好友",userName];
    }
    //对方不同意
    else if (type == XMPPTypePresenceUnsubscribed){
        aSession.lastMsg = [NSString stringWithFormat:@"%@拒绝添加你为好友",userName];
    }
    
    BOOL optFlag = [ConversationDao insertOrUpdateSession:aSession];
    if (optFlag) {
        NSLog(@"插入session成功");
    }
    
    //重新查询名称
    [XMPPHelper xmppQueryRoster];
}

+(void)xmppBuddyAddWithUserName:(NSString *)userName{
    //持久化到数据库
    User *queryBean = [[User alloc] init];
    queryBean.userId = userName;
    
    NSArray *userArray = [SharedAppDelegate.databaseService.baseDBManager queryDbToObjectArray:[User class] withConditionObject:queryBean];
    User *user1 = [userArray objectAtIndex:0];
    
    if (!user1) {
        User *aUser = [[User alloc] init];
        aUser.userId = userName;
        aUser.subscribe = @"to";
        [SharedAppDelegate.databaseService.baseDBManager insertObject:aUser];
        
        //删除
        //[SharedAppDelegate.databaseService.baseDBManager deleteRecordWithClazz:[User class] withConditionObject:queryBean];
    }
    
    //发送xmpp
    XMPPJID *jid = [XMPPJID jidWithString:[NSString stringWithFormat:@"%@@%@",userName,SharedAppDelegate.globals.xmppServerDomain]];
    [[XMPPServer xmppRoster] subscribePresenceToUser:jid];
}

+(void)xmppDeleteBuddyWithUserId:(NSString *)userId{
    XMPPJID *jid = [XMPPJID jidWithString:[NSString stringWithFormat:@"%@@%@",userId,SharedAppDelegate.globals.xmppServerDomain]];
    [[XMPPServer xmppRoster] unsubscribePresenceFromUser:jid];
}

+(void)xmppLoginRoomWithName:(NSString *)roomName{
    
//     XMPPJID *roomJID = [XMPPJID jidWithString:[NSString stringWithFormat:@"%d@conference.%@",roomName,globals.openFireHostName]];
//     xmppRoom = [[XMPPRoom alloc] initWithRoomStorage:self jid:roomJID];
//     [xmppRoom activate:xmppStream];
//     NSXMLElement *history = [NSXMLElement elementWithName:@"history"];
//     [history addAttributeWithName:@"since" stringValue:[Globals dateToStr_Format:[NSDate dateWithTimeIntervalSince1970:globals.lastLoginOutTime]]];
//     [xmppRoom addDelegate:self delegateQueue:dispatch_get_current_queue()];
//     [xmppRoom joinRoomUsingNickname:[NSString stringWithFormat:@"%d",globals.userId] history:history];
//    
//    
//    XMPPRoomCoreDataStorage *rosterstorage = [[XMPPRoomCoreDataStorage alloc] init];
//    XMPPRoom *room = [[XMPPRoom alloc] initWithRoomStorage:rosterstorage jid:[XMPPJID jidWithString:roomName] dispatchQueue:dispatch_get_main_queue()];
//    [rosterstorage release];
//    _xmppRoom = room;
//    XMPPStream *stream = [XMPPServer xmppStream];
//    [room activate:stream];
//    
//    [room joinRoomUsingNickname:@"smith" history:nil];
//    [room configureRoomUsingOptions:nil];
//    //    [room fetchConfigurationForm];
//    [room addDelegate:self delegateQueue:dispatch_get_main_queue()];

}

//发送xmpp消息
+(void)xmppSendMessage:(XMPPMsg *)xmppMsg{
    XMPPType type = xmppMsg.msgType;
    NSString *msgContent = xmppMsg.content;
    
    //生成XML消息文档
    NSXMLElement *mes = [NSXMLElement elementWithName:@"message"];
    //消息类型
    [mes addAttributeWithName:@"type" stringValue:@"chat"];
    //发送给谁
    NSString *jidStr = [NSString stringWithFormat:@"%@@%@",xmppMsg.targetId,SharedAppDelegate.globals.xmppServerDomain];
    [mes addAttributeWithName:@"to" stringValue:jidStr];
    //由谁发送
    [mes addAttributeWithName:@"from" stringValue:[[NSUserDefaults standardUserDefaults] stringForKey:kUserID]];
    if (msgContent) {
        //生成<body>文档
        NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
        [body setStringValue:xmppMsg.content];
        [mes addChild:body];
    }

    //发送消息
    [[XMPPServer xmppStream] sendElement:mes];
}

/*
 * <iq type='set' id='reg2'>
 *    <query xmlns='jabber:iq:register'>
 *        <username>bill</username>
 *        <password>Calliope</password>
 *        <email>bard@shakespeare.lit</email>
 *    </query>
 * </iq>
 *
 */
+(void)xmppRegisterWithUser:(XmppUserInfo *)userInfo{
    
    NSXMLElement *userNameEle = [NSXMLElement elementWithName:@"username" stringValue:userInfo.userName];
    
    NSXMLElement *passwordEle = [NSXMLElement elementWithName:@"password" stringValue:userInfo.password];
    
    NSXMLElement *emailEle = [NSXMLElement elementWithName:@"email" stringValue:userInfo.email];
    
    NSArray *elements = [NSArray arrayWithObjects:userNameEle,passwordEle,emailEle, nil];
    
    [[XMPPServer xmppStream] registerWithElements:elements error:nil];

}

@end
