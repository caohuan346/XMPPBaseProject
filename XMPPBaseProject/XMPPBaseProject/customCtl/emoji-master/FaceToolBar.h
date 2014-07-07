//
//  FaceToolBar.h
//  TestKeyboard
//
//  Created by wangjianle on 13-2-26.
//  Copyright (c) 2013年 wangjianle. All rights reserved.
//
#define Time  0.25
#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]
#define  keyboardHeight 216
#define  toolBarHeight 45
#define  choiceBarHeight 35
#define  facialViewWidth 300
#define facialViewHeight 170
#define  buttonWh 34
#import <UIKit/UIKit.h>
#import "FacialView.h"
#import "UIExpandingTextView.h"

@class FaceToolBar;
@protocol FaceToolBarDelegate <NSObject>
//文字消息
-(void)faceToolBar:(FaceToolBar *)faceToolBar sendTextAction:(NSString *)inputText;
//点击语音按钮
-(void)faceToolBar:(FaceToolBar *)faceToolBar didClickedAudioButton:(UIButton *)audioButton;
//发送语音消息
-(void)faceToolBar:(FaceToolBar *)faceToolBar sendAudioMessage:(UIButton *)recordButton;
//点击更多按钮
-(void)faceToolBar:(FaceToolBar *)faceToolBar didClickMoreButton:(UIButton *)moreButton;
//开始触摸录音
-(void)faceToolBar:(FaceToolBar *)faceToolBar beginTouchRecordButton:(UIButton *)recordButton;
//停止录音
-(void)faceToolBar:(FaceToolBar *)faceToolBar stopRecording:(UIButton *)recordButton;
//将要取消录音
-(void)faceToolBar:(FaceToolBar *)faceToolBar willCancelRecording:(UIButton *)recordButton;
//取消掉语音发送
-(void)faceToolBar:(FaceToolBar *)faceToolBar didCanceledRecording:(UIButton *)recordButton;

@end

@interface FaceToolBar : UIToolbar<facialViewDelegate,UIExpandingTextViewDelegate,UIScrollViewDelegate>
{
    UIScrollView *scrollView;//表情滚动视图
    UIPageControl *pageControl;
    
    BOOL keyboardIsShow;//键盘是否显示
}

@property(nonatomic, weak) UIView *theSuperView;

@property(nonatomic, strong) UIView *toolBar;//工具栏
@property(nonatomic, strong) UIExpandingTextView *textView;//文本输入框
@property(nonatomic, strong) UIButton *faceButton;//表情按钮
@property(nonatomic, strong) UIButton *voiceButton;//语音
@property(nonatomic, strong) UIButton *recordButton;//录音长按按钮
@property(nonatomic, strong) UIButton *moreButton;//更多

@property(nonatomic, assign) NSObject<FaceToolBarDelegate> *chatDelegate;

- (void)dismissKeyBoard;
- (void)dismissFaceScrollView;
- (id)initWithFrame:(CGRect)frame superView:(UIView *)superView;
- (void)initSubviewsWithFrame:(CGRect)frame superView:(UIView *)superView;
@end
