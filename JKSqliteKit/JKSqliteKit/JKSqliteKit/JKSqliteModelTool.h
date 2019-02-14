//
//  JKSqliteModelTool.h
//  JKSqliteKit
//
//  Created by 王冲 on 2019/2/14.
//  Copyright © 2019年 JK科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
// 导入协议
#import "JKSqliteProtocol.h"
NS_ASSUME_NONNULL_BEGIN

@interface JKSqliteModelTool : NSObject

// 关于这个工具类的封装
/**
 实现方案：
 1、基于配置，用户自己来设置
 2、runtime动态获取
 */
+(BOOL)createTable:(Class)cls uid:(NSString *)uid;

#pragma mark 判断是否要更新表
/**
 判断是否要更新表

 @param cls 类
 @param uid 用户的uid
 @return 返回一个是否更新的 BOOL： YES:需要更新 NO:不需要更新
 */
+(BOOL)isUpdateTable:(Class)cls uid:(NSString *)uid;

#pragma mark 更新表(前提是表已经判断 是否需要更新)
/**
 更新表(前提是表已经判断 是否需要更新)

 @param cls 类
 @param uid 用户的uid
 @return YES：更新成功 NO：更新表失败
 */
+(BOOL)updateTable:(Class)cls uid:(NSString *)uid;

@end

NS_ASSUME_NONNULL_END
