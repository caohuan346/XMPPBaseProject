//
//  NSObject+Property.m
//  KuaiKuai
//
//  Created by caohuan on 13-11-18.
//  Copyright (c) 2013年 MONTNETS. All rights reserved.
//

#import "NSObject+Property.h"

@implementation NSObject (Property)

 
- (NSArray *)getPropertyList{
    return [self getPropertyList:[self class]];
}

- (NSArray *)getPropertyList: (Class)clazz
{
    u_int count;
    objc_property_t *properties  = class_copyPropertyList(clazz, &count);
    NSMutableArray *propertyArray = [NSMutableArray arrayWithCapacity:count];
    
    for (int i = 0; i < count ; i++)
    {
        const char* propertyName = property_getName(properties[i]);
        [propertyArray addObject: [NSString  stringWithUTF8String: propertyName]];
    }
    
    free(properties);
    
    return propertyArray;
}

- (NSString *)tableSql:(NSString *)tablename{
    NSMutableString *sql = [[NSMutableString alloc] init];
    NSArray *array = [self getPropertyList];
    [sql appendFormat:@"create table %@ (",tablename] ;
    NSInteger i = 0;
    for (NSString *key in array) {
        if (i>0) {
            [sql appendString:@","];
        }
        [sql appendFormat:@"%@ text",key];
        i++;
    }
    [sql appendString:@")"];
    return sql;
}

- (NSString *)tableSql{
    return [self tableSql:[self className]];
}
 

- (NSDictionary *)convertDictionary{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    NSArray *propertyList = [self getPropertyList];
    for (NSString *key in propertyList) {
        SEL selector = NSSelectorFromString(key);
        
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            id value = [self performSelector:selector];
        #pragma clang diagnostic pop
        
        if (value == nil) {
            value = [NSNull null];
        }
        [dict setObject:value forKey:key];
    }
    return dict;
}
- (id)initWithDictionary:(NSDictionary *)dict{
    self = [self init];
    if(self)
        [self dictionaryForObject:dict];
    return self;
    
}
- (NSString *)className{
    return [NSString stringWithUTF8String:object_getClassName(self)];
}

- (BOOL)checkPropertyName:(NSString *)name {
    unsigned int propCount, i;
    objc_property_t* properties = class_copyPropertyList([self class], &propCount);
    for (i = 0; i < propCount; i++) {
        objc_property_t prop = properties[i];
        const char *propName = property_getName(prop);
        if(propName) {
            NSString *_name = [NSString stringWithCString:propName encoding:NSUTF8StringEncoding];
            if ([name isEqualToString:_name]) {
                return YES;
            }
        }
    }
    return NO;
}


- (void)dictionaryForObject:(NSDictionary*) dict{
    for (NSString *key in [dict allKeys]) {
        id value = [dict objectForKey:key];
        
        if (value==[NSNull null]) {
            continue;
        }
        if ([value isKindOfClass:[NSDictionary class]]) {
            id subObj = [self valueForKey:key];
            if (subObj)
                [subObj dictionaryForObject:value];
        }
        else{
             [self setValue:value forKeyPath:key];
        }
    }
}


#pragma mark - extra

- (NSString *)createTableTableSql{
    return [self createTableSqlExtend:[self className]];
}

//采用获取属性类型字典的方式进行sql语句创建
- (NSString *)createTableSqlExtend:(NSString *)tablename{
    
    NSMutableString *sql = [[NSMutableString alloc] init];
    
    NSDictionary *dic = [self getPropertyDictionay];
    
    [sql appendFormat:@"create table %@ (",tablename] ;
    
    NSInteger i = 0;
    for (NSString *key in dic.allKeys) {
        if (i>0) {
            [sql appendString:@","];
        }
        
        NSString *fieldType = [dic objectForKey:key];
        
        if ([@"NSDate" isEqualToString:fieldType]) {
            [sql appendFormat:@"%@ date",key];
        }else if ([@"NSNumber" isEqualToString:fieldType]) {
            [sql appendFormat:@"%@ integer",key];
        }else if ([@"NSString" isEqualToString:fieldType]) {
            [sql appendFormat:@"%@ text",key];
        }
       
        i++;
    }
    [sql appendString:@")"];
    NSLog(@"建表sql:%@",sql);
    return sql;
}

- (NSDictionary *)getPropertyDictionay{
    return [self getPropertyDictionayByClazz:[self class]];
}

//反射获取对象属性类型字典
- (NSDictionary *)getPropertyDictionayByClazz: (Class)clazz
{
    u_int count;
    objc_property_t *properties  = class_copyPropertyList(clazz, &count);
    
    NSMutableDictionary *propertyDictionary = [NSMutableDictionary dictionaryWithCapacity:count];
    
    for (int i = 0; i < count ; i++)
    {
        const char* propertyName = property_getName(properties[i]);
        //[propertyArray addObject: [NSString  stringWithUTF8String: propertyName]];
        
        //————————————————————————————————————————————————
        //T@"NSDate",C,N,V_msgId
        //T@"NSNumber",C,N,V_parentSerial
        //T@"NSString",C,N,V_senderId
        NSString *attrStr = [[NSString alloc] initWithUTF8String:property_getAttributes(properties[i])];
        //NSArray *attrArray = [attrStr componentsSeparatedByString:@","];
        NSRange nsDateRange = [attrStr rangeOfString:@"NSDate"];
        NSRange nsNumberRange = [attrStr rangeOfString:@"NSNumber"];
        NSRange nsStringRange = [attrStr rangeOfString:@"NSString"];
        
        NSString *propertyStr = [NSString stringWithUTF8String: propertyName];
        //NSDate
        if (nsDateRange.location != NSNotFound) {
            [propertyDictionary setObject:@"NSDate" forKey:propertyStr];
        }
        //NSNumber
        else if (nsNumberRange.location != NSNotFound){
            [propertyDictionary setObject:@"NSNumber" forKey:propertyStr];
        }
        //NSString
        else if (nsStringRange.location != NSNotFound){
            [propertyDictionary setObject:@"NSString" forKey:propertyStr];
        }
        //————————————————————————————————————————————————
    }
    
    free(properties);
    
    return propertyDictionary;
}
@end