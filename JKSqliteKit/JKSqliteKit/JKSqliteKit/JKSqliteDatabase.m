//
//  JKSqliteDatabase.m
//  JKSqliteKit
//
//  Created by 王冲 on 2019/2/14.
//  Copyright © 2019年 JK科技有限公司. All rights reserved.
//

#import "JKSqliteDatabase.h"

#import "sqlite3.h"

// 数据库存储的位置，每一个用户都对应一个数据库

#define JKSqliteCachePath [NSHomeDirectory() stringByAppendingPathComponent:@"/Library/Caches"]


// #define JKSqliteCachePath @"/Users/wangchong/Desktop/"

// 全局的数据库对象
sqlite3 *ppDb = nil;


@implementation JKSqliteDatabase

/**
 用户机制，操作数据库（ DDL 增删改）
 
 @param sql sql 语句
 @param uid 用户的id,存在的话，操作对一个id的数据库，不存在的话，操作公有的数据库
 */
+(BOOL)deal:(NSString *)sql witUid:(NSString *)uid{
    
    // 1.打开数据库
    if (![self openDB:uid]) {
        NSLog(@"打开失败");
        return NO;
    }
    
    // 2、执行sql语句
    /**
     第1个参数：数据库对象
     第2个参数：sql语句
     第3个参数：查询时候用到的一个结果集闭包，sqlite3_callback 是回调，当这条语句运行之后，sqlite3会去调用你提供的这个函数。
     第4个参数：void * 是你所提供的指针，你能够传递不论什么一个指针參数到这里，这个參数终于会传到回调函数里面。假设不须要传递指针给回调函数。能够填NULL。等下我们再看回调函数的写法，以及这个參数的使用。
     第5个参数：char ** errmsg 是错误信息。注意是指针的指针。sqlite3里面有非常多固定的错误信息。运行 sqlite3_exec之后，运行失败时能够查阅这个指针（直接 printf(“%s/n”,errmsg)）得到一串字符串信息，这串信息告诉你错在什么地方。sqlite3_exec函数通过改动你传入的指针的指针，把你提供的指针指向错误提示信息，这样sqlite3_exec函数外面就能够通过这个 char*得到详细错误提示。
     说明：通常，sqlite3_callback 和它后面的 void * 这两个位置都能够填 NULL。
     填NULL表示你不须要回调。比方你做 insert 操作，做 delete 操作,做update 操作，就没有必要使用回调。而当你做 select 时，就要使用回调。由于 sqlite3 把数据查出来，得通过回调告诉你查出了什么数据。
     */

    BOOL result = sqlite3_exec(ppDb, sql.UTF8String, nil, nil, nil) == SQLITE_OK;
    
    // 3、关闭数据库
    [self closeDB];
    
    return result;
}

/**
 查询数据
 
 @param sql sql 语句
 @param uid 用户的id
 @return 字典组成的数组，每一个字典都是一行记录
 */
+(NSMutableArray <NSMutableDictionary *>*)querySql:(NSString *)sql witUid:(NSString *)uid{
    
    // 1.打开数据库
    if (![self openDB:uid]) {
        NSLog(@"打开失败");
        return nil;
    }
    
    // 准备语句，预处理语句
    // 2.创建准备语句
    /**
     第1个参数：一个已经打开的数据库对象
     第2个参数：sql语句
     第3个参数：参数2中取出多少字节的长度，-1 自动计算，\0停止取出
     第4个参数：准备语句
     第5个参数：通过参数3，取出参数2的长度字节之后，剩下的字符串
     */
    sqlite3_stmt *ppStmt = nil;
    if (sqlite3_prepare_v2(ppDb, sql.UTF8String, -1, &ppStmt, nil) != SQLITE_OK) {
        NSLog(@"准备语句编译失败");
        return nil;
    }
    
    // 2.绑定数据(可以有 ？ 的省略)
    
    // 3.执行
    // 大数组 : SQLITE_ROW代表数据的不断的向下查找
    NSMutableArray *rowDicArray = [NSMutableArray array];
    
    while (sqlite3_step(ppStmt) == SQLITE_ROW) {
        // 一行记录 -> 字典
        // 记录值的字典
        NSMutableDictionary *rowDictionary = [NSMutableDictionary dictionary];
        
        // 3.1、获取所有列的个数
        int columnCount = sqlite3_column_count(ppStmt);
        
        // 3.2、遍历所有的列
        for (int i=0; i<columnCount; i++) {
            
            // 3.2.1、获取所有列的名字，也就是表中字段的名字
            // C语言的字符串
            const char *columnNameC = sqlite3_column_name(ppStmt, i);
            // 把 C 语言字符串转为 OC
            NSString *columnName = [NSString stringWithUTF8String:columnNameC];
            // 3.2.2、获取列值
            // 不同列的类型，使用不同的函数，进行获取值
            // 3.2.2.1、获取列的类型
            int type = sqlite3_column_type(ppStmt, i);
            /** 我们使用的是 SQLite3，所以是：SQLITE3_TEXT
             SQLite version 2 and SQLite version 3 should use SQLITE3_TEXT, not
             
             SQLITE_INTEGER  1
             SQLITE_FLOAT    2
             SQLITE3_TEXT    3
             SQLITE_BLOB     4
             SQLITE_NULL     5
             
             */
            // 3.2.2.2、根据列的类型，使用不同的函数，获取列的值
            id value = nil;
            
            switch (type) {
                case SQLITE_INTEGER:
                    value = @(sqlite3_column_int(ppStmt,i));
                    break;
                case SQLITE_FLOAT:
                    value = @(sqlite3_column_double(ppStmt, i));
                    break;
                case SQLITE3_TEXT:
                    value = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(ppStmt, i)];
                    break;
                case SQLITE_BLOB:
                    value = CFBridgingRelease(sqlite3_column_blob(ppStmt, i));
                    break;
                case SQLITE_NULL:
                    value = @"";
                    break;
                    
                default:
                    break;
            }
            
            // 字典填值
            [rowDictionary setValue:value forKey:columnName];
        }
        
        // 每一个添加到数组中
        [rowDicArray addObject:rowDictionary];
    }
    
    // 4.重置(省略)
    
    
    // 5.释放资源
    sqlite3_finalize(ppStmt);
    
    // 6.关闭数据库
    [self closeDB];
    
    return rowDicArray;
}

/**
 执行多条sql语句
 
 @param sqls sql 语句
 @param uid 用户的id
 @return 返回是否都执行成功 YES：都执行成功 NO：没有全部执行成功
 */
+(BOOL)dealSqls:(NSArray <NSString *>*)sqls witUid:(NSString *)uid{
    
    [self beginTransactionUid:uid];
    
    for (NSString *sql in sqls) {
        
        BOOL result = [self deal:sql witUid:uid];
        if (!result) {
            
            // 执行失败，进行回滚
            [self rollBackTransactionUid:uid];
            
            return NO;
        }
    }
    
    // 走到这里说明都执行成功了，进行提交
    [self commitTransactionUid:uid];
    
    // 关闭数据库
    [self closeDB];
    
    return YES;
}

// 开启事务
+(void)beginTransactionUid:(NSString *)uid{
    
    [self deal:@"begin transaction" witUid:uid];
}

// 提交事务
+(void)commitTransactionUid:(NSString *)uid{
    
    [self deal:@"commit transaction" witUid:uid];
}

// 回滚事务
+(void)rollBackTransactionUid:(NSString *)uid{
    
    [self deal:@"rollback transaction" witUid:uid];
}

#pragma mark 私有方法

// 打开数据库
+(BOOL)openDB:(NSString *)uid{
    
    // 1.获取数据库的名字以及对应的路径
    // 1.1、获取数据库的名字
    NSString *sqliteName = @"jk_common.sqlite";
    if (uid.length != 0) {
        
        sqliteName = [NSString stringWithFormat:@"jk_%@.sqlite",uid];
    }
    // 1.2、对应的路径
    NSString *sqlitePath = [JKSqliteCachePath stringByAppendingPathComponent:sqliteName];
    // 2.打开数据库，不存在的情况下自动创建
    return sqlite3_open(sqlitePath.UTF8String, &ppDb) == SQLITE_OK;
}

// 关闭数据库
+(void)closeDB{
    
    // 4、关闭数据库
    sqlite3_close(ppDb);
}

@end
