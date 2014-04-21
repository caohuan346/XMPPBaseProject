//  PathService.h
//  KuaiKuai
//
//  Created by hxc on 13-4-21.
//  Copyright (c) 2013年 Andy. All rights reserved.
//
//  常用路径及目录服务

#import <Foundation/Foundation.h>

//全局配置文件
#define ALL_CONFIG_FILE_NAME @"allconfig.plist"
//用户配置文件
#define USER_CONFIG_FILE_NAME @"userconfig.plist"
//用户登录数据文件,存放用于登陆的基本信息
#define USER_DATA_FILE_NAME @"userdata.plist"
//数据库文件
#define USER_DB_FILE_NAME @"userdb.sqlite3"

@interface PathService : NSObject

//取得某个用户id全部资源类型文件的目录
+ (NSString *)pathForUserId:(NSString *)userId;
//是否创建了某个用户id全部资源类型文件的目录
+ (BOOL)pathExistForUserId:(NSString *)userId;
//取得所有用户、所有资源的根目录
+ (NSString *)pathForAllUsers;
//所有用户caches位置，一般图像、较大的wav音频都存放在这里
+ (NSString *)pathForAllUserCaches;
//取得用户登录信息缓存文件的路径
+ (NSString *)pathForAllUserDataFile;
//取得用户数据库文件的路径
+ (NSString *)pathForUserDataBaseFileOfUser:(NSString *)userId;
//取得全局配置文件路径
+ (NSString *)pathForAllConfigFile;
//取得单个用户配置文件路径
+ (NSString *)pathForConfigFileOfUser:(NSString *)userId;

@end
