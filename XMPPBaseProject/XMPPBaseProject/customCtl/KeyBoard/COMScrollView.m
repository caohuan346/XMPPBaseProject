//
//  COMScrollView.m
//  EduSun
//
//  Created by Huan Cho on someday.
//  Copyright (c) 2013年 mentnets. All rights reserved.
//
//  modified by Huan Cho 2013-07-19

#import "COMScrollView.h"
#import "UIView+Add.h"

@interface COMScrollView ()  {
    CGPoint _lastContentOffSet;
    CGRect _comConverRect;//普通换出键盘
}
@end

@implementation COMScrollView

#pragma mark - life circle
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initial];
        CGPoint contentOffSet = self.contentOffset;
        _lastContentOffSet = contentOffSet;
    }
    return self;
}

- (id)init {
    if (self = [super init]) {
        [self initial];
    }
    return self;
}

-(void)updateScollView{
    [self initial];
    
    CGPoint contentOffSet = self.contentOffset;
    _lastContentOffSet = contentOffSet;
}

#pragma mark -
- (void)initial {
    self.contentSize = self.bounds.size;
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    float version = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (version >= 5.0) {
        [center addObserver:self selector:@selector(keybordWillShow:) name:UIKeyboardWillChangeFrameNotification object:nil];
        // 注册键盘隐藏的通知
        [center addObserver:self selector:@selector(keybordWillHide:) name:UIKeyboardWillHideNotification object:nil];
    }else{
        // 注册键盘显示的通知
        [center addObserver:self selector:@selector(keybordWillShow:) name:UIKeyboardWillShowNotification object:nil];
        // 注册键盘隐藏的通知
        [center addObserver:self selector:@selector(keybordWillHide:) name:UIKeyboardWillHideNotification object:nil];
    }
}

#pragma mark keybordWillShow
- (void)keybordWillShow:(NSNotification *)notification{
//    CGRect keyboardRect = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
//    
//    UITextField *textField = [UIView findFistResponder:self];
//    UIView *superView=(UIView*)[textField superview];
//    //判断当前view是否是根view
//    if (![superView isKindOfClass:[UIWindow class]]) {
//        _comConverRect=superView.frame;
//    }else{
//        // toView用nil值，代表UIWindow
//        _comConverRect= [superView convertRect:textField.bounds toView:nil];//转换坐标系
//        
//    }
//    
//    CGFloat distance =(CGRectGetMaxY(_comConverRect) +50)- CGRectGetMinY(keyboardRect);
//    NSLog(@"挡住了----%f",distance);
//    if (distance > 0) { // 说明键盘挡住了文本框
//        [self animationWithUserInfo:notification.userInfo block:^{
//            CGPoint offset  = CGPointZero;
//            offset.y += distance;
//            self.contentOffset = offset;
//        }];
//    }
    CGRect keyboardRect = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    UITextField *textField = [UIView findFistResponder:self];
    CGRect convertRect = [textField convertRect:textField.bounds toView:nil];
    //如果键盘的y值-(转换后的坐标高度+文本框的高度)小于0的话，说明是被键盘挡住了
    CGFloat postionY = keyboardRect.origin.y - (convertRect.origin.y+textField.bounds.size.height + 10);
    //被挡住了
    if (postionY < 0 ) {
       [self animationWithUserInfo:notification.userInfo block:^{
            CGPoint contentOffSet = self.contentOffset;
            contentOffSet.y -= postionY;
            self.contentOffset = contentOffSet;
        }];
    }
}

#pragma mark keybordWillHide
- (void)keybordWillHide:(NSNotification *)notification {
    [self animationWithUserInfo:notification.userInfo block:^{
        self.contentOffset = _lastContentOffSet;
    }];
}

#pragma mark animation
- (void)animationWithUserInfo:(NSDictionary *)userInfo block:(void (^)(void))block {
    // 取出键盘弹出的时间
    CGFloat duration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    // 取出键盘弹出的速率节奏
    int curve = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:duration];
    [UIView setAnimationCurve:curve];
    
    block();
    
    [UIView commitAnimations];
}

#pragma mark -
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self endEditing:YES];
}

#pragma mark -
- (void)dealloc {
    //removeObserver
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self];
}

@end
