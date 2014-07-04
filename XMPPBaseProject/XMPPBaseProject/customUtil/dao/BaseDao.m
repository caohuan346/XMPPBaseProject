//
//  BaseDBManager.m
//  KuaiKuai
//
//  Created by caohuan on 13-11-18.
//  Copyright (c) 2013年 MONTNETS. All rights reserved.
//

#import "BaseDao.h"
#import "DataBaseHandler.h"
#import "DBModelProtocol.h"

@implementation BaseDao

#pragma mark - singleton
SYNTHESIZE_SINGLETON_FOR_CLASS(BaseDao)

#pragma mark - update
-(BOOL)updateRecordWithTable:(NSString *)tablename withModifiedBean:(NSObject *)modifiedBean withConditionObj:(NSObject *)conditionObj{
    
    NSMutableString  *sql = [NSMutableString stringWithFormat:@"UPDATE %@  SET ",tablename];
    
    NSMutableString *conditionSql = [NSMutableString stringWithFormat:@" where 1=1 "];
    
    NSMutableArray *arrayValue = [NSMutableArray array];
    
    if (modifiedBean) {
        //遍历所有字段
        NSArray *columnArray = [modifiedBean propertyArray];
        
        NSInteger i = 0;
        NSInteger j = 0;
        for (NSString *field in columnArray) {
            SEL selector = NSSelectorFromString(field);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            id value = [modifiedBean performSelector:selector];
            
            id conditionVal = [conditionObj performSelector:selector];
#pragma clang diagnostic pop
            
            //组装设置值
            if (value!=nil) {
                if (i>0) {
                    [sql appendString:@","];
                }
                
                [arrayValue addObject:value];
                
                [sql appendFormat:@" %@ = ? ",field];
                
                i++;
            }
            
            //组装条件
            if (conditionVal!=nil) {
                
                [conditionSql appendFormat:@" and %@=%@ ",field,conditionVal];
                
                j++;
            }
        }
    }
    
    //追加条件
    [sql appendString:conditionSql];
    NSLog(@"条件更新sql:%@",sql);
    
    //执行
    __block BOOL executeResult;
    [[DataBaseHandler sharedInstance].fmdbQueue inDatabase:^(FMDatabase *db) {
        [db open];
        executeResult = [db executeUpdate:sql withArgumentsInArray:arrayValue];
        [db close];
    }];
    
    return executeResult;
}

-(BOOL)updateRecordWithClazz:(Class )clazz withModifiedBean:(NSObject *)modifiedBean withConditionObject:(NSObject *)conditionObj{
    NSString *tableName = [NSString  stringWithUTF8String:class_getName(clazz)];
    return  [self updateRecordWithTable:tableName withModifiedBean:modifiedBean withConditionObj:conditionObj];
}

//根据值对象和条件字典更新对应记录:各字段的各种条件，如大于、不等于，like...
-(BOOL)updateRecordWithClazz:(Class)clazz withModifiedBean:(NSObject *)modifiedBean withConditionBeanArray:(NSArray *)conditionBeanArray{
    NSString *tableName = [NSString  stringWithUTF8String:class_getName(clazz)];
    NSMutableString  *sql = [NSMutableString stringWithFormat:@"UPDATE %@  SET ",tableName];
    
    NSMutableArray *arrayValue = [NSMutableArray array];
    
    //组装设置值
    if (modifiedBean) {
        //遍历所有字段
        NSArray *columnArray = [modifiedBean propertyArray];
        
        NSInteger i = 0;
        for (NSString *field in columnArray) {
            SEL selector = NSSelectorFromString(field);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            id value = [modifiedBean performSelector:selector];
#pragma clang diagnostic pop
            
            if (value!=nil) {
                if (i>0) {
                    [sql appendString:@","];
                }
                
                [arrayValue addObject:value];
                
                [sql appendFormat:@" %@ = ? ",field];
                
                i++;
            }
        }
    }
    
    if (conditionBeanArray) {
        
        //组装条件sql：
        NSString *whereSql = [self createWhereSqlByConditionBeanArray:conditionBeanArray];
        [sql appendString:whereSql];
    }
    
    NSLog(@"条件更新sql:%@",sql);
    
    //执行
    __block BOOL executeResult;
    [[DataBaseHandler sharedInstance].fmdbQueue inDatabase:^(FMDatabase *db) {
        [db open];
        executeResult = [db executeUpdate:sql withArgumentsInArray:arrayValue];
        [db close];
    }];
    
    return executeResult;
}


#pragma mark 更科学的数据库实体CRUD ————————————2014-07-03 11:35:35————————————————

#pragma mark - drop or create table
-(BOOL)dropExistsTable:(NSString*)tableName{
    if ([self isExistsTable:tableName]) {
        NSString *sql = [NSString stringWithFormat:@"drop table %@",tableName];
        
        __block BOOL result;
        [[DataBaseHandler sharedInstance].fmdbQueue inDatabase:^(FMDatabase *db) {
            [db open];
            result = [db executeUpdate:sql];
            [db close];
        }];
        
        return result;
    }
    return YES;
}

-(void)dropAllTable
{
    [[DataBaseHandler sharedInstance].fmdbQueue inDatabase:^(FMDatabase* db){
        FMResultSet* set = [db executeQuery:@"select name from sqlite_master where type='table'"];
        NSMutableArray* dropTables = [NSMutableArray arrayWithCapacity:0];
        while ([set next]) {
            [dropTables addObject:[set stringForColumnIndex:0]];
        }
        [set close];
        for (NSString* tableName in dropTables) {
            NSString* dropTable = [NSString stringWithFormat:@"drop table %@",tableName];
            [db executeUpdate:dropTable];
        }
    }];
}

-(BOOL)isExistsTable:(NSString *)tablename{
    __block BOOL ret = NO;
    [[DataBaseHandler sharedInstance].fmdbQueue inDatabase:^(FMDatabase *db) {
        [db open];
        ret = [db tableExists:tablename];
        [db close];
    }];
    return ret;
}

-(void)executeByQueue:(NSString *)sql{
    [[DataBaseHandler sharedInstance].fmdbQueue inDatabase:^(FMDatabase *db) {
        [db open];
        [db executeUpdate:sql];
        [db close];
    }];
}


#pragma mark - private
//根据FMDB的rs获取结果集列名数组
-(NSArray *)fMSetColumnArray:(FMResultSet *)fmset{
    //字段名-index字典
    NSDictionary *dictionary = [fmset columnNameToIndexMap];
    return dictionary.allKeys;
}
/**
 *	获取tableName
 *
 *	@param	model	dbmodel
 *
 *	@return	tableName
 */
-(NSString *) tableName4DBModel:(NSObject<DBModelProtocol> *) model{
    NSString *tableName;
    if ([model respondsToSelector:@selector(tableName)]) {
        tableName = [model tableName];
        if (!tableName) {
            tableName = [NSString  stringWithUTF8String:class_getName(self.class)];
        }
    }else{
        tableName = [NSString  stringWithUTF8String:class_getName(self.class)];
    }
    return tableName;
}

-(NSString *) primaryKey4DBModel:(NSObject<DBModelProtocol> *) model{
    NSString *primaryKey = nil;
    if ([model respondsToSelector:@selector(primaryKey)]) {
        primaryKey = [model primaryKey];
    }
    return primaryKey;
}

//插入sql，占位符方式   ///////////////////////  good /////////////////////////
-(NSString *)createInsertSQL4DBModel:(NSObject<DBModelProtocol> *) model{
    
    NSString *tableName = [self tableName4DBModel:model];
    
    NSMutableString *sql = [[NSMutableString alloc] init];
    NSDictionary *propertyInfoDic = [model propertyInfoDictionary];
    NSArray *propertyNameArray = [propertyInfoDic objectForKey:@"name"];
    
    [sql appendFormat:@"insert into %@ (",tableName] ;
    
    NSInteger count = propertyNameArray.count;
    
    for (int i=0; i< count; i++) {
        if (i>0) {
            [sql appendString:@","];
        }
        [sql appendFormat:@"%@",propertyNameArray[i]];
    }
    
    [sql appendString:@") values ("];
    
    for (int i = 0; i< count; i++) {
        if (i>0) {
            [sql appendString:@","];
        }
        [sql appendFormat:@":%@",propertyNameArray[i]];
        i++;
    }
    [sql appendString:@")"];
    
    return sql;
}

#pragma mark - generate SQL
//根据条件bean创建where条件sql段
-(NSString *)createWhereSqlByConditionDic:(NSDictionary *)conditionDic{
    //组装条件
    NSMutableString *conditionSql = [NSMutableString stringWithFormat:@" where 1=1 "];
    
    NSInteger i = 0;
    
    for (NSString *filedName in conditionDic.allKeys) {
        ConditionBean *condition = [conditionDic objectForKey:filedName];
        if(condition.filedValue){
            if ([condition.comparisonMark isEqual:CHComparisonMarkLike]) {
                [conditionSql appendFormat:@"and %@ %@ '%%%@%%' ",filedName,condition.comparisonMark,condition.filedValue];
            }else{
                [conditionSql appendFormat:@"and %@%@'%@' ",filedName,condition.comparisonMark,condition.filedValue];
            }
            
            i++;
        }
    }
    
    NSLog(@"where sql:%@",conditionSql);
    
    if (i>0) {
        return conditionSql;
    }
    
    return @"";
}

//根据对象获取插入该对象的sql语句
-(NSString *)createInsertSQL4DBModel:(NSObject<DBModelProtocol> *) model valueArray:(NSMutableArray *)valueArray{
    NSMutableString *sql = [[NSMutableString alloc] init];
    NSArray *propertyArray = [model propertyArray];
    [sql appendFormat:@"insert into %@ (",[self tableName4DBModel:model]] ;
    
    NSString *primaryKey = [self primaryKey4DBModel:model];
    
    NSInteger i = 0;
    for (NSString *property in propertyArray) {
        //escape primary key
        if ([property isEqualToString:primaryKey]) {
            continue;
        }
        
        if (i>0) {
            [sql appendString:@","];
        }
        [sql appendFormat:@"%@",property];
        i++;
    }
    [sql appendString:@") values ("];
    //NSMutableArray *arrayValue = [NSMutableArray array];
    i=0;
    for (NSString *property in propertyArray) {
        //如果是主键oid，跳过
        if ([property isEqualToString:@"oid"]) {
            continue;
        }
        
        SEL selector = NSSelectorFromString(property);
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        id value = [model performSelector:selector];
#pragma clang diagnostic pop
        
        if (value==nil) {
            value = @"";
        }
        
        [valueArray addObject:value];
        
        if (i>0) {
            [sql appendString:@","];
        }
        [sql appendString:@"?"];
        i++;
    }
    [sql appendString:@")"];
    
    NSLog(@"新增sql:%@",sql);
    
    return sql;
}

/**
 *	根据条件bean创建where条件sql段
 *
 *	@param	beanArray	<#beanArray description#>
 *
 *	@return	<#return value description#>
 */
-(NSString *)createWhereSqlByConditionBeanArray:(NSArray *)beanArray{
    //组装条件
    NSMutableString *conditionSql = [NSMutableString stringWithFormat:@" where 1=1 "];
    
    NSInteger i = 0;
    
    for (ConditionBean *condition  in beanArray) {
        if(condition.filedValue){
            if ([condition.comparisonMark isEqual:CHComparisonMarkLike]) {
                [conditionSql appendFormat:@"and %@ %@ '%%%@%%' ",condition.filedName,condition.comparisonMark,condition.filedValue];
            }else{
                [conditionSql appendFormat:@"and %@%@'%@' ",condition.filedName,condition.comparisonMark,condition.filedValue];
            }
            
            i++;
        }
    }
    
    NSLog(@"where sql:%@",conditionSql);
    
    if (i>0) {
        return conditionSql;
    }
    
    return @"";
}

/**
 *	根据表名和条件字典生成查询sql
 *
 *	@param	tableName	<#tableName description#>
 *	@param	beanArray	<#beanArray description#>
 *
 *	@return	<#return value description#>
 */
-(NSString *)createQuerySqlByTableName:(NSString *)tableName conditionBeanArray:(NSArray *)beanArray{
    NSMutableString *sql = [NSMutableString stringWithFormat:@"select * from %@ ",tableName];//where 1=1
    NSMutableString *orderSql = [NSMutableString stringWithFormat:@" order by "];//排序部分sql
    if (beanArray) {
        
        //组装条件段
        NSString *whereSql = [self createWhereSqlByConditionBeanArray:beanArray];
        [sql appendString:whereSql];
        
        //组装排序段
        //select * from AppMessage where 1=1 and msgId<>'21' , order by  msgId asc  sendDate desc
        NSInteger i = 0;
        for (ConditionBean *condition in beanArray) {
            if (condition.orderMark) {
                if (i>0) {
                    [orderSql appendString:@","];
                }
                
                [orderSql appendFormat:@" %@ %@ ",condition.filedName,condition.orderMark];
                
                i++;
            }
            
            //limit part
            if (condition.limitSize > 0) {
                [orderSql appendFormat:@" limit %d ",condition.limitSize];
            }
            if (condition.offset > 0) {
                [orderSql appendFormat:@" offset %d ",condition.offset];
            }
        }
        
        if (i>0) {
            [sql appendString:orderSql];
        }
    }
    
    NSLog(@"ConditionBean方式条件查询sql:%@",sql);
    return sql;
}

#pragma mark - CRUD1 common : for every table in sqlite——————————————————————————————————————————
//如下的删除和更新的条件都是等值条件：即where子句中都是 “字段名=值” 的形式
- (BOOL)deleteRecord:(NSString*) tableName withConditionDic:(NSDictionary*) conditionDic{
    
    __block BOOL result;
    
    [[DataBaseHandler sharedInstance].fmdbQueue inDatabase:^(FMDatabase *db){
        
        NSArray *keys;
        int i, count;
        id key, value;
        NSString    *strSql = [NSString stringWithFormat:@"delete from %@   " , tableName];
        
        strSql = [strSql stringByAppendingFormat:@" where "];
        count = conditionDic.count;
        keys = [conditionDic allKeys];
        
        for (i = 0; i < count; i++){
            key = [keys objectAtIndex: i];
            value = [conditionDic objectForKey: key];
            NSString *strTemp = [NSString stringWithFormat:@" %@='%@' ",key,value];
            strSql = [strSql stringByAppendingString:strTemp];
            if (i<count -1) {
                strSql =  [strSql stringByAppendingString:@" and "];
            }
            NSLog (@"Key: %@ for value: %@", key, value);
        }
        
        NSLog (@"strSql: %@ ", strSql);
        [db open];
        result = [db executeUpdate:strSql];
        [db close];
    }];
    
    if (!result){
        NSLog(@"delete failed");
        return NO;
    }else{
        return YES;
    }
}

- (BOOL)updateTable:(NSString*) tableName withModifyValueDic:(NSDictionary*)modifyDic withConditionDic:(NSDictionary*) conditionDic
{
    __block BOOL result;
    [[DataBaseHandler sharedInstance].fmdbQueue inDatabase:^(FMDatabase *db){
        NSArray *keys;
        int i, count;
        id key, value;
        keys = [modifyDic allKeys];
        count = [keys count];
        NSString    *strSql = [NSString stringWithFormat:@"UPDATE %@  SET " , tableName];
        for (i = 0; i < count; i++)
        {
            key = [keys objectAtIndex: i];
            value = [modifyDic objectForKey: key];
            NSString *strTemp = [NSString stringWithFormat:@"%@='%@'",key,value];
            strSql = [strSql stringByAppendingString:strTemp];
            NSLog (@"Key: %@ for value: %@", key, value);
        }
        
        strSql = [strSql stringByAppendingFormat:@" where "];
        count = conditionDic.count;
        keys = [conditionDic allKeys];
        for (i = 0; i < count; i++)
        {
            key = [keys objectAtIndex: i];
            value = [conditionDic objectForKey: key];
            NSString *strTemp = [NSString stringWithFormat:@"%@='%@'",key,value];
            strSql = [strSql stringByAppendingString:strTemp];
            if (i<count -1) {
                strSql =  [strSql stringByAppendingString:@" and "];
            }
            NSLog (@"Key: %@ for value: %@", key, value);
        }
        
        NSLog (@"strSql: %@ ", strSql);
        [db open];
        result = [db executeUpdate:strSql];
        if (!result) {
            
        }
        [db close];
    }];
    if (!result) {
        
        return FALSE;
    }
   	return TRUE;
}

#pragma mark - CRUD common2 : for every table in sqlite ——————————————————————————————————————————
//下面的四个方法为数据库通用方法，所有表都能用使用
//其中查询、更新、删除可以是任意条件：如where子句中可能有的 >=,<,+,<>,like等，针对查询还提供排序
//注意使用的conditionBeanDic是 value为ConditionBean,key为条件字段的字典

- (BOOL)insertTable:(NSString*) tableName withDictionary:(NSDictionary*) dictionary{
    __block BOOL result;
    [[DataBaseHandler sharedInstance].fmdbQueue inDatabase:^(FMDatabase *db){
        
        NSMutableString *sqlStr = [NSMutableString stringWithFormat:@"insert into %@ (",tableName];
        
        NSMutableArray *argArray = [NSMutableArray array];
        
        //追加字段
        NSInteger i = 0;
        for (NSString *field in dictionary.allKeys) {
            if (i>0) {
                [sqlStr appendString:@","];
            }
            [sqlStr appendFormat:@"%@",field];
            i++;
            
            //添加到值字典
            NSObject *fieldValue = [dictionary objectForKey:field];
            [argArray addObject:fieldValue];
        }
        
        //追加占位符
        [sqlStr appendString:@") values ("];
        i = 0;
        for (NSString *field in dictionary.allKeys) {
            if (i>0) {
                [sqlStr appendString:@","];
            }
            
            //[sqlStr appendFormat:@":%@",field];
            [sqlStr appendFormat:@"?"];
            
            i++;
        }
        
        [sqlStr appendString:@");"];
        
        [db open];
        
        [db executeUpdate:sqlStr withArgumentsInArray:argArray];
        
        if (!result) {
            //TODO
        }
        
        [db close];
        
    }];
    
	if (!result) {
		return FALSE;
	}
    
	return TRUE;
}

- (BOOL)insertTableInBatchMode:(NSString*) tableName withDictionaryArray:(NSArray*) dataArray{
    
    [[DataBaseHandler sharedInstance].fmdbQueue inDatabase:^(FMDatabase *db){
        
        [db open];
        [db beginTransaction];
        
        for (NSDictionary  *dictionary in dataArray) {
            
            NSMutableString *sqlStr = [NSMutableString stringWithFormat:@"insert into %@ ( ",tableName];
            NSMutableArray *argArray = [NSMutableArray array];
            
            //追加字段
            NSInteger i = 0;
            for (NSString *field in dictionary.allKeys) {
                if (i>0) {
                    [sqlStr appendString:@","];
                }
                [sqlStr appendFormat:@"%@",field];
                i++;
                
                //添加到值字典
                NSObject *fieldValue = [dictionary objectForKey:field];
                [argArray addObject:fieldValue];
            }
            
            //追加占位符
            [sqlStr appendString:@") values ("];
            i = 0;
            for (NSString *field in dictionary.allKeys) {
                if (i>0) {
                    [sqlStr appendString:@","];
                }
                
                //[sqlStr appendFormat:@":%@",field];
                [sqlStr appendFormat:@"%@",@"?"];
                
                i++;
            }
            
            [sqlStr appendString:@");"];
            
            NSLog(@"批量插入数据：%@",sqlStr);
            
            BOOL result = [db executeUpdate:sqlStr withArgumentsInArray:argArray];
            
            if (!result) {
                NSLog(@"插入数据失败");
            }else{
                NSLog(@"插入数据成功");
            }
        }
        
        [db commit];
        [db close];
        
    }];
    
	return TRUE;
}

-(BOOL)deleteRecordWithConditionModel:(NSObject<DBModelProtocol> *) model{
    NSString *tableName = [self tableName4DBModel:model];
    NSMutableString *sql = [NSMutableString stringWithFormat:@"delete from %@ where 1=1 ",tableName];
    if (model) {
        //遍历所有字段
        NSArray *columnArray = [model propertyArray];
        for (NSString *field in columnArray) {
            SEL selector = NSSelectorFromString(field);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            id value = [model performSelector:selector];
#pragma clang diagnostic pop
            
            if (value!=nil) {
                [sql appendFormat:@" and %@ = '%@' ",field,value];
            }
        }
    }
    
    __block BOOL executeResult;
    [[DataBaseHandler sharedInstance].fmdbQueue inDatabase:^(FMDatabase *db) {
        [db open];
        executeResult = [db executeUpdate:sql];
        [db close];
    }];
    
    NSLog(@"条件删除sql:%@",sql);
    
    return executeResult;
}

-(BOOL)deleteRecord:(NSString *)tableName withConditionBeanArray:(NSArray *)conditionBeanArray{
    
    NSMutableString *sql = [NSMutableString stringWithFormat:@"delete from %@ ",tableName];
    //where
    NSString *whereSql = [self createWhereSqlByConditionBeanArray:conditionBeanArray];
    if (whereSql && whereSql.length>0) {
        [sql appendString:whereSql];
    }
    
    __block BOOL executeResult;
    [[DataBaseHandler sharedInstance].fmdbQueue inDatabase:^(FMDatabase *db) {
        [db open];
        executeResult = [db executeUpdate:sql];
        [db close];
    }];
    
    NSLog(@"条件删除sql:%@",sql);
    
    return executeResult;
}

-(NSArray *)queryToDictionaryArray:(NSString*) tableName withConditionBeanArray:(NSArray *)conditionBeanArray{
    
    NSString *sql = [self createQuerySqlByTableName:tableName conditionBeanArray:conditionBeanArray];
    
    return [self query2DictionaryWithSql:sql];
}

-(NSArray *)query2DictionaryWithSql:(NSString *)sql{
    NSLog(@"自定义queryToDictionaryWithSql:%@",sql);
    
    __block NSMutableArray *array= [NSMutableArray array];
    
    [[DataBaseHandler sharedInstance].fmdbQueue inDatabase:^(FMDatabase *db){
        [db open];
        
        FMResultSet *rs = [db executeQuery:sql];
        
        if (!rs) {
            [db close];
            return ;
        }
        
        NSArray *columnArray = [self fMSetColumnArray:rs];
        
        NSString *columnName = nil;
        
        while ([rs next]) {
            NSMutableDictionary *syncData = [[NSMutableDictionary alloc] init];
            
            for(int i =0;i<columnArray.count;i++)
            {
                columnName = [columnArray objectAtIndex:i];
                NSString *columnValue = [rs stringForColumn: columnName];
                
                if (columnValue==nil) {
                    columnValue=@"";
                }
                [syncData setObject:columnValue forKey:columnName];
            }
            
            [array addObject:syncData];
        }
        
        [db close];
    }];
    
    if ([array count]==0) {
        return nil;
    }
    return array;
}


-(BOOL)updateRecord:(NSString *)tableName withModifiedDic:(NSDictionary *)modifiedDic withConditionBeanArray:(NSArray *)conditionBeanArray{
    
    NSMutableString *sql = [NSMutableString stringWithFormat:@"UPDATE %@  SET ",tableName];
    
    //组装设置值
    NSMutableArray *arrayValue = [NSMutableArray array];
    if (modifiedDic) {
        //遍历所有字段
        NSInteger i = 0;
        for (NSString *key in modifiedDic.allKeys) {
            id value = [modifiedDic objectForKey:key];
            if (value!=nil) {
                if (i>0) {
                    [sql appendString:@","];
                }
                
                [arrayValue addObject:value];
                
                [sql appendFormat:@" %@ = ? ",key];
                
                i++;
            }
        }
    }
    
    //条件语句
    NSString *whereSql = [self createWhereSqlByConditionBeanArray:conditionBeanArray];
    if (whereSql) {
        [sql appendString:whereSql];
    }
    
    NSLog(@"条件更新sql:%@",sql);
    
    //执行
    __block BOOL executeResult;
    [[DataBaseHandler sharedInstance].fmdbQueue inDatabase:^(FMDatabase *db) {
        [db open];
        executeResult = [db executeUpdate:sql withArgumentsInArray:arrayValue];
        [db close];
    }];
    
    return executeResult;
}


#pragma mark- static method

const static NSString* normalTypesString = @"floatdoublelong";
const static NSString* intTypesString = @"intcharshort";
const static NSString* dateTypeString = @"NSDate";
const static NSString* blobTypeString = @"NSDataUIImage";

- (NSString *)sqlliteTypeWithPropertyType:(NSString *)type
{
    if([intTypesString rangeOfString:type].location != NSNotFound){
        return K_SQLTYPE_Int;
    }
    if ([normalTypesString rangeOfString:type].location != NSNotFound) {
        return K_SQLTYPE_Double;
    }
    if ([blobTypeString rangeOfString:type].location != NSNotFound) {
        return K_SQLTYPE_Blob;
    }
    if ([dateTypeString rangeOfString:type].location != NSNotFound) {
        return K_SQLTYPE_Date;
    }
    return K_SQLTYPE_Text;
}

- (NSString *)createTableSQLWithDBModel:(NSObject<DBModelProtocol> *) model {
    
    NSString *tableName;
    
    if ([model respondsToSelector:@selector(tableName)]) {
        tableName = [model tableName];
        if (!tableName) {
            tableName = [NSString stringWithUTF8String:class_getName([model class])];
        }
    }else {
        tableName = [NSString stringWithUTF8String:class_getName([model class])];
    }
    
    NSMutableString *sql = [[NSMutableString alloc] init];
    
    if (!tableName) {
        tableName = [NSString  stringWithUTF8String:class_getName(self.class)];
    }
    
    [sql appendFormat:@"CREATE TABLE IF NOT EXISTS %@ (",tableName] ;
    
    NSDictionary *propertyInfoDic = [model propertyInfoDictionary];
    NSMutableArray* propertyNameArray = [propertyInfoDic objectForKey:@"name"];
    NSMutableArray* propertyTypeArray = [propertyInfoDic objectForKey:@"type"];
    
    //primaryKey
    NSString *primaryKey;
    if ([model respondsToSelector:@selector(primaryKey)]) {
        primaryKey = [model primaryKey];
        if (![propertyNameArray containsObject:primaryKey]) {
            primaryKey = nil;
        }
    }else{
        primaryKey = nil;
    }
    
    NSInteger count = propertyNameArray.count;
    for (int i=0; i < count; i++) {
        if (i>0) {
            [sql appendString:@","];
        }
        
        NSString *propertyName = propertyNameArray[i];
        NSString *propertyType = propertyTypeArray[i];
        
        [sql appendFormat:@"%@ %@",propertyName, [self sqlliteTypeWithPropertyType:propertyType]];
        
        if (primaryKey) {
            [sql appendString:@"PRIMARY KEY ASC AUTOINCREMENT DEFAULT 1 "];
        }
    }
    [sql appendString:@")"];
    
    NSLog(@"建表sql:%@",sql);
    
    return sql;
}

//建表：无主键
-(BOOL)createTableWithDBModel:(NSObject<DBModelProtocol> *) model {
    
    NSString *sql = [self createTableSQLWithDBModel:model];
    
    __block BOOL result;
    
    [[DataBaseHandler sharedInstance].fmdbQueue inDatabase:^(FMDatabase *db) {
        [db open];
        result = [db executeUpdate:sql];
        [db close];
    }];
    
    if (result) {
        NSLog(@"创建表 %@ 成功",[model tableName]);
    }
    
    return result;
    
    return NO;
}

#pragma mark - CRUD3——————————————————————————————————————————
//下面的所有方法为数据库通用方法，根据实体反射实现，
//注意不是所有的表都能用，必须是通过实体建立的表，保证实体表的的属性对应表的字段，名称一致，属性一致
#pragma mark - insert
-(void)insertDBModel:(NSObject<DBModelProtocol> *) model dict:(NSDictionary *)dict{
    
    NSString *sql = [self createInsertSQL4DBModel:model];
    
    if (sql && sql.length>0) {
        [[DataBaseHandler sharedInstance].fmdbQueue inDatabase:^(FMDatabase *db) {
            [db open];
            [db executeUpdate:sql withParameterDictionary:dict];
            [db close];
        }];
    }
}

-(BOOL)insertDBModel:(NSObject<DBModelProtocol> *) model{
    
    NSMutableArray *valueArray = [NSMutableArray array];
    NSString *sql = [self createInsertSQL4DBModel:model ];
    
    __block BOOL executeResult;
    [[DataBaseHandler sharedInstance].fmdbQueue inDatabase:^(FMDatabase *db) {
        [db open];
        executeResult = [db executeUpdate:sql withArgumentsInArray:valueArray];
        [db close];
    }];
    return executeResult;
}

-(void)insertDBModelArray:(NSArray *)modelArray{
    [[DataBaseHandler sharedInstance].fmdbQueue inDatabase:^(FMDatabase *db){
        [db open];
        [db beginTransaction];
        
        for (NSObject<DBModelProtocol> *model in modelArray) {
            NSMutableArray *valueArray = [[NSMutableArray alloc] init];
            NSString *insertSql = [self createInsertSQL4DBModel:model valueArray:valueArray];
            BOOL insertResult = [db executeUpdate:insertSql withArgumentsInArray:valueArray];
            if (!insertResult) {
                NSLog(@"插入数据失败");
            }
        }
        
        [db commit];
        [db close];
    }];
}

#pragma mark - query: for object which is implement DBModelProtocol

-(NSArray *)query2ObjectArrayWithDBModel:(NSObject<DBModelProtocol> *)model WithConditionBeanArray:(NSArray *)conditionBeanArray{
    
    NSString *tableName = [self tableName4DBModel:model];
    
    NSString *sql = [self createQuerySqlByTableName:tableName conditionBeanArray:conditionBeanArray];
    
    return [self query2ObjectArray:model sql:sql];
    
}

#pragma mark - query 1
-(NSArray *)query2ObjectArray:(NSObject<DBModelProtocol> *)conditionObj sql:(NSString *)sql{
    __block NSMutableArray *array= [NSMutableArray array];
    [[DataBaseHandler sharedInstance].fmdbQueue inDatabase:^(FMDatabase *db){
        [db open];
        
        FMResultSet *rs = [db executeQuery:sql];
        
        if (!rs) {
            [db close];
            return ;
        }
        
        NSDictionary *columnDic = [conditionObj propertyInfoDictionary];
        
        while ([rs next]) {
            NSObject *obj = [[conditionObj.class alloc] init];
            
            if (obj==nil) {
                continue;
            }
            
            for(NSString *columnName in columnDic.allKeys)
            {
                NSString *columnType = [columnDic objectForKey:columnName];
                
                NSObject *columnValue;
                if ([@"NSDate" isEqualToString:columnType]) {
                    columnValue = [rs dateForColumn: columnName];
                }else if ([@"NSNumber" isEqualToString:columnType]) {
                    columnValue = [NSNumber numberWithInt:[rs intForColumn: columnName]];
                }else if ([@"NSString" isEqualToString:columnType]) {
                    columnValue = [rs stringForColumn: columnName];
                }else{
                    columnValue = @"";
                }
                
                SEL selector = NSSelectorFromString(columnName);
                
                if ([obj respondsToSelector:selector]) {
                    [obj setValue:columnValue forKeyPath:columnName ];
                }
            }
            [array addObject:obj];
        }
        [db close];
	}];
    
    if ([array count]==0) {
        return nil;
    }
    
    return array;
}

-(NSArray *)query2ObjectArrayWithConditionObject:(NSObject<DBModelProtocol> *)conditionObj{
    NSString *tableName = [self tableName4DBModel:conditionObj];
    NSMutableString *sql = [NSMutableString stringWithFormat:@"select * from %@ where 1=1 ",tableName];
    if (conditionObj) {
        //遍历所有字段
        NSArray *columnArray = [conditionObj propertyArray];
        for (NSString *field in columnArray) {
            SEL selector = NSSelectorFromString(field);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            id value = [conditionObj performSelector:selector];
#pragma clang diagnostic pop
            
            if (value!=nil) {
                [sql appendFormat:@" and %@ = '%@' ",field,value];
            }
        }
    }
    NSLog(@"条件查询sql:%@",sql);
    
    return [self query2ObjectArray:conditionObj sql:sql];
}

-(NSArray *)query2DictionaryArray:(NSString *)tablename sql:(NSString *)sql{
    
    __block NSMutableArray *array= [NSMutableArray array];
    
    NSLog(@"%@",[DataBaseHandler sharedInstance]);
    NSLog(@"%@",[DataBaseHandler sharedInstance].fmdbQueue);
    [[DataBaseHandler sharedInstance].fmdbQueue inDatabase:^(FMDatabase *db){
        [db open];
        
        FMResultSet *rs = [db executeQuery:sql];
        
        if (!rs) {
            [db close];
            return ;
        }
        
        NSObject *obj = [[[NSClassFromString(tablename) class] alloc] init];
        
        NSDictionary *columnDic = [obj propertyInfoDictionary];
        
        while ([rs next]) {
            NSMutableDictionary *syncData = [[NSMutableDictionary alloc] init];
            
            for(NSString *columnName in columnDic.allKeys)
            {
                NSString *columnType = [columnDic objectForKey:columnName];
                
                NSObject *columnValue;
                if ([@"NSDate" isEqualToString:columnType]) {
                    columnValue = [rs dateForColumn: columnName];
                }else if ([@"NSNumber" isEqualToString:columnType]) {
                    columnValue = [NSNumber numberWithInt:[rs intForColumn: columnName]];
                }else if ([@"NSString" isEqualToString:columnType]) {
                    columnValue = [rs stringForColumn: columnName];
                }else{
                    columnValue = @"";
                }
                [syncData setObject:columnValue forKey:columnName];
            }
            
            [array addObject:syncData];
        }
        
        [db close];
    }];
    
    if ([array count]==0) {
        return nil;
    }
    return array;
}

-(NSArray *)query2DictionaryWithConditionObject:(NSObject<DBModelProtocol> *)conditionObj{
    NSString *tableName = [self tableName4DBModel:conditionObj];
    NSMutableString *sql = [NSMutableString stringWithFormat:@"select * from %@ where 1=1 ",tableName];
    if (conditionObj) {
        //loop all properties
        NSArray *columnArray = [conditionObj propertyArray];
        for (NSString *field in columnArray) {
            SEL selector = NSSelectorFromString(field);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            id value = [conditionObj performSelector:selector];
#pragma clang diagnostic pop
            if (value!=nil) {
                [sql appendFormat:@" and %@ = '%@' ",field,value];
            }
        }
    }
    NSLog(@"条件查询sql:%@",sql);
    
    return [self query2DictionaryArray:tableName sql:sql];
}

@end

#pragma mark ——————————————@implementation ConditionBean——————————————

//
//  ConditionBean.m
//  XmppBaseProject
//
//  Created by ch on 13-11-18.
//  Copyright (c) 2013年 ch. All rights reserved.
//
@implementation ConditionBean

//条件、排序
+(id)conditionWhereAndOrderBeanWithField:(NSString *)fieldName compare:(NSString *)comparisonMark withValue:(NSObject *)filedValue inOrder:(NSString *)orderMark{
    ConditionBean *bean = [[ConditionBean alloc]init];
    bean.filedName =bean.filedName;
    bean.filedValue = filedValue;
    bean.comparisonMark = comparisonMark;
    bean.orderMark = orderMark;
    return bean;
}

//条件bean
+(id)conditionWhereBeanWithField:(NSString *)fieldName compare:(NSString *)comparisonMark withValue:(NSObject *)filedValue{
    ConditionBean *bean = [[ConditionBean alloc]init];
    bean.filedName =fieldName;
    bean.filedValue = filedValue;
    bean.comparisonMark = comparisonMark;
    return bean;
}

//排序bean
+(id)conditionOrderBeanWithField:(NSString *)fieldName inOrder:(NSString *)orderMark{
    ConditionBean *bean = [[ConditionBean alloc]init];
    bean.filedName = fieldName;
    bean.orderMark = orderMark;
    return bean;
}

//分页查询 bean
+(id)conditionLimitBeanWithSize:(NSInteger)size offset:(NSInteger)offset {
    ConditionBean *bean = [[ConditionBean alloc]init];
    bean.limitSize = size;
    bean.offset = offset;
    return bean;
}

@end
