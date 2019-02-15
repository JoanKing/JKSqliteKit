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

#pragma mark 是否存在表格
/** 是否存在表格 */
+(BOOL)isTableExists:(Class)cls uid:(NSString *)uid;

@end

NS_ASSUME_NONNULL_END
