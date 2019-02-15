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
#import "JKSqliteDatabase.h"
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
    return [JKSqliteDatabase deal:createTableSql witUid:uid];
}

/**
 判断是否要更新表
 
 @param cls 类
 @param uid 用的uid
 @return 返回一个是否更新的 BOOL： YES:需要更新 NO:不需要更新
 */
+(BOOL)isUpdateTable:(Class)cls uid:(NSString *)uid{
   
    // 1.获取模型里面的所有成员变量的名字
    NSArray *modelNames = [JKSqliteModel allTableSortedIvarNames:cls];
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
    
    NSString *dropTmpTableSql = [NSString stringWithFormat:@"drop table if exists %@;", tmpTableName];
    [execSqls addObject:dropTmpTableSql];
    
    NSString *primaryKey = [cls primaryKey];
    // 2、获取一个模型里面所有的字段名字，以及类型
    NSString *createTmpTableSql = [NSString stringWithFormat:@"create table if not exists %@(%@, primary key(%@));",tmpTableName,[JKSqliteModel columnNamesAndTypesStr:cls],primaryKey];
    
    [execSqls addObject:createTmpTableSql];
    
    // 3、把先把旧表的主键往新表里面插入数据
    NSString *insertPrimaryKeyData = [NSString stringWithFormat:@"insert into %@(%@) select %@ from %@;",tmpTableName,primaryKey,primaryKey,oldTableName];
    
    [execSqls addObject:insertPrimaryKeyData];
    
    // 4、根据主键把所有 旧表 中的数据更新到 新表 中
    // 旧表中字段名的数组
    NSArray *oldTableNames = [JKSqliteTableTool tableColumnNames:cls uid:uid];
    // 获取x新模型的所有变量名
    NSArray *tmpTableNames = [JKSqliteModel allTableSortedIvarNames:cls];
    
    // 获取更名字典
    NSDictionary *newNameReplaceOldNameDict = @{};
    if ([cls respondsToSelector:@selector(updateFieldNewNameReplaceOldName)]) {
        newNameReplaceOldNameDict = [cls updateFieldNewNameReplaceOldName];
    }
    
    // 根据主键 插入新表中有的字段
    for (NSString *columnName in tmpTableNames) {
        // 找映射的旧的字段的名字
        NSString *oldName = columnName;
        if ([newNameReplaceOldNameDict[oldName] length] != 0) {
            oldName = newNameReplaceOldNameDict[oldName];
        }
        // 包含主键也过滤掉（上面主键已经赋过值）
        if ((![oldTableNames containsObject:columnName] && ![oldTableNames containsObject:oldName]) || [columnName isEqualToString:primaryKey]) {
            // 新表中没有的字段就不需要再更新过来了
            continue;
        }
        
        // 根据主键在新表插入和旧表中一样字段的数据
        NSString *updateSqlStr = [NSString stringWithFormat:@"update %@ set %@ = (select %@ from %@ where %@.%@ = %@.%@);",tmpTableName,columnName,oldName,oldTableName,tmpTableName,primaryKey,oldTableName,primaryKey];
        
        [execSqls addObject:updateSqlStr];
        
    }
    
    // 5.把旧表删除
    NSString *deleteOldTableSqlStr = [NSString stringWithFormat:@"drop table if exists %@;",oldTableName];
    
    [execSqls addObject:deleteOldTableSqlStr];
    
    // 6.把新表的名字改为旧表的名字，就行隐形替换
    NSString *renameTmpTableNameSqlStr = [NSString stringWithFormat:@"alter table %@ rename to %@;",tmpTableName,oldTableName];
    
    [execSqls addObject:renameTmpTableNameSqlStr];
    
    // 7.执行上面的sql 语句
    return [JKSqliteDatabase dealSqls:execSqls witUid:uid];
}

/**
 保存一个模型
 
 @param model 类
 @param uid 用户的uid
 @return 返回一个保存的结果
 */
+(BOOL)saveOrUpdateModel:(id)model uid:(NSString *)uid{
    
    // 用户在使用的过程中直接调用这个方法，来保存模型
    
    Class cls = [model class];
    // 1、判断表格是否存在，不存在就去创建
    if (![JKSqliteTableTool isTableExists:cls uid:uid]) {
        // 创建表格
        if (![self createTable:cls uid:uid]) {
            // 创建失败
            return NO;
        }
    }
    
    // 2、检测表格是否需要更新，需要则更新，不需要则不更新
    if ([self isUpdateTable:cls uid:uid]) {
        
        // 更新表格
        if (![self updateTable:cls uid:uid]) {
            return NO;
        }
    }
    
    // 3、判断记录是否存在，按照主键的值查询，如果能查询到，那么久更新数据，如果查询不到，就把这条数据插入
    // 获取表名
    NSString *tableName = [JKSqliteModel tableName:cls];
    // 判断模型里面是否有主键
    if (![cls respondsToSelector:@selector(primaryKey)]) {
        NSLog(@"请设置模型里面的主键，遵守协议，实现+(NSString *)primaryKey;，d从而得到主键信息");
        return NO;
    }
    // 拿到主键
    NSString *primaryKey = [cls primaryKey];
    // 模型里面主键的值
    id primaryKeyValue = [model valueForKeyPath:primaryKey];
    // 创建sql语句
    NSString *checkPrimaryKeySql = [NSString stringWithFormat:@"select * from %@ where %@ = %@;",tableName,primaryKey,primaryKeyValue];
    // 进行查询
    // 获取表中所有的字段（下面的方法获取的是字典，我们取其键）
    NSArray *columnNames = [JKSqliteModel classIvarNameTypeDictionary:cls].allKeys;
    // 获取模型里面所有的值数组
    NSMutableArray *columnNameValues = [NSMutableArray array];
    for (NSString *columnName in columnNames) {
        
        id columnNameValue = [model valueForKeyPath:columnName];
        // 判断类型是不是数组或者字典
        if ([columnNameValue isKindOfClass:[NSArray class]] || [columnNameValue isKindOfClass:[NSDictionary class]]) {
            // 在这里我们把数组或者字典处理成一个字符串，才能正确的保存到数据库里面去
            
            // 字典/数组 -> NSData ->NSString
            NSData *data = [NSJSONSerialization dataWithJSONObject:columnNameValue options:NSJSONWritingPrettyPrinted error:nil];
            columnNameValue = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        }
        
        [columnNameValues addObject:columnNameValue];
    }
    
    // 把字段和值拼接生成  字段 = 值   字符的数组
    NSInteger count = columnNames.count;
    NSMutableArray *setValueArray = [NSMutableArray array];
    for (int i = 0; i<count; i++) {
        
        NSString *name = columnNames[i];
        id value = columnNameValues[i];
        NSString *setStr = [NSString stringWithFormat:@"%@ = '%@'",name,value];
        [setValueArray addObject:setStr];
    }
    
    NSString *execSql = @"";
    
    if ([JKSqliteDatabase querySql:checkPrimaryKeySql witUid:uid].count > 0) {
        // update 表名 set 字段1=值 字段2=值.... where 主键名 = 对应的主键值;"
        // 查询的结果大于0说明表中有这条数据，进行数据更新
        // 获取 更新的 sql 语句
        execSql = [NSString stringWithFormat:@"update %@ set %@ where %@ = %@;",tableName,[setValueArray componentsJoinedByString:@","],primaryKey,primaryKeyValue];
    }else{
        
        // 不存在数据，进行记录的插入操作
        // 提示这里 insert into %@(%@) values('%@');，其中的value 要是： 'value1','value2','value2'这样的格式
        execSql = [NSString stringWithFormat:@"insert into %@(%@) values('%@');",tableName,[columnNames componentsJoinedByString:@","],[columnNameValues componentsJoinedByString:@"','"]];
        
    }
    
    return [JKSqliteDatabase deal:execSql witUid:uid];
    
}

#pragma mark 删除模型 删除模型里面的一条记录
/**
 删除模型里面的一条记录
 */
+(BOOL)deleteRecordingModel:(id)model uid:(NSString *)uid{
    
    Class cls = [model class];
    
    // 判断模型里面是否有主键
    if (![cls respondsToSelector:@selector(primaryKey)]) {
        NSLog(@"请设置模型里面的主键，遵守协议，实现+(NSString *)primaryKey;，d从而得到主键信息");
        return NO;
    }
    // 拿到主键
    NSString *primaryKey = [cls primaryKey];
    // 模型里面主键的值
    id primaryKeyValue = [model valueForKeyPath:primaryKey];
    
    // 获取表名
    NSString *tableName = [JKSqliteModel tableName:cls];
    NSString *deleteSql = [NSString stringWithFormat:@"delete from %@ where %@ = %@;",tableName,primaryKey,primaryKeyValue];
    
    return [JKSqliteDatabase deal:deleteSql witUid:uid];
}

/**
 删除模型，也是删除模型中的全部数据，可以说是删除整个表
 */
+(BOOL)deleteModel:(id)model uid:(NSString *)uid{
    
    Class cls = [model class];

    // 获取表名
    NSString *tableName = [JKSqliteModel tableName:cls];
    
    if (![JKSqliteTableTool isTableExists:cls uid:uid]) {
        // 表不存在默认删除成功
        return YES;
    }
    
    // 组建删除表的语句
    NSString *deleteSql = [NSString stringWithFormat:@"drop table %@;",tableName];
    
    return [JKSqliteDatabase deal:deleteSql witUid:uid];
}

/**
 根据条件来删除一些数据
 
 @param model 模型对象
 @param condition 条件
 @param uid 用的id
 @return 返回一个结果
 */
+(BOOL)deleteModel:(id)model whereStr:(NSString *)condition uid:(NSString *)uid{
    
    Class cls = [model class];
    
    // 获取表名
    NSString *tableName = [JKSqliteModel tableName:cls];
    
    // 条件小于0直接返回
    if (!(condition.length > 0)) {
        return NO;
    }
    
    // 组建删除表的语句
    NSString *deleteSql = [NSString stringWithFormat:@"delete from %@ where %@;",tableName,condition];
    
    return [JKSqliteDatabase deal:deleteSql witUid:uid];
}

/**
 简化用户删除模型数据的操作
 
 @param model 模型
 @param name 字段名
 @param relation 条件：ColumnNameToValueRelationType
 @param value 值
 @param uid 用户的uid
 @return 返回结果
 */
+(BOOL)deleteModel:(id)model columnName:(NSString *)name relation:(ColumnNameToValueRelationType)relation value:(NSString *)value uid:(NSString *)uid{
    
    Class cls = [model class];
    
    // 获取表名
    NSString *tableName = [JKSqliteModel tableName:cls];
    
    // 组建删除表的语句
    /**
      self.columnNameToValueRelationTypeDic[@(relation)] 利用映射取值
     */
    NSString *deleteSql = [NSString stringWithFormat:@"delete from %@ where %@ %@ %@;",tableName,name,self.columnNameToValueRelationTypeDic[@(relation)],value];
    
    return [JKSqliteDatabase deal:deleteSql witUid:uid];
}

/** 查询模型中所有的数据 */
+(NSArray *)queryAllDataModel:(Class)cls uid:(NSString *)uid{
    
    // 1.查询前序
    // 获取表名
    NSString *tableName = [JKSqliteModel tableName:cls];
    // 组合查询语句
    NSString *querySql = [NSString stringWithFormat:@"select * from %@",tableName];
    
    // 2.执行查询 key value
    // 模型的属性名称 和 属性值
    NSArray <NSDictionary *>*results = [JKSqliteDatabase querySql:querySql witUid:uid];
    
    // 3.处理查询结果集 -> 模型数组
    return [self parseResults:results withClass:cls];
}

/**
 根据条件来查询模型里面的部分数据
 
 @param cls 模型对象
 @param condition 条件
 @param uid 用的id
 @return 返回一个结果
 */
+(BOOL)queryDataModel:(Class)cls whereStr:(NSString *)condition uid:(NSString *)uid{
    
    // 1.查询前序
    // 获取表名
    NSString *tableName = [JKSqliteModel tableName:cls];
    // 组合查询语句
    NSString *querySql = [NSString stringWithFormat:@"select * from %@ where %@;",tableName,condition];
    
    // 2.执行查询 key value
    // 模型的属性名称 和 属性值
    NSArray <NSDictionary *>*results = [JKSqliteDatabase querySql:querySql witUid:uid];
    
    // 3.处理查询结果集 -> 模型数组
    return [self parseResults:results withClass:cls];
}

/**
 简化用户查询模型数据的操作
 
 @param cls 类对象
 @param name 字段名
 @param relation 条件：ColumnNameToValueRelationType
 @param value 值
 @param uid 用户的uid
 @return 返回结果
 */
+(BOOL)queryDataModel:(Class)cls columnName:(NSString *)name relation:(ColumnNameToValueRelationType)relation value:(NSString *)value uid:(NSString *)uid{
    
    // 1.查询前序
    // 获取表名
    NSString *tableName = [JKSqliteModel tableName:cls];
    // 组合查询语句
    NSString *querySql = [NSString stringWithFormat:@"select * from %@ where %@ %@ %@;",tableName,name,self.columnNameToValueRelationTypeDic[@(relation)],value];
    
    // 2.执行查询 key value
    // 模型的属性名称 和 属性值
    NSArray <NSDictionary *>*results = [JKSqliteDatabase querySql:querySql witUid:uid];
    
    // 3.处理查询结果集 -> 模型数组
    return [self parseResults:results withClass:cls];
}

+ (NSArray *)parseResults:(NSArray <NSDictionary *>*)results withClass:(Class)cls {
    
    // 属性名称 -> 类型 dic
    NSDictionary *nameTypeDic = [JKSqliteModel classIvarNameTypeDictionary:cls];
    
    // 3. 处理查询的结果集 -> 模型数组
    NSMutableArray *models = [NSMutableArray array];
    
    for (NSDictionary *modelDic in results) {
        id model = [[cls alloc] init];
        [models addObject:model];
        
        [modelDic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            
            NSString *type = nameTypeDic[key];
            //
            id resultValue = obj;
            if ([type isEqualToString:@"NSArray"] || [type isEqualToString:@"NSDictionary"]) {
                
                // 字符串 -> NSData -> 相应的类型
                NSData *data = [obj dataUsingEncoding:NSUTF8StringEncoding];
                /**
                 NSJSONReadingMutableContainers = (1UL << 0), 可变的
                 NSJSONReadingMutableLeaves = (1UL << 1), 可变的的类型里面还有可变的
                 NSJSONReadingAllowFragments =
                 kNilOptions 不可变
                 */
                resultValue = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                
                
            }else if ([type isEqualToString:@"NSMutableArray"] || [type isEqualToString:@"NSMutableDictionary"]){
                
                // 字符串 -> NSData -> 相应的类型
                NSData *data = [obj dataUsingEncoding:NSUTF8StringEncoding];
                resultValue = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            }
            
            [model setValue:resultValue forKey:key];
        }];
    }
    
    return models;
}

// 条件的映射
+(NSDictionary *)columnNameToValueRelationTypeDic{
    
    return @{@(ColumnNameToValueRelationMore):@">",
             @(ColumnNameToValueRelationLess):@"<",
             @(ColumnNameToValueRelationEqual):@"=",
             @(ColumnNameToValueRelationMoreEqual):@">=",
             @(ColumnNameToValueRelationLessEqual):@"<"
             };
}

@end
