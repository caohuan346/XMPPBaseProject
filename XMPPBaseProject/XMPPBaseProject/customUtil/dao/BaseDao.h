//
//  BaseDBManager.h
//  XMPPBaseProject
//
//  Created by hc on 14-06-21.
//  Copyright (c) 2014年 hc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NSObject+Property.h"
#import "DBModelProtocol.h"

#define CHComparisonMarkEQ @"="     //Equal
#define CHComparisonMarkGT @">"     //Greater Than
#define CHComparisonMarkGE @">="    //Greater than or equal to
#define CHComparisonMarkLT @"<"     //Less than
#define CHComparisonMarkLE @"<="    //Less than or equal to
#define CHComparisonMarkNE @"<>"    //Not Equal

#define CHComparisonMarkLike @"like"  //模糊查询
#define CHOrderMarkDesc @"desc"       //降序
#define CHOrderMarkAsc  @"asc"        //升序

@class DataBaseHandler;
@interface BaseDao : NSObject{
//    DataBaseHandler *dbCenter;
}

//singleton
SYNTHESIZE_SINGLETON_FOR_HEADER(BaseDao)

#pragma mark create table—————————————2014-07-03 11:35:35————————————————
//建表：无主键
-(BOOL)createTableWithDBModel:(id <DBModelProtocol>) model;

#pragma mark create table—————————————————————————————
//建表：无主键
-(BOOL)createTableByClass:(Class)clazz;
//创建带主键的表,约定主键名为oid
-(BOOL)createTableWithPKByClass:(Class)clazz;

#pragma mark - drop table
-(void)dropAllTable;

#pragma mark - CRUD1——————————————————————————————————————————
//如下的删除和更新的条件都是等值条件：即where子句中都是 “字段名=值” 的形式

//根据表名、条件字典删除记录(等值，删除)
- (BOOL)deleteRecord:(NSString*) tableName withConditionDic:(NSDictionary*) conditionDic;
//根据表名、条件字典、需要修改字段-值字典进行更新
- (BOOL)updateTable:(NSString*) tableName withModifyValueDic:(NSDictionary*)modifyDic withConditionDic:(NSDictionary*) conditionDic;

#pragma mark - 根据表名、条件字典进行的CRUD
#pragma mark - CRUD2——————————————————————————————————————————
/*下面的四个方法为数据库通用方法，所有表都能用使用
 其中查询、更新、删除可以是任意条件：如where子句中可能有的 >=,<,+,<>,like等，针对查询还提供排序*/
//根据表名、值字典插入记录
- (BOOL)insertTable:(NSString*) tableName withDictionary:(NSDictionary*) dictionary;
//根据表名、记录（字典型）数组插入记录
- (BOOL)insertTableInBatchMode:(NSString*) tableName withDictionaryArray:(NSArray*) dataArray;

//根据类反射和条件字典删除
-(BOOL)deleteRecord:(NSString *)tableName withConditionBeanArray:(NSArray *)conditionBeanArray;
//根据表名、条件字典查询记录(字典数组),提供各种条件过滤，如like,<>,并提供排序
-(NSArray *)queryToDictionaryArray:(NSString*) tableName withConditionBeanArray:(NSArray *)conditionBeanArray;

/**
 *	根据sql获得字典记录
 *
 *	@param	sql	<#sql description#>
 *
 *	@return	<#return value description#>
 */

-(NSArray *)query2DictionaryWithSql:(NSString *)sql;
//根据表名、值字典、条件字典更新:提供各种条件
-(BOOL)updateRecordWithTableName:(NSString *)tableName withModifiedDic:(NSDictionary *)modifiedDic withConditionBeanArray:(NSArray *)conditionBeanArray;

#pragma mark - 根据类字节码、条件字典反射进行的CRUD
#pragma mark - CRUD3——————————————————————————————————————————
/*下面的四个方法为数据库通用方法，
 其中查询、更新、删除可以是任意条件：如where子句中可能有的 >=,<,+,<>,like等，针对查询还提供排序
 注意不是所有的表都能用，必须是通过实体建立的表，保证实体表的的属性对应表的字段，名称一致，属性一致*/

//根据类class、值字典插入记录
- (BOOL)insertWithClazz:(Class)clazz withDictionary:(NSDictionary*) dictionary;
//根据类class、记录（字典型）数组插入记录
- (BOOL)insertInBatchWithClazz:(Class)clazz withDictionaryArray:(NSArray*) dataArray;
//根据类反射和条件字典删除
-(BOOL)deleteRecordWithClazz:(Class)clazz withConditionBeanArray:(NSArray *)conditionBeanArray;
//根据类class、条件字典查询记录(字典数组),提供各种条件过滤，如like,<>,并提供排序
-(NSArray *)queryToDictionaryArrayWithClazz:(Class)clazz withConditionBeanArray:(NSArray *)conditionBeanArray;
//根据类class、值字典、条件字典更新:提供各种条件
-(BOOL)updateRecordWithClazz:(Class)clazz withModifiedDic:(NSDictionary *)modifiedDic withConditionBeanArray:(NSArray *)conditionBeanArray;

#pragma mark - CRUD4——————————————————————————————————————————
//下面的所有方法为数据库通用方法，根据实体反射实现，
//注意不是所有的表都能用，必须是通过实体建立的表，保证实体表的的属性对应表的字段，名称一致，属性一致

#pragma mark - insert
//根据字典进行插入
-(void)insertDBModel:(NSObject<DBModelProtocol> *) model dict:(NSDictionary *)dict;
// 插入单个实体
-(BOOL)insertDBModel:(NSObject<DBModelProtocol> *) model;
//批量插入多个实体
-(void)insertDBModelArray:(NSArray *)modelArray;

#pragma mark - delete
//根据类反射和条件对象删除(等值删除)
-(BOOL)deleteRecordWithClazz:(Class )clazz withConditionObject:(NSObject *)conditionObj;

#pragma mark - query
//查询数据到字典数组，字典的Key对应列名（等值过滤）
-(NSArray *)query2DictionaryWithConditionObject:(NSObject<DBModelProtocol> *)conditionObj;
//根据条件对象进行条件查询(等值过滤)
-(NSArray *)query2ObjectArrayWithConditionObject:(NSObject<DBModelProtocol> *)conditionObj;
//根据条件对象进行条件查询，条件不一定是等值过滤，如like,<>,并提供排序
-(NSArray *)query2ObjectArrayWithDBModel:(NSObject<DBModelProtocol> *)model WithConditionBeanArray:(NSArray *)conditionBeanArray;

#pragma mark - update
//根据值对象和条件对象更新对应记录:等值条件
-(BOOL)updateRecordWithClazz:(Class )clazz withModifiedBean:(NSObject *)modifiedBean withConditionObject:(NSObject *)conditionObj;
//根据值对象和条件字典更新对应记录:各字段的各种条件，如大于、不等于，like...
-(BOOL)updateRecordWithClazz:(Class)clazz withModifiedBean:(NSObject *)modifiedBean withConditionBeanArray:(NSArray *)conditionBeanArray;

@end


//
//  ConditionBean.h
//  KuaiKuai
//
//  Created by caohuan on 13-11-18.
//  Copyright (c) 2013年 MONTNETS. All rights reserved.
//
@interface ConditionBean : NSObject

@property(nonatomic,copy)   NSString    *filedName;         //字段值
@property(nonatomic,strong) NSObject    *filedValue;        //字段值
@property(nonatomic,copy)   NSString    *comparisonMark;    //条件比较标记
@property(nonatomic,copy)   NSString    *orderMark;         //排序标记
@property(nonatomic,assign)  NSInteger  limitSize;          //排序标记
@property(nonatomic,assign)  NSInteger  offset;             //排序标记


//条件、排序
+(id)conditionWhereAndOrderBeanWithField:(NSString *)fieldName compare:(NSString *)comparisonMark withValue:(NSObject *)filedValue inOrder:(NSString *)orderMark;
//条件bean
+(id)conditionWhereBeanWithField:(NSString *)fieldName compare:(NSString *)comparisonMark withValue:(NSObject *)filedValue;
//排序bean
+(id)conditionOrderBeanWithField:(NSString *)fieldName inOrder:(NSString *)orderMark;
//分页查询bean
+(id)conditionLimitBeanWithSize:(NSInteger)size offset:(NSInteger)offset;

@end
