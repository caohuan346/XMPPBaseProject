//
//  NSObject+Property.h
//  KuaiKuai
//
//  Created by caohuan on 13-11-18.
//  Copyright (c) 2013年 MONTNETS. All rights reserved.
//
#import <objc/runtime.h>
#import <Foundation/Foundation.h>

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
//创建建表sql
- (NSString *)createTableTableSql;
//根据类反射获取对象属性类型字典，创建对应类型字段的实体表的建表sql
- (NSString *)createTableSqlExtend:(NSString *)tablename;
@end
