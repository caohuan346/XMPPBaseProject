//
//  Define.h
//  BaseProject
//
//  Created by Huan Cho on 13-8-5.
//  Copyright (c) 2013年 ch. All rights reserved.
//

#ifndef BaseProject_Define_h
#define BaseProject_Define_h

#endif

//本机tigase
//#define XMPPServerURL      @"192.168.2.226"
//#define XMPPServerHostName @"192.168.2.226"

//mini of
#define XMPPServerURL      @"192.168.8.53"
#define XMPPServerHostName @"hc-mini.local"

//macbook of
//#define XMPPServerURL      @"192.168.1.57"
//#define XMPPServerHostName @"macbook-pro.lan"

//本机tigase
//#define XMPPServerURL      @"192.168.2.226"
//#define XMPPServerHostName @"Mac-mini.local"

#define kUserID @"loginId"
#define kPassword @"pwd"

#define kXMPPServerIP @"kXMPPServerIP"
#define kXMPPServerDomain @"kXMPPServerDomain"

#define XMPPRequest_TimeOut 20         //http请求超时时间
#define XMPPRequest_MaxTime 4          //http请求超时最大重连次数

//Local notification
#define  LOCAL_NOTIFICATION_UNREADMESSAGENUMBERCHANGE @"LocalNotificationUnReadMessageNumberChange"
#define  LOCAL_NOTIFICATION_LOGIN_SUCESS @"LocalNotificationLoginSuccess"

#define kNoti_XMPP_didReceiveXMPPMsg @"didReceiveXMPPMsg"    //收到新消息

#define SharedAppDelegate ((AppDelegate *)[UIApplication sharedApplication].delegate)
#define StandardUserDefaults [NSUserDefaults standardUserDefaults]

/*********************************** device ************************************/
//判断是否是Retina显示屏
#define isRetina ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 960), [[UIScreen mainScreen] currentMode].size) : NO)
//判断是否是iPhone5
#define iPhone5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)
#define isInch4 [UIScreen mainScreen].bounds.size.height==568
//判断是否是pad
#define isPad (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
//主屏宽
#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
//主屏高
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)
//当前设备的ios版本
#define IOS_VERSION [[[UIDevice currentDevice] systemVersion] floatValue]
//当前设备的语言
#define CurrentLanguage ([[NSLocale preferredLanguages] objectAtIndex:0])


/********************************** color *************************************/
#define UIColorFromRGB(rgbValue) [UIColor  colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0  green:((float)((rgbValue & 0xFF00) >> 8))/255.0  blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
//RGB转UIColor（带alpha值）
#define UIColorFromRGBWithAlpha(rgbValue,a) [UIColor  colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0  green:((float)((rgbValue & 0xFF00) >> 8))/255.0  blue:((float)(rgbValue & 0xFF))/255.0 alpha:a]
