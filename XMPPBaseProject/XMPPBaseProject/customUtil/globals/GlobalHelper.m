//
//  GlobalHelper.m
//  XMPPBaseProject
//
//  Created by hc on 14-6-18.
//  Copyright (c) 2014年 hc. All rights reserved.
//

#import "GlobalHelper.h"
#import "SSKeychain.h"
#import "User.h"

static NSString *kSSToolkitTestsServiceName = @"SSToolkitTestService";
static NSString *kSSToolkitTestsAccountName = @"SSToolkitTestAccount";
static NSString *kSSToolkitTestsPassword = @"SSToolkitTestPassword";

static NSString *kTDIMServiceName = @"kTDIMServiceName";

@implementation GlobalHelper

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

#pragma mark - login password persist etc.
+(BOOL)setPassword:(NSString *)password forAccount:(NSString *)account {
    return  [SSKeychain setPassword:password forService:kTDIMServiceName account:account];
}

+(NSString *)passwordForAccount:(NSString *)account {
    return  [SSKeychain passwordForService:kTDIMServiceName account:account];
}

+(BOOL)deletePasswordForAccount:(NSString *)account {
    return  [SSKeychain deletePasswordForService:kTDIMServiceName account:account];
}

+(AppUser *)lastLoginPerson{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *userId = [defaults stringForKey:kUserID];
    AppUser *user = [[AppUser alloc] init];
    user.userId = userId;
    user.password = [GlobalHelper passwordForAccount:userId];;
    return user;
}


#pragma mark - gloab setting

@end
