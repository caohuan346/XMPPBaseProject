//  PathService.m
//  KuaiKuai
//
//  Created by hxc on 13-4-21.
//  Copyright (c) 2013年 Andy. All rights reserved.
//

#import "Globals.h"
#import "AppDelegate.h"
#import "PathService.h"

@implementation PathService

#pragma mark - of all users
+ (NSString *)pathForAllUsers {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [self pathCheckOrCreate:[paths objectAtIndex:0]];
}

+ (NSString *)pathForAllUserCaches {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    return [self pathCheckOrCreate:[paths objectAtIndex:0]];
}

+ (NSString *)pathForAllUserDataFile {
	return [[self pathForAllUsers] stringByAppendingPathComponent:USER_DATA_FILE_NAME];
}

+ (NSString *)pathForAllConfigFile {
	return [[self pathForAllUsers] stringByAppendingPathComponent:ALL_CONFIG_FILE_NAME];
}

#pragma mark - current user
+ (NSString *)pathForCurrentUser:(NSString *)userId {
	if (!userId || [userId isEqualToString:@""]) {
		userId = @"0";
	}
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath=[documentsDirectory stringByAppendingPathComponent:userId];
    return [self pathCheckOrCreate:filePath];
}

+ (BOOL)pathExistForCurrentUser:(NSString *)userId {
	if (!userId || [userId isEqualToString:@""]) {
		userId = @"0";
	}
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *filePath=[documentsDirectory stringByAppendingPathComponent:userId];
	BOOL isDirectory = TRUE;
    return [fileManager fileExistsAtPath:filePath isDirectory:&isDirectory];
}

+ (NSString *)pathOfConfigFileForCurrentUser:(NSString *)userId {
	return [[self pathForCurrentUser:userId] stringByAppendingPathComponent:USER_CONFIG_FILE_NAME];
}

+ (NSString *)pathOfDataBaseFileForCurrentUser:(NSString *)userId {
    return [[self pathForCurrentUser:userId] stringByAppendingPathComponent:USER_DB_FILE_NAME];
}

#pragma mark - path service: target chat msg 、 audio
+ (NSString *)pathForTarget: (NSString *)targetId {
    NSString *path = [[self pathForCurrentUser:SharedAppDelegate.globals.userId] stringByAppendingPathComponent:targetId];
    return [self pathCheckOrCreate:path];
}

+ (NSString *)pathOfOriginalMsgImageForTarget:(NSString *)targetId{
    NSString *path = [[self pathForTarget:targetId] stringByAppendingPathComponent:kMsgImgSrcComponentOriginal];
    return [self pathCheckOrCreate:path];
}

+ (NSString *)pathOfThumbMsgImageForTarget:(NSString *)targetId{
    NSString *path = [[self pathForTarget:targetId] stringByAppendingPathComponent:kMsgImgSrcComponentThumb];
    return [self pathCheckOrCreate:path];
}

+ (NSString *)pathOfWavMsgAudioForTarget:(NSString *)targetId{
    NSString *path = [[self pathForTarget:targetId] stringByAppendingPathComponent:kMsgAudioSrcComponentWav];
    return [self pathCheckOrCreate:path];
}

+ (NSString *)pathOfAmrMsgAudioForTarget:(NSString *)targetId{
    NSString *path = [[self pathForTarget:targetId] stringByAppendingPathComponent:kMsgAudioSrcComponentAmr];
    return [self pathCheckOrCreate:path];
}

#pragma mark - path check or create
+(NSString *)pathCheckOrCreate:(NSString *)path {
    NSFileManager *fileManager = [NSFileManager defaultManager];
	BOOL isDirectory = TRUE;
	if (![fileManager fileExistsAtPath:path isDirectory:&isDirectory]) {
		[fileManager createDirectoryAtPath:path withIntermediateDirectories:TRUE attributes:nil error:nil];
	}
    return path;
}


@end
