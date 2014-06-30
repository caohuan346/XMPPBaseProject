//
//  MultiUserChatViewCtl.m
//  BaseProject
//
//  Created by Huan Cho on 13-8-3.
//  Copyright (c) 2013年 ch. All rights reserved.
//

#import "MultiUserChatViewCtl.h"
#import "KKMessageCell.h"
#import "XMPPStream.h"
#import "XMPPRoom.h"
#import "XMPPRoomCoreDataStorage.h"
#import "Globals.h"

#define padding 20

@interface MultiUserChatViewCtl (){
    XMPPRoom *_xmppRoom;
}
@property(nonatomic,retain)NSMutableArray *messages;

@end

@implementation MultiUserChatViewCtl

@synthesize roomName = _roomName;
@synthesize tView = _tView;
@synthesize messageTextField = _messageTextField;
@synthesize messages = _messages;

#pragma mark - life circle
- (void)viewDidLoad
{
    
    [super viewDidLoad];
    
    self.tView.delegate = self;
    self.tView.dataSource = self;
    self.tView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self.messageTextField resignFirstResponder];
    
    self.messages = [NSMutableArray array];
    
    [self initRoom];
}

-(void)viewWillAppear:(BOOL)animated{
    self.roomNameLabel.text = self.roomName;
}

- (void)viewDidUnload
{
    [self setTView:nil];
    [self setMessageTextField:nil];
    [self setRoomNameLabel:nil];
    [super viewDidUnload];
}

-(void)viewWillDisappear:(BOOL)animated{
    [_xmppRoom deactivate];
}

//初始化聊天室
-(void)initRoom{
    XMPPRoomCoreDataStorage *rosterstorage = [[XMPPRoomCoreDataStorage alloc] init];
    XMPPRoom *room = [[XMPPRoom alloc] initWithRoomStorage:rosterstorage jid:[XMPPJID jidWithString:self.roomName] dispatchQueue:dispatch_get_main_queue()];
    _xmppRoom = room;
    XMPPStream *stream = [XMPPServer xmppStream];
    [room activate:stream];
    
    [room joinRoomUsingNickname:@"smith" history:nil];
    [room configureRoomUsingOptions:nil];
//    [room fetchConfigurationForm];
    [room addDelegate:self delegateQueue:dispatch_get_main_queue()];
}

//可以创建一个聊天室:room2
/*
-(void)createRoom{
    XMPPRoomCoreDataStorage *rosterstorage = [[XMPPRoomCoreDataStorage alloc] init];
    XMPPRoom *room = [[XMPPRoom alloc] initWithRoomStorage:rosterstorage jid:[XMPPJID jidWithString:@"room2@conference.chtekimacbook-pro.local"] dispatchQueue:dispatch_get_main_queue()];
    [rosterstorage release];
    XMPPStream *stream = [XMPPServer xmppStream];
    [room activate:stream];
    [room joinRoomUsingNickname:@"smith" history:nil];
    [room configureRoomUsingOptions:nil];
    [room addDelegate:self delegateQueue:dispatch_get_main_queue()];
}
 */

#pragma mark - UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.messages count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *identifier = @"msgCell";
    KKMessageCell *cell =(KKMessageCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[KKMessageCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
    }
    NSMutableDictionary *dict = [self.messages objectAtIndex:indexPath.row];
    //发送者
    NSString *sender = [dict objectForKey:@"sender"];
    //消息
    NSString *message = [dict objectForKey:@"msg"];
    //时间
    NSString *time = [dict objectForKey:@"time"];
    CGSize textSize = {260.0 ,10000.0};
    CGSize size = [message sizeWithFont:[UIFont boldSystemFontOfSize:13] constrainedToSize:textSize lineBreakMode:UILineBreakModeWordWrap];
    size.width +=(padding/2);
    cell.messageContentView.text = message;
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.userInteractionEnabled = NO;
    UIImage *bgImage = nil;
    
    //发送消息
    if ([sender isEqualToString:@"me"]) {
        bgImage = [[UIImage imageNamed:@"GreenBubble2.png"] stretchableImageWithLeftCapWidth:14 topCapHeight:15];
        
        [cell.messageContentView setFrame:CGRectMake(320-size.width - padding, padding*2, size.width, size.height)];
        [cell.bgImageView setFrame:CGRectMake(cell.messageContentView.frame.origin.x - padding/2, cell.messageContentView.frame.origin.y - padding/2, size.width + padding, size.height + padding)];
    }else {
        //背景图
        bgImage = [[UIImage imageNamed:@"BlueBubble2.png"] stretchableImageWithLeftCapWidth:20 topCapHeight:15];
        [cell.messageContentView setFrame:CGRectMake(padding, padding*2, size.width, size.height)];
        
        [cell.bgImageView setFrame:CGRectMake(cell.messageContentView.frame.origin.x - padding/2, cell.messageContentView.frame.origin.y - padding/2, size.width + padding, size.height + padding)];
    }
    
    cell.bgImageView.image = bgImage;
    cell.senderAndTimeLabel.text = [NSString stringWithFormat:@"%@ %@", sender, time];
    
    return cell;
    
}

//每一行的高度
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSMutableDictionary *dict  = [self.messages objectAtIndex:indexPath.row];
    NSString *msg = [dict objectForKey:@"msg"];
    
    CGSize textSize = {260.0 , 10000.0};
    CGSize size = [msg sizeWithFont:[UIFont boldSystemFontOfSize:13] constrainedToSize:textSize lineBreakMode:NSLineBreakByWordWrapping];
    
    size.height += padding*2;
    
    CGFloat height = size.height < 65 ? 65 : size.height;
    return height;
}

#pragma mark - private
- (IBAction)sendButton:(id)sender {
    //本地输入框中的信息
    NSString *message = self.messageTextField.text;
    if (message.length > 0) {
        //XMPPFramework主要是通过KissXML来生成XML文件
        //生成<body>文档
        NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
        [body setStringValue:message];
        //生成XML消息文档
        NSXMLElement *mes = [NSXMLElement elementWithName:@"message"];
        //消息类型：群聊
        [mes addAttributeWithName:@"type" stringValue:@"groupchat"];
        //发送给谁
        [mes addAttributeWithName:@"to" stringValue:_roomName];
        //由谁发送
        [mes addAttributeWithName:@"from" stringValue:[[NSUserDefaults standardUserDefaults] stringForKey:kUserID]];
        //组合
        [mes addChild:body];
        //发送消息
        [[XMPPServer xmppStream] sendElement:mes];
        
        self.messageTextField.text = @"";
        [self.messageTextField resignFirstResponder];
        
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
        
        [dictionary setObject:message forKey:@"msg"];
        [dictionary setObject:@"me" forKey:@"sender"];
        //加入发送时间
        [dictionary setObject:[GlobalHandler handleCurrentTimeGet] forKey:@"time"];
        
        [self.messages addObject:dictionary];
        
        //重新刷新tableView
        [self.tView reloadData];
    }
}

#pragma mark - XMPPRoom delegate
//创建结果
-(void)xmppRoomDidCreate:(XMPPRoom *)sender{
    NSLog(@"xmppRoomDidCreate");
}

//是否已经加入房间
-(void)xmppRoomDidJoin:(XMPPRoom *)sender{
    NSLog(@"xmppRoomDidJoin");
    [_xmppRoom fetchConfigurationForm];
    [_xmppRoom fetchBanList];
    [_xmppRoom fetchMembersList];
    [_xmppRoom fetchModeratorsList];
}

//是否已经离开
-(void)xmppRoomDidLeave:(XMPPRoom *)sender{
    NSLog(@"xmppRoomDidLeave");
}

#pragma mark - 房间存在，会调用委托
// 收到禁止名单列表
- (void)xmppRoom:(XMPPRoom *)sender didFetchBanList:(NSArray *)items{
     NSLog(@"%s", __FUNCTION__);
}
// 收到好友名单列表
- (void)xmppRoom:(XMPPRoom *)sender didFetchMembersList:(NSArray *)items{
    NSLog(@"%s", __FUNCTION__);
}
// 收到主持人名单列表
- (void)xmppRoom:(XMPPRoom *)sender didFetchModeratorsList:(NSArray *)items{
    NSLog(@"%s", __FUNCTION__);
}
#pragma mark - 房间不存在，调用委托
- (void)xmppRoom:(XMPPRoom *)sender didNotFetchBanList:(XMPPIQ *)iqError{
    NSLog(@"%s", __FUNCTION__);
}
- (void)xmppRoom:(XMPPRoom *)sender didNotFetchMembersList:(XMPPIQ *)iqError{
    NSLog(@"%s", __FUNCTION__);
}
- (void)xmppRoom:(XMPPRoom *)sender didNotFetchModeratorsList:(XMPPIQ *)iqError{
    NSLog(@"%s", __FUNCTION__);
}

#pragma mark - 
//有人在群里发言
-(void)xmppRoom:(XMPPRoom *)sender didReceiveMessage:(XMPPMessage *)message fromOccupant:(XMPPJID *)occupantJID{
    NSLog(@"xmppRoom:didReceiveMessage:fromOccupant:");
//    NSLog(@"%@,%@,%@",occupantJID.user,occupantJID.domain,occupantJID.resource);
    NSString *msg = [[message elementForName:@"body"] stringValue];
    NSString *from = [[message attributeForName:@"from"] stringValue];
    
    if (![[sender myNickname] isEqualToString:occupantJID.resource]) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        if (msg !=nil) {
            [dict setObject:msg forKey:@"msg"];
//            [dict setObject:from forKey:@"sender"];
            if (occupantJID.resource) {
                [dict setObject:occupantJID.resource forKey:@"sender"];
            }else{
                [dict setObject:from forKey:@"sender"];
            }

            //消息接收到的时间
            [dict setObject:[GlobalHandler handleCurrentTimeGet] forKey:@"time"];
            [self.messages addObject:dict];
            [self.tView reloadData];
        }
    }
}

//房间人员加入
- (void)xmppRoom:(XMPPRoom *)sender occupantDidJoin:(XMPPJID *)occupantJID withPresence:(XMPPPresence *)presence{
    NSLog(@"occupantDidJoin");
    NSString *jid = occupantJID.user;
    NSString *domain = occupantJID.domain;
    NSString *resource = occupantJID.resource;
    NSString *presenceType = [presence type];
    NSString *userId = [sender myRoomJID].user;
    NSString *presenceFromUser = [[presence from] user];
    
    NSLog(@"occupantDidJoin----jid=%@,domain=%@,resource=%@,当前用户:%@ ,出席用户:%@,presenceType:%@",jid,domain,resource,userId,presenceFromUser,presenceType);
    
    if (![presenceFromUser isEqualToString:userId]) {
        //对收到的用户的在线状态的判断在线状态
        
        //在线用户
        if ([presenceType isEqualToString:@"available"]) {
            NSString *buddy = [NSString stringWithFormat:@"%@@%@", presenceFromUser, XMPPServerHostName];
//            [chatDelegate newBuddyOnline:buddy];//用户列表委托
        }
        
        //用户下线
        else if ([presenceType isEqualToString:@"unavailable"]) {
//            [chatDelegate buddyWentOffline:[NSString stringWithFormat:@"%@@%@", presenceFromUser, XMPPServerHostName]];//用户列表委托
        }
    }
}

//房间人员离开
-(void)xmppRoom:(XMPPRoom *)sender occupantDidLeave:(XMPPJID *)occupantJID withPresence:(XMPPPresence *)presence{
    NSString *jid = occupantJID.user;
    NSString *domain = occupantJID.domain;
    NSString *resource = occupantJID.resource;
    NSString *presenceType = [presence type];
    NSString *userId = [sender myRoomJID].user;
    NSString *presenceFromUser = [[presence from] user]; 
    NSLog(@"occupantDidLeave----jid=%@,domain=%@,resource=%@,当前用户:%@ ,出席用户:%@,presenceType:%@",jid,domain,resource,userId,presenceFromUser,presenceType);
}

//房间人员加入
-(void)xmppRoom:(XMPPRoom *)sender occupantDidUpdate:(XMPPJID *)occupantJID withPresence:(XMPPPresence *)presence{
    NSString *jid = occupantJID.user;
    NSString *domain = occupantJID.domain;
    NSString *resource = occupantJID.resource;
    NSString *presenceType = [presence type];
    NSString *userId = [sender myRoomJID].user;
    NSString *presenceFromUser = [[presence from] user]; 
    NSLog(@"occupantDidUpdate----jid=%@,domain=%@,resource=%@,当前用户:%@ ,出席用户:%@,presenceType:%@",jid,domain,resource,userId,presenceFromUser,presenceType);
}


@end
