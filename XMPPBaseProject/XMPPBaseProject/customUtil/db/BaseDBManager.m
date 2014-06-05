//
//  BaseDBManager.m
//  KuaiKuai
//
//  Created by caohuan on 13-11-18.
//  Copyright (c) 2013年 MONTNETS. All rights reserved.
//

#import "BaseDBManager.h"
#import "DBCenter.h"

@implementation BaseDBManager

#pragma mark - life circle
-(id)initWithDBCenter:(DBCenter *)param_dbCenter
{
    if ((self = [super init])) {
		
        if (dbCenter) {
            dbCenter = nil;
        }
        dbCenter = param_dbCenter;
	}
	return self;
}


#pragma mark - private
//根据FMDB的rs获取结果集列名数组
-(NSArray *)fMSetColumnArray:(FMResultSet *)fmset{
    //字段名-index字典
    NSDictionary *dictionary = [fmset columnNameToIndexMap];
    return dictionary.allKeys;
    
    /*
     FMStatement *statement = fmset.statement;
     NSInteger columnCount = sqlite3_column_count(statement.statement);
     NSMutableArray *columnArray = [NSMutableArray array];
     
     for (NSInteger columnIdx = 0; columnIdx < columnCount; columnIdx++) {
     NSString *columnName = [NSString stringWithUTF8String:sqlite3_column_name(statement.statement, columnIdx)];
     [columnArray addObject:columnName];
     }
     return columnArray;
     */
}

//插入sql，:方式（Deprecated）
-(NSString *)createInsertSqlByDictionary:(NSDictionary *)dict tablename:(NSString *)table{
    
    NSMutableString *sql = [[NSMutableString alloc] init];
    [sql appendFormat:@"insert into %@ (",table] ;
    NSInteger i = 0;
    for (NSString *key in dict.allKeys) {
        if (i>0) {
            [sql appendString:@","];
        }
        [sql appendFormat:@"%@",key];
        i++;
    }
    [sql appendString:@") values ("];
    i = 0;
    for (NSString *key in dict.allKeys) {
        if (i>0) {
            [sql appendString:@","];
        }
        [sql appendFormat:@":%@",key];
        i++;
    }
    [sql appendString:@")"];
    return sql;
}

//插入sql，占位符方式
-(NSString *)createInsertSqlByClass:(Class)clazz{
    id obj = [[clazz alloc] init];
    if (obj==nil) {
        return nil;
    }
    NSString *classname = [NSString  stringWithUTF8String:class_getName(clazz)];
    
    NSMutableString *sql = [[NSMutableString alloc] init];
    NSArray *array = [obj getPropertyList];
    [sql appendFormat:@"insert into %@ (",classname] ;
    NSInteger i = 0;
    for (NSString *key in array) {
        if (i>0) {
            [sql appendString:@","];
        }
        [sql appendFormat:@"%@",key];
        i++;
    }
    [sql appendString:@") values ("];
    i = 0;
    for (NSString *key in array) {
        if (i>0) {
            [sql appendString:@","];
        }
        [sql appendFormat:@":%@",key];
        i++;
    }
    [sql appendString:@")"];
    return sql;
}

//根据表名和条件字典生成查询sql
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
        }
        
        if (i>0) {
            [sql appendString:orderSql];
        }
    }
    
    NSLog(@"ConditionBean方式条件查询sql:%@",sql);
    return sql;
}


//根据对象获取插入该对象的sql语句
-(NSString *)getInsertSqlByObject:(id)object arrayValue:(NSMutableArray *)arrayValue{
    NSMutableString *sql = [[NSMutableString alloc] init];
    NSArray *array = [object getPropertyList];
    [sql appendFormat:@"insert into %@ (",[object className]] ;
    NSInteger i = 0;
    for (NSString *key in array) {
        //如果是主键oid，跳过
        if ([key isEqualToString:@"oid"]) {
            continue;
        }
        
        if (i>0) {
            [sql appendString:@","];
        }
        [sql appendFormat:@"%@",key];
        i++;
    }
    [sql appendString:@") values ("];
    //NSMutableArray *arrayValue = [NSMutableArray array];
    i=0;
    for (NSString *key in array) {
        //如果是主键oid，跳过
        if ([key isEqualToString:@"oid"]) {
            continue;
        }
        
        SEL selector = NSSelectorFromString(key);
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        id value = [object performSelector:selector];
#pragma clang diagnostic pop
        
        if (value==nil) {
            value = @"";
        }
        [arrayValue addObject:value];
        if (i>0) {
            [sql appendString:@","];
        }
        [sql appendString:@"?"];
        i++;
    }
    [sql appendString:@")"];
    //[_db executeUpdate:sql withArgumentsInArray:arrayValue];
    NSLog(@"新增sql:%@",sql);
    
    return sql;
}

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

//根据条件bean创建where条件sql段
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

#pragma mark - drop or create table
-(BOOL)DropExistsTable:(NSString*)tableName{
    if ([self isExistsTable:tableName]) {
        NSString *sql = [NSString stringWithFormat:@"drop table %@",tableName];
        
        __block BOOL result;
        
        [dbCenter.fmdbQueue inDatabase:^(FMDatabase *db) {
            [db open];
            result = [db executeUpdate:sql];
            [db close];
        }];
        
        return result;
    }
    return YES;
}

-(BOOL)createTableWithPKByClass:(Class)clazz{
    NSString *classname = [NSString  stringWithUTF8String:class_getName(clazz)];
    if ([self isExistsTable:classname]) {
        return YES;
    }
    id obj = [[NSClassFromString(classname) alloc] init];
    if (obj==nil) {
        return NO;
    }
    NSMutableString *sql = [[NSMutableString alloc] init];
    NSDictionary *fieldDic = [obj getPropertyDictionay];
    [sql appendFormat:@"create table %@ (",classname] ;
    NSInteger i = 0;
    for (NSString *field in fieldDic.allKeys) {
        //拼接字段
        if (i>0) {
            [sql appendString:@","];
        }
        
        [sql appendFormat:@"%@ ",field];
        
        //设置类型
        NSString *fieldType = [fieldDic objectForKey:field];
        NSString *columnType;
        if ([@"NSDate" isEqualToString:fieldType]) {
            columnType = @"date ";
        }else if ([@"NSNumber" isEqualToString:fieldType]) {
            columnType = @"integer ";
        }else if ([@"NSString" isEqualToString:fieldType]) {
            columnType = @"text ";
        }else{
            columnType = @"text ";
        }
        
        [sql appendString:columnType];
        
        //设置主键
        if ([@"oid" isEqualToString:field]) {
            [sql appendString:@"PRIMARY KEY ASC AUTOINCREMENT DEFAULT 1 "];
        }
        
        i++;
    }
    [sql appendString:@")"];
    
    __block BOOL result;
    [dbCenter.fmdbQueue inDatabase:^(FMDatabase *db) {
        [db open];
        result = [db executeUpdate:sql];
        [db close];
    }];
    
    if (result) {
        NSLog(@"创建表 %@ 成功",classname);
    }
    
    return result;
}

-(BOOL)createTableByClass:(Class)clazz{
    NSString *classname = [NSString  stringWithUTF8String:class_getName(clazz)];
    return [self createTableByClassName:classname];
}

-(BOOL)createTableByClassName:(NSString *)classname{
    if ([self isExistsTable:classname]) {
        return YES;
    }
    id obj = [[NSClassFromString(classname) alloc] init];
    if (obj==nil) {
        return NO;
    }
    
    //NSString *sql = [obj tableSql];//表属性都是NSString
    NSString *sql = [obj createTableTableSql];//根据各属性类型创建
    
    __block BOOL result;
    [dbCenter.fmdbQueue inDatabase:^(FMDatabase *db) {
        [db open];
        result = [db executeUpdate:sql];
        [db close];
    }];
    return result;
}

-(BOOL)isExistsTable:(NSString *)tablename{
    //FMResultSet *rs = [_db executeQuery:@"select count(*) as 'count' from sqlite_master where type ='table' and name = ?", tablename];
    
    /*
    __block FMResultSet *rs;
    
    [dbCenter.fmdbQueue inDatabase:^(FMDatabase *db) {
        [db open];
        rs = [db executeQuery:@"select count(*) as 'count' from sqlite_master where type ='table' and name = ?", tablename];
        [db close];
    }];
    
    BOOL ret = NO;
    while ([rs next])
    {
        // just print out what we've got in a number of formats.
        NSInteger count = [rs intForColumn:@"count"];
        //  NSLog(@"isTableOK %d", count);
        
        if (0 == count)
        {
            ret = NO;
        }
        else
        {
            ret = YES;
        }
    }
    return ret;
    */
    
    __block BOOL ret = NO;
    [dbCenter.fmdbQueue inDatabase:^(FMDatabase *db) {
        [db open];
        ret = [db tableExists:tablename];
        [db close];
    }];
    return ret;
}

-(void)executeByQueue:(NSString *)sql{
    [dbCenter.fmdbQueue inDatabase:^(FMDatabase *db) {
        [db open];
        [db executeUpdate:sql];
        [db close];
    }];
}

#pragma mark - CRUD1——————————————————————————————————————————
//如下的删除和更新的条件都是等值条件：即where子句中都是 “字段名=值” 的形式

- (BOOL)deleteWithTable:(NSString*) tableName withConditionDic:(NSDictionary*) conditionDic{
    
    __block BOOL result;
    
    [dbCenter.fmdbQueue inDatabase:^(FMDatabase *db){
        
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

- (BOOL)updateWithTable:(NSString*) tableName withModifyValueDic:(NSDictionary*)modifyDic withConditionDic:(NSDictionary*) conditionDic
{
    __block BOOL result;
    [dbCenter.fmdbQueue inDatabase:^(FMDatabase *db){
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

#pragma mark - CRUD2  common——————————————————————————————————————————
//下面的四个方法为数据库通用方法，所有表都能用使用
//其中查询、更新、删除可以是任意条件：如where子句中可能有的 >=,<,+,<>,like等，针对查询还提供排序
//注意使用的conditionBeanDic是 value为ConditionBean,key为条件字段的字典

- (BOOL)insertWithTable:(NSString*) tableName withDictionary:(NSDictionary*) dictionary{
    __block BOOL result;
    [dbCenter.fmdbQueue inDatabase:^(FMDatabase *db){
        
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
            [sqlStr appendFormat:@"%@",@"?"];
            
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

- (BOOL)insertInBatchWithTable:(NSString*) tableName withDictionaryArray:(NSArray*) dataArray{
    
    [dbCenter.fmdbQueue inDatabase:^(FMDatabase *db){
        
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

-(BOOL)deleteRecordWithTableName:(NSString *)tableName withConditionBeanArray:(NSArray *)conditionBeanArray{
    
    NSMutableString *sql = [NSMutableString stringWithFormat:@"delete from %@ ",tableName];
    //where
    NSString *whereSql = [self createWhereSqlByConditionBeanArray:conditionBeanArray];
    if (whereSql && whereSql.length>0) {
        [sql appendString:whereSql];
    }
    
    __block BOOL executeResult;
    [dbCenter.fmdbQueue inDatabase:^(FMDatabase *db) {
        [db open];
        executeResult = [db executeUpdate:sql];
        [db close];
    }];
    
    NSLog(@"条件删除sql:%@",sql);
    
    return executeResult;
}

-(NSArray *)queryToDictionaryArrayWithTable:(NSString*) tableName withConditionBeanArray:(NSArray *)conditionBeanArray{
    
    NSString *sql = [self createQuerySqlByTableName:tableName conditionBeanArray:conditionBeanArray];
    
    //return [self queryDbToDictionaryArray:tableName sql:sql];
    
    return [self queryToDictionaryWithSql:sql];
}


-(BOOL)updateRecordWithTableName:(NSString *)tableName withModifiedDic:(NSDictionary *)modifiedDic withConditionBeanArray:(NSArray *)conditionBeanArray{
    
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
    [dbCenter.fmdbQueue inDatabase:^(FMDatabase *db) {
        [db open];
        executeResult = [db executeUpdate:sql withArgumentsInArray:arrayValue];
        [db close];
    }];
    
    return executeResult;
}

#pragma mark - CRUD3  clazz——————————————————————————————————————————
/*下面的四个方法为数据库通用方法，所有表都能用使用
 其中查询、更新、删除可以是任意条件：如where子句中可能有的 >=,<,+,<>,like等，针对查询还提供排序*/
//根据类class、值字典插入记录
- (BOOL)insertWithClazz:(Class)clazz withDictionary:(NSDictionary*) dictionary{
    NSString *tableName = [NSString  stringWithUTF8String:class_getName(clazz)];
    return [self insertWithTable:tableName withDictionary:dictionary];
}
//根据类class、记录（字典型）数组插入记录
- (BOOL)insertInBatchWithClazz:(Class)clazz withDictionaryArray:(NSArray*) dataArray{
    NSString *tableName = [NSString  stringWithUTF8String:class_getName(clazz)];
    return [self insertInBatchWithTable:tableName withDictionaryArray:dataArray];
}
//根据类反射和条件字典删除
-(BOOL)deleteRecordWithClazz:(Class)clazz withConditionBeanArray:(NSArray *)conditionBeanArray{
    NSString *tableName = [NSString  stringWithUTF8String:class_getName(clazz)];
    return [self deleteRecordWithTableName:tableName withConditionBeanArray:conditionBeanArray];
}
//根据类class、条件字典查询记录(字典数组),提供各种条件过滤，如like,<>,并提供排序
-(NSArray *)queryToDictionaryArrayWithClazz:(Class)clazz withConditionBeanArray:(NSArray *)conditionBeanArray{
    NSString *tableName = [NSString  stringWithUTF8String:class_getName(clazz)];
    return [self queryToDictionaryArrayWithTable:tableName withConditionBeanArray:conditionBeanArray];
}
//根据类class、值字典、条件字典更新:提供各种条件
-(BOOL)updateRecordWithClazz:(Class)clazz withModifiedDic:(NSDictionary *)modifiedDic withConditionBeanArray:(NSArray *)conditionBeanArray{
    NSString *tableName = [NSString  stringWithUTF8String:class_getName(clazz)];
    return [self updateRecordWithTableName:tableName withModifiedDic:modifiedDic withConditionBeanArray:conditionBeanArray];
}

#pragma mark - CRUD3——————————————————————————————————————————
//下面的所有方法为数据库通用方法，根据实体反射实现，
//注意不是所有的表都能用，必须是通过实体建立的表，保证实体表的的属性对应表的字段，名称一致，属性一致

#pragma mark - insert
-(void)insert:(Class)clazz dict:(NSDictionary *)dict{
    NSString *sql = [self createInsertSqlByClass:clazz ];
    if (sql && sql.length>0) {
        [dbCenter.fmdbQueue inDatabase:^(FMDatabase *db) {
            [db open];
            [db executeUpdate:sql withParameterDictionary:dict];
            [db close];
        }];
    }
}

-(BOOL)insertObject:(id)object{
    NSString *tablename = [object className];
    NSMutableString *sql = [[NSMutableString alloc] init];
    NSArray *array = [object getPropertyList];
    [sql appendFormat:@"insert into %@ (",tablename] ;
    NSInteger i = 0;
    for (NSString *key in array) {
        //如果是主键oid，跳过
        if ([key isEqualToString:@"oid"]) {
            continue;
        }
        if (i>0) {
            [sql appendString:@","];
        }
        [sql appendFormat:@"%@",key];
        i++;
    }
    [sql appendString:@") values ("];
    NSMutableArray *arrayValue = [NSMutableArray array];
    i=0;
    for (NSString *key in array) {
        //如果是主键oid，跳过
        if ([key isEqualToString:@"oid"]) {
            continue;
        }
        SEL selector = NSSelectorFromString(key);
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        id value = [object performSelector:selector];
#pragma clang diagnostic pop
        
        if (value==nil) {
            value = @"";
        }
        [arrayValue addObject:value];
        if (i>0) {
            [sql appendString:@","];
        }
        [sql appendString:@"?"];
        i++;
    }
    [sql appendString:@")"];
    //[_db executeUpdate:sql withArgumentsInArray:arrayValue];
    NSLog(@"新增sql:%@",sql);
    
    __block BOOL executeResult;
    [dbCenter.fmdbQueue inDatabase:^(FMDatabase *db) {
        [db open];
        executeResult = [db executeUpdate:sql withArgumentsInArray:arrayValue];
        [db close];
    }];
    return executeResult;
}

-(void)insertObjectArray:(NSArray *)objectList{
    [dbCenter.fmdbQueue inDatabase:^(FMDatabase *db){
        [db open];
        [db beginTransaction];
        
        for (NSObject *obj in objectList) {
            NSMutableArray *array = [[NSMutableArray alloc] init];
            NSString *insertSql = [self getInsertSqlByObject:obj arrayValue:array];
            BOOL insertResult = [db executeUpdate:insertSql withArgumentsInArray:array];
            if (!insertResult) {
                NSLog(@"插入数据失败");
            }
        }
        
        [db commit];
        [db close];
    }];
}


#pragma mark - delete

-(BOOL)deleteRecordWithTable:(NSString *)tablename withConditionBean:(NSObject *)conditionBean{
    NSMutableString *sql = [NSMutableString stringWithFormat:@"delete from %@ where 1=1 ",tablename];
    if (conditionBean) {
        //遍历所有字段
        NSArray *columnArray = [conditionBean getPropertyList];
        for (NSString *field in columnArray) {
            SEL selector = NSSelectorFromString(field);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            id value = [conditionBean performSelector:selector];
#pragma clang diagnostic pop
            
            if (value!=nil) {
                [sql appendFormat:@" and %@ = '%@' ",field,value];
            }
        }
    }
    
    __block BOOL executeResult;
    [dbCenter.fmdbQueue inDatabase:^(FMDatabase *db) {
        [db open];
        executeResult = [db executeUpdate:sql];
        [db close];
    }];
    
    NSLog(@"条件删除sql:%@",sql);
    
    return executeResult;
}

-(BOOL)deleteRecordWithClazz:(Class )clazz withConditionObject:(NSObject *)conditionObj{
    NSString *tableName = [NSString  stringWithUTF8String:class_getName(clazz)];
    return [self deleteRecordWithTable:tableName withConditionBean:conditionObj];
}

#pragma mark - query 1
-(NSArray *)queryDbToObjectArray:(Class )clazz sql:(NSString *)sql{
    __block NSMutableArray *array= [NSMutableArray array];
    [dbCenter.fmdbQueue inDatabase:^(FMDatabase *db){
        [db open];
        
        FMResultSet *rs = [db executeQuery:sql];
        
        if (!rs) {
            [db close];
            return ;
        }
        
        //NSArray *columnArray = [self fMSetColumnArray:rs];
        NSObject *obj = [[clazz alloc] init];
        //NSArray *columnArray = [obj getPropertyList];
        NSDictionary *columnDic = [obj getPropertyDictionay];
        
        //NSString *columnName = nil;
        while ([rs next]) {
            NSObject *obj = [[clazz alloc] init];
            
            if (obj==nil) {
                continue;
            }
            /*
             for(int i =0;i<columnArray.count;i++)
             {
             columnName = [columnArray objectAtIndex:i];
             NSString *columnValue = [rs stringForColumn: columnName];
             SEL selector = NSSelectorFromString(columnName);
             
             if ([obj respondsToSelector:selector]) {
             [obj setValue:columnValue forKeyPath:columnName ];
             }
             }
             */
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

-(NSArray *)queryDbToObjectArray:(Class )clazz withConditionObject:(NSObject *)conditionObj{
    NSString *tableName = [NSString  stringWithUTF8String:class_getName(clazz)];
    NSMutableString *sql = [NSMutableString stringWithFormat:@"select * from %@ where 1=1 ",tableName];
    if (conditionObj) {
        //遍历所有字段
        NSArray *columnArray = [conditionObj getPropertyList];
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
    
    return [self queryDbToObjectArray:clazz sql:sql];
}

-(NSArray *)queryDbToDictionaryArray:(NSString *)tablename sql:(NSString *)sql{
    
    __block NSMutableArray *array= [NSMutableArray array];
    
    [dbCenter.fmdbQueue inDatabase:^(FMDatabase *db){
        [db open];
        
        FMResultSet *rs = [db executeQuery:sql];
        
        if (!rs) {
            [db close];
            return ;
        }
        
        //NSArray *columnArray = [self fMSetColumnArray:rs];
        NSObject *obj = [[[NSClassFromString(tablename) class] alloc] init];
        
        //NSArray *columnArray = [obj getPropertyList];
        NSDictionary *columnDic = [obj getPropertyDictionay];
        
        //NSString *columnName = nil;
        
        while ([rs next]) {
            NSMutableDictionary *syncData = [[NSMutableDictionary alloc] init];
            /*
             for(int i =0;i<columnArray.count;i++)
             {
             columnName = [columnArray objectAtIndex:i];
             NSString *columnValue = [rs stringForColumn: columnName];
             if (columnValue==nil) {
             columnValue=@"";
             }
             [syncData setObject:columnValue forKey:columnName];
             }*/
            
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

-(NSArray *)queryDbToDictionaryArray:(NSString *)tableName withConditionObject:(NSObject *)conditionObj{
    NSMutableString *sql = [NSMutableString stringWithFormat:@"select * from %@ where 1=1 ",tableName];
    if (conditionObj) {
        //遍历所有字段
        NSArray *columnArray = [conditionObj getPropertyList];
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
    
    return [self queryDbToDictionaryArray:tableName sql:sql];
}

#pragma mark - query 2

-(NSArray *)queryToObjectArray:(Class )clazz withConditionBeanArray:(NSArray *)conditionBeanArray{
    
    NSString *tableName = [NSString  stringWithUTF8String:class_getName(clazz)];
    
    NSString *sql = [self createQuerySqlByTableName:tableName conditionBeanArray:conditionBeanArray];
    
    return [self queryDbToObjectArray:clazz sql:sql];
    
}

-(NSArray *)queryToDictionaryWithSql:(NSString *)sql{
    NSLog(@"自定义queryToDictionaryWithSql:%@",sql);
    
    __block NSMutableArray *array= [NSMutableArray array];
    
    [dbCenter.fmdbQueue inDatabase:^(FMDatabase *db){
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

#pragma mark - update
-(BOOL)updateRecordWithTable:(NSString *)tablename withModifiedBean:(NSObject *)modifiedBean withConditionObj:(NSObject *)conditionObj{
    
    NSMutableString  *sql = [NSMutableString stringWithFormat:@"UPDATE %@  SET ",tablename];
    
    NSMutableString *conditionSql = [NSMutableString stringWithFormat:@" where 1=1 "];
    
    NSMutableArray *arrayValue = [NSMutableArray array];
    
    if (modifiedBean) {
        //遍历所有字段
        NSArray *columnArray = [modifiedBean getPropertyList];
        
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
    [dbCenter.fmdbQueue inDatabase:^(FMDatabase *db) {
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
        NSArray *columnArray = [modifiedBean getPropertyList];
        
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
    [dbCenter.fmdbQueue inDatabase:^(FMDatabase *db) {
        [db open];
        executeResult = [db executeUpdate:sql withArgumentsInArray:arrayValue];
        [db close];
    }];
    
    return executeResult;
}

@end


#pragma mark ——————————————@implementation ConditionBean——————————————

//
//  ConditionBean.m



//  KuaiKuai
//
//  Created by caohuan on 13-11-18.
//  Copyright (c) 2013年 MONTNETS. All rights reserved.
//
@implementation ConditionBean

@synthesize filedValue = _filedValue;
@synthesize comparisonMark = _comparisonMark;
@synthesize orderMark = _orderMark;
@synthesize filedName = _filedName;

- (id)initWithField:(NSString *)fieldName compare:(NSString *)comparisonMark withValue:(NSObject *)filedValue inOrder:(NSString *)orderMark{
    if (self = [super init]) {
        self.filedName = fieldName;
        self.filedValue = filedValue;
        self.comparisonMark = comparisonMark;
        self.orderMark = orderMark;
    }
    return self;
}

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


@end
