//
//  JKSqliteDatabase.h
//  JKSqliteKit
//
//  Created by 王冲 on 2019/2/14.
//  Copyright © 2019年 JK科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JKSqliteDatabase : NSObject

#pragma mark 用户机制，操作数据库

/**
 用户机制，操作数据库
 
 @param sql sql 语句
 @param uid 用户的id,存在的话，操作对一个id的数据库，不存在的话，操作公有的数据库
 */
+(BOOL)deal:(NSString *)sql witUid:(NSString *)uid;

#pragma mark 查询数据

/**
 查询数据
 
 @param sql sql 语句
 @param uid 用户的id
 @return 字典组成的数组，每一个字典都是一行记录
 */
+(NSMutableArray <NSMutableDictionary *>*)querySql:(NSString *)sql witUid:(NSString *)uid;

#pragma mark 执行多条sql语句
/**
 执行多条sql语句
 
 @param sqls sql 语句
 @param uid 用户的id
 @return 返回是否都执行成功 YES：都执行成功 NO：没有全部执行成功
 */
+(BOOL)dealSqls:(NSArray <NSString *>*)sqls witUid:(NSString *)uid;


@end

NS_ASSUME_NONNULL_END
