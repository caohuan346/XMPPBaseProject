//  Globals.h
//  EduSun
//
//  Created by yisi on 13-4-21.
//  Copyright (c) 2013年 hc. All rights reserved.
//  全局对象

#import <Foundation/Foundation.h>

@interface Globals : NSObject

@property(nonatomic,copy)NSString *userId;
@property(nonatomic,copy) NSString   *userToken;
@property(nonatomic,copy) NSString   *userPassword;
@property(nonatomic,assign)NSInteger userType;
@property(nonatomic,copy)  NSString  *userAllType;
@property(nonatomic,copy)  NSString  *userName;
@property(nonatomic,assign)NSInteger userClassId;
@property(nonatomic,assign)NSInteger userSchoolId;
@property(nonatomic,assign)NSInteger userPrivelege;
@property(nonatomic,retain)NSString  *account;
@property(nonatomic,assign)NSTimeInterval   lastLoginOutTime;
@property(nonatomic,copy)  NSString  *position;
@property(nonatomic,copy)  NSString  *password;
@property(nonatomic,copy)  NSString  *job;
@property(nonatomic,copy)  NSString  *name;
@property(nonatomic,copy)  NSString  *headUrl;
@property(nonatomic,retain)UIImage   *head;
@property(nonatomic,copy)  NSString  *signature;
@property(nonatomic,assign)NSInteger sex;
@property(nonatomic,copy)  NSString  *birthday;
@property(nonatomic,copy)  NSString  *mobile;
@property(nonatomic,copy)  NSString  *telphone;
@property(nonatomic,copy)  NSString  *qq;
@property(nonatomic,copy)  NSString  *email;
@property(nonatomic,copy)  NSString  *msn;
@property(nonatomic,assign)NSInteger groupLimit;
@property(nonatomic,retain)NSDate    *updateTime;

@property(nonatomic,assign)NSTimeInterval lastDBUpdateTime;  //-1表示初次同步
@property(nonatomic,assign)NSTimeInterval lastOnlineUpdateTime;

@property(nonatomic,assign)NSInteger currentTheme;
@property(nonatomic)		BOOL		loginState;
@property(nonatomic,retain) NSString	*firmwareInfo;
@property(nonatomic,retain) NSString	*deviceToken;
@property(nonatomic,retain) NSString	*deviceId;

//XMPP
@property(nonatomic,retain) NSString	*xmppServerIP;
@property(nonatomic,retain) NSString	*xmppServerDomain;

@property(nonatomic,retain) NSString	*xmppServerPort;

@property(nonatomic,retain) NSString	*fileServerIP;
@property(nonatomic,retain) NSString	*fileServerPort;
@property(nonatomic,retain,getter = fileServerUrl) NSString	*fileServerUrl;

//@property(nonatomic,setter = setUnreadMessageNumbers:)		NSInteger	unreadMessageNumbers;	//未读的消息条数
//@property(nonatomic,setter = setUnreadOperateNumbers:)		NSInteger	unreadOperateNumbers;	//未读的推送条数
//@property(nonatomic,setter = setUnreadClassZoneNumbers:)    NSInteger	unreadClassZoneNumbers;	//未读的动态条数

#pragma mark - setting
//声音与震动
@property(nonatomic,assign) BOOL	soundOn;  //声音提醒
@property(nonatomic,assign) BOOL	vibrateOn;//震动开关状态
@property(nonatomic,assign) NSTimeInterval currentInterval;//当前消息的接收时间
@property(nonatomic,assign) NSTimeInterval  previousInterval;//上一条消息的接收时间

- (id)init;
- (void)clearWhenLogOut;
- (void)globalInfoPersist;
- (void)globalSystemSoundPlay;

@end
