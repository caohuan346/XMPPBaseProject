//
//  BuddyViewController.m
//  BaseProject
//
//  Created by Huan Cho on 13-12-19.
//  Copyright (c) 2013年 ch. All rights reserved.
//

#import "BuddyViewController.h"
#import "ChatViewController.h"
#import "AddBuddyViewCtl.h"
#import "XMPPHelper.h"
#import "Message.h"
#import "User.h"
#import "AppDelegate.h"
/*
 //到服务器上请求联系人名片信息
 - (void)fetchvCardTempForJID:(XMPPJID *)jid;
 
 //请求联系人的名片，如果数据库有就不请求，没有就发送名片请求
 - (void)fetchvCardTempForJID:(XMPPJID *)jid ignoreStorage:(BOOL)ignoreStorage;
 
 //获取联系人的名片，如果数据库有就返回，没有返回空，并到服务器上抓取
 - (XMPPvCardTemp *)vCardTempForJID:(XMPPJID *)jid shouldFetch:(BOOL)shouldFetch;
 
 //更新自己的名片信息
 - (void)updateMyvCardTemp:(XMPPvCardTemp *)vCardTemp;
 
 //获取到一盒联系人的名片信息的回调
 - (void)xmppvCardTempModule:(XMPPvCardTempModule *)vCardTempModule
 didReceivevCardTemp:(XMPPvCardTemp *)vCardTemp
 forJID:(XMPPJID *)jid
 
 */
@interface BuddyViewController (){
}

@property(nonatomic,retain) NSMutableArray *subscribeBothUsers;
@property(nonatomic,retain) NSMutableArray *subscribeFromUsers;
@property(nonatomic,retain) NSMutableArray *subscribeToUsers;

@end

@implementation BuddyViewController

#pragma mark - life circle

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNoti_XMPP_didReceiveXMPPMsg object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //NSLog(@"%@",AppDelegateConstant);
    self.subscribeBothUsers = [NSMutableArray array];
    self.subscribeFromUsers = [NSMutableArray array];
    self.subscribeToUsers = [NSMutableArray array];

    [self initData];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    NSString *userId = [[NSUserDefaults standardUserDefaults] stringForKey:kUserID];
    NSString *pass = [[NSUserDefaults standardUserDefaults] stringForKey:kPassword];
    NSString *server = [[NSUserDefaults standardUserDefaults] stringForKey:kXMPPServerDomain];
    
    if (userId) {
        /*
        if ([[XMPPServer sharedServer] connect]) {
            NSLog(@"show buddy list");
        }
         */
    }else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您还没有设置账号" delegate:self cancelButtonTitle:@"设置" otherButtonTitles:nil, nil];
        [alert show];
        
    }

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveXMPPMsg:) name:kNoti_XMPP_didReceiveXMPPMsg object:nil];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex == 0) {
        //[self toChat];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - private
//init data
-(void)initData{
    [self.subscribeBothUsers removeAllObjects];
    [self.subscribeFromUsers removeAllObjects];
    [self.subscribeToUsers removeAllObjects];
    
    User *queryBean = [[User alloc] init];
    queryBean.subscribe = @"both";
    NSArray *bothUsers = [[BaseDao sharedInstance] query2ObjectArrayWithConditionObject:queryBean];
    self.subscribeBothUsers = [NSMutableArray arrayWithArray:bothUsers];
    
    queryBean.subscribe = @"from";
    NSArray *fromUsers = [[BaseDao sharedInstance] query2ObjectArrayWithConditionObject:queryBean];
    self.subscribeFromUsers = [NSMutableArray arrayWithArray:fromUsers];;
    
    queryBean.subscribe = @"to";
    NSArray *toUsers = [[BaseDao sharedInstance] query2ObjectArrayWithConditionObject:queryBean];
    self.subscribeToUsers = [NSMutableArray arrayWithArray:toUsers];
}

-(void)refreshData{
    [self initData];
    [self.tableView reloadData];
}

//收到xmpp消息
- (void)didReceiveXMPPMsg:(NSNotification*)aNotification{
    XMPPMsg *aMsg = (XMPPMsg *)aNotification.object;
    XMPPType type = aMsg.msgType;
    
    switch (type) {
        case XMPPTypeMessagePersonalNormal:
        case XMPPTypeMessageIsComposing:
        case XMPPTypeMessageHasPaused:
            [self.tableView reloadData];
            break;
            
        case XMPPTypePresenceAvailable:
        case XMPPTypePresenceUnavailable:
        case XMPPTypePresenceSubscribe:
        case XMPPTypePresenceUnsubscribe:
        case XMPPTypePresenceSubscribed:
        case XMPPTypePresenceUnsubscribed:
            [self refreshData];
            break;
        
        case XMPPTypeIQQueryResult:
            [self refreshData];
            break;
        default:
            break;
    }
}


#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section ==0) {
        return self.subscribeBothUsers.count;
    }else if (section == 1){
        return self.subscribeFromUsers.count;
    }else if (section == 2){
        return self.subscribeToUsers.count;
    }
    return 0;
}

- (NSString *)tableView:(UITableView *)sender titleForHeaderInSection:(NSInteger)sectionIndex
{
    if (sectionIndex ==0) {
        return @"好友";
    }else if (sectionIndex == 1){
        return @"陌生人";
    }else if (sectionIndex == 2){
        return @"等待验证";
    }
	return @"";
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *identifier = @"userCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    User *user;
    if (indexPath.section ==0) {
        user = [self.subscribeBothUsers objectAtIndex:indexPath.row];
    }else if (indexPath.section == 1){
        user = [self.subscribeFromUsers objectAtIndex:indexPath.row];
    }else if (indexPath.section == 2){
        user = [self.subscribeToUsers objectAtIndex:indexPath.row];
    }else{
        user = [[User alloc] init];
    }
    
    cell.textLabel.text = user.userId;
    
    //头像
    XMPPJID *jid = [XMPPJID jidWithString:[NSString stringWithFormat:@"%@@%@",user.userId,SharedAppDelegate.globals.xmppServerDomain]];
    UIImage *photo = [XMPPHelper xmppUserPhotoForJID:jid];
    if (photo){
         cell.imageView.image = photo;
    }else{
        cell.imageView.image = [UIImage imageNamed:@"defaultPerson"];
    }
    
    NSDictionary *onlineDic = SharedAppDelegate.xmppServer.onlineDict;
    if (![onlineDic objectForKey:user.userId]) {
        cell.imageView.alpha = 0.5f;
    }else{
        cell.imageView.alpha = 1.0f;
    }
    
    //标记
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

#pragma mark UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self performSegueWithIdentifier:@"chat" sender:self];
    /*
    ChatViewController *chatViewCtl = [[ChatViewController alloc] init];
    
    //start a Chat
    if (indexPath.section == 0) {
        chatViewCtl.chatTargetUser = [self.subscribeBothUsers objectAtIndex:indexPath.row];
    }else if (indexPath.section == 1) {
        chatViewCtl.chatTargetUser = [self.subscribeFromUsers objectAtIndex:indexPath.row];
    }else if (indexPath.section == 2) {
        chatViewCtl.chatTargetUser = [self.subscribeToUsers objectAtIndex:indexPath.row];
    }
   
    [self.navigationController pushViewController:chatViewCtl animated:YES];
     */
}

//tableView的编辑模式中当提交一个编辑操作时候调用：比如删除，添加等
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if(editingStyle == UITableViewCellEditingStyleDelete){
        
        User *user;
        if (indexPath.section ==0) {
            user = [self.subscribeBothUsers objectAtIndex:indexPath.row];
        }else if (indexPath.section == 1){
            user = [self.subscribeFromUsers objectAtIndex:indexPath.row];
        }else if (indexPath.section == 2){
            user = [self.subscribeToUsers objectAtIndex:indexPath.row];
        }else{
            user = [[User alloc] init];
        }
        
        //解除服务器上好友关系:<iq type="set"><query xmlns="jabber:iq:roster"><item jid="user1@openfire" subscription="remove"/></query></iq>
        XMPPJID *jid = [XMPPJID jidWithString:[NSString stringWithFormat:@"%@@%@",user.userId,SharedAppDelegate.globals.xmppServerDomain]];
        [[XMPPServer xmppRoster] removeUser:jid];
        
        //删除数据库中用户表信息
        User *queryBean = [[User alloc] init];
        queryBean.userId = user.userId;
        [[BaseDao sharedInstance] deleteDbModel:queryBean];
        
        //删除数据库中聊天信息
        Message *msgQueryBean = [[Message alloc] init];
        msgQueryBean.chatUserId = user.userId;
        [[BaseDao sharedInstance] deleteDbModel:msgQueryBean];
        
        if (indexPath.section == 0) {
            [self.subscribeBothUsers removeObjectAtIndex:indexPath.row];
        }else if (indexPath.section == 1) {
            [self.subscribeFromUsers removeObjectAtIndex:indexPath.row];
        }else if (indexPath.section == 2) {
            [self.subscribeToUsers removeObjectAtIndex:indexPath.row];
        }
        
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    }
}

#pragma mark - event
- (IBAction)addNewBuddy:(id)sender;{
//    AddBuddyViewCtl *addBuddyCtl = [[AddBuddyViewCtl alloc] init];
//    [self.navigationController pushViewController:addBuddyCtl animated:YES];
    
    [self performSegueWithIdentifier:@"add" sender:self];
}

#pragma mark - segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"chat"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        ChatViewController *chatViewCtl = segue.destinationViewController;
        
        //start a Chat
        if (indexPath.section == 0) {
            chatViewCtl.chatTargetUser = [self.subscribeBothUsers objectAtIndex:indexPath.row];
        }else if (indexPath.section == 1) {
            chatViewCtl.chatTargetUser = [self.subscribeFromUsers objectAtIndex:indexPath.row];
        }else if (indexPath.section == 2) {
            chatViewCtl.chatTargetUser = [self.subscribeToUsers objectAtIndex:indexPath.row];
        }
        
    }
}
@end

