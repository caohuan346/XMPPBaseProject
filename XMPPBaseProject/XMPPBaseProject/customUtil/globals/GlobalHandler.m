//
//  GlobalHandler.m
//  XMPPBaseProject
//
//  Created by hc on 14-6-27.
//  Copyright (c) 2014年 hc. All rights reserved.
//

#import "GlobalHandler.h"
#import "SSKeychain.h"
#import "User.h"
#import <ifaddrs.h>
#import <arpa/inet.h>
#import "BuddyManager.h"
#import "ConversationManager.h"
#import "MessageManager.h"

static NSString *kSSToolkitTestsServiceName = @"SSToolkitTestService";
static NSString *kSSToolkitTestsAccountName = @"SSToolkitTestAccount";
static NSString *kSSToolkitTestsPassword = @"SSToolkitTestPassword";

static NSString *kTDIMServiceName = @"kTDIMServiceName";

@implementation GlobalHandler

#pragma mark - singleton
SYNTHESIZE_SINGLETON_FOR_CLASS(GlobalHandler)

- (void)testAll {
	// Getting & Setings Passwords
	[SSKeychain setPassword:kSSToolkitTestsPassword forService:kSSToolkitTestsServiceName account:kSSToolkitTestsAccountName];
	NSString *password = [SSKeychain passwordForService:kSSToolkitTestsServiceName account:kSSToolkitTestsAccountName];
	//STAssertEqualObjects(password, kSSToolkitTestsPassword, @"Password reads and writes");
	
	// Getting Accounts
	NSArray *accounts = [SSKeychain allAccounts];
	//STAssertTrue([self _accounts:accounts containsAccountWithName:kSSToolkitTestsAccountName], @"All accounts");
	accounts = [SSKeychain accountsForService:kSSToolkitTestsServiceName];
    
	//STAssertTrue([self _accounts:accounts containsAccountWithName:kSSToolkitTestsAccountName], @"Account for service");
	
	// Deleting Passwords
	[SSKeychain deletePasswordForService:kSSToolkitTestsServiceName account:kSSToolkitTestsAccountName];
	password = [SSKeychain passwordForService:kSSToolkitTestsServiceName account:kSSToolkitTestsAccountName];
	//STAssertNil(password, @"Password deletes");
}


- (BOOL)_accounts:(NSArray *)accounts containsAccountWithName:(NSString *)name {
	for (NSDictionary *dictionary in accounts) {
		if ([[dictionary objectForKey:@"acct"] isEqualToString:name]) {
			return YES;
		}
	}
	return NO;
}

#pragma mark - getter
-(BuddyManager *)buddyManager{
    return [BuddyManager sharedInstance];
}

-(MessageManager *)messageManager{
    return [MessageManager sharedInstance];
}

-(ConversationManager *)conversationManager{
    return [ConversationManager sharedInstance];
}

#pragma mark - login password persist etc.
+(BOOL)handlePasswordSet:(NSString *)password forAccount:(NSString *)account {
    return  [SSKeychain setPassword:password forService:kTDIMServiceName account:account];
}

+(NSString *)handlePasswordGetForAccount:(NSString *)account {
    return  [SSKeychain passwordForService:kTDIMServiceName account:account];
}

+(BOOL)handlePasswordDeleteForAccount:(NSString *)account {
    return  [SSKeychain deletePasswordForService:kTDIMServiceName account:account];
}

+(AppUser *)handleLastLoginPersonGet{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *userId = [defaults stringForKey:kUserID];
    AppUser *user = [[AppUser alloc] init];
    user.userId = userId;
    user.password = [GlobalHandler handlePasswordGetForAccount:userId];
    return user;
}


#pragma mark - gloab setting


#pragma mark - date hander


//格式时间转时间按磋
+ (NSTimeInterval)handleStrToTimeInterval:(NSString *)dateString{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date = [dateFormatter dateFromString:dateString];
    NSTimeInterval timeInterval = [date timeIntervalSince1970];
    return timeInterval;
}

//字符串到日期
+ (NSDate *)handleStrToDate:(NSString *)year month:(NSString *)month day:(NSString *)day hour:(NSString *)hour minute:(NSString *)minute{
	NSDateComponents *comps = [[NSDateComponents alloc] init];
	[comps setYear:[year integerValue]];
	[comps setMonth:[month integerValue]];
	[comps setDay:[day integerValue]];
	[comps setHour:[hour integerValue]];
	[comps setMinute:[minute integerValue]];
	[comps setSecond:0];
	
	NSCalendar *calendar = [NSCalendar currentCalendar];
	NSDate *date = [calendar dateFromComponents:comps];
	
	return date;
}


//日期变成字符串
+ (NSString *)handleDateToStr:(NSDate *)date{
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"MM-dd HH:mm"];
	
	NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
	[dateFormatter setLocale:locale];
	NSString *dateStr = [dateFormatter stringFromDate:date];
	
	return dateStr;
}

+ (NSString *)handleDateToStr_v2:(NSDate *)date {
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"yyyy_MM_dd_HH_mm_ss"];
	
	NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
	[dateFormatter setLocale:locale];
	NSString *dateStr = [dateFormatter stringFromDate:date];
	
	return dateStr;
}

+ (NSString *)handleDateToStr_v3:(NSDate *)date {
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"EE M月d日"];
	dateFormatter.weekdaySymbols = [NSArray arrayWithObjects:@"周日", @"周一", @"周二", @"周三", @"周四", @"周五", @"周六", nil];
	
	NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
	[dateFormatter setLocale:locale];
	NSString *dateStr = [dateFormatter stringFromDate:date];
	
	return dateStr;
}

+ (NSString *)handleDateToStr_v4:(NSDate *)date {
	NSString *dateFormatterStr = @"今天 HH:mm";
	
	NSDateComponents *subComponents = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:date];
	NSDateComponents *nowComponents = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:[NSDate date]];;
	if (subComponents.day != nowComponents.day || subComponents.month != nowComponents.month || subComponents.year != nowComponents.year) {
		dateFormatterStr = @"yyyy-MM-dd HH:mm";
	}
	
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:dateFormatterStr];
	NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
	[dateFormatter setLocale:locale];
	NSString *dateStr = [dateFormatter stringFromDate:date];
	
	return dateStr;
}


+ (NSString *)handleDateToStr_v5:(NSDate *)date {
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"M月d日"];
	
	NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
	[dateFormatter setLocale:locale];
	NSString *dateStr = [dateFormatter stringFromDate:date];
	
	return dateStr;
}

+ (NSString *)handleDateToStr_v6:(NSDate *)date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"yyyy年MM月dd日"];
	
	NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
	[dateFormatter setLocale:locale];
	NSString *dateStr = [dateFormatter stringFromDate:date];
	
	return dateStr;
}

+ (NSString *)handleDateToStr_v7:(NSDate *)date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"yyyy-MM-dd"];
	
	NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
	[dateFormatter setLocale:locale];
	NSString *dateStr = [dateFormatter stringFromDate:date];
	
	return dateStr;
}

+ (NSString *)handleDateToStr_v8:(NSString *)dateString {
    if (dateString == nil || [dateString length] == 0) {
        return dateString;
    }
    NSString *patternStr = [NSString stringWithFormat:@"^(?:(?!0000)[0-9]{4}-(?:(?:0[1-9]|1[0-2])-(?:0[1-9]|1[0-9]|2[0-8])|(?:0[13-9]|1[0-2])-(?:29|30)|(?:0[13578]|1[02])-31)|(?:[0-9]{2}(?:0[48]|[2468][048]|[13579][26])|(?:0[48]|[2468][048]|[13579][26])00)-02-29)\\s+([01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9]$"];
    NSRegularExpression *regularexpression = [[NSRegularExpression alloc] initWithPattern:patternStr options:NSRegularExpressionCaseInsensitive error:nil];
    NSUInteger numberofMatch = [regularexpression numberOfMatchesInString:dateString options:NSMatchingReportProgress range:NSMakeRange(0, dateString.length)];
    
    if(numberofMatch > 0){
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate *date = [dateFormatter dateFromString:dateString];
        NSString *dateFormatterStr = @"今天 HH:mm";
        NSDateComponents *subComponents = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:date];
        NSDateComponents *nowComponents = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:[NSDate date]];
        if (subComponents.day != nowComponents.day || subComponents.month != nowComponents.month || subComponents.year != nowComponents.year) {
            dateFormatterStr = @"MM-dd HH:mm";
        }
        [dateFormatter setDateFormat:dateFormatterStr];
        NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
        [dateFormatter setLocale:locale];
        NSString *dateStr = [dateFormatter stringFromDate:date];
        
        return dateStr;
    } else{
        return dateString;
    }
    return @"";
}


+ (NSString *)handleDateToStr_Format:(NSDate *)date {
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
	NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
	[dateFormatter setLocale:locale];
	NSString *dateStr = [dateFormatter stringFromDate:date];
	
	return dateStr;
}

+ (NSString *)handleDateToStr_dbFormat:(NSDate *)date {
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
	NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
	[dateFormatter setLocale:locale];
	NSString *dateStr = [dateFormatter stringFromDate:date];
	
	return dateStr;
}

+ (NSString *)handleDateToStr_dbFormatWithoutHMS:(NSDate *)date {
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"yyyy-MM-dd 00:00:00"];
	
	NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
	[dateFormatter setLocale:locale];
	NSString *dateStr = [dateFormatter stringFromDate:date];
	
	return dateStr;
}

+ (NSString *)handleAstroGetWithMonth:(int)m day:(int)d {
    NSString *astroString = @"魔羯水瓶双鱼白羊金牛双子巨蟹狮子处女天秤天蝎射手魔羯";
    NSString *astroFormat = @"102123444543";
    NSString *result;
    if (m<1||m>12||d<1||d>31){
        return @"错误日期格式!";
    }
    if(m==2 && d>29)
    {
        return @"错误日期格式!!";
    } else if(m==4 || m==6 || m==9 || m==11) {
        if (d>30) {
            return @"错误日期格式!!!";
        }
    }
    result=[NSString stringWithFormat:@"%@座",[astroString substringWithRange:NSMakeRange(m*2-(d < [[astroFormat substringWithRange:NSMakeRange((m-1), 1)] intValue] - (-19))*2,2)]];
    return result;
}

+ (NSString *)handleAstroGetWithDate:(NSDate *)_date {
    if (_date == nil) {
        return nil;
    }
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:_date];
    return [self handleAstroGetWithMonth:[components month] day:[components day]];
}

+(NSString *)handleCurrentTimeGet{
    
    NSDate *nowUTC = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    
    return [dateFormatter stringFromDate:nowUTC];
    
}

#pragma mark - data type handle
/* 编码转换unicode转utf8 */
+(NSString *) handleUnicodeToUtf8:(NSString *)string
{
    NSString *tempStr1 = [string stringByReplacingOccurrencesOfString:@"&#x" withString:@"\\U"];
    NSString *tempStr2 = [tempStr1 stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    NSString *tempStr3 = [[@"\"" stringByAppendingString:tempStr2] stringByAppendingString:@"\""];
    NSString *tempStr4 = [tempStr3 stringByReplacingOccurrencesOfString:@";" withString:@""];
    NSData *tempData = [tempStr4 dataUsingEncoding:NSUTF8StringEncoding];
    NSString* returnStr = [NSPropertyListSerialization propertyListFromData:tempData
                                                           mutabilityOption:NSPropertyListImmutable
                                                                     format:NULL
                                                           errorDescription:NULL];
    
    //NSLog(@"Output = %@", returnStr);
    
    return [returnStr stringByReplacingOccurrencesOfString:@"\\r\\n" withString:@"\n"];
}

/* 编码转换utf8转unicode */
+(NSString *) handleUtf8ToUnicode:(NSString *)string
{
    NSUInteger length = [string length];
    NSMutableString *s = [NSMutableString stringWithCapacity:0];
    for (int i = 0;i < length; i++) {
        unichar _char = [string characterAtIndex:i];
        //判断是否为英文和数字
        if (_char <= '9' && _char >= '0') {
            [s appendFormat:@"%@",[string substringWithRange:NSMakeRange(i, 1)]];
        }else if(_char >= 'a' && _char <= 'z')
        {
            [s appendFormat:@"%@",[string substringWithRange:NSMakeRange(i, 1)]];
        }else if(_char >= 'A' && _char <= 'Z')
        {
            [s appendFormat:@"%@",[string substringWithRange:NSMakeRange(i, 1)]];
        }else
        {
            [s appendFormat:@"&#x%x;",[string characterAtIndex:i]];
        }
        
    }
    return s;
}

+(id )handleJsonStringToDict:(NSString *)jsonString{
    id jsonDict = nil;
    if ([jsonString length] > 0) {
        NSError *error = nil;
        jsonDict = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
    }
    return jsonDict;
}

+(NSString *)handleIntToAscII:(int)num
{
    // 默认传过来的num是负值
    int tmpNum = -num;
    NSString *strAscII = nil;
    if (tmpNum > 0) {
        strAscII = [NSString stringWithFormat:@"%c", tmpNum];
    }else{
        // 这种情况说明判断错误直接把原来的值返回，不转换
        strAscII = [NSString stringWithFormat:@"%d", num];
    }
    
    return strAscII;
}


#pragma mark -

//登出时，清空用户缓存在内存中的相关数据
- (void)handleUserDatasClearWhenLogOut:(BOOL)isHotLogout {
    
}


//消除一个字符串内多余的空行
+ (NSString *)handleBlankLineDeleteForStr:(NSString *)sourceStr {
	if (sourceStr == nil || [sourceStr isEqualToString:@""]) {
		return sourceStr;
	}
	NSString *regEx = @"[\\n\\r]{2,}";
	NSRange range = {0, [sourceStr length]};
	NSString *targetStr = [sourceStr stringByReplacingOccurrencesOfString:regEx withString:@"" options:NSRegularExpressionSearch range:range];
	return targetStr;
}

/* 获取本机IP地址 */
+(NSString *)handleLocalIPAddressGet
{
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0)
    {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL)
        {
            if(temp_addr->ifa_addr->sa_family == AF_INET)
            {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"])
                {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    
    // Free memory
    freeifaddrs(interfaces);
    
    return address;
}

@end

