//  Globals.h
//  EduSun
//
//  Created by yisi on 13-4-21.
//  Copyright (c) 2013年 MONTNETS. All rights reserved.
//  全局对象

#import <Foundation/Foundation.h>

@interface Globals : NSObject {
    NSString  *userId;
    NSString  *userToken;
    NSString  *userPassword;
    NSInteger userType;
    NSString  *userAllType;
    NSString  *userName;      //姓名
    NSInteger userClassId;
    NSInteger userSchoolId;
    NSInteger userPrivelege;
    
    NSString  *account;   //账户id
    NSString  *password;
    NSString  *position;
    NSString  *job;       //老师职务
	NSString  *name;      //账户姓名
    NSString  *headUrl;
	UIImage   *head;		
	NSString  *signature;	
	NSInteger sex;        //0－女；1－男；
    NSString  *birthday;
	NSString  *mobile;	
	NSString  *telphone;
    NSString  *qq;
    NSString  *email;
    NSString  *msn;
    NSInteger groupLimit;
    NSDate    *updateTime;
    
    NSTimeInterval lastDBUpdateTime;
    NSTimeInterval lastOnlineUpdateTime;
    
	BOOL		loginState;
    BOOL        soundOn;
    NSInteger   currentTheme;
	NSString	*firmwareInfo;    //手机固件信息
	NSString	*deviceToken;     //苹果推送令牌
	NSString	*deviceId;        //设备ID
    
    NSTimeInterval  lastLoginOutTime;
    
    NSString    *fileServerIP;
    NSString    *fileServerPort;
    NSString    *fileServerUrl;
	
	NSInteger	unreadMessageNumbers;
    NSInteger   unreadOperateNumbers;
    NSInteger   unreadClassZoneNumbers;
}
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
@property(nonatomic)		BOOL		soundOn;
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

@property(nonatomic,setter = setUnreadMessageNumbers:)		NSInteger	unreadMessageNumbers;	//未读的消息条数
@property(nonatomic,setter = setUnreadOperateNumbers:)		NSInteger	unreadOperateNumbers;	//未读的推送条数
@property(nonatomic,setter = setUnreadClassZoneNumbers:)    NSInteger	unreadClassZoneNumbers;	//未读的动态条数

- (id)init;
- (void)dealloc;
- (void)clearWhenLogOut;

+ (NSTimeInterval)strToTimeInterval:(NSString *)dateString;
+ (NSString *)dateToStr:(NSDate *)date;
+ (NSString *)dateToStr_v2:(NSDate *)date;
+ (NSString *)dateToStr_v3:(NSDate *)date;
+ (NSString *)dateToStr_v4:(NSDate *)date;
+ (NSString *)dateToStr_v5:(NSDate *)date;
+ (NSString *)dateToStr_v6:(NSDate *)date;
+ (NSString *)dateToStr_v7:(NSDate *)date;
+ (NSString *)dateToStr_v8:(NSString *)dateString;
+ (NSString *)dateToStr_Format:(NSDate *)date;
+ (NSString *)dateToStr_dbFormat:(NSDate *)date;
+ (NSString *)dateToStr_dbFormatWithoutHMS:(NSDate *)date;
+ (NSDate *)strToDate:(NSString* )year month:(NSString *)month day:(NSString *)day hour:(NSString *)hour minute:(NSString *)minute;
- (void)clearUserDatasWhenLogOut:(BOOL)isHotLogout;
+ (NSString *)getAstroWithMonth:(int)m day:(int)d;
+ (NSString *)getAstroWithDate:(NSDate *)_date;
+ (NSString *)stringByDeleteBlankLines:(NSString *)sourceStr;

+ (NSString *)GetLocalIPAddress;
+ (NSString *)getCurrentTime;
+ (NSString *) UnicodeToUtf8:(NSString *)string;
+ (NSString *) Utf8ToUnicode:(NSString *)string;
+(id )JsonStringToDict:(NSString *)jsonString;
// ascII 码转换
+ (NSString *)intToAscII:(int)num;
@end
