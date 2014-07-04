//
//  DBModelProtocol.h
//  XMPPBaseProject
//
//  Created by hc on 14-7-3.
//  Copyright (c) 2014年 hc. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DBModelProtocol <NSObject>

@required

/**
 *	表名
 *
 *	@return	table name
 */
-(NSString *)tableName;

/**
 *	建表sql
 *
 *	@return	create table sql
 */
-(NSString *)tableCreateSQL;

/**
 *	表主键
 *
 *	@return	primaryKey
 */
-(NSString *)primaryKey;

@end
