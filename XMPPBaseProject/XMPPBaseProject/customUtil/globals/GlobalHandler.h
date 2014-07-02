//
//  GlobalHandler.h
//  XMPPBaseProject
//
//  Created by hc on 14-6-27.
//  Copyright (c) 2014年 hc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AppUser;
@class BuddyManager;
@class MessageManager;
@class ConversationManager;

@interface GlobalHandler : NSObject

//singleton
SYNTHESIZE_SINGLETON_FOR_HEADER(GlobalHandler)

@property (nonatomic, readonly)BuddyManager *buddyManager;
@property (nonatomic, readonly)MessageManager *messageManager;
@property (nonatomic, readonly)ConversationManager *conversationManager;

#pragma mark - getter
-(BuddyManager *)buddyManager;
-(MessageManager *)messageManager;
-(ConversationManager *)conversationManager;

#pragma mark - login pwd handle
//set password
+(BOOL)handlePasswordSet:(NSString *)password forAccount:(NSString *)account;
//get password
+(NSString *)handlePasswordGetForAccount:(NSString *)account;
//delete password
+(BOOL)handlePasswordDeleteForAccount:(NSString *)account;

+(AppUser *)handleLastLoginPersonGet;

#pragma mark - date handler
+ (NSTimeInterval)handleStrToTimeInterval:(NSString *)dateString;
+ (NSString *)handleDateToStr:(NSDate *)date;
+ (NSString *)handleDateToStr_v2:(NSDate *)date;
+ (NSString *)handleDateToStr_v3:(NSDate *)date;
+ (NSString *)handleDateToStr_v4:(NSDate *)date;
+ (NSString *)handleDateToStr_v5:(NSDate *)date;
+ (NSString *)handleDateToStr_v6:(NSDate *)date;
+ (NSString *)handleDateToStr_v7:(NSDate *)date;
+ (NSString *)handleDateToStr_v8:(NSString *)dateString;

+ (NSString *)handleDateToStr_Format:(NSDate *)date;
+ (NSString *)handleDateToStr_dbFormat:(NSDate *)date;
+ (NSString *)handleDateToStr_dbFormatWithoutHMS:(NSDate *)date;
+ (NSDate *)handleStrToDate:(NSString* )year month:(NSString *)month day:(NSString *)day hour:(NSString *)hour minute:(NSString *)minute;
+ (NSString *)handleAstroGetWithMonth:(int)m day:(int)d;
+ (NSString *)handleAstroGetWithDate:(NSDate *)_date;
+ (NSString *)handleCurrentTimeGet;

#pragma mark - data type handle
+ (NSString *) handleUnicodeToUtf8:(NSString *)string;
+ (NSString *) handleUtf8ToUnicode:(NSString *)string;
+(id )handleJsonStringToDict:(NSString *)jsonString;
// ascII
+ (NSString *)handleIntToAscII:(int)num;

#pragma mark - other util
- (void)handleUserDatasClearWhenLogOut:(BOOL)isHotLogout;
+ (NSString *)handleBlankLineDeleteForStr:(NSString *)sourceStr;
+ (NSString *)handleLocalIPAddressGet;

@end
