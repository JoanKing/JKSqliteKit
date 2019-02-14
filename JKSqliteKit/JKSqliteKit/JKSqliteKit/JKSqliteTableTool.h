//
//  JKSqliteTableTool.h
//  JKSqliteKit
//
//  Created by 王冲 on 2019/2/14.
//  Copyright © 2019年 JK科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JKSqliteTableTool : NSObject

#pragma mark 取出表中所有的字段名
/**
 取出表中所有的字段名
 
 @param cls 模型类
 @param uid 用户的uid
 @return 返回字段名数组
 */
+(NSArray *)tableColumnNames:(Class)cls uid:(NSString *)uid;

#pragma mark 获取表中所有字段(已排序)
/**
 获取模型所有成员变量名(已排序)
 
 @param cls 类（模型）
 @return 模型所有成员变量名(已排序)
 */
+(NSArray *)allTableSortedIvarNames:(Class)cls;


@end

NS_ASSUME_NONNULL_END
