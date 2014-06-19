//
//  GlobalHelper.h
//  XMPPBaseProject
//
//  Created by hc on 14-6-18.
//  Copyright (c) 2014年 hc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GlobalHelper : NSObject
//set password
+(BOOL)setPassword:(NSString *)password forAccount:(NSString *)account;
//get password
+(NSString *)passwordForAccount:(NSString *)account;
//delete password
+(BOOL)deletePasswordForAccount:(NSString *)account;

@end
