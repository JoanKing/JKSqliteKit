//
//  JKSqliteModel.h
//  JKSqliteKit
//
//  Created by 王冲 on 2019/2/14.
//  Copyright © 2019年 JK科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JKSqliteModel : NSObject

#pragma mark 获取表名
/**
 获取表名
 
 @param cls 类
 @return 表名
 */
+(NSString *)tableName:(Class)cls;

#pragma mark 获取临时表名（在更新表的时候用到）
/**
 获取临时表名（在更新表的时候用到）
 
 @param cls 类
 @return 表名
 */
+(NSString *)tmpTableName:(Class)cls;

#pragma mark 获取一个模型里面所有的字段名字，以及类型
/**
 获取一个模型里面所有的字段名字，以及类型
 
 @param cls 类（模型）
 @return 所有的字段
 */
+(NSDictionary *)classIvarNameTypeDictionary:(Class)cls;

#pragma mark 获取一个模型里面所有的字段名字，以及类型（类型转换为sqlite里面的类型）
/**
 获取一个模型里面所有的字段名字，以及类型（类型转换为sqlite里面的类型）
 
 @param cls 类（模型）
 @return 所有的字段
 */
+(NSDictionary *)classIvarNameSqliteTypeDictionary:(Class)cls;

#pragma mark 把上面两个方法合成的字段组合成sql语句里面的 字段
+(NSString *)columnNamesAndTypesStr:(Class)cls;

#pragma mark 获取模型所有成员变量名(已排序)
/**
 获取模型所有成员变量名(已排序)
 
 @param cls 类（模型）
 @return 模型所有成员变量名(已排序)
 */
+(NSArray *)allTableSortedIvarNames:(Class)cls;


@end

NS_ASSUME_NONNULL_END
