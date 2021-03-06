//
//  AppDelegate.h
//  XMPPBaseProject
//
//  Created by caohuan on 14-4-9.
//  Copyright (c) 2014年 ___FULLUSERNAME___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BMapKit.h"
#import "XMPPServer.h"
#import "DataBaseHandler.h"

extern NSString *const AppDelegateConstant;

@class LoginViewController;
@class Globals;
@class DataBaseHandler;
@interface AppDelegate : UIResponder <UIApplicationDelegate,BMKGeneralDelegate,XMPPServerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic,retain) UIViewController *viewController;
@property (nonatomic,retain) UIViewController *selectedViewCtl;

@property (strong, nonatomic)  XMPPServer  *xmppServer;
@property (strong, nonatomic)  Globals  *globals;
@property (strong, nonatomic)  DataBaseHandler	*databaseService;

- (Globals *)globals;
- (DataBaseHandler *)databaseService;

//注销
-(void)logout;
//显示提示信息
-(void)showRemarkMsg:(NSString *)remarkMsg;

@end
