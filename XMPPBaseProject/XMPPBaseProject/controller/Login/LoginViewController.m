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
    NSString *password = [defaults stringForKey:kPassword];
    //NSString *xmppServer = [defaults stringForKey:kXMPPServerDomain];
    
    self.userTextField.text = userId;
    self.passTextField.text = password;
    //self.serverTextField.text = xmppServer;
    
    /*
     //自动登录：
    if (userId && password) {
        XmppUserInfo *userInfo = [[XmppUserInfo alloc] init];
        userInfo.userName = userId;
        userInfo.password = password;
        [[XMPPServer sharedServer] connectWithUserInfo:userInfo];
    }
     */
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
        
        //持久化登录消息
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:self.userTextField.text forKey:kUserID];
        [defaults setObject:self.passTextField.text forKey:kPassword];
        [defaults synchronize];
        
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

#pragma mark - xmppServer delegate
-(void)xmppServerLoginSuccess{
    [SharedAppDelegate initUserData];
    [self performSegueWithIdentifier:@"login" sender:self];
    [SVProgressHUD dismissWithSuccess:@"登录成功!" afterDelay:2];
}

-(void)xmppServerLoginFail{
    [SVProgressHUD dismissWithError:@"连接服务器失败"];
}

-(void)xmppServerAuthenticateFail{
    [SVProgressHUD dismissWithError:@"登录失败，请检查用户名或密码"];
}

@end
