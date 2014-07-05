//
//  NSObject+Property.h
//  XMPPBaseProject
//
//  Created by caohuan on 13-11-18.
//  Copyright (c) 2013年 hc. All rights reserved.
//
#import <objc/runtime.h>
#import <Foundation/Foundation.h>

#define K_SQLTYPE_Text @"text"
#define K_SQLTYPE_Date @"Date"
#define K_SQLTYPE_Int @"integer"
#define K_SQLTYPE_Double @"float"
#define K_SQLTYPE_Blob @"blob"
#define K_SQLTYPE_Null @"null"
#define K_SQLTYPE_PrimaryKey @"primary key"

@interface NSObject (Property)

/**
 *	获取对象的属性列表
 *
 *	@return	属性列表
 */
- (NSArray *)propertyArray;

- (NSString *)tableSql:(NSString *)tablename;
- (NSString *)tableSql;

- (NSDictionary *)convertDictionary;
- (id)initWithDictionary:(NSDictionary *)dict;
- (NSString *)className;

#pragma mark - extend

/**
 *	根据类反射获取对象属性类型字典
 *
 *	@return	property info
 */
- (NSDictionary *)propertyInfoDictionary;

/**
 *	建表SQL
 *
 *	@return	create table sql
 */
- (NSString *)createTableSQL:(NSString *) tableName;

@end
