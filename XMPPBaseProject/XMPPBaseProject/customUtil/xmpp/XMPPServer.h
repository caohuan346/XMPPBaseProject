//
//  XMPPServer.h
//  BaseProject
//
//  Created by Huan Cho on 13-8-5.
//  Copyright (c) 2013年 ch. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "XMPPFramework.h"
#import "XMPPAutoPing.h"
#import "ARCSingletonTemplate.h"

//MPPServer代理接口
@protocol XMPPServerDelegate <NSObject>
@optional
-(void)xmppServerLoginSuccess;
-(void)xmppServerLoginFail;
-(void)xmppServerAuthenticateFail;
@end

//消息类代理接口
@class Message;
@protocol XMPPMessageDelegate <NSObject>
@optional
-(void)xmppMessageReceived:(Message *)message;
-(void)xmppMessageReceivedWithDic:(NSDictionary *)messageContent;
@end

//在线列表类代理接口
@protocol XMPPPresenceDelegate <NSObject>
@optional
-(void)newBuddyOnline:(NSString *)buddyName;
-(void)buddyWentOffline:(NSString *)buddyName;
@end

//业务类接口
@protocol XMPPOperationDelegate <NSObject>
@optional
-(void)operationPush:(NSDictionary *)operation;
@end

//数据同步类接口
@protocol XMPPDataSyncDelegate <NSObject>
@optional
-(void)dataSyncPush:(NSDictionary *)dataSyncInfo;
@end

@class Globals;
@class XmppUserInfo;
@interface XMPPServer : NSObject<XMPPRosterDelegate,XMPPRoomStorage,XMPPAutoPingDelegate>{
    XMPPStream *xmppStream;
    Globals   *globals;
    XMPPRoom  *xmppRoom;
    
    XMPPReconnect *xmppReconnect;
    XMPPRoster *xmppRoster;
	XMPPRosterCoreDataStorage *xmppRosterStorage;
    
    XMPPvCardCoreDataStorage *xmppvCardStorage;
	XMPPvCardTempModule *xmppvCardTempModule;
	XMPPvCardAvatarModule *xmppvCardAvatarModule;
    
    XMPPCapabilities *xmppCapabilities;
	XMPPCapabilitiesCoreDataStorage *xmppCapabilitiesStorage;
    
    NSMutableDictionary *subWebServerDict;//用户信息下载字典器
    NSMutableDictionary *operateDataDict;
    NSMutableDictionary *loginRoomTryDict;
    
    BOOL isOpen;            //xmppStream是否开着
    BOOL isReConnect;       //是否是重连
    NSInteger  tryCount; //尝试次数
}



@property (nonatomic, strong, readonly) XMPPStream *xmppStream;
@property (nonatomic, strong, readonly) XMPPReconnect *xmppReconnect;
@property (nonatomic, strong, readonly) XMPPRoster *xmppRoster;
@property (nonatomic, strong, readonly) XMPPRosterCoreDataStorage *xmppRosterStorage;
@property (nonatomic, strong, readonly) XMPPvCardTempModule *xmppvCardTempModule;
@property (nonatomic, strong, readonly) XMPPvCardAvatarModule *xmppvCardAvatarModule;
@property (nonatomic, strong, readonly) XMPPCapabilities *xmppCapabilities;
@property (nonatomic, strong, readonly) XMPPCapabilitiesCoreDataStorage *xmppCapabilitiesStorage;

@property (nonatomic, retain, readonly) NSMutableDictionary *onlineDict; //key:userid value:status(online/busy/outline)

@property(nonatomic, assign)id<XMPPServerDelegate>     delegate;
@property(nonatomic, assign)id<XMPPMessageDelegate>    messageDelegate;//消息类代理
@property(nonatomic, assign)id<XMPPPresenceDelegate>   presenceDelegate;//在线列表类代理
@property(nonatomic, assign)id<XMPPOperationDelegate>  operationDelegate;  //业务类接口
@property(nonatomic, assign)id<XMPPDataSyncDelegate>   dataSyncDelegate;   //数据同步类接口

@property(nonatomic,assign) BOOL isRegister;//是否是注册

SYNTHESIZE_SINGLETON_FOR_HEADER(XMPPServer)

+(XMPPServer *)sharedServer;
//连接
-(BOOL)connectWithUserInfo:(XmppUserInfo *)userInfo;
//断开连接
-(void)disconnect;
//设置XMPPStream
-(void)setupStream;
//上线
-(void)goOnline;
//下线
-(void)goOffline;
//登陆房间
-(void)loginAllRoom;
//登陆特定房间
-(void)loginRoomById:(NSInteger)groupId;
//发送消息
- (void)sendMessage:(Message *) message;
//判断用户是否在线
-(BOOL)isONline:(NSInteger)userId;
//保存推送数据
-(void)savePushDataAndLastLoginOutTime;
//读取推送数据
-(void)readPushDataAndLastLoginOutTime;
//获取推送缓存id数组
-(NSArray *)getOperateIdArray:(NSInteger)operateType;
//获取某种推送类型的数量
-(NSInteger )getOperateArrayCount:(NSInteger)operateType;
//清理缓存数组
-(BOOL)removeOperateIdByOperateType:(NSInteger)operateType operateCount:(NSInteger)operateCount;
//清空缓存数组
-(BOOL)removeOperateIdByOperateType:(NSInteger)operateType;

@end
