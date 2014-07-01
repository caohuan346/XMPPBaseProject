//
//  ChatViewController.m
//  BaseProject
//
//  Created by hc on 14-12-19.
//  Copyright (c) 2014年 hc. All rights reserved.
//

#import "ChatViewController.h"
#import "Globals.h"
#import "Message.h"
#import "User.h"
#import "AppDelegate.h"
#import "XMPPHelper.h"
#import "FaceToolBar.h"
#import "AccessoryView.h"
#import "ChatMsgCell.h"
#import "MJRefresh.h"

#define kLimitSize 10

#define kChatPadding 10
#define kChatIconWidth 40
#define kChatFont [UIFont systemFontOfSize:15]

@interface ChatViewController (){
    
    MJRefreshHeaderView *_header;

    NSInteger _displayMsgCount;  //界面展示的消息
    
}
@property(nonatomic,retain)NSMutableArray *messages;

@end

@implementation ChatViewController

#pragma mark - life circle
- (void)viewDidLoad
{
    
    [super viewDidLoad];
    
    self.tView.delegate = self;
    self.tView.dataSource = self;
    self.tView.separatorStyle = UITableViewCellSeparatorStyleNone;
    NSLog(@"%@",NSStringFromCGRect(self.view.frame));
    NSLog(@"%@",NSStringFromCGRect(self.tView.frame));
    
    [self addHeader];
    
    self.messages = [NSMutableArray array];
    
	// Do any additional setup after loading the view, typically from a nib.
    
    [self initData];
    
    [self initaccessoryView];

    //init chat tool bar
    [self.chatToolBar initSubviewsWithFrame:self.chatToolBar.frame superView:self.view];
    self.chatToolBar.chatDelegate=self;
    
    [self performSelectorOnMainThread:@selector(refreshDataToButtom) withObject:nil waitUntilDone:NO];
}

-(void)viewWillAppear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveXMPPMsg:) name:kNoti_XMPP_didReceiveXMPPMsg object:nil];
}

-(void)viewDidAppear:(BOOL)animated{
    //[self refreshData];
}

-(void)viewWillDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNoti_XMPP_didReceiveXMPPMsg object:nil];
}

- (void)viewDidUnload
{
    [self setTView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - private
-(void)initData{
    ConditionBean *bean1 = [ConditionBean conditionWhereBeanWithField:@"chatUserId" compare:CHComparisonMarkEQ withValue:_chatTargetUser.userId];
    ConditionBean *bean2 = [ConditionBean conditionOrderBeanWithField:@"sendTime" inOrder:CHOrderMarkDesc];
    ConditionBean *bean3 = [ConditionBean conditionLimitBeanWithSize:kLimitSize offset:_displayMsgCount];
    
    NSArray *condiBeanArray = [NSArray arrayWithObjects:bean1,bean2,bean3,nil];
    
    NSArray *tempMsgArray = [SharedAppDelegate.databaseService.baseDBManager queryToObjectArray:[Message class] withConditionBeanArray:condiBeanArray];
    
    //reverse the msgs
    NSArray* reversedArray = [[tempMsgArray reverseObjectEnumerator] allObjects];
    
    self.messages = [NSMutableArray arrayWithArray:reversedArray];
    
    // //next offset
    _displayMsgCount += tempMsgArray.count;
//    [self goBottom];
}

-(void)seekData{
    ConditionBean *bean1 = [ConditionBean conditionWhereBeanWithField:@"chatUserId" compare:CHComparisonMarkEQ withValue:_chatTargetUser.userId];
    ConditionBean *bean2 = [ConditionBean conditionOrderBeanWithField:@"sendTime" inOrder:CHOrderMarkDesc];
    ConditionBean *bean3 = [ConditionBean conditionLimitBeanWithSize:kLimitSize offset:_displayMsgCount];
    
    NSArray *condiBeanArray = [NSArray arrayWithObjects:bean1,bean2,bean3,nil];
    
    NSArray *tempMsgArray = [SharedAppDelegate.databaseService.baseDBManager queryToObjectArray:[Message class] withConditionBeanArray:condiBeanArray];
    
    if (tempMsgArray.count > 0) {
        //reverse the msgs
        NSArray* reversedArray = [[tempMsgArray reverseObjectEnumerator] allObjects];
        
        //insert data at front
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, reversedArray.count)];
        [self.messages insertObjects:reversedArray atIndexes:indexSet];
        
        //refreshData
        [self performSelector:@selector(refreshDataToPrevious:) withObject:reversedArray afterDelay:0.1];
        
        //next offset
        _displayMsgCount += tempMsgArray.count;
    }
    
    [self performSelector:@selector(doneWithView:) withObject:_header afterDelay:1.0f];
}

-(void)initaccessoryView{
    CGRect accessoryRect = CGRectMake(0, (isInch4 ? self.view.frame.size.height+88:self.view.frame.size.height), self.view.frame.size.width, keyboardHeight);
    accessoryView = [[AccessoryView alloc] initWithFrame:accessoryRect sessionType:1];
    accessoryView.accessoryDelegate = self;
    [self.view addSubview:accessoryView];
}

//收到xmpp消息
- (void)didReceiveXMPPMsg:(NSNotification*)aNotification{
    
    XMPPMsg *aXmppMsg = (XMPPMsg *)aNotification.object;
    XMPPType type = aXmppMsg.msgType;
    
    if (type == XMPPTypeMessagePersonalNormal) {
        Message *aChatMsg = [[Message alloc] init];
        aChatMsg.content = aXmppMsg.content;
        aChatMsg.sendTime = [NSDate date];
        
        XMPPJID *jid = [XMPPJID jidWithString:SharedAppDelegate.globals.userId];
        aChatMsg.chatUserId = jid.user;
        aChatMsg.chatUserJID = aXmppMsg.senderId;
        
        [self.messages addObject:aChatMsg];
        
        [self refreshDataToButtom];
    }
    
    else if (type == XMPPTypeMessageIsComposing){
        NSLog(@"%@正在输入",aXmppMsg.senderId);
    }
    
    else if (type == XMPPTypeMessageHasPaused){
        NSLog(@"%@正在输入",aXmppMsg.senderId);
    }
}

/*
 - (IBAction)sendButton:(id)sender {
 
 //本地输入框中的信息
 NSString *message = self.messageTextField.text;
 
 if (message.length > 0) {
 //发送xmpp
 XMPPMsg *aXmppMsg = [[XMPPMsg alloc] init];
 aXmppMsg.msgType = XMPPTypeMessagePersonalNormal;//个人聊天消息
 aXmppMsg.content = message;
 aXmppMsg.targetId = _chatTargetUser.userId;
 [XMPPHelper xmppSendMessage:aXmppMsg];
 
 //当前界面操作
 self.messageTextField.text = @"";
 [self.messageTextField resignFirstResponder];
 
 Message *myMsg = [[Message alloc] init];
 myMsg.messageType = [NSString stringWithFormat:@"%d",SessionTypePersonalChat];
 myMsg.content = message;
 myMsg.sendTime = [NSDate date];
 myMsg.chatUserId = _chatTargetUser.userId;
 myMsg.chatUserJID = [NSString stringWithFormat:@"%@@%@",_chatTargetUser.userId,SharedAppDelegate.globals.xmppServerDomain];
 myMsg.isFrom = @"0";
 BOOL insertFlag = [SharedAppDelegate.databaseService.baseDBManager insertObject:myMsg];
 if (!insertFlag) {
 NSLog(@"保存失败");
 }
 
 [self.messages addObject:myMsg];
 [self refreshData];
 }
 }
 */

-(void)refreshDataToButtom{
    [self.tView reloadData];
    [self goBottom];
}

-(void)refreshDataToPrevious:(NSArray *)resultArray{
    [self.tView reloadData];
    [self.tView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:resultArray.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
}


#pragma mark - subviews position handle
//tableview go buttom
-(void)goBottom{
    if (self.messages.count > 1) {
        [self.tView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.messages.count - 1 inSection:0]
                          atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    }
}

-(void)goBottomEnhance {
    if (self.messages.count > 1) {
//        UITableViewCell *cell = [self.tView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.messages.count - 1 inSection:0]];
//        
//        CGPoint tViewOffset = self.tView.contentOffset;
//
//        tViewOffset.y = CGRectGetMaxY(cell.frame);
//        NSLog(@"%@",NSStringFromCGSize(self.tView.contentSize));
//        self.tView.contentOffset = tViewOffset;
        
        NSIndexPath *localIndexPath = [NSIndexPath indexPathForRow:[self.messages count] inSection:0];
        UITableViewCell *cell = [self.tView cellForRowAtIndexPath:localIndexPath];
        [self.tView scrollRectToVisible:cell.frame animated:YES];

    }
}

//chat tool bar position restore
-(void)restoreChatToolBarFrame:(FaceToolBar *)faceToolBar{
    [UIView animateWithDuration:Time
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationCurveEaseOut
                     animations:^{
                         //附件view frame
                         CGRect frame = accessoryView.frame;
                         frame.origin.y = self.view.frame.size.height;
                         accessoryView.frame = frame;
                         
                         //tool bar frame
                         faceToolBar.toolBar.frame = CGRectMake(0, self.view.frame.size.height-faceToolBar.toolBar.frame.size.height,  self.view.bounds.size.width,faceToolBar.toolBar.frame.size.height);
                         
                         //tView
                         [self tViewMoreUp:NO];
                     }
                     completion:^(BOOL finished){
                         accessoryView.hidden=YES;
                         faceToolBar.moreButton.selected=NO;
                     }];
}

//tView位置上下调整
-(void)tViewMoreUp:(BOOL)upFlag{
    CGRect tFrame = self.tView.frame;
    tFrame.size.height = upFlag?tFrame.size.height - accessoryView.frame.size.height:tFrame.size.height + accessoryView.frame.size.height;
    self.tView.frame = tFrame;
    [self goBottom];
}

#pragma mark - MJRefreshView

- (void)addHeader
{
    
    MJRefreshHeaderView *header = [MJRefreshHeaderView header];
    header.scrollView = _tView;
    
    header.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView) {
        // 进入刷新状态就会回调这个Block
        // 增加5条假数据
        
        [self seekData];
        
        // 模拟延迟加载数据，因此2秒后才调用）
        // 这里的refreshView其实就是header
        [self performSelector:@selector(doneWithView:) withObject:refreshView afterDelay:30.0f];
        
        NSLog(@"%@开始进入刷新状态", refreshView.class);
    };
    header.endStateChangeBlock = ^(MJRefreshBaseView *refreshView) {
        // 刷新完毕就会回调这个Block
        NSLog(@"%@刷新完毕", refreshView.class);
    };
    header.refreshStateChangeBlock = ^(MJRefreshBaseView *refreshView, MJRefreshState state) {
        // 控件的刷新状态切换了就会调用这个block
        switch (state) {
            case MJRefreshStateNormal:
                NSLog(@"%@切换到：普通状态", refreshView.class);
                break;
                
            case MJRefreshStatePulling:
                NSLog(@"%@切换到：松开即可刷新的状态", refreshView.class);
                break;
                
            case MJRefreshStateRefreshing:
                NSLog(@"%@切换到：正在刷新状态", refreshView.class);
                break;
            default:
                break;
        }
    };
    _header = header;
    //[header beginRefreshing];
}


- (void)doneWithView:(MJRefreshBaseView *)refreshView
{
    // 刷新表格
    //[myTableView reloadData];
    // (最好在刷新表格后调用)调用endRefreshing可以结束刷新状态
    [refreshView endRefreshing];
}


#pragma mark - UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.messages count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
//    static NSString *CellIdentifier = @"ChatMsgCell";//ChatMsgCell_target
    static NSString *CellIdentifier = @"ChatMsgCell_target";
    static NSString *CellIdentifier2 = @"ChatMsgCell_self";
    
    Message *aMsg = [self.messages objectAtIndex:indexPath.row];
    
    ChatMsgCell *cell;
    
    if ([aMsg.isFrom isEqualToString:@"0"]) {
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier2 forIndexPath:indexPath];
    }else  {
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    }
    
    UIImage *headImg;
    UIImage *bubbleImg;
    
//    cell.backgroundColor = [UIColor grayColor];
//    cell.msgLabel.backgroundColor = [UIColor yellowColor];
//    cell.iconImgV.backgroundColor = [UIColor purpleColor];
//    cell.bubbleImgV.backgroundColor = [UIColor orangeColor];

    //self
    if ([aMsg.isFrom isEqualToString:@"0"]) {
        headImg = [UIImage imageNamed:@"pl_message_normal"];
        bubbleImg = [UIImage imageNamed:@"SenderTextNodeBkg"];
    }
    else{
        headImg = [UIImage imageNamed:@"pl_picture_normal"];
        bubbleImg = [UIImage imageNamed:@"ReceiverTextNodeBkg"];
    }
  
    cell.iconImgV.image = headImg;
    
    NSInteger leftCapWidth = bubbleImg.size.width * 0.5f;
    NSInteger topCapHeight = bubbleImg.size.height * 0.5f;
    bubbleImg = [bubbleImg stretchableImageWithLeftCapWidth:leftCapWidth topCapHeight:topCapHeight];
    cell.bubbleImgV.image = bubbleImg;
    
    cell.msgLabel.text = aMsg.content;
    
    return cell;
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath22:(NSIndexPath *)indexPath{
    
    static NSString *CellIdentifier = @"ChatMsgCell";
    
    ChatMsgCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    Message *aMsg = [self.messages objectAtIndex:indexPath.row];
    
    CGSize textSize = {CGRectGetWidth(self.view.frame) - 2*kChatIconWidth - 4*kChatPadding ,10000.0};
    CGSize size = [aMsg.content sizeWithFont:kChatFont constrainedToSize:textSize lineBreakMode:cell.msgLabel.lineBreakMode];
    if (size.height < 20) {
        size.height = 20;
    }
    
    UIImage *headImg;
    UIImage *bubbleImg;
    
    CGRect iconRect = cell.iconImgV.frame;
    CGRect msgULRect = cell.msgLabel.frame;
    msgULRect.size = size;
    CGRect bubbleImgVRect = cell.bubbleImgV.frame;
    
    cell.backgroundColor = [UIColor grayColor];
    cell.msgLabel.backgroundColor = [UIColor yellowColor];
    cell.iconImgV.backgroundColor = [UIColor purpleColor];
    cell.bubbleImgV.backgroundColor = [UIColor orangeColor];
    
    //self
    if ([aMsg.isFrom isEqualToString:@"0"]) {
        headImg = [UIImage imageNamed:@"pl_message_normal"];
        
        iconRect.origin.x = self.view.bounds.size.width - 10 - 40;
        
        bubbleImgVRect = CGRectMake(CGRectGetWidth(self.view.frame) - 5*kChatPadding - kChatIconWidth-size.width, CGRectGetMinY(iconRect), size.width + 3*kChatPadding, size.height +2*kChatPadding);
        msgULRect = CGRectMake(CGRectGetMinX(bubbleImgVRect)+12, iconRect.origin.y+5, size.width+5, size.height);
        
        bubbleImg = [UIImage imageNamed:@"SenderTextNodeBkg"];
    } else{
        headImg = [UIImage imageNamed:@"pl_picture_normal"];
        
        iconRect.origin.x = 10;
        
        bubbleImgVRect = CGRectMake(kChatIconWidth + 2*kChatPadding, CGRectGetMinY(iconRect), size.width + 3*kChatPadding, size.height +2*kChatPadding);
        
        msgULRect = CGRectMake(CGRectGetMinX(bubbleImgVRect)+15, iconRect.origin.y+5, size.width, size.height);
        
        bubbleImg = [UIImage imageNamed:@"ReceiverTextNodeBkg"];
        
    }
    
    iconRect.size.height = 40;
    cell.iconImgV.frame = iconRect;
    cell.iconImgV.image = headImg;
    
    cell.bubbleImgV.frame = bubbleImgVRect;
    NSInteger leftCapWidth = bubbleImg.size.width * 0.5f;
    NSInteger topCapHeight = bubbleImg.size.height * 0.5f;
    bubbleImg = [bubbleImg stretchableImageWithLeftCapWidth:leftCapWidth topCapHeight:topCapHeight];
    cell.bubbleImgV.image = bubbleImg;
    
    cell.msgLabel.frame = msgULRect;
    cell.msgLabel.text = aMsg.content;
    
    return cell;
    
}


//每一行的高度
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    Message *aMsg  = [self.messages objectAtIndex:indexPath.row];
    
    CGSize textSize = {CGRectGetWidth(self.view.frame) - 2*kChatIconWidth - 5*kChatPadding ,10000.0};
    CGSize size = [aMsg.content sizeWithFont:kChatFont constrainedToSize:textSize lineBreakMode:NSLineBreakByWordWrapping];
    
    //size.height = size.height+kChatPadding*3;
    size.height = size.height+kChatPadding*4;

    CGFloat height = size.height < 60 ? 60 : size.height;
    
    return height;
}

#pragma mark - chat tool bar delegate
//文字消息
-(void)faceToolBar:(FaceToolBar *)faceToolBar sendTextAction:(NSString *)inputText{
    if (inputText.length > 0) {
        //发送xmpp
        XMPPMsg *aXmppMsg = [[XMPPMsg alloc] init];
        aXmppMsg.msgType = XMPPTypeMessagePersonalNormal;//个人聊天消息
        aXmppMsg.content = inputText;
        aXmppMsg.targetId = _chatTargetUser.userId;
        [XMPPHelper xmppSendMessage:aXmppMsg];
        
        Message *myMsg = [[Message alloc] init];
        myMsg.messageType = [NSString stringWithFormat:@"%d",SessionTypePersonalChat];
        myMsg.content = inputText;
        myMsg.sendTime = [NSDate date];
        myMsg.chatUserId = _chatTargetUser.userId;
        myMsg.chatUserJID = [NSString stringWithFormat:@"%@@%@",_chatTargetUser.userId,SharedAppDelegate.globals.xmppServerDomain];
        myMsg.isFrom = @"0";
        BOOL insertFlag = [SharedAppDelegate.databaseService.baseDBManager insertObject:myMsg];
        if (!insertFlag) {
            NSLog(@"保存失败");
        }
        
        [self.messages addObject:myMsg];
        [self refreshDataToButtom];
    }
}

//点击语音按钮
-(void)faceToolBar:(FaceToolBar *)faceToolBar didClickedAudioButton:(UIButton *)audioButton{
    [self restoreChatToolBarFrame:faceToolBar];
}

//发送语音消息
-(void)faceToolBar:(FaceToolBar *)faceToolBar sendAudioMessage:(UIButton *)recordButton{
    
}

//点击更多按钮
-(void)faceToolBar:(FaceToolBar *)faceToolBar didClickMoreButton:(UIButton *)moreButton{
    [faceToolBar.textView endEditing:YES];
    [faceToolBar dismissFaceScrollView];
    
    //弹出
    if (!moreButton.selected) {
        accessoryView.hidden=NO;
        moreButton.selected=YES;

        [UIView animateWithDuration:Time animations:^{
            //accessoryView frame
            CGRect accessoryViewframe = accessoryView.frame;
            accessoryViewframe.origin.y = self.view.frame.size.height - keyboardHeight;
            accessoryView.frame = accessoryViewframe;
            
            //toolBar frame
            CGFloat toolBarY = accessoryView.frame.origin.y-faceToolBar.toolBar.frame.size.height;
            CGRect toolBarFrame = CGRectMake(0, toolBarY,  self.view.bounds.size.width,faceToolBar.toolBar.frame.size.height);
            faceToolBar.toolBar.frame = toolBarFrame;
            
            //tableView frame
            [self tViewMoreUp:YES];
        }];
    }
    
    //退出（隐藏）附件view
    else{
        [self restoreChatToolBarFrame:faceToolBar];
    }

}

//开始触摸录音
-(void)faceToolBar:(FaceToolBar *)faceToolBar beginTouchRecordButton:(UIButton *)recordButton{
    
}

//停止录音
-(void)faceToolBar:(FaceToolBar *)faceToolBar stopRecording:(UIButton *)recordButton{
    
}

//将要取消录音
-(void)faceToolBar:(FaceToolBar *)faceToolBar willCancelRecording:(UIButton *)recordButton{
    
}
//取消掉语音发送
-(void)faceToolBar:(FaceToolBar *)faceToolBar didCanceledRecording:(UIButton *)recordButton{
    
}

#pragma mark - image picker delegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    NSDictionary *dict=nil;
    if ([mediaType isEqualToString:@"public.image"]) {
        UIImage *originImage = [info objectForKey:UIImagePickerControllerOriginalImage];
        //dict=[self handleImage:originImage];
        if (picker.sourceType==UIImagePickerControllerSourceTypeCamera) {
            UIImageWriteToSavedPhotosAlbum(originImage, nil, nil, nil);
        }
    }
    //[SVProgressHUD dismiss];
    [self dismissViewControllerAnimated:YES completion:^{
       
    }];
//    if (dict) {
//        [self performSelector:@selector(sendImage:) withObject:dict afterDelay:1];
//    }
}

#pragma mark - accessary view button event
//图片
-(void)accessaryBtnChoosePhoto{
    UIImagePickerController * picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    }else{
        NSLog(@"模拟器无法打开相机");
    }
    [self presentViewController:picker animated:YES completion:^{ }];
}

//拍照
-(void)accessaryBtnTakePhoto{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:^{ }];
}

//位置
-(void)accessaryBtnLocation{
    [self performSegueWithIdentifier:@"toLocation" sender:self];
}

//消息
-(void)accessaryBtnNormalMsg{
    
}

//文件
-(void)accessaryBtnSendFile{
    
}

@end
