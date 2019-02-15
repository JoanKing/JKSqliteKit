//
//  JKSqliteModel.m
//  JKSqliteKit
//
//  Created by 王冲 on 2019/2/14.
//  Copyright © 2019年 JK科技有限公司. All rights reserved.
//

#import "JKSqliteModel.h"
#import <objc/runtime.h>
// 导入协议
#import "JKSqliteProtocol.h"
@implementation JKSqliteModel

/**
 获取表名(类名作为表名)
 
 @param cls 类
 @return 表名
 */
+(NSString *)tableName:(Class)cls{
    
    // 把类转化为类名的字符串
    return NSStringFromClass(cls);
}

/**
 获取临时表名（在更新表的时候用到）
 
 @param cls 类
 @return 表名
 */
+(NSString *)tmpTableName:(Class)cls{
    
    // 在类名后拼接 tmp
    return [NSStringFromClass(cls) stringByAppendingString:@"tmp"];
}

/**
 获取一个模型里面所有的字段名字，以及类型
 
 @param cls 类（模型）
 @return 所有的字段
 */
+(NSDictionary *)classIvarNameTypeDictionary:(Class)cls{
    
    NSMutableDictionary *nameTypeDictionary = [NSMutableDictionary dictionary];
    
    NSArray *ignoreNamesArray = nil;
    if ([cls respondsToSelector:@selector(ignoreColumnNames)]) {
        
        ignoreNamesArray = [cls ignoreColumnNames];
    }
    
    // 获取所有的成员变量
    unsigned int  outCount = 0;
    Ivar *varList = class_copyIvarList(cls, &outCount);

    for (int i = 0; i<outCount; ++i) {
        
        Ivar ivar = varList[i];
        
        // 1.获取成员变量名字
        NSString *ivarName = [NSString stringWithUTF8String:ivar_getName(ivar)];
        
        /**
         "_studentAge" = i;
         "_studentName" = "@\"NSString\"";
         "_studentNumber" = i;
         "_studentScore" = f;
         */
        if ([ivarName hasPrefix:@"_"]) {
            // 把 _ 去掉，读取后面的
            ivarName = [ivarName substringFromIndex:1];
        }
        
        // 1.1、查看有没有忽略字段，如果有就不去创建(根据自己模型里面是否设置了忽略字段)
        if ([ignoreNamesArray containsObject:ivarName]) {
            continue;
        }
        
        // 2.获取成员变量类型
        NSString *ivarType = [NSString stringWithUTF8String:ivar_getTypeEncoding(ivar)];
        // 把包含 @\" 的去掉，如 "@\"NSString\"";-> NSString
        ivarType = [ivarType stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"@\""]];
        
        NSLog(@"ivarType=%@",ivarType);
        
        // 3.成员变量的类型可能重复，成员变量的名字不会重复，所以以成员变量的名字为key
        [nameTypeDictionary setValue:ivarType forKey:ivarName];
        
    }
    
    return nameTypeDictionary;
}

#pragma mark 获取一个模型里面所有的字段名字，以及类型（类型转换为sqlite里面的类型）
/**
 获取一个模型里面所有的字段名字，以及类型（类型转换为sqlite里面的类型）
 
 @param cls 类（模型）
 @return 所有的字段
 */
+(NSDictionary *)classIvarNameSqliteTypeDictionary:(Class)cls{
    
    NSMutableDictionary *dict = [[self classIvarNameTypeDictionary:cls] mutableCopy];
    NSDictionary *typeDict = [self switchOCTypeToSqliteTypeDict];
    [dict enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *obj, BOOL * _Nonnull stop) {
        
        // 字典
        dict[key] = typeDict[obj];
    }];
    
    return dict;
}

// 把上面两个方法合成的字段组合成sql语句里面的 字段
+(NSString *)columnNamesAndTypesStr:(Class)cls{
    
    NSDictionary *dict = [self classIvarNameSqliteTypeDictionary:cls];
    
    NSMutableArray *result = [NSMutableArray array];
    [dict enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *obj, BOOL * _Nonnull stop) {
        
        [result addObject:[NSString stringWithFormat:@"%@ %@",key,obj]];
    }];
    
    return [result componentsJoinedByString:@","];
}

/**
 获取模型所有成员变量名(已排序)
 
 @param cls 类（模型）
 @return 模型所有成员变量名(已排序)
 */
+(NSArray *)allTableSortedIvarNames:(Class)cls{
    
    // 1、获取模型中所有成员变量的名字
    NSDictionary *dict = [JKSqliteModel classIvarNameTypeDictionary:cls];
    NSArray *keys = dict.allKeys;
    // 不可变的数组，重新赋值
    keys = [keys sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [obj1 compare:obj2];
    }];
    return keys;
}

#pragma mark 私有方法

+(NSDictionary *)switchOCTypeToSqliteTypeDict{
    
    return @{
             @"d": @"real", // double
             @"f": @"real", // float
             
             @"i": @"integer",  // int
             @"q": @"integer", // long
             @"Q": @"integer", // long long
             @"B": @"integer", // bool
             
             @"NSData": @"blob",// 二进制
             @"NSDictionary": @"text",
             @"NSMutableDictionary": @"text",
             @"NSArray": @"text",
             @"NSMutableArray": @"text",
             
             @"NSString": @"text"
             };
}



@end
