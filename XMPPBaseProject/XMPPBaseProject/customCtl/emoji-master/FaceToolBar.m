//
//  FaceToolBar.m
//  TestKeyboard
//
//  Created by wangjianle on 13-2-26.
//  Copyright (c) 2013年 wangjianle. All rights reserved.
//

#import "FaceToolBar.h"

@implementation FaceToolBar
-(id)init{
    self = [super init];
    if (self) {
        
    }
    return self;
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
    }
    return self;
}
-(void)initSubviewsWithFrame:(CGRect)frame superView:(UIView *)superView{
    keyboardIsShow=NO;
    self.theSuperView=superView;
    
    self.toolBar= [[UIToolbar alloc] initWithFrame:CGRectMake(0.0f,superView.bounds.size.height - toolBarHeight,superView.bounds.size.width,toolBarHeight)];
    self.toolBar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
//    UIEdgeInsets insets = UIEdgeInsetsMake(40, 0, 40, 0);
    
    //background
    UIImageView *bg=[[UIImageView alloc] initWithFrame:_toolBar.bounds];
    [bg setImage:[UIImage imageNamed:@"chat_input_bar"]];
    bg.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [_toolBar addSubview:bg];
    
    //可以自适应高度的文本输入框
    if (IOS_VERSION >= 7.0) {
        self.textView = [[UIExpandingTextView alloc] initWithFrame:CGRectMake(40, 5, 205, 48)];
    }else{
        self.textView = [[UIExpandingTextView alloc] initWithFrame:CGRectMake(40, 5, 205, 36)];
    }
    self.textView.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(4.0f, 0.0f, 10.0f, 0.0f);
    [self.textView.internalTextView setReturnKeyType:UIReturnKeySend];
    self.textView.delegate = self;
    self.textView.maximumNumberOfLines=5;
    [self.toolBar addSubview:self.textView];
    
    //语音按钮
    self.voiceButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.voiceButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin;
    [self.voiceButton setBackgroundImage:[UIImage imageNamed:@"Speak"] forState:UIControlStateNormal];
    [self.voiceButton addTarget:self action:@selector(didClickedAudioButton:) forControlEvents:UIControlEventTouchUpInside];
    self.voiceButton.frame = CGRectMake(5,self.toolBar.bounds.size.height-38.0f,buttonWh,buttonWh);
    self.voiceButton.selected=NO;
    [self.toolBar addSubview:self.voiceButton];
    
    //录音按钮
    self.recordButton =[UIButton buttonWithType:UIButtonTypeCustom];
    self.recordButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin;
    UIImage *recordImage=[UIImage imageNamed:@"chat_bottombar_voice_normal"];
    UIImage *newImage=[recordImage stretchableImageWithLeftCapWidth:10 topCapHeight:16];
    [self.recordButton setBackgroundImage:newImage forState:UIControlStateNormal];
    [self.recordButton setTitle:@"按住 说话" forState:UIControlStateNormal];
    self.recordButton.titleLabel.font=[UIFont boldSystemFontOfSize:16];
    [self.recordButton addTarget:self action:@selector(startRecord:) forControlEvents:UIControlEventTouchDown];
    [self.recordButton addTarget:self action:@selector(endRecord:) forControlEvents:UIControlEventTouchUpInside];
    [self.recordButton addTarget:self action:@selector(cancelRecording:) forControlEvents:UIControlEventTouchDragOutside];
    [self.recordButton addTarget:self action:@selector(willCancelRecording:) forControlEvents:UIControlEventTouchDragExit];
    self.recordButton.frame = CGRectMake(40,self.toolBar.bounds.size.height-38.0f,205,buttonWh);
    self.recordButton.hidden=YES;
    [self.toolBar addSubview:self.recordButton];
    
    //表情按钮
    self.faceButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.faceButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin;
    [self.faceButton setBackgroundImage:[UIImage imageNamed:@"face"] forState:UIControlStateNormal];
    [self.faceButton addTarget:self action:@selector(disFaceKeyboard) forControlEvents:UIControlEventTouchUpInside];
    self.faceButton.frame = CGRectMake(self.toolBar.bounds.size.width - 70.0f,self.toolBar.bounds.size.height-38.0f,buttonWh,buttonWh);
    [self.toolBar addSubview:self.faceButton];
    
    //更多按钮
    self.moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.moreButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin;
    self.moreButton.enabled=YES;
    [self.moreButton setBackgroundImage:[UIImage imageNamed:@"TypeSelectorBtn_Black"] forState:UIControlStateNormal];
    [self.moreButton setBackgroundImage:[UIImage imageNamed:@"TypeSelectorBtnHL_Black"] forState:UIControlStateSelected];
    [self.moreButton addTarget:self action:@selector(chatInputMore) forControlEvents:UIControlEventTouchUpInside];
    self.moreButton.frame = CGRectMake(self.toolBar.bounds.size.width - 7.0f-30,self.toolBar.bounds.size.height-30-8.0f,buttonWh,buttonWh);
    [self.toolBar addSubview:self.moreButton];

    
    //给键盘注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(inputKeyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(inputKeyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    //创建表情键盘
    if (scrollView==nil) {
        scrollView=[[UIScrollView alloc] initWithFrame:CGRectMake(0, superView.frame.size.height, superView.frame.size.width, keyboardHeight)];
        [scrollView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"facesBack"]]];
        for (int i=0; i<9; i++) {
            FacialView *fview=[[FacialView alloc] initWithFrame:CGRectMake(12+320*i, 15, facialViewWidth, facialViewHeight)];
            [fview setBackgroundColor:[UIColor clearColor]];
            [fview loadFacialView:i size:CGSizeMake(33, 43)];
            fview.delegate=self;
            [scrollView addSubview:fview];
        }
    }
    [scrollView setShowsVerticalScrollIndicator:NO];
    [scrollView setShowsHorizontalScrollIndicator:NO];
    scrollView.contentSize=CGSizeMake(320*9, keyboardHeight);
    scrollView.pagingEnabled=YES;
    scrollView.delegate=self;
    [superView addSubview:scrollView];
    
    pageControl=[[UIPageControl alloc]initWithFrame:CGRectMake(98, superView.frame.size.height-40, 150, 30)];
    [pageControl setCurrentPage:0];
    pageControl.pageIndicatorTintColor=RGBACOLOR(195, 179, 163, 1);
    pageControl.currentPageIndicatorTintColor=RGBACOLOR(132, 104, 77, 1);
    pageControl.numberOfPages = 9;//指定页面个数
    [pageControl setBackgroundColor:[UIColor clearColor]];
    pageControl.hidden=YES;
    [pageControl addTarget:self action:@selector(changePage:)forControlEvents:UIControlEventValueChanged];
    [superView addSubview:pageControl];
    
    [superView addSubview:self.toolBar];
}

- (void)scrollViewDidScroll:(UIScrollView *)sender {
    int page = scrollView.contentOffset.x / 320;//通过滚动的偏移量来判断目前页面所对应的小白点
    pageControl.currentPage = page;//pagecontroll响应值的变化
}
//pagecontroll的委托方法

- (IBAction)changePage:(id)sender {
    int page = pageControl.currentPage;//获取当前pagecontroll的值
    [scrollView setContentOffset:CGPointMake(320 * page, 0)];//根据pagecontroll的值来改变scrollview的滚动位置，以此切换到指定的页面
}


#pragma mark -
#pragma mark UIExpandingTextView delegate
//改变键盘高度
-(void)expandingTextView:(UIExpandingTextView *)expandingTextView willChangeHeight:(float)height
{
    /* Adjust the height of the toolbar when the input component expands */
    float diff = (self.textView.frame.size.height - height);
    CGRect r = self.toolBar.frame;
    r.origin.y += diff;
    r.size.height -= diff;
    self.toolBar.frame = r;
    if (expandingTextView.text.length>2&&[[Emoji allEmoji] containsObject:[expandingTextView.text substringFromIndex:expandingTextView.text.length-2]]) {
        NSLog(@"最后输入的是表情%@",[self.textView.text substringFromIndex:self.textView.text.length-2]);
        self.textView.internalTextView.contentOffset=CGPointMake(0,self.textView.internalTextView.contentSize.height-self.self.textView.internalTextView.frame.size.height );
    }
    
}
//return方法
- (BOOL)expandingTextViewShouldReturn:(UIExpandingTextView *)expandingTextView{
    [self sendAction];
    return YES;
}
//文本是否改变
-(void)expandingTextViewDidChange:(UIExpandingTextView *)expandingTextView
{
    /* Enable/Disable the button */
    /*
    if ([expandingTextView.text length] > 0)
        moreButton.enabled = YES;
    else
        moreButton.enabled = NO;
     */
}
#pragma mark - envent
//发送文本消息
-(void)sendAction{
    if (self.textView.text.length>0) {
        if ([_chatDelegate respondsToSelector:@selector(faceToolBar:sendTextAction:)])
        {
            [_chatDelegate faceToolBar:self sendTextAction:_textView.text];
        }
        [_textView clearText];
    }
}

//更多
-(void)chatInputMore{
    [_faceButton setBackgroundImage:[UIImage imageNamed:@"face"] forState:UIControlStateNormal];
    
    [_voiceButton setBackgroundImage:[UIImage imageNamed:@"Speak"] forState:UIControlStateNormal];
    _voiceButton.selected=NO;
    _textView.hidden=NO;
    _recordButton.hidden=YES;
    if([_chatDelegate respondsToSelector:@selector(faceToolBar:didClickMoreButton:)])
    {
        [_chatDelegate faceToolBar:self didClickMoreButton:_moreButton];
    }
}

-(void)didClickedAudioButton:(id)sender{
    UIButton *btn=sender;
    if (!btn.selected) {
        btn.selected=YES;
        
        [btn setBackgroundImage:[UIImage imageNamed:@"Text"] forState:UIControlStateNormal];
        _recordButton.hidden=NO;
        _textView.hidden=YES;
        _textView.text=@"";
    } else {
        [btn setBackgroundImage:[UIImage imageNamed:@"Speak"] forState:UIControlStateNormal];
        btn.selected=NO;
        _textView.hidden=NO;
        _recordButton.hidden=YES;
    }
    if ([_chatDelegate respondsToSelector:@selector(faceToolBar:didClickedAudioButton:)]) {
        [_chatDelegate faceToolBar:self didClickedAudioButton:_voiceButton];
    }
    [self dismissKeyBoard];
}

#pragma mark -
-(void)startRecord:(UIButton *)recordBtn{
    
}
-(void)endRecord:(UIButton *)recordBtn{
    
}
-(void)cancelRecording:(UIButton *)recordBtn{
    
}
-(void)willCancelRecording:(UIButton *)recordBtn{
    
}

#pragma mark -
-(void)disFaceKeyboard{
    _moreButton.selected=NO;
    //如果直接点击表情，通过toolbar的位置来判断
    if (_toolBar.frame.origin.y== self.theSuperView.bounds.size.height - toolBarHeight&&_toolBar.frame.size.height==toolBarHeight) {
        [UIView animateWithDuration:Time animations:^{
            _toolBar.frame = CGRectMake(0, self.theSuperView.frame.size.height-keyboardHeight-toolBarHeight,  self.theSuperView.bounds.size.width,toolBarHeight);
        }];
        [UIView animateWithDuration:Time animations:^{
            [scrollView setFrame:CGRectMake(0, self.theSuperView.frame.size.height-keyboardHeight,self.theSuperView.frame.size.width, keyboardHeight)];
        }];
        [pageControl setHidden:NO];
        [_faceButton setBackgroundImage:[UIImage imageNamed:@"Text"] forState:UIControlStateNormal];
        return;
    }
    //如果键盘没有显示，点击表情了，隐藏表情，显示键盘
    if (!keyboardIsShow) {
        [UIView animateWithDuration:Time animations:^{
            
            [scrollView setFrame:CGRectMake(0, self.theSuperView.frame.size.height, self.theSuperView.frame.size.width, keyboardHeight)];
        }];
        [_textView becomeFirstResponder];
        [pageControl setHidden:YES];
        
    }else{
        
        //键盘显示的时候，toolbar需要还原到正常位置，并显示表情
        [UIView animateWithDuration:Time animations:^{
            _toolBar.frame = CGRectMake(0, self.theSuperView.frame.size.height-keyboardHeight-_toolBar.frame.size.height,  self.theSuperView.bounds.size.width,_toolBar.frame.size.height);
        }];
        
        [UIView animateWithDuration:Time animations:^{
            [scrollView setFrame:CGRectMake(0, self.theSuperView.frame.size.height-keyboardHeight,self.theSuperView.frame.size.width, keyboardHeight)];
        }];
        [pageControl setHidden:NO];
        [_textView resignFirstResponder];
    }
    
}
#pragma mark 隐藏键盘
-(void)dismissKeyBoard{
    //键盘显示的时候，toolbar需要还原到正常位置，并显示表情
    [UIView animateWithDuration:Time animations:^{
        _toolBar.frame = CGRectMake(0, self.theSuperView.frame.size.height-_toolBar.frame.size.height,  self.theSuperView.bounds.size.width,_toolBar.frame.size.height);
    }];
    
    [UIView animateWithDuration:Time animations:^{
        [scrollView setFrame:CGRectMake(0, self.theSuperView.frame.size.height,self.theSuperView.frame.size.width, keyboardHeight)];
    }];
    [pageControl setHidden:YES];
    [_textView resignFirstResponder];
    [_faceButton setBackgroundImage:[UIImage imageNamed:@"face"] forState:UIControlStateNormal];
}
#pragma mark 监听键盘的显示与隐藏
-(void)inputKeyboardWillShow:(NSNotification *)notification{
    //键盘显示，设置toolbar的frame跟随键盘的frame
    CGFloat animationTime = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    [UIView animateWithDuration:animationTime animations:^{
        CGRect keyBoardFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
        if (_toolBar.frame.size.height>45) {
            _toolBar.frame = CGRectMake(0, keyBoardFrame.origin.y-20-_toolBar.frame.size.height,  self.theSuperView.bounds.size.width,_toolBar.frame.size.height);
        }else{
            CGRect toolBarFrame = CGRectMake(0, keyBoardFrame.origin.y-_toolBar.frame.size.height,  self.theSuperView.bounds.size.width,toolBarHeight);
            _toolBar.frame = toolBarFrame;
        }
    }];
    [_faceButton setBackgroundImage:[UIImage imageNamed:@"face"] forState:UIControlStateNormal];
    keyboardIsShow=YES;
    [pageControl setHidden:YES];
}
-(void)inputKeyboardWillHide:(NSNotification *)notification{
    [_faceButton setBackgroundImage:[UIImage imageNamed:@"Text"] forState:UIControlStateNormal];
    keyboardIsShow=NO;
}

#pragma mark -
-(void)dismissFaceScrollView{
    [UIView animateWithDuration:Time animations:^{
        [scrollView setFrame:CGRectMake(0, self.theSuperView.frame.size.height,self.theSuperView.frame.size.width, keyboardHeight)];
    }];
    [pageControl setHidden:YES];
}

#pragma mark facialView delegate 点击表情键盘上的文字
-(void)selectedFacialView:(NSString*)str
{
    NSString *newStr;
    if ([str isEqualToString:@"删除"]) {
        if (_textView.text.length>0) {
            if ([[Emoji allEmoji] containsObject:[_textView.text substringFromIndex:_textView.text.length-2]]) {
                NSLog(@"删除emoji %@",[_textView.text substringFromIndex:_textView.text.length-2]);
                newStr=[_textView.text substringToIndex:_textView.text.length-2];
            }else{
                NSLog(@"删除文字%@",[_textView.text substringFromIndex:_textView.text.length-1]);
                newStr=[_textView.text substringToIndex:_textView.text.length-1];
            }
            _textView.text=newStr;
        }
        NSLog(@"删除后更新%@",_textView.text);
    }else{
        NSString *newStr=[NSString stringWithFormat:@"%@%@",_textView.text,str];
        [_textView setText:newStr];
        NSLog(@"点击其他后更新%d,%@",str.length,_textView.text);
    }
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardDidShowNotification
                                                  object:nil];
}

#pragma mark - tableView的键盘跟随移动
/*
 //
 //将键盘推出时候，view重新回到原来位置
 //
 -(void)viewKeyboardDisappearChangeRect {
 NSTimeInterval animationDuration = 0.30f;
 [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
 [UIView setAnimationDuration:animationDuration];
 //把view设置回默认的Rect
 CGRect rect = CGRectMake(0.0, 0, self.view.frame.size.width, self.view.frame.size.height);
 self.view.frame = rect;
 //cardTableView.frame = rect;
 [UIView commitAnimations];
 }
 
 //
 //view要往上推
 //@offset:要推的高度偏移
 //
 -(void)viewKeyboardAppearChangeRect:(int)offset {
 [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
 [UIView setAnimationDuration:0.30f];
 float width = self.view.frame.size.width;
 float height = self.view.frame.size.height;
 if (offset > 0) {
 //self.view.frame = CGRectMake(0, -offset, width, height);
 self.view.frame = CGRectMake(0, -offset, width, height);
 }
 [UIView commitAnimations];
 }
*/

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
