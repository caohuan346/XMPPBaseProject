//
//  User.h
//  BaseProject
//
//  Created by caohuan on 13-12-19.
//  Copyright (c) 2013年 ch. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject

@property(nonatomic,copy)NSString *userId;
@property(nonatomic,copy)NSString *subscribe;
@property(nonatomic,copy)NSString *groupId;

@end


@interface XmppUserInfo : User

@property(nonatomic,copy)NSString *userName;
@property(nonatomic,copy)NSString *firstName;
@property(nonatomic,copy)NSString *lastName;
@property(nonatomic,copy)NSString *password;
@property(nonatomic,copy)NSString *email;
@property(nonatomic,copy)NSString *gender;

@end
