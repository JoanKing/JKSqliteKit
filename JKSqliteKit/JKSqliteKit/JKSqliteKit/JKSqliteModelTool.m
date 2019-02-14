//
//  JKSqliteModelTool.m
//  JKSqliteKit
//
//  Created by 王冲 on 2019/2/14.
//  Copyright © 2019年 JK科技有限公司. All rights reserved.
//

#import "JKSqliteModelTool.h"
#import "JKSqliteModel.h"
// sql语句执行
#import "JKSqliteKit.h"
// 操作表的类
#import "JKSqliteTableTool.h"
@implementation JKSqliteModelTool



// 关于这个工具类的封装
/**
 实现方案：
 1、基于配置，用户自己来设置
 2、runtime动态获取
 */
+(BOOL)createTable:(Class)cls uid:(NSString *)uid{
    
    // 1.创建表格的sql语句给拼接出来
    /**
     create table if not exists 表名(字段1 字段1类型(约束),字段2 字段2类型(约束),字段3 字段3类型(约束),.....,primary(字段))
     
     primary： 主键
     */
    // 1.1、获取表名
    NSString *tableName = [JKSqliteModel tableName:cls];
    // 判断模型里面是否有主键
    
    if (![cls respondsToSelector:@selector(primaryKey)]) {
        NSLog(@"请设置模型里面的主键，遵守协议，实现+(NSString *)primaryKey;，d从而得到主键信息");
        return NO;
    }
    
    NSString *primaryKey = [cls primaryKey];
    // 1.2、获取一个模型里面所有的字段名字，以及类型
    NSString *createTableSql = [NSString stringWithFormat:@"create table if not exists %@(%@, primary key(%@))",tableName,[JKSqliteModel columnNamesAndTypesStr:cls],primaryKey];
    // 2、执行(返回是否创建成功)
    return [JKSqliteKit deal:createTableSql witUid:uid];
}

/**
 判断是否要更新表
 
 @param cls 类
 @param uid 用的uid
 @return 返回一个是否更新的 BOOL： YES:需要更新 NO:不需要更新
 */
+(BOOL)isUpdateTable:(Class)cls uid:(NSString *)uid{
   
    // 1.获取模型里面的所有成员变量的名字
    NSArray *modelNames = [JKSqliteTableTool allTableSortedIvarNames:cls];
    // 2.获取uid对应数据库里面对应表的字段数组
    NSArray *tableNames = [JKSqliteTableTool tableColumnNames:cls uid:uid];
    // 3.判断两个数组是否相等，返回响应的结果,取反：相等不需要更新，不相等才需要去更新
    return ![modelNames isEqualToArray:tableNames];
    
}

/**
 更新表(前提是表已经判断 是否需要更新)
 
 @param cls 类
 @param uid 用户的uid
 @return YES：更新成功 NO：更新表失败
 */
+(BOOL)updateTable:(Class)cls uid:(NSString *)uid{
    
    // 1、获取表名
    // 临时表名
    NSString *tmpTableName = [JKSqliteModel tmpTableName:cls];
    // 旧表名
    NSString *oldTableName = [JKSqliteModel tableName:cls];
    // 判断模型里面是否有主键
    
    if (![cls respondsToSelector:@selector(primaryKey)]) {
        NSLog(@"请设置模型里面的主键，遵守协议，实现+(NSString *)primaryKey;，d从而得到主键信息");
        return NO;
    }
    
    // 创建数组记录执行的sql
    NSMutableArray *execSqls = [NSMutableArray array];
    
    NSString *primaryKey = [cls primaryKey];
    // 2、获取一个模型里面所有的字段名字，以及类型
    NSString *createTmpTableSql = [NSString stringWithFormat:@"create table if not exists %@(%@, primary key(%@));",tmpTableName,[JKSqliteModel columnNamesAndTypesStr:cls],primaryKey];
    
    [execSqls addObject:createTmpTableSql];
    
    // 3、把先把旧表的主键往新表里面插入数据
    NSString *insertPrimaryKeyData = [NSString stringWithFormat:@"insert into %@(%@) select %@ from %@;",tmpTableName,primaryKey,primaryKey,oldTableName];
    
    [execSqls addObject:insertPrimaryKeyData];
    
    // 4、根据主键把所有 旧表 中的数据更新到 新表 中
    // 旧表中字段名的数组
    NSArray *oldTableNames = [JKSqliteTableTool allTableSortedIvarNames:cls];
    // 获取x新模型的所有变量名
    NSArray *tmpTableNames = [JKSqliteTableTool tableColumnNames:cls uid:uid];
    // 根据主键 插入新表中有的字段
    for (NSString *columnName in tmpTableNames) {
        
        if (![oldTableNames containsObject:columnName]) {
            // 新表中没有的字段就不需要再更新过来了
            continue;
        }
        
        // 根据主键在新表插入和旧表中一样字段的数据
        NSString *updateSqlStr = [NSString stringWithFormat:@"update %@ set %@ = (select %@ from %@ where %@.%@ = %@.%@)",tmpTableName,columnName,columnName,oldTableName,tmpTableName,primaryKey,oldTableName,primaryKey];
        
        [execSqls addObject:updateSqlStr];
        
    }
    
    // 5.把旧表删除
    NSString *deleteOldTableSqlStr = [NSString stringWithFormat:@"drop table if exists %@",oldTableName];
    
    [execSqls addObject:deleteOldTableSqlStr];
    
    // 6.把新表的名字改为旧表的名字，就行隐形替换
    NSString *renameTmpTableNameSqlStr = [NSString stringWithFormat:@"alter table %@ rename to %@",tmpTableName,oldTableName];
    
    [execSqls addObject:renameTmpTableNameSqlStr];
    
    // 7.执行上面的sql 语句
    return [JKSqliteKit dealSqls:execSqls witUid:uid];
}

@end
