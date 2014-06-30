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
#import "User.h"
#import "XMPPServer.h"
#import "PathService.h"

#define KEEP_ALIVE_INTERVAL 600

@interface AppDelegate (){
    BMKMapManager * _mapManager;
    
    UIBackgroundTaskIdentifier _bgTask;
    NSInteger bgCount;
}

@end

@implementation AppDelegate

#pragma life circle
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

    NSLog(@"%p",[GlobalHandler sharedInstance].buddyService);
    // 启动BaiduMapManager使用百度地图
	_mapManager = [[BMKMapManager alloc]init];
	BOOL ret = [_mapManager start:@"bGPHXDF6Nj6W2oGu7jeknQ73" generalDelegate:self];
	if (!ret) {
		NSLog(@"manager start failed!");
	}
    
    //判断是否由远程消息通知触发应用程序启动
    if ([launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]!=nil) {
        //获取应用程序消息通知标记数（即小红圈中的数字）
        int badge = [UIApplication sharedApplication].applicationIconBadgeNumber;
        if (badge>0) {
            //如果应用程序消息通知标记数（即小红圈中的数字）大于0，清除标记。
            badge--;
            //清除标记。清除小红圈中数字，小红圈中数字为0，小红圈才会消除。
            [UIApplication sharedApplication].applicationIconBadgeNumber = badge;
        }
    }
    //消息推送注册
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeSound|UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeBadge];
    
    //1. 将app注册notification里面,
    [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeSound|UIRemoteNotificationTypeBadge];

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    self.xmppServer = [XMPPServer sharedServer];

    [self initUsersPublicData];
    
    AppUser *appUser = [GlobalHandler handleLastLoginPersonGet];
    if (appUser.password) {
        [self toHomePage];
        
        //登录xmpp服务器
        XmppUserInfo *userInfo = [[XmppUserInfo alloc] init];
        userInfo.userName = appUser.userId;
        userInfo.password = appUser.password;
        [self.xmppServer connectWithUserInfo:userInfo];
        
    }else{
        //首先到登陆页面
        LoginViewController *loginViewController = [[LoginViewController alloc]init];
        self.window.rootViewController = loginViewController;
    }
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
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
    
    if ([self isMultitaskingSupported])
    {
        [self performSelectorOnMainThread:@selector(keepAppAlive) withObject:nil waitUntilDone:YES];
        BOOL backgroundAccepted = [application setKeepAliveTimeout:KEEP_ALIVE_INTERVAL handler:^{
            NSLog(@"setKeepAliveTimeout:%d",bgCount);
            if (_bgTask == UIBackgroundTaskInvalid && bgCount) {
                [self performSelectorOnMainThread:@selector(keepAppAlive) withObject:nil waitUntilDone:YES];
                bgCount = 0;
            }
        }];
        if (backgroundAccepted) {
            NSLog(@"backgrounding accepted");
        }
    }
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

#pragma mark -registerForRemoteNotifications
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    //2: 并从APNS上获取测试机的deviceToken.
    NSString *dToken=[[deviceToken description] substringWithRange:NSMakeRange(1, [deviceToken description].length-2)];
    NSLog(@"%@",dToken);
    [StandardUserDefaults setObject:dToken forKey:@"deviceToken"];
    [StandardUserDefaults synchronize];
    NSLog(@"%s-----%@", __FUNCTION__,[deviceToken description]);
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{
    NSLog(@"%s == %@", __FUNCTION__,error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
    NSLog(@" 收到推送消息 ： %@",[[userInfo objectForKey:@"aps"] objectForKey:@"alert"]);
    if ([[userInfo objectForKey:@"aps"] objectForKey:@"alert"]!=NULL) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"推送通知"
                                            message:[[userInfo objectForKey:@"aps"] objectForKey:@"alert"]
                                            delegate:self
                                            cancelButtonTitle:@" 关闭"
                                            otherButtonTitles:@" 更新状态",nil];
        [alert show];
        NSLog(@"%s", __FUNCTION__);
    }
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification{
    NSLog(@"%s", __FUNCTION__);
}

#pragma mark - background
- (BOOL) isMultitaskingSupported{
    BOOL result = NO;
    if ([[UIDevice currentDevice] respondsToSelector:@selector(isMultitaskingSupported)])
    {
        result = [[UIDevice currentDevice] isMultitaskingSupported];
    }
    return result;
}

- (void)keepAppAlive{
    //bg task
    _bgTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        NSLog(@"beginBackgroundTaskWithExpirationHandler:%d",1);
        [[UIApplication sharedApplication]  endBackgroundTask:_bgTask];
        _bgTask = UIBackgroundTaskInvalid;
        bgCount += 1;
    }];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        while (1) {
            if (_bgTask == UIBackgroundTaskInvalid) {
                break;
            }
            NSTimeInterval remainingTime = [UIApplication sharedApplication].backgroundTimeRemaining;
            if (remainingTime == DBL_MAX) {
                bgCount = 0;
                break;
            }else{
                NSLog(@"BackgroundTaskWithExpiration,BGTime left: %f", remainingTime);
            }
            sleep(1);
        }
        NSLog(@"beginBackgroundTaskWithExpirationHandler:%d",2);
        [[UIApplication sharedApplication]  endBackgroundTask:_bgTask];
        _bgTask = UIBackgroundTaskInvalid;
        bgCount += 1;
    });
}


#pragma mark - private
-(void)toHomePage{
    [self initPersonalData];
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    self.window.rootViewController = [storyBoard instantiateInitialViewController];
}

-(void)logout{
    [[XMPPServer sharedServer] disconnect];
    //[self.viewController dismissModalViewControllerAnimated:YES];
    
    //self.selectedViewCtl = loginViewController;
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

- (void)keepAlive {
    static int i = 0;
    NSLog(@"11111---%d",i++);
}

#pragma mark - custome getters
- (Globals *)globals {
	if (_globals == nil) {
		_globals = [[Globals alloc] init];
	}
	return _globals;
}

- (DataBaseHandler *)databaseService {
	if (_databaseService == nil) {
		_databaseService = [[DataBaseHandler alloc] init];
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
    [self performSelector:@selector(toHomePage) withObject:nil afterDelay:1.0];
    [SVProgressHUD dismissWithSuccess:@"登录成功！" afterDelay:1.0];
}

-(void)xmppServerLoginFail{
    [SVProgressHUD dismissWithError:@"登录失败！" afterDelay:1.0];
}

-(void)xmppServerAuthenticateFail{
    [SVProgressHUD dismissWithError:@"验证失败！" afterDelay:1.0];
}

#pragma mark - BMKGeneral Delegate
- (void)onGetNetworkState:(int)iError
{
    if (0 == iError) {
        NSLog(@"联网成功");
    }
    else{
        NSLog(@"onGetNetworkState %d",iError);
    }
    
}

- (void)onGetPermissionState:(int)iError
{
    if (0 == iError) {
        NSLog(@"授权成功");
    }
    else {
        NSLog(@"onGetPermissionState %d",iError);
    }
}


#pragma mark - public instance method
//init all users public data
-(void)initUsersPublicData{
   [PathService pathForAllConfigFile];
   [PathService pathForAllUserDataFile];
}

//init personal data for currentUser
-(void)initPersonalData{
    
    self.globals.userId= [[NSUserDefaults standardUserDefaults] objectForKey:kUserID];

    //创建数据库
    [self.databaseService createDb];
    
    //查询所有用户
    [XMPPHelper xmppQueryRoster];
}


@end
