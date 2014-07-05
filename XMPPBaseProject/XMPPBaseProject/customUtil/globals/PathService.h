//  PathService.h
//  XMPPBaseProject
//
//  Created by hxc on 13-4-21.
//  Copyright (c) 2013年 Andy. All rights reserved.
//
//  常用路径及目录服务

#import <Foundation/Foundation.h>

//全局配置文件
#define ALL_CONFIG_FILE_NAME @"allconfig.plist"
//用户登录数据文件,存放用于登陆的基本信息
#define USER_DATA_FILE_NAME @"userdata.plist"
//用户数据库文件
#define USER_DB_FILE_NAME @"userdb.sqlite3"
//用户配置文件
#define USER_CONFIG_FILE_NAME @"userconfig.plist"
//用户

//聊天对象图片原图
#define kMsgImgSrcComponentOriginal @"msgImg/original/"
//聊天对象图片缩略图
#define kMsgImgSrcComponentThumb @"msgImg/thumb/"
//聊天对象wav录制语音
#define kMsgAudioSrcComponentWav @"msgAudio/wav/"
//聊天对象amr格式语音（wav转码所得）
#define kMsgAudioSrcComponentAmr @"msgAudio/amr/"

//系统图片路径
//TODO

@interface PathService : NSObject

#pragma mark - of all users
//取得所有用户、所有资源的根目录
+ (NSString *)pathForAllUsers;
//所有用户caches位置，一般图像、较大的wav音频都存放在这里
+ (NSString *)pathForAllUserCaches;
//取得用户登录信息缓存文件的路径
+ (NSString *)pathForAllUserDataFile;
//取得全局配置文件路径
+ (NSString *)pathForAllConfigFile;

#pragma mark - of current user
//是否创建了某个用户id全部资源类型文件的根目录
+ (BOOL)pathExistForCurrentUser:(NSString *)userId;
//取得某个用户id全部资源类型文件的目录
+ (NSString *)pathForCurrentUser:(NSString *)userId;
//取得单个用户配置文件路径
+ (NSString *)pathOfConfigFileForCurrentUser:(NSString *)userId;
//取得用户数据库文件的路径
+ (NSString *)pathOfDataBaseFileForCurrentUser:(NSString *)userId;

#pragma mark - of taget img and audio
+ (NSString *)pathForTarget: (NSString *)targetId;
//聊天对象原图根目录
+ (NSString *)pathOfOriginalMsgImageForTarget:(NSString *)targetId;
//聊天对象缩略图根目录
+ (NSString *)pathOfThumbMsgImageForTarget:(NSString *)targetId;
//聊天对象wav语音根目录
+ (NSString *)pathOfWavMsgAudioForTarget:(NSString *)targetId;
//聊天对象amr语音根目录
+ (NSString *)pathOfAmrMsgAudioForTarget:(NSString *)targetId;


#pragma mark - path check or create
//路径检测或创建
+(NSString *)pathCheckOrCreate:(NSString *)path;
@end
