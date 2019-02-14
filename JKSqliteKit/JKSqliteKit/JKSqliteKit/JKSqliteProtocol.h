//
//  JKSqliteProtocol.h
//  JKSqliteKit
//
//  Created by 王冲 on 2019/2/14.
//  Copyright © 2019年 JK科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol JKSqliteProtocol <NSObject>

// 主键
@required // 必须实现的方法
+(NSString *)primaryKey;

@optional // 可以不用实现的方法
+(NSArray *)ignoreColumnNames;

@end

NS_ASSUME_NONNULL_END
