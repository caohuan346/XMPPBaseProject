//
//  NSObject+Property.h
//  KuaiKuai
//
//  Created by caohuan on 13-11-18.
//  Copyright (c) 2013年 MONTNETS. All rights reserved.
//
#import <objc/runtime.h>
#import <Foundation/Foundation.h>

#define kPropertyType_NSNumber @"kPropertyType_NSNumber"
#define kPropertyType_NSDate @"kPropertyType_NSDate"
#define kPropertyType_NSData @"kPropertyType_NSData"
#define kPropertyType_NSString @"kPropertyType_NSString"
#define kPropertyType_unsigned_int @"kPropertyType_unsigned_int"
#define kPropertyType_int @"kPropertyType_int"
#define kPropertyType_long @"kPropertyType_long"
#define kPropertyType_long_long @"kPropertyType_long_long"
#define kPropertyType_unsigned_long @"kPropertyType_unsigned_long"
#define kPropertyType_bool @"kPropertyType_bool"
#define kPropertyType_double @"kPropertyType_double"

@interface NSObject (Property)
- (NSArray *)getPropertyList;
- (NSArray *)getPropertyList: (Class)clazz;
- (NSString *)tableSql:(NSString *)tablename;
- (NSString *)tableSql;

- (NSDictionary *)convertDictionary;
- (id)initWithDictionary:(NSDictionary *)dict;
- (NSString *)className;

#pragma mark - extend
//获取属性字典
- (NSDictionary *)getPropertyDictionay;
//根据类反射获取对象属性类型字典
- (NSDictionary *)getPropertyDictionayByClazz: (Class)clazz;
/**
 *	根据类反射获取对象属性类型字典
 *
 *	@param	clazz	clazz
 *
 *	@return	property info
 */
- (NSDictionary *)propertyInfoDictionaryWithClazz: (Class)clazz;

//创建建表sql
- (NSString *)createTableTableSql;
//根据类反射获取对象属性类型字典，创建对应类型字段的实体表的建表sql
- (NSString *)createTableSqlExtend:(NSString *)tablename;
@end
