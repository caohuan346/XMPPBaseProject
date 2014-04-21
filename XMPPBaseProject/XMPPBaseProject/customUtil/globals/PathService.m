//  PathService.m
//  KuaiKuai
//
//  Created by hxc on 13-4-21.
//  Copyright (c) 2013年 Andy. All rights reserved.
//

#import "Globals.h"
#import "PathService.h"

@implementation PathService

+ (NSString *)pathForUserId:(NSString *)userId {
	if (!userId || [userId isEqualToString:@""]) {
		userId = @"0";
	}
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *filePath=[documentsDirectory stringByAppendingPathComponent:userId];
	BOOL isDirectory = TRUE;
	if (![fileManager fileExistsAtPath:filePath isDirectory:&isDirectory]) {
		[fileManager createDirectoryAtPath:filePath withIntermediateDirectories:TRUE attributes:nil error:nil];
	}
	return [documentsDirectory stringByAppendingPathComponent:userId];
}

+ (BOOL)pathExistForUserId:(NSString *)userId {
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


+ (NSString *)pathForAllUsers {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *filePath=[paths objectAtIndex:0];
	BOOL isDirectory = TRUE;
	if (![fileManager fileExistsAtPath:filePath isDirectory:&isDirectory]) {
		[fileManager createDirectoryAtPath:filePath withIntermediateDirectories:TRUE attributes:nil error:nil];
	}
	return [paths objectAtIndex:0];
}

+ (NSString *)pathForAllUserCaches {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *filePath=[paths objectAtIndex:0];
	BOOL isDirectory = TRUE;
	if (![fileManager fileExistsAtPath:filePath isDirectory:&isDirectory]) {
		[fileManager createDirectoryAtPath:filePath withIntermediateDirectories:TRUE attributes:nil error:nil];
	}
	return [paths objectAtIndex:0];
}

+ (NSString *)pathForAllUserDataFile {
	return [[self pathForAllUsers] stringByAppendingPathComponent:USER_DATA_FILE_NAME];
}

+ (NSString *)pathForUserDataBaseFileOfUser:(NSString *)userId {
	return [[self pathForUserId:userId] stringByAppendingPathComponent:USER_DB_FILE_NAME];
}

+ (NSString *)pathForAllConfigFile {
	return [[self pathForAllUsers] stringByAppendingPathComponent:ALL_CONFIG_FILE_NAME];
}

+ (NSString *)pathForConfigFileOfUser:(NSString *)userId {
	return [[self pathForUserId:userId] stringByAppendingPathComponent:USER_CONFIG_FILE_NAME];
}

@end
