//
//  XMPPServer.m
//  BaseProject
//
//  Created by Huan Cho on 13-8-5.
//  Copyright (c) 2013年 ch. All rights reserved.
//

#import "XMPPServer.h"
#import "XMPPPresence.h"
#import "XMPPJID.h"
#import "XMPPMessage+XEP_0085.h"
#import "XMPPMessage+XEP_0184.h"
#import "XMPPHelper.h"
#import "Message.h"
#import "Globals.h"
#import "SVProgressHUD.h"
#import "AppDelegate.h"
#import "DDLog.h"
#import "DDTTYLogger.h"
#import "Message.h"
#import "User.h"
#import "ConversationDao.h"

#if DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_INFO;
#endif

static XMPPServer *singleton = nil;

@interface XMPPServer (){
    
}

@property(nonatomic,retain)XmppUserInfo *userInfo;

@end

@implementation XMPPServer

@synthesize xmppStream;
@synthesize xmppReconnect;
@synthesize xmppRoster;
@synthesize xmppRosterStorage;
@synthesize xmppvCardTempModule;
@synthesize xmppvCardAvatarModule;
@synthesize xmppCapabilities;
@synthesize xmppCapabilitiesStorage;

@synthesize delegate;
@synthesize presenceDelegate;
@synthesize messageDelegate;

#pragma mark - singleton

SYNTHESIZE_SINGLETON_FOR_CLASS(XMPPServer)

+(XMPPServer *)sharedServer{
    @synchronized(self){
        if (singleton == nil) {
            singleton = [[self alloc] init];
        }
    }
    return singleton;
    
}

+(id)allocWithZone:(NSZone *)zone{
    
    @synchronized(self){
        if (singleton == nil) {
            singleton = [super allocWithZone:zone];
            return singleton;
        }
    }
    return nil;
}

- (id)copyWithZone:(NSZone *)zone{
    return singleton;
}

/*
-(id)retain{
    return singleton;
}

-(oneway void)release{
}

+(id)release{
    return nil;
}

-(id)autorelease{
    return singleton;
}

-(void)dealloc{
    [_userInfo release];
    
     [self teardownStream];
    [super dealloc];
}
*/

#pragma mark - private
-(void)setupStream{
    
    _onlineDict = [[NSMutableDictionary alloc] init];
    operateDataDict = [[NSMutableDictionary alloc] init];
    subWebServerDict = [[NSMutableDictionary alloc] init];
    
    
    // NSAssert(xmppStream == nil, @"Method setupStream invoked multiple times");
	
	// Setup xmpp stream
	//
	// The XMPPStream is the base class for all activity.
	// Everything else plugs into the xmppStream, such as modules/extensions and delegates.
    
	xmppStream = [[XMPPStream alloc] init];
	
#if !TARGET_IPHONE_SIMULATOR
	{
		// Want xmpp to run in the background?
		//
		// P.S. - The simulator doesn't support backgrounding yet.
		//        When you try to set the associated property on the simulator, it simply fails.
		//        And when you background an app on the simulator,
		//        it just queues network traffic til the app is foregrounded again.
		//        We are patiently waiting for a fix from Apple.
		//        If you do enableBackgroundingOnSocket on the simulator,
		//        you will simply see an error message from the xmpp stack when it fails to set the property.
		
		xmppStream.enableBackgroundingOnSocket = YES;
	}
#endif
	
	// Setup reconnect
	//
	// The XMPPReconnect module monitors for "accidental disconnections" and
	// automatically reconnects the stream for you.
	// There's a bunch more information in the XMPPReconnect header file.
	
	xmppReconnect = [[XMPPReconnect alloc] init];
	
	// Setup roster
	//
	// The XMPPRoster handles the xmpp protocol stuff related to the roster.
	// The storage for the roster is abstracted.
	// So you can use any storage mechanism you want.
	// You can store it all in memory, or use core data and store it on disk, or use core data with an in-memory store,
	// or setup your own using raw SQLite, or create your own storage mechanism.
	// You can do it however you like! It's your application.
	// But you do need to provide the roster with some storage facility.
	
	xmppRosterStorage = [[XMPPRosterCoreDataStorage alloc] init];
    //	xmppRosterStorage = [[XMPPRosterCoreDataStorage alloc] initWithInMemoryStore];
	
	xmppRoster = [[XMPPRoster alloc] initWithRosterStorage:xmppRosterStorage];
	
	xmppRoster.autoFetchRoster = YES;
	xmppRoster.autoAcceptKnownPresenceSubscriptionRequests = YES;
	
	// Setup vCard support
	//
	// The vCard Avatar module works in conjuction with the standard vCard Temp module to download user avatars.
	// The XMPPRoster will automatically integrate with XMPPvCardAvatarModule to cache roster photos in the roster.
	
	xmppvCardStorage = [XMPPvCardCoreDataStorage sharedInstance];
	xmppvCardTempModule = [[XMPPvCardTempModule alloc] initWithvCardStorage:xmppvCardStorage];
	
	xmppvCardAvatarModule = [[XMPPvCardAvatarModule alloc] initWithvCardTempModule:xmppvCardTempModule];
	
	// Setup capabilities
	//
	// The XMPPCapabilities module handles all the complex hashing of the caps protocol (XEP-0115).
	// Basically, when other clients broadcast their presence on the network
	// they include information about what capabilities their client supports (audio, video, file transfer, etc).
	// But as you can imagine, this list starts to get pretty big.
	// This is where the hashing stuff comes into play.
	// Most people running the same version of the same client are going to have the same list of capabilities.
	// So the protocol defines a standardized way to hash the list of capabilities.
	// Clients then broadcast the tiny hash instead of the big list.
	// The XMPPCapabilities protocol automatically handles figuring out what these hashes mean,
	// and also persistently storing the hashes so lookups aren't needed in the future.
	//
	// Similarly to the roster, the storage of the module is abstracted.
	// You are strongly encouraged to persist caps information across sessions.
	//
	// The XMPPCapabilitiesCoreDataStorage is an ideal solution.
	// It can also be shared amongst multiple streams to further reduce hash lookups.
	
	xmppCapabilitiesStorage = [XMPPCapabilitiesCoreDataStorage sharedInstance];
    xmppCapabilities = [[XMPPCapabilities alloc] initWithCapabilitiesStorage:xmppCapabilitiesStorage];
    
    xmppCapabilities.autoFetchHashedCapabilities = YES;
    xmppCapabilities.autoFetchNonHashedCapabilities = NO;
    
	// Activate xmpp modules
    
	[xmppReconnect         activate:xmppStream];
	[xmppRoster            activate:xmppStream];
	[xmppvCardTempModule   activate:xmppStream];
	[xmppvCardAvatarModule activate:xmppStream];
	[xmppCapabilities      activate:xmppStream];
    
	// Add ourself as a delegate to anything we may be interested in
    
	[xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
	[xmppRoster addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
	// Optional:
	//
	// Replace me with the proper domain and port.
	// The example below is setup for a typical google talk account.
	//
	// If you don't supply a hostName, then it will be automatically resolved using the JID (below).
	// For example, if you supply a JID like 'user@quack.com/rsrc'
	// then the xmpp framework will follow the xmpp specification, and do a SRV lookup for quack.com.
	//
	// If you don't specify a hostPort, then the default (5222) will be used.
	
    //[xmppStream setHostName:@"tgserver"];
    //[xmppStream setHostName:OpenFireUrl];
    [xmppStream setHostPort:5222];
    
}

- (void)teardownStream
{
	[xmppStream removeDelegate:self];
	[xmppRoster removeDelegate:self];
	
	[xmppReconnect         deactivate];
	[xmppRoster            deactivate];
	[xmppvCardTempModule   deactivate];
	[xmppvCardAvatarModule deactivate];
	[xmppCapabilities      deactivate];
	
	[xmppStream disconnect];
	
	xmppStream = nil;
	xmppReconnect = nil;
    xmppRoster = nil;
	xmppRosterStorage = nil;
	xmppvCardStorage = nil;
    xmppvCardTempModule = nil;
	xmppvCardAvatarModule = nil;
	xmppCapabilities = nil;
	xmppCapabilitiesStorage = nil;
}

-(void)goOnline{
    //发送在线状态
    XMPPPresence *presence = [XMPPPresence presence];
    if (xmppStream) {
        [xmppStream sendElement:presence];
    }
}

-(void)goOffline{
    //发送下线状态
    
}

-(BOOL)connectWithUserInfo:(XmppUserInfo *)userInfo{
    self.userInfo = userInfo;
    
    isReConnect = FALSE;
    tryCount= 0;
    //登陆房间信息字典
    if (!loginRoomTryDict) {
        loginRoomTryDict = [[NSMutableDictionary alloc] init];
    } else {
        [loginRoomTryDict removeAllObjects];
    }
    
    [self setupStream];
    
    //读取本度缓存的推送信息和用户最后登陆的信息
    [self readPushDataAndLastLoginOutTime];
    
    //从本地取得用户名，密码和服务器地址
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    NSString *userId = [defaults stringForKey:kUserID];
    
    NSString *serverIP = XMPPServerURL;
    NSString *serverDomain = XMPPServerHostName;
    
    if (![self.xmppStream isDisconnected]) {
        return YES;
    }
    
    //设置用户：user1@domain格式的用户名
    XMPPJID *myJid = [XMPPJID jidWithString:[NSString stringWithFormat:@"%@@%@",userInfo.userName,serverDomain]];
    [xmppStream setMyJID:myJid];
    
    //设置服务器
    [xmppStream setHostName:serverIP];
    
    //连接
    NSError *error = nil;
    //    if ( ![xmppStream connect:&error]) {
    if (![xmppStream connectWithTimeout:10 error:&error]) {//新版本的xmpp
        NSLog(@"cant connect %@", serverIP);
        return NO;
    }
    return YES;
}

-(void)timeOutReConnect{
    tryCount ++;
    isReConnect = TRUE;
    NSError *error = nil;
    if (![xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:&error]) {
            NSLog(@"can not connect error:%@", error);
    }
}

//断开连接
-(void)disconnect{
    [self goOffline];
    [xmppStream disconnect];
    
    loginRoomTryDict = nil;
    
    //切断链接
    [xmppStream disconnectAfterSending];
    
    //保存用户最后的登出时间和推送缓存
    [self savePushDataAndLastLoginOutTime];
}

//发送消息
- (void)sendMessage:(Message *)message{
    /*
    if (message == nil) {
        return;
    }
    message.localAudioFlag = 0;
    if (message.messageType == MessageType_User) {
        
        //私聊
        XMPPJID *xmppJid = [XMPPJID jidWithString:[NSString stringWithFormat:@"%d@%@",message.userId,globals.xmppServerHostName]];
        XMPPMessage *xmppMessage = [XMPPMessage messageWithType:@"chat" to:xmppJid elementID:[NSString stringWithFormat:@"%ld", (long)[[NSDate date] timeIntervalSince1970]]];
        
        //消息体
        NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
        NSMutableDictionary *bodyDict = [[NSMutableDictionary alloc] init];
        if (message.contentType == MessageContentType_Image) {
            [bodyDict setObject:message.fileUrl forKey:@"Cnt"];
        } else if(message.contentType == MessageContentType_Audio){
            [bodyDict setObject:[NSString stringWithFormat:@"%@.%d",message.fileUrl,message.timeSpan] forKey:@"Cnt"];
        } else {
            [bodyDict setObject:message.content forKey:@"Cnt"];
        }
        [bodyDict setObject:@"10000" forKey:@"msgType"];
        [bodyDict setObject:[NSString stringWithFormat:@"%d",message.contentType] forKey:@"mtype"];
        
        //json序列化
        NSError *error = nil;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:bodyDict options:NSJSONWritingPrettyPrinted error:&error];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        [body setStringValue:jsonString];
        [xmppMessage addChild:body];
        
        //发送
        NSLog(@"sendXMPPMessage = %@", xmppMessage);
        [xmppStream sendElement:xmppMessage];
        [bodyDict release];
        
    } else if (message.messageType == MessageType_Group){
        
        //群聊
        XMPPJID *xmppJid = [XMPPJID jidWithString:[NSString stringWithFormat:@"%d@conference.%@",message.groupId,globals.xmppServerHostName]];
        XMPPMessage *xmppMessage = [XMPPMessage messageWithType:@"groupchat" to:xmppJid];
        [xmppMessage addAttributeWithName:@"from" stringValue:[NSString stringWithFormat:@"%@@%@",globals.userId,globals.xmppServerHostName]];
        
        //消息体
        NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
        NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];
        if (message.contentType == MessageContentType_Image) {
            [bodyDict setObject:message.fileUrl forKey:@"Cnt"];
        } else if(message.contentType == MessageContentType_Audio){
            [bodyDict setObject:[NSString stringWithFormat:@"%@.%d",message.fileUrl,message.timeSpan] forKey:@"Cnt"];
        } else {
            [bodyDict setObject:message.content forKey:@"Cnt"];
        }
        [bodyDict setObject:@"10000" forKey:@"msgType"];
        [bodyDict setObject:[NSString stringWithFormat:@"%d",message.contentType] forKey:@"mtype"];
        
        //json序列化
        NSError *error = nil;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:bodyDict options:NSJSONWritingPrettyPrinted error:&error];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        [body setStringValue:jsonString];
        [xmppMessage addChild:body];
        
        //发送
        NSLog(@"sendXMPPMessage = %@", xmppMessage);
        [xmppStream sendElement:xmppMessage];
    }
     */
}

#pragma mark - XMPPStream delegate  
//已连接
- (void)xmppStreamDidConnect:(XMPPStream *)sender{
    
    //注册
    if (_isRegister) {
        [XMPPHelper xmppRegisterWithUser:self.userInfo];
        return;
    }

    tryCount= 0;
    isOpen = YES;
    NSError *error = nil;
    
    //持久化登录消息
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:XMPPServerHostName forKey:kXMPPServerDomain];
    [defaults setObject:XMPPServerURL forKey:kXMPPServerIP];
    [defaults synchronize];
    
    NSString *pwd = [defaults stringForKey:kPassword];
    BOOL passFlag = [xmppStream authenticateWithPassword:pwd error:&error];
    //BOOL passFlag = [xmppStream authenticateAnonymously:&error];
    if (passFlag) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        SharedAppDelegate.globals.userId = [defaults objectForKey:kUserID];
        SharedAppDelegate.globals.password = [defaults objectForKey:kPassword];
        SharedAppDelegate.globals.xmppServerDomain = [defaults objectForKey:kXMPPServerDomain];
        SharedAppDelegate.globals.xmppServerIP = [defaults objectForKey:kXMPPServerIP];
        
        [delegate xmppServerLoginSuccess];
    }else{
        [delegate xmppServerAuthenticateFail];
    }
}

//连接服务器失败
- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    if (error != nil) {
        NSLog(@"xmppStreamDidDisconnect withError = %@", error);
        //超时重连 （7:连上的服务器被断开）
        if (tryCount < XMPPRequest_MaxTime && [error code] != 7) {
            [self timeOutReConnect];
        }
        //失败
        else {
            tryCount = 0;
            [delegate xmppServerLoginFail];
        }
    }else{
        [delegate xmppServerLoginFail];
    }
}

//验证通过
- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    [self goOnline];
    
    [self loginAllRoom];
}

/**
 * These methods are called after their respective XML elements are received on the stream.
 *
 * In the case of an IQ, the delegate method should return YES if it has or will respond to the given IQ.
 * If the IQ is of type 'get' or 'set', and no delegates respond to the IQ,
 * then xmpp stream will automatically send an error response.
 *
 * Concerning thread-safety, delegates shouldn't modify the given elements.
 * As documented in NSXML / KissXML, elements are read-access thread-safe, but write-access thread-unsafe.
 * If you have need to modify an element for any reason,
 * you should copy the element first, and then modify and use the copy.
 *
 */
- (void)xmppStreamDidRegister:(XMPPStream *)sender{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.userInfo.userName forKey:kUserID];
    [defaults setObject:self.userInfo.password forKey:kPassword];
    [defaults synchronize];
    
    [SVProgressHUD dismissWithSuccess:@"注册成功" afterDelay:1.0];
    
    self.isRegister = NO;
    
    XMPPMsg *aXmppMsg = [[XMPPMsg alloc] init];
    aXmppMsg.msgType = XMPPTypeRegisterSuccess;
    [[NSNotificationCenter defaultCenter] postNotificationName:kNoti_XMPP_didReceiveXMPPMsg object:aXmppMsg userInfo:nil];
}

/** This method is called if registration fails. */
- (void)xmppStream:(XMPPStream *)sender didNotRegister:(NSXMLElement *)error{
    NSLog(@"xmppStream:(XMPPStream *)sender didNotRegister:(NSXMLElement *)error");
}

/*
 名册
 <iq xmlns="jabber:client" from="192.168.2.119" type="result" id="1234567" to="caoh@192.168.2.119/tigase-1">
    <query xmlns="jabber:iq:roster">
        <item name="zengjh" jid="zengjh192.168.2.119@192.168.2.119" subscription="none" ask="subscribe">
            <group>好友</group>
        </item>
        <item name="zengjh" jid="zengjh@192.168.2.119" subscription="both">
            <group>好友</group>
        </item>
        <item name="caoh2" jid="caoh2@192.168.2.119" subscription="to"/>
        <item name="xialu" jid="xialu@192.168.2.119" subscription="from"/>
    </query>
 </iq>
 */

- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq{
    
    
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    //NSString *userId = [[sender myJID] user];//当前用户
    
    XMPPMsg *aXmppMsg = [[XMPPMsg alloc] init];
    
    if ([@"result" isEqualToString:iq.type]) {
        NSXMLElement *childEle = iq.childElement;
        
        //1:查询名册结果
        if ([@"query" isEqualToString:childEle.name]) {
            aXmppMsg.msgType = XMPPTypeIQQueryResult;
            
            NSArray *items = [childEle children];
            NSMutableArray *users = [NSMutableArray array];
            for (NSXMLElement *item in items) {
                //订阅签署状态
                NSString *subscription = [item attributeStringValueForName:@"subscription"];
                NSString *jidStr = [item attributeStringValueForName:@"jid"];
                
                XMPPJID *jid = [XMPPJID jidWithString:jidStr];
                User *aUser = [[User alloc] init];
                aUser.subscribe = subscription;
                aUser.userId = jid.user;
                
                //好友：双方通过
                if ([subscription isEqualToString:@"both"]) {
                    //群组：
                    NSArray *groups = [item elementsForName:@"group"];
                    for (NSXMLElement *groupElement in groups) {
                        NSString *groupName = groupElement.stringValue;
                        aUser.groupId = groupName;
                        NSLog(@"didReceiveIQ----xmppJID:%@ , in group:%@",jid,groupName);
                        //[[XMPPServer xmppRoster] addUser:xmppJID withNickname:@""];
                    }
                }
                //对方请求加为好友
                else if ([subscription isEqualToString:@"from"]){
                    
                }
                //请求加为好友，未认证通过的
                else if ([subscription isEqualToString:@"to"]){
                    
                }
                [users addObject:aUser];
            }
            
            //BOOL delFlag = [[BaseDao sharedInstance] deleteDbModel:[[User alloc] init]];
            BOOL delFlag = [[BaseDao sharedInstance] deleteDbModel:[[User alloc] init] withConditionBeanArray:nil];
            if (delFlag) {
                [[BaseDao sharedInstance] insertDBModelArray:users];
            }
        }
    }
    
    //xmpp消息通知
    [[NSNotificationCenter defaultCenter] postNotificationName:kNoti_XMPP_didReceiveXMPPMsg object:aXmppMsg userInfo:nil];
    
    return YES;
}

/*
 收到消息
 
 <message
     to='romeo@example.net'
     from='juliet@example.com/balcony'
     type='chat'
     xml:lang='en'>
     <body>Wherefore art thou, Romeo?</body>
 </message>
 
 */
- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message{
    /*
    NSString *type = [[message attributeForName:@"type"] stringValue];
    NSString *from = [[message attributeForName:@"from"] stringValue];  //发送者
    NSString *to = [[message attributeForName:@"to"] stringValue];      //接收者
    XMPPJID *fromJID = [XMPPJID jidWithString:from];
    XMPPJID *toJID = [XMPPJID jidWithString:to];
    
    XMPPMsg *aXmppMsg = [[XMPPMsg alloc] init];
    aXmppMsg.senderId = from;
    aXmppMsg.targetId = to;
    aXmppMsg.sendTime = [NSDate date];
    
    NSString *msgContent = [[message elementForName:@"body"] stringValue];
    if (msgContent) {
        aXmppMsg.content = msgContent;
        if ([@"chat" isEqualToString:type]) {
            aXmppMsg.msgType = XMPPTypeMessagePersonalNormal;
        }else{
            aXmppMsg.msgType = XMPPTypeMessageGroupNormal;
        }

        //信息入库
        Message *aMsg = [[Message alloc] init];
        aMsg.messageType = [NSString stringWithFormat:@"%d",ConversationTypePersonalChat];
        aMsg.chatUserId = fromJID.user;
        aMsg.chatUserJID = from;
        aMsg.isFrom = @"1";//1表示接收到得，0表示发送的
        aMsg.sendTime = [NSDate date];
        aMsg.content = msgContent;
        [[BaseDao sharedInstance] insertDBModel:aMsg];
        
        //会话入库
        Session *aSession = [[Session alloc] init];
        aSession.senderId = from;
        aSession.lastMsg = msgContent;
        aSession.lastestMsgTime = [NSDate date];
        aSession.conversationType = [NSString stringWithFormat:@"%d",ConversationTypePersonalChat];
        aSession.detailType = [NSString stringWithFormat:@"%d",ConversationTypePersonalChat];
        BOOL optFlag = [ConversationDao insertOrUpdateSession:aSession];
        if (optFlag) {
            NSLog(@"插入聊天信息session成功");
        }
        
        //播放消息
        [SharedAppDelegate.globals globalSystemSoundPlay];
    }
    
    //正在输入
    else{
        NSXMLElement *composingElement = [message elementForName:@"composing"];
        NSXMLElement *pausedElement = [message elementForName:@"paused"];
        if (composingElement) {
            NSLog(@"%@正在输入",from);
            aXmppMsg.msgType = XMPPTypeMessageIsComposing;
        }else if (pausedElement){
            NSLog(@"%@停止输入",from);
            aXmppMsg.msgType = XMPPTypeMessageHasPaused;
        }
    }
    
    //xmpp消息通知
    [[NSNotificationCenter defaultCenter] postNotificationName:kNoti_XMPP_didReceiveXMPPMsg object:aXmppMsg userInfo:nil];
    */
    
    // A simple example of inbound message handling.
    if([message hasChatState] && ![message isErrorMessage])
    {
        //OTRManagedBuddy * messageBuddy = [self buddyWithMessage:message inContext:context];
        if([message isComposingChatState]){
            //[messageBuddy receiveChatStateMessage:kOTRChatStateComposing];
        }
        
        else if([message isPausedChatState]){
           //[messageBuddy receiveChatStateMessage:kOTRChatStatePaused];
        }
        
        else if([message isActiveChatState]){
             //[messageBuddy receiveChatStateMessage:kOTRChatStateActive];
        }
        
        else if([message isInactiveChatState]){
            //[messageBuddy receiveChatStateMessage:kOTRChatStateInactive];
        }
            
        else if([message isGoneChatState]){
             //[messageBuddy receiveChatStateMessage:kOTRChatStateGone];
        }
           
    }
    
    if ([message hasReceiptResponse] && ![message isErrorMessage]) {
        //[OTRManagedMessage receivedDeliveryReceiptForMessageID:[message receiptResponseID]];
    }
    
	if ([message isMessageWithBody] && ![message isErrorMessage])
	{
        NSString *body = [[message elementForName:@"body"] stringValue];
        
        /*
        OTRManagedBuddy * messageBuddy = [self buddyWithMessage:message inContext:context];
        
        NSDate * date = [message delayedDeliveryDate];
        
        OTRManagedMessage *otrMessage = [OTRManagedMessage newMessageFromBuddy:messageBuddy message:body encrypted:YES delayedDate:date inContext:context];
        [context MR_saveToPersistentStoreAndWait];
        
        [OTRCodec decodeMessage:otrMessage completionBlock:^(OTRManagedMessage *message) {
            [OTRManagedMessage showLocalNotificationForMessage:message];
        }];
         */
	}
    
    
    /*
     NSDictionary *bodyDict = [Globals JsonStringToDict:[[message elementForName:@"body"] stringValue]];
     NSInteger msgType = [[bodyDict objectForKey:@"msgType"] intValue];
     switch (msgType) {
     case 10000:// 即时消息
     [self didReceiveCharMessage:message bodyDict:bodyDict];
     break;
     case 10001:// 學生處理(加人，删人)
     [self didReceiveSyncUserInfoMessage:message operationType:msgType bodyDict:bodyDict];
     break;
     case 10002:// 群组操作(新建群组/删除群组/修改群组/添加群成员/删除群成员)
     [self didReceiveGroupDealMessage:message bodyDict:bodyDict];
     break;
     case 10003:// 布置作业
     [self didReceiveOperationMessage:message operationType:msgType bodyDict:bodyDict];
     break;
     case 10004:// 教师点评
     [self didReceiveOperationMessage:message operationType:msgType bodyDict:bodyDict];
     break;
     case 10005:// 班级通知
     [self didReceiveOperationMessage:message operationType:msgType bodyDict:bodyDict];
     break;
     case 10006:// 学习成绩
     [self didReceiveOperationMessage:message operationType:msgType bodyDict:bodyDict];
     break;
     case 10007:// 课程表
     [self didReceiveOperationMessage:message operationType:msgType bodyDict:bodyDict];
     break;
     case 10008:// 学校公告
     [self didReceiveOperationMessage:message operationType:msgType bodyDict:bodyDict];
     break;
     case 10009:// 学生奖励
     [self didReceiveOperationMessage:message operationType:msgType bodyDict:bodyDict];
     break;
     case 10010:// 学生考勤
     [self didReceiveOperationMessage:message operationType:msgType bodyDict:bodyDict];
     break;
     case 10012:// 學生處理(用户资料变更)
     [self didReceiveSyncUserInfoMessage:message operationType:msgType bodyDict:bodyDict];
     break;
     case 10013:// 发送信息成功的返回
     [self didReceiveMessageSuccess:message bodyDict:bodyDict];
     break;
     case 10014:// 空间动态
     [self didReceiveOperationMessage:message operationType:msgType bodyDict:bodyDict];
     break;
     case 10015:// 强制数据库刷新
     [self didReceiveRefreshDatabase:message bodyDict:bodyDict];
     break;
     default:
     break;
     }
     */
}

/*
 
 收到好友状态
<presence xmlns="jabber:client"
    from="user3@chtekimacbook-pro.local/ch&#x7684;MacBook Pro"
    to="user2@chtekimacbook-pro.local/7b55e6b">
    <priority>0</priority>
    <c xmlns="http://jabber.org/protocol/caps" node="http://www.apple.com/ichat/caps" ver="900" ext="ice recauth rdserver maudio audio rdclient mvideo auxvideo rdmuxing avcap avavail video"/>
     <x xmlns="http://jabber.org/protocol/tune"/>
     <x xmlns="vcard-temp:x:update">
        <photo>E10C520E5AE956E659A0DBC5C7F48E12DF9BE6EB</photo>
     </x>
 </presence>
 */
- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    if ([presence isErrorPresence]) {
        //登陆失败
    }
    
    NSString *presenceType = [presence type]; //取得好友状态
    NSString *userId = [[sender myJID] user];//当前用户
    NSString *presenceFromUser = [[presence from] user];//在线用户
    
    //群上线
    NSRange range =[[[presence attributeForName:@"from"] stringValue] rangeOfString:@"conference"];
    if (range.location != NSNotFound){
        return;
    }

    NSLog(@"didReceivePresence---- presenceType:%@,用户:%@",presenceType,presenceFromUser);
    XMPPMsg *aXmppMsg = [[XMPPMsg alloc] init];
    aXmppMsg.senderId = presenceFromUser;
    aXmppMsg.sendTime = [NSDate date];

    if (![presenceFromUser isEqualToString:userId]) {
        //用户上线
        if ([presenceType isEqualToString:@"available"]) {
            aXmppMsg.msgType = XMPPTypePresenceAvailable;
            [_onlineDict setObject:@"online" forKey:presenceFromUser];
            
            [SharedAppDelegate showRemarkMsg:[NSString stringWithFormat:@"%@ is Online",presenceFromUser]];
        }
        
        //用户下线
        else if ([presenceType isEqualToString:@"unavailable"]) {
            aXmppMsg.msgType = XMPPTypePresenceUnavailable;
            if ([_onlineDict objectForKey:presenceFromUser]) {
                [_onlineDict removeObjectForKey:presenceFromUser];
            }
            
            [SharedAppDelegate showRemarkMsg:[NSString stringWithFormat:@"%@ is Offline",presenceFromUser]];
        }
        
        //用户请求添加好友
        else if ([presenceType isEqualToString:@"subscribe"]) {
            aXmppMsg.msgType = XMPPTypePresenceSubscribe;
            [XMPPHelper xmppDidReceiveSubscribeRequest:presenceFromUser type:XMPPTypePresenceSubscribe];
        }
        
        //这里再次加好友:如果请求的用户返回的是同意添加
        else if ([presenceType isEqualToString:@"subscribed"]) {
            aXmppMsg.msgType = XMPPTypePresenceSubscribed;
            [XMPPHelper xmppDidReceiveSubscribeRequest:presenceFromUser type:XMPPTypePresenceSubscribed];
            //XMPPJID *jid = [XMPPJID jidWithString:[NSString stringWithFormat:@"%@",[presence from]]];
            //[[XMPPServer xmppRoster] acceptPresenceSubscriptionRequestFrom:jid andAddToRoster:YES];
        }
        //用户请求拒绝添加好友
        else if ([presenceType isEqualToString:@"unsubscrib"]) {
            aXmppMsg.msgType = XMPPTypePresenceUnsubscribe;
            [XMPPHelper xmppDidReceiveSubscribeRequest:presenceFromUser type:XMPPTypePresenceUnsubscribe];
        }
        //用户拒绝添加好友
        else if ([presenceType isEqualToString:@"unsubscribed"]) {
            aXmppMsg.msgType = XMPPTypePresenceUnsubscribed;
            [XMPPHelper xmppDidReceiveSubscribeRequest:presenceFromUser type:XMPPTypePresenceUnsubscribed];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kNoti_XMPP_didReceiveXMPPMsg object:aXmppMsg];
    }
}

#pragma mark - Delegate: XMPPRoomStorage
- (void)handlePresence:(XMPPPresence *)presence room:(XMPPRoom *)room{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    NSXMLElement *x = [presence elementForName:@"x" xmlns:XMPPMUCUserNamespace];
    NSArray *status = [x elementsForName:@"status"];
    if ([status isKindOfClass:[NSArray class]] && [status count] > 0 && [[status objectAtIndex:0] attributeIntValueForName:@"code"] == 201){
        //登陆房间失败,重联三次
        NSInteger loginRoomtryCount = [[loginRoomTryDict objectForKey:room.myRoomJID.user] intValue];
        if (loginRoomtryCount < XMPPRequest_MaxTime) {
            loginRoomtryCount ++;
            [loginRoomTryDict setObject:[NSString stringWithFormat:@"%d",loginRoomtryCount] forKey:room.myRoomJID.user];
            NSLog(@"登陆房间%@失败，开始第%d次重联尝试",room.myRoomJID.user,loginRoomtryCount);
            
            NSLog(@"begin loginRoom %@",room.myRoomJID.user);
            
            XMPPJID *roomJID = [XMPPJID jidWithString:[NSString stringWithFormat:@"%@@conference.%@",room.myRoomJID.user,globals.xmppServerDomain]];
            xmppRoom = [[XMPPRoom alloc] initWithRoomStorage:self jid:roomJID];
            [xmppRoom activate:xmppStream];
            NSXMLElement *history = [NSXMLElement elementWithName:@"history"];
            [history addAttributeWithName:@"since" stringValue:[GlobalHandler handleDateToStr_Format:[NSDate date]]];
            [xmppRoom addDelegate:self delegateQueue:dispatch_get_current_queue()];
            [xmppRoom joinRoomUsingNickname:globals.userId history:history];
        }
    } else {
        //登陆房间成功后移除其失败记录
        if ([room.myRoomJID.user length] > 0) {
            [loginRoomTryDict removeObjectForKey:room.myRoomJID.user];
        }
    }
}

- (void)handleIncomingMessage:(XMPPMessage *)message room:(XMPPRoom *)room{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)handleOutgoingMessage:(XMPPMessage *)message room:(XMPPRoom *)room{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (BOOL)configureWithParent:(XMPPRoom *)aParent queue:(dispatch_queue_t)queue{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
	return YES;
}

- (void)handleDidLeaveRoom:(XMPPRoom *)room{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}


#pragma mark - XMPPRoster delegate
/**
 * Sent when a presence subscription request is received.
 * That is, another user has added you to their roster,
 * and is requesting permission to receive presence broadcasts that you send.
 *
 * The entire presence packet is provided for proper extensibility.
 * You can use [presence from] to get the JID of the user who sent the request.
 *
 * The methods acceptPresenceSubscriptionRequestFrom: and rejectPresenceSubscriptionRequestFrom: can
 * be used to respond to the request.
 *
 *  好友添加请求
 
 <presence xmlns="jabber:client" from="rend@192.168.2.119" type="subscribe" to="caoh@192.168.2.119">
    <x xmlns="vcard-temp:x:update">
        <photo>44b4d2660bbb0594d7029f71ae1ce5e50fd76608</photo>
    </x>
    <x xmlns="jabber:x:avatar">
        <hash>44b4d2660bbb0594d7029f71ae1ce5e50fd76608</hash>
    </x>
    <c xmlns="http://jabber.org/protocol/caps" hash="sha-1" node="http://vacuum-im.googlecode.com" ver="nvOfScxvX/KRll5e2pqmMEBIls0="/>
 </presence>
 */
//收到添加好友的请求  
- (void)xmppRoster:(XMPPRoster *)sender didReceivePresenceSubscriptionRequest:(XMPPPresence *)presence{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    //好友状态
    NSString *presenceType = [NSString stringWithFormat:@"%@", [presence type]];
    //请求的用户
    NSString *presenceFromUser =[NSString stringWithFormat:@"%@", [[presence from] user]];
    NSLog(@"didReceivePresenceSubscriptionRequest----presenceType:%@,用户：%@,presence:%@",presenceType,presenceFromUser,presence);
    
    //好友添加请求:presence xmlns="jabber:client" from="caoh3@192.168.2.119" type="subscribe" to="caoh@192.168.2.119"/>
    if ([@"subscribe" isEqualToString:presenceType]) {
        [XMPPHelper xmppDidReceiveSubscribeRequest:presenceFromUser type:XMPPTypePresenceSubscribe];
        //XMPPJID *jid = [XMPPJID jidWithString:presenceFromUser];
        //[[XMPPServer xmppRoster] acceptPresenceSubscriptionRequestFrom:jid andAddToRoster:YES];
    }
}

/**
 * Sent when a Roster Push is received as specified in Section 2.1.6 of RFC 6121.
 *  
 * 添加好友、好友确认、删除好友
    
 //请求添加user6@chtekimacbook-pro.local 为好友
 <iq xmlns="jabber:client" type="set" id="880-334" to="user2@chtekimacbook-pro.local/f3e9c656">
    <query xmlns="jabber:iq:roster">
        <item jid="user6@chtekimacbook-pro.local" ask="subscribe" subscription="none"/>
    </query>
 </iq>

 //用户6确认后：
 <iq xmlns="jabber:client" type="set" id="880-334" to="user2@chtekimacbook-pro.local/662d302c"><query xmlns="jabber:iq:roster"><item jid="user6@chtekimacbook-pro.local" ask="subscribe" subscription="none"/></query></iq>
 
 //删除用户6：？？？
 <iq xmlns="jabber:client" type="set" id="592-372" to="user2@chtekimacbook-pro.local/c8f2ab68"><query xmlns="jabber:iq:roster"><item jid="user6@chtekimacbook-pro.local" ask="unsubscribe" subscription="from"/></query></iq>
  
 <iq xmlns="jabber:client" type="set" id="954-374" to="user2@chtekimacbook-pro.local/c8f2ab68"><query xmlns="jabber:iq:roster"><item jid="user6@chtekimacbook-pro.local" ask="unsubscribe" subscription="none"/></query></iq>

 <iq xmlns="jabber:client" type="set" id="965-376" to="user2@chtekimacbook-pro.local/e799ef0c"><query xmlns="jabber:iq:roster"><item jid="user6@chtekimacbook-pro.local" subscription="remove"/></query></iq>
  */
- (void)xmppRoster:(XMPPRoster *)sender didReceiveRosterPush:(XMPPIQ *)iq{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

/**
 * Sent when the initial roster is received.
 *
 */
- (void)xmppRosterDidBeginPopulating:(XMPPRoster *)sender{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

/**
 * Sent when the initial roster has been populated into storage.
 *
 */
//获取完好友列表
- (void)xmppRosterDidEndPopulating:(XMPPRoster *)sender{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

/**
 * Sent when the roster recieves a roster item.
 *
 * Example:
 *
 * <item jid='romeo@example.net' name='Romeo' subscription='both'>
 *   <group>Friends</group>
 * </item>
 *
 */

//获取到一个好友节点
- (void)xmppRoster:(XMPPRoster *)sender didRecieveRosterItem:(NSXMLElement *)item{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
//    NSString *jid = [item attributeStringValueForName:@"jid"];
//    NSString *name = [item attributeStringValueForName:@"name"];
//    NSString *subscription = [item attributeStringValueForName:@"subscription"];
    
//    DDXMLNode *node = [item childAtIndex:0];
//    node
//    NSXMLElement *groupElement = [item elementForName:@"group"];
//    NSString *group = [groupElement attributeStringValueForName:@"group"];
    
//    NSLog(@"didRecieveRosterItem:  jid=%@,name=%@,subscription=%@,group=%@",jid,name,subscription);
    
}

#pragma mark - customized: General
-(BOOL)isONline:(NSInteger)userId{
    return [_onlineDict objectForKey:[NSString stringWithFormat:@"%d",userId]] != nil;
}

-(void)loginAllRoom{
    /*
    //建立全部房间链接以接收群聊消息
    NSMutableArray *groupInfoArray = [groupDataManager getAllGroupBaseInfo];
    for (Group *groupInfo in groupInfoArray) {
        NSInteger groupId = groupInfo.groupId;
        if (groupId > 0) {
            XMPPJID *roomJID = [XMPPJID jidWithString:[NSString stringWithFormat:@"%d@conference.%@",groupId,globals.openFireHostName]];
            xmppRoom = [[XMPPRoom alloc] initWithRoomStorage:self jid:roomJID];
            [xmppRoom activate :xmppStream];
            NSXMLElement *history = [NSXMLElement elementWithName:@"history"];
            [history addAttributeWithName:@"since" stringValue:[Globals dateToStr_Format:isReConnect?[NSDate date]:[NSDate dateWithTimeIntervalSince1970:globals.lastLoginOutTime]]];
            [xmppRoom addDelegate:self delegateQueue:dispatch_get_main_queue()];
            [xmppRoom joinRoomUsingNickname:[NSString stringWithFormat:@"%d",globals.userId] history:history];
            
            NSLog(@"loginRoom %d since:%@",groupId,[Globals dateToStr_Format:isReConnect?[NSDate dateWithTimeIntervalSinceNow:-2]:[NSDate dateWithTimeIntervalSince1970:globals.lastLoginOutTime]]);
        }
    }
     */
}

-(void)loginRoomById:(NSInteger)groupId{
    /*
    if (LOG_SWITCH_OPENFIRESERVER) {
        NSLog(@"begin loginRoom %d",groupId);
    }
    XMPPJID *roomJID = [XMPPJID jidWithString:[NSString stringWithFormat:@"%d@conference.%@",groupId,globals.openFireHostName]];
    xmppRoom = [[XMPPRoom alloc] initWithRoomStorage:self jid:roomJID];
    [xmppRoom activate:xmppStream];
    NSXMLElement *history = [NSXMLElement elementWithName:@"history"];
    [history addAttributeWithName:@"since" stringValue:[Globals dateToStr_Format:[NSDate dateWithTimeIntervalSince1970:globals.lastLoginOutTime]]];
    [xmppRoom addDelegate:self delegateQueue:dispatch_get_current_queue()];
    [xmppRoom joinRoomUsingNickname:[NSString stringWithFormat:@"%d",globals.userId] history:history];
     */
}

-(void)savePushDataAndLastLoginOutTime{
    /*
    NSString *userDataFilePath = [PathService pathForDataFileOfUser:globals.userId];
    NSMutableDictionary *userDataDictionary = [NSMutableDictionary dictionaryWithContentsOfFile:userDataFilePath];
    if (userDataDictionary == nil) {
        userDataDictionary = [NSMutableDictionary dictionary];
    }
    if (operateDataDict == nil) {
        [userDataDictionary removeObjectForKey:@"userPushData"];
    } else {
        [userDataDictionary setObject:operateDataDict forKey:@"userPushData"];
    }
    if (globals.lastLoginOutTime) {
        [userDataDictionary setObject:[NSString stringWithFormat:@"%f",globals.lastLoginOutTime] forKey:@"lastLoginOutTime"];
    }
    [userDataDictionary writeToFile:userDataFilePath atomically:TRUE];
     */
}

-(void)readPushDataAndLastLoginOutTime{
    /*
    //添加推送数据缓存
    NSString *userDataFilePath = [PathService pathForDataFileOfUser:globals.userId];
    NSMutableDictionary *userDataDictionary = [NSMutableDictionary dictionaryWithContentsOfFile:userDataFilePath];
    NSMutableDictionary *userPushData = [userDataDictionary objectForKey:@"userPushData"];
    NSTimeInterval lastLoginOutTime = [[userDataDictionary objectForKey:@"lastLoginOutTime"] doubleValue];
    if (lastLoginOutTime) {
        globals.lastLoginOutTime = lastLoginOutTime;
    }
    if (userPushData != nil) {
        operateDataDict = [userPushData retain];
        //清空先
        globals.unreadOperateNumbers = 0;
        globals.unreadClassZoneNumbers = 0;
        //读取缓存
        NSArray *keyArray = [operateDataDict allKeys];
        for (NSString *key in keyArray) {
            NSMutableArray *operateArray = [operateDataDict objectForKey:key];
            if ([key intValue] != XMPPOperationType_ClassZone) {
                globals.unreadOperateNumbers += [operateArray count];
                [[NSNotificationCenter defaultCenter] postNotificationName:LOCAL_NOTIFICATION_GET_OPERATEID object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:key,@"msgType", nil]];
            } else {
                globals.unreadClassZoneNumbers += [operateArray count];
                [[NSNotificationCenter defaultCenter] postNotificationName:LOCAL_NOTIFICATION_GET_CLASSZONEID object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:key,@"msgType", nil]];
            }
        }
    }
     */
}

-(NSArray *)getOperateIdArray:(NSInteger)operateType{
    NSArray *operateDataIdArray =  [operateDataDict objectForKey:[NSString stringWithFormat:@"%d",operateType]];
    return operateDataIdArray;
}

-(BOOL)removeOperateIdByOperateType:(NSInteger)operateType operateCount:(NSInteger)operateCount{
    /*
    NSMutableArray *operateDataIdArray =  [operateDataDict objectForKey:[NSString stringWithFormat:@"%d",operateType]];
    if (operateDataIdArray && operateCount <= [operateDataIdArray count]) {
        [operateDataIdArray removeObjectsInRange:NSMakeRange(0, operateCount)];
        if (operateType != XMPPOperationType_ClassZone) {
            globals.unreadOperateNumbers -= operateCount;
            [[NSNotificationCenter defaultCenter] postNotificationName:LOCAL_NOTIFICATION_GET_OPERATEID object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d",operateType],@"msgType", nil]];
        } else {
            globals.unreadClassZoneNumbers -= operateCount;
            [[NSNotificationCenter defaultCenter] postNotificationName:LOCAL_NOTIFICATION_GET_CLASSZONEID object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d",operateType],@"msgType", nil]];
        }
        return TRUE;
    }
     */
    return FALSE;
}

-(BOOL)removeOperateIdByOperateType:(NSInteger)operateType{
    /*
    NSMutableArray *operateDataIdArray =  [operateDataDict objectForKey:[NSString stringWithFormat:@"%d",operateType]];
    if (operateDataIdArray) {
        if (operateType != XMPPOperationType_ClassZone) {
            globals.unreadOperateNumbers -= [operateDataIdArray count];
            [operateDataDict removeObjectForKey:[NSString stringWithFormat:@"%d",operateType]];
            [[NSNotificationCenter defaultCenter] postNotificationName:LOCAL_NOTIFICATION_GET_OPERATEID object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d",operateType],@"msgType", nil]];
        } else {
            globals.unreadClassZoneNumbers -= [operateDataIdArray count];
            [operateDataDict removeObjectForKey:[NSString stringWithFormat:@"%d",operateType]];
            [[NSNotificationCenter defaultCenter] postNotificationName:LOCAL_NOTIFICATION_GET_CLASSZONEID object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d",operateType],@"msgType", nil]];
        }
        return TRUE;
    }
     */
    return FALSE;
}

-(NSInteger )getOperateArrayCount:(NSInteger)operateType{
    NSArray *operateDataIdArray =  [operateDataDict objectForKey:[NSString stringWithFormat:@"%d",operateType]];
    return [operateDataIdArray count];
}


@end
