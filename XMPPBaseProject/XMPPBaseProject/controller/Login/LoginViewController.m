//
//  LoginViewController.m
//  BaseProject
//
//  Created by Huan Cho on 13-12-19.
//  Copyright (c) 2013年 ch. All rights reserved.
//

#import "LoginViewController.h"
#import "AppDelegate.h"
#import "SVProgressHUD.h"
#import "COMScrollView.h"
#import "RegisterViewCtl.h"
#import "User.h"

@interface LoginViewController (){
    BOOL loginFlag;
}

@end

@implementation LoginViewController

#pragma mark - life circle
- (void)viewDidLoad
{
    
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *userId = [defaults stringForKey:kUserID];
    //NSString *password = [defaults stringForKey:kPassword];
    NSString *password = [GlobalHelper passwordForAccount:userId];
    
    //NSString *xmppServer = [defaults stringForKey:kXMPPServerDomain];
    
    self.userTextField.text = userId;
    self.passTextField.text = password;
    //self.serverTextField.text = xmppServer;
    
     //自动登录：
    /*
    if (userId && password) {
        XmppUserInfo *userInfo = [[XmppUserInfo alloc] init];
        userInfo.userName = userId;
        userInfo.password = password;
        [[XMPPServer sharedServer] connectWithUserInfo:userInfo];
    }
     */
    
//    [self toLogin:nil];
    
    [self initAnim6];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

#pragma mark -private
- (IBAction)toLogin:(id)sender{
    if ([self validateWithUser:_userTextField.text andPass:_passTextField.text]) {
        /*
        //持久化登录消息
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:self.userTextField.text forKey:kUserID];
        [defaults setObject:self.passTextField.text forKey:kPassword];
        [defaults synchronize];
        */
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:self.userTextField.text forKey:kUserID];
        
        //persist pwd with keychain
        [GlobalHelper setPassword:_passTextField.text forAccount:_userTextField.text];
        
        [SVProgressHUD showInView:SharedAppDelegate.selectedViewCtl.view status:@"正在登录，请稍候..." networkIndicator:YES];
        
        //登录xmpp服务器
        XmppUserInfo *userInfo = [[XmppUserInfo alloc] init];
        userInfo.userName = self.userTextField.text;
        userInfo.password = self.passTextField.text;
        [[XMPPServer sharedServer] connectWithUserInfo:userInfo];
        [XMPPServer sharedServer].delegate = self;
#warning mark - 测试使用
        //[self performSegueWithIdentifier:@"login" sender:self];
        
        //超时检测
        [self performSelector:@selector(checkTimeOut) withObject:nil afterDelay:15];
        
    }else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请输入用户名，密码" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    }
}


//check time out
-(BOOL)validateWithUser:(NSString *)userText andPass:(NSString *)passText{
    return userText.length > 0 && passText.length > 0;
}

-(void)checkTimeOut{
    if (!loginFlag) {
        [SVProgressHUD dismissWithError:@"登录超时"];
    }
}

- (IBAction)toRegister:(id)sender{
    RegisterViewCtl *registerVC = [[RegisterViewCtl alloc] init];
    [self presentViewController:registerVC animated:YES completion:^{
        
    }];
}

#pragma mark - xmppServer delegate
-(void)xmppServerLoginSuccess{
    [SharedAppDelegate initUserData];
    //[self performSegueWithIdentifier:@"login" sender:self];
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    SharedAppDelegate.window.rootViewController = [storyBoard instantiateInitialViewController];
    
    [SVProgressHUD dismissWithSuccess:@"登录成功!" afterDelay:2];
}

-(void)xmppServerLoginFail{
    [SVProgressHUD dismissWithError:@"连接服务器失败"];
}

-(void)xmppServerAuthenticateFail{
    [SVProgressHUD dismissWithError:@"登录失败，请检查用户名或密码"];
}

//#pragma mark - segue
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
//{
//    if ([segue.identifier isEqualToString:@"register"]) {
//
//    }
//}


#pragma mark - anim
//平移动画
-(void)initAnim1{
    CABasicAnimation *basicAnim = [CABasicAnimation animationWithKeyPath:@"position"];
    basicAnim.duration = 2;
    //    basicAnim.fromValue = [NSValue valueWithCGPoint:CGPointMake(100, 100)];
    basicAnim.toValue = [NSValue valueWithCGPoint:CGPointMake(250, 300)];
    //    basicAnim.byValue =[NSValue valueWithCGPoint:CGPointMake(100, 100)];
    [self.userTextField.layer addAnimation:basicAnim forKey:nil];
    
    basicAnim.removedOnCompletion  = NO;
    basicAnim.fillMode = kCAFillModeForwards;
    
    // 设置动画代理
    basicAnim.delegate = self;
}

//旋转动画
-(void)initAnim2{
     CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    anim.toValue = @M_PI_4;
    anim.duration = 2;
    anim.repeatCount = MAXFLOAT;
    anim.removedOnCompletion = NO;
    anim.fillMode = kCAFillModeForwards;
    [self.userTextField.layer addAnimation:anim forKey:nil];
}

//自定义动画-平移1
-(void)initAnim3{
    CAKeyframeAnimation *anim = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    anim.duration = 2;
    NSValue *p1 = [NSValue valueWithCGPoint:CGPointMake(0, 0)];
    NSValue *p2 = [NSValue valueWithCGPoint:CGPointMake(300, 0)];
    NSValue *p3 = [NSValue valueWithCGPoint:CGPointMake(300, 300)];
    NSValue *p4 = [NSValue valueWithCGPoint:CGPointMake(0, 300)];
    anim.values = @[p1, p2, p3, p4];
    
    [self.userTextField.layer addAnimation:anim forKey:nil];
}

//自定义动画-平移2 根据路径进行动画
-(void)initAnim4{
    CAKeyframeAnimation *anim = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddEllipseInRect(path, NULL, CGRectMake(0, 0, 300, 300));
    anim.duration = 1;
    anim.path = path;
    anim.repeatCount = MAXFLOAT;
    [self.userTextField.layer addAnimation:anim forKey:nil];
    CGPathRelease(path);
}

//抖动动画
#define angle2radian(x) (((x)/180.0)*M_PI) //定义一个宏定义
-(void)initAnim5{
    CAKeyframeAnimation *anim = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation"];
    float angle = angle2radian(3);
    anim.values = @[@(-angle), @(angle), @(-angle)];
    anim.repeatCount = MAXFLOAT;
    anim.duration = 0.2;
    [self.userTextField.layer addAnimation:anim forKey:nil];
}
#pragma mark - anim2
-(void)initAnim6{
    CATransition *anim = [CATransition animation];
    anim.type = @"fade";
    anim.subtype = kCATransitionFromRight;
    anim.duration = 0.5;
    [self.userTextField.layer addAnimation:anim forKey:nil];
}
@end
