//
//  Message.h
//  BaseProject
//
//  Created by caohuan on 13-12-19.
//  Copyright (c) 2013年 ch. All rights reserved.
//

#import <Foundation/Foundation.h>

//chat msg
@interface Message : NSObject

@property(nonatomic,copy)NSString *content;
@property(nonatomic,copy)NSString *chatUserId;    //发送者id，对应JID中得用户名
@property(nonatomic,copy)NSString *chatUserJID;   //发送者的JID
@property(nonatomic,retain)NSDate *sendTime;
@property(nonatomic,copy)NSString *isFrom;     //0表示自己发送，1表示接收到
@property(nonatomic,copy)NSString *messageType;   //枚举MessageType

@end

//xmpp msg
@interface XMPPMsg: NSObject

@property(nonatomic,copy)NSString *content;
@property(nonatomic,copy)NSString *senderId;
@property(nonatomic,copy)NSString *targetId;
@property(nonatomic,retain)NSDate *sendTime;
@property(nonatomic,assign)XMPPType msgType;   //枚举XMPPType

@end
