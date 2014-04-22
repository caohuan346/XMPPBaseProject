//
//  ChatViewController.m
//  BaseProject
//
//  Created by Huan Cho on 13-12-19.
//  Copyright (c) 2013年 ch. All rights reserved.
//

#import "ChatViewController.h"
#import "KKMessageCell.h"
#import "Globals.h"
#import "Message.h"
#import "User.h"
#import "AppDelegate.h"
#import "XMPPHelper.h"
#import "FaceToolBar.h"
#import "AccessoryView.h"

#define padding 20

@interface ChatViewController (){
    
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

    self.messages = [NSMutableArray array];
//    [_messageTextField becomeFirstResponder];
    
	// Do any additional setup after loading the view, typically from a nib.
    
    [self initData];
    
    [self initaccessoryView];

    //init chat tool bar
    [self.chatToolBar initSubviewsWithFrame:self.chatToolBar.frame superView:self.view];
    self.chatToolBar.chatDelegate=self;
}

-(void)viewWillAppear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveXMPPMsg:) name:kNoti_XMPP_didReceiveXMPPMsg object:nil];
}

-(void)viewDidAppear:(BOOL)animated{
    [self refreshData];
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
    
    Message *aMsg = [self.messages objectAtIndex:indexPath.row];
    
    CGSize textSize = {260.0 ,10000.0};
    CGSize size = [aMsg.content sizeWithFont:[UIFont boldSystemFontOfSize:13] constrainedToSize:textSize lineBreakMode:NSLineBreakByWordWrapping];
    
    size.width +=(padding/2);
    
    cell.messageContentView.text = aMsg.content;
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.userInteractionEnabled = NO;
    
    UIImage *bgImage = nil;
    
    //自己发送
    if ([aMsg.isFrom isEqualToString:@"0"]) {
        bgImage = [[UIImage imageNamed:@"GreenBubble2.png"] stretchableImageWithLeftCapWidth:14 topCapHeight:15];
        
        [cell.messageContentView setFrame:CGRectMake(320-size.width - padding, padding*2, size.width, size.height)];
        [cell.bgImageView setFrame:CGRectMake(cell.messageContentView.frame.origin.x - padding/2, cell.messageContentView.frame.origin.y - padding/2, size.width + padding, size.height + padding)];
        
        cell.senderAndTimeLabel.text = [NSString stringWithFormat:@"%@ %@", SharedAppDelegate.globals.userId, [NSString stringWithFormat:@"%@",aMsg.sendTime]];
        
    }else {
        bgImage = [[UIImage imageNamed:@"BlueBubble2.png"] stretchableImageWithLeftCapWidth:20 topCapHeight:15];
        [cell.messageContentView setFrame:CGRectMake(padding, padding*2, size.width, size.height)];
        
        [cell.bgImageView setFrame:CGRectMake(cell.messageContentView.frame.origin.x - padding/2, cell.messageContentView.frame.origin.y - padding/2, size.width + padding, size.height + padding)];
        
        cell.senderAndTimeLabel.text = [NSString stringWithFormat:@"%@ %@", aMsg.chatUserJID, [NSString stringWithFormat:@"%@",aMsg.sendTime]];
    }
    
    cell.bgImageView.image = bgImage;
    
    return cell;
    
}

//每一行的高度
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    Message *aMsg  = [self.messages objectAtIndex:indexPath.row];
    
    CGSize textSize = {260.0 , 10000.0};
    
    CGSize size = [aMsg.content sizeWithFont:[UIFont boldSystemFontOfSize:13] constrainedToSize:textSize lineBreakMode:NSLineBreakByWordWrapping];
    
    size.height += padding*2;
    
    CGFloat height = size.height < 65 ? 65 : size.height;
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
        [self refreshData];
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
    
}

//消息
-(void)accessaryBtnNormalMsg{
    
}

//文件
-(void)accessaryBtnSendFile{
    
}


#pragma mark - private 
-(void)initData{
    ConditionBean *bean1 = [ConditionBean conditionWhereBeanWithField:@"chatUserId" compare:CHComparisonMarkEQ withValue:_chatTargetUser.userId];
    ConditionBean *bean2 = [ConditionBean conditionOrderBeanWithField:@"sendTime" inOrder:CHOrderMarkAsc];
    NSArray *condiBeanArray = [NSArray arrayWithObjects:bean1, bean2,nil];
    NSArray *msgList = [SharedAppDelegate.databaseService.baseDBManager queryToObjectArray:[Message class] withConditionBeanArray:condiBeanArray];
    self.messages = [NSMutableArray arrayWithArray:msgList];
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
        [self refreshData];
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

-(void)refreshData{
    [self.tView reloadData];
    [self goBottom];
}


#pragma mark - subviews position handle
//tableview go buttom
-(void)goBottom{
    if (self.messages.count > 1) {
        [self.tView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.messages.count - 1 inSection:0]
                          atScrollPosition:UITableViewScrollPositionBottom animated:YES];
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

@end
