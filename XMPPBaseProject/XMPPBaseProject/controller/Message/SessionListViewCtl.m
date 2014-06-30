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
#import "MJRefresh.h"

@interface SessionListViewCtl (){
    MJRefreshHeaderView *_header;
    MJRefreshFooterView *_footer;
}

@property(nonatomic,strong)NSArray *sessionList;

@end

@implementation SessionListViewCtl

#pragma mark - life circle

- (void)dealloc
{
     [[NSNotificationCenter defaultCenter] removeObserver:self name:kNoti_XMPP_didReceiveXMPPMsg object:nil];
    [_header free];
    [_footer free];
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
    
    //初始化数据
    [self initData];
    
    // 集成刷新控件
    //1.下拉刷新
    [self addHeader];
    
    //2.上拉加载更多
    [self addFooter];

}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    NSLog(@"%p",[GlobalHandler sharedInstance].buddyService);
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

#pragma mark - refresh view
- (void)addFooter
{
    __unsafe_unretained SessionListViewCtl *vc = self;
    MJRefreshFooterView *footer = [MJRefreshFooterView footer];
    footer.scrollView = self.tableView;
    footer.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView) {
        //TODO 增加数据
//        // 增加5条假数据
//        for (int i = 0; i<5; i++) {
//            int random = arc4random_uniform(1000000);
//            [vc->_fakeData addObject:[NSString stringWithFormat:@"随机数据---%d", random]];
//        }

        // 模拟延迟加载数据，因此2秒后才调用）
        // 这里的refreshView其实就是footer
        [vc performSelector:@selector(doneWithView:) withObject:refreshView afterDelay:2.0];
        
        NSLog(@"%@----开始进入刷新状态", refreshView.class);
    };
    _footer = footer;
}

- (void)addHeader
{
    __unsafe_unretained SessionListViewCtl *vc = self;
    
    MJRefreshHeaderView *header = [MJRefreshHeaderView header];
    header.scrollView = self.tableView;
    header.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView) {
        // 进入刷新状态就会回调这个Block
        
        //TODO 增加数据
        // 增加5条假数据
//        for (int i = 0; i<5; i++) {
//            int random = arc4random_uniform(1000000);
//            [vc->_fakeData insertObject:[NSString stringWithFormat:@"随机数据---%d", random] atIndex:0];
//        }

        
        // 模拟延迟加载数据，因此2秒后才调用）
        // 这里的refreshView其实就是header
        [vc performSelector:@selector(doneWithView:) withObject:refreshView afterDelay:2.0];
        
        NSLog(@"%@----开始进入刷新状态", refreshView.class);
    };
    header.endStateChangeBlock = ^(MJRefreshBaseView *refreshView) {
        // 刷新完毕就会回调这个Block
        NSLog(@"%@----刷新完毕", refreshView.class);
    };
    header.refreshStateChangeBlock = ^(MJRefreshBaseView *refreshView, MJRefreshState state) {
        // 控件的刷新状态切换了就会调用这个block
        switch (state) {
            case MJRefreshStateNormal:
                NSLog(@"%@----切换到：普通状态", refreshView.class);
                break;
                
            case MJRefreshStatePulling:
                NSLog(@"%@----切换到：松开即可刷新的状态", refreshView.class);
                break;
                
            case MJRefreshStateRefreshing:
                NSLog(@"%@----切换到：正在刷新状态", refreshView.class);
                break;
            default:
                break;
        }
    };
    [header beginRefreshing];
    _header = header;
}

- (void)doneWithView:(MJRefreshBaseView *)refreshView
{
    // 刷新表格
    [self.tableView reloadData];
    // (最好在刷新表格后调用)调用endRefreshing可以结束刷新状态
    [refreshView endRefreshing];
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

@end
