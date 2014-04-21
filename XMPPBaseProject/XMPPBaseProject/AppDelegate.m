//
//  AppDelegate.m
//  XMPPBaseProject
//
//  Created by caohuan on 14-4-9.
//  Copyright (c) 2014年 ___FULLUSERNAME___. All rights reserved.
//

#import "AppDelegate.h"
#import "LoginViewController.h"
#import "Globals.h"
#import "SVProgressHUD.h"
#import "XMPPHelper.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - private
-(void)logout{
    [[XMPPServer sharedServer] disconnect];
    //[self.viewController dismissModalViewControllerAnimated:YES];
    
    //self.selectedViewCtl = loginViewController;
}

-(void)login{
    [self initUserData];
    
    //mainViewController = [[MainViewController alloc] init];
    //[self.viewController presentModalViewController:mainViewController animated:YES];
}


-(void)showRemarkMsg:(NSString *)remarkMsg{
//    [UIView beginAnimations:nil context:nil];
//    mainViewController.remarkLabel.hidden = NO;
//    mainViewController.remarkLabel.text = remarkMsg;
//    [UIView commitAnimations];
//    [self performSelector:@selector(hideRemarkLable) withObject:nil afterDelay:1.0];
}
 

-(void)hideRemarkLable{
//    [UIView beginAnimations:nil context:nil];
//    mainViewController.remarkLabel.hidden = YES;
//    mainViewController.remarkLabel.text = @"";
//    [UIView commitAnimations];
}
#pragma mark - custome getters
- (Globals *)globals {
	if (_globals == nil) {
		_globals = [[Globals alloc] init];
	}
	return _globals;
}

- (DBCenter *)databaseService {
	if (_databaseService == nil) {
		_databaseService = [[DBCenter alloc] init];
	}
	return _databaseService;
}

- (XMPPServer *)xmppServer {
	if (_xmppServer == nil) {
		_xmppServer = [XMPPServer sharedServer];
	}
	return _xmppServer;
}

#pragma mark XMPPServerDelegate
-(void)xmppServerLoginSuccess{
    [SVProgressHUD dismissWithSuccess:@"登录成功！" afterDelay:1.0];
    [self performSelector:@selector(login) withObject:nil afterDelay:1.0];
}

-(void)xmppServerLoginFail{
    [SVProgressHUD dismissWithError:@"登录失败！" afterDelay:1.0];
}

-(void)xmppServerAuthenticateFail{
    [SVProgressHUD dismissWithError:@"验证失败！" afterDelay:1.0];
}

#pragma mark - public instance method
-(void)initUserData{
    
    self.globals.userId= [[NSUserDefaults standardUserDefaults] objectForKey:kUserID];
    
    //创建数据库
    [self.databaseService createDb];
    
    //查询所有用户
    [XMPPHelper xmppQueryRoster];
}


@end
