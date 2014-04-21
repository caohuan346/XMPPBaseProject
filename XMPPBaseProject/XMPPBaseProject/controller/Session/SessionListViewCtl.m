//
//  SessionListViewCtl.m
//  BaseProject
//
//  Created by caohuan on 13-12-19.
//  Copyright (c) 2013年 ch. All rights reserved.
//

#import "SessionListViewCtl.h"
#import "Session.h"
#import "Message.h"
#import "User.h"
#import "AppDelegate.h"
#import "SessionCell.h"
#import "XMPPHelper.h"
#import "ChatViewController.h"
#import "EGORefreshTableHeaderView.h"

@interface SessionListViewCtl (){
    EGORefreshTableHeaderView *_refreshHeaderView;
}

@property(nonatomic,strong)NSArray *sessionList;


@end

@implementation SessionListViewCtl

#pragma mark - life circle

- (void)dealloc
{
     [[NSNotificationCenter defaultCenter] removeObserver:self name:kNoti_XMPP_didReceiveXMPPMsg object:nil];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.sessionList = [NSArray array];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveXMPPMsg:) name:kNoti_XMPP_didReceiveXMPPMsg object:nil];
    
//    EGORefreshTableHeaderView *refreshview = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, -320.0f, self.view.frame.size.width, 320)];
//    refreshview.delegate = self;
//    [self.tableView addSubview:refreshview];
//    _refreshHeaderView = refreshview;

    [self initData];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - custom private
//init data
-(void)initData{
    self.sessionList = [SharedAppDelegate.databaseService.baseDBManager queryDbToObjectArray:[Session class] withConditionObject:nil];
}

//refresh Data
-(void)refreshData{
    [self initData];
    [self.tableView reloadData];
}

//收到xmpp消息
- (void)didReceiveXMPPMsg:(NSNotification*)aNotification{
    XMPPMsg *aMsg = (XMPPMsg *)aNotification.object;
    XMPPType type = aMsg.msgType;
    if (type == XMPPTypeMessagePersonalNormal) {
        NSLog(@"收到来自 %@ 的消息",aMsg.senderId);
    }else if (type == XMPPTypeMessageIsComposing){
        NSLog(@"%@正在输入",aMsg.senderId);
    }else if (type == XMPPTypeMessageHasPaused){
        NSLog(@"%@停止输入",aMsg.senderId);
    }
    [self refreshData];
}


#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.sessionList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SessionCell";
    SessionCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        NSArray *nibs=[[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:self options:nil];
        cell=[nibs objectAtIndex: 0];
    }
    
    Session *aSession = [self.sessionList objectAtIndex:[indexPath row]];
    
    cell.contentLabel.text = aSession.lastMsg;
    cell.timeLabel.text = [NSString stringWithFormat:@"%@",aSession.lastestMsgTime];
    cell.icon.alpha = 1.0f;
    NSInteger sessionType = [aSession.sessionType intValue];
    
    UIImage *iconImage;
    //个人
    if (sessionType == SessionTypePersonalChat) {
        XMPPJID *jid = [XMPPJID jidWithString:[NSString stringWithFormat:@"%@@%@",aSession.senderId,SharedAppDelegate.globals.xmppServerDomain]];
        
        cell.nameLabel.text = jid.user;
        
        iconImage = [XMPPHelper xmppUserPhotoForJID:jid];
        
        NSMutableDictionary *onlineUsersDic = SharedAppDelegate.xmppServer.onlineDict;
        if (![onlineUsersDic objectForKey:jid.user]) {
            cell.icon.alpha = 0.5f;
        }
        cell.icon.image = iconImage;
    }
    //群组
    else if (sessionType == SessionTypeGroupChat){
        
    }
    //添加好友等等处理信息
    else if (sessionType == SessionTypeSubscription){
        cell.nameLabel.text = @"系统消息";
    }
    
    //系统消息
    else if (sessionType == SessionTypeSystem){
        
    }
    
    return cell;
}

#pragma mark - Table view delegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60.0;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    Session *aSession = [self.sessionList objectAtIndex:[indexPath row]];
    NSInteger sessionType = [aSession.sessionType intValue];
    
    //个人
    if (sessionType == SessionTypePersonalChat) {
        [self performSegueWithIdentifier:@"chat" sender:self];
    }
    
    //群组
    else if (sessionType == SessionTypeGroupChat){
        
    }
    
    //添加好友等等处理信息
    else if (sessionType == SessionTypeSubscription){
        
    }
    
    //系统消息
    else if (sessionType == SessionTypeSystem){
        
    }
}

#pragma mark - segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"chat"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];

        Session *aSession = [self.sessionList objectAtIndex:[indexPath row]];
        NSInteger sessionType = [aSession.sessionType intValue];
        
        //个人
        if (sessionType == SessionTypePersonalChat) {
            ChatViewController *chatViewCtl = segue.destinationViewController;
            User *targetUser = [[User alloc] init];
            XMPPJID *targetJID = [XMPPJID jidWithString:aSession.senderId];
            targetUser.userId = targetJID.user;
            chatViewCtl.chatTargetUser = targetUser;
        }
        
        //群组
        else if (sessionType == SessionTypeGroupChat){
            
        }
        
        //添加好友等等处理信息
        else if (sessionType == SessionTypeSubscription){
            
        }
        
        //系统消息
        else if (sessionType == SessionTypeSystem){
            
        }
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
}
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}


#pragma mark - ego refresh delegate
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
    
    NSLog(@"1");
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
    NSLog(@"2");
    return true;
}

- (void)egoRefreshTableHeaderDidTriggerToBottom{
    NSLog(@"3");
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
    NSLog(@"4");
    return [NSDate date];
}
@end
