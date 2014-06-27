//
//  GlobalHelper.h
//  XMPPBaseProject
//
//  Created by hc on 14-6-18.
//  Copyright (c) 2014年 hc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AppUser;
@interface GlobalHelper : NSObject

#pragma mark - login pwd handle
//set password
+(BOOL)setPassword:(NSString *)password forAccount:(NSString *)account;
//get password
+(NSString *)passwordForAccount:(NSString *)account;
//delete password
+(BOOL)deletePasswordForAccount:(NSString *)account;

+(AppUser *)lastLoginPerson;

#pragma mark - date handler
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
+ (NSString *)getAstroWithMonth:(int)m day:(int)d;
+ (NSString *)getAstroWithDate:(NSDate *)_date;
+ (NSString *)getCurrentTime;

#pragma mark - data type handle
+ (NSString *) UnicodeToUtf8:(NSString *)string;
+ (NSString *) Utf8ToUnicode:(NSString *)string;
+(id )JsonStringToDict:(NSString *)jsonString;
// ascII
+ (NSString *)intToAscII:(int)num;

#pragma mark - other util
- (void)clearUserDatasWhenLogOut:(BOOL)isHotLogout;
+ (NSString *)stringByDeleteBlankLines:(NSString *)sourceStr;
+ (NSString *)GetLocalIPAddress;

@end
