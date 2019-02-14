//
//  Student.h
//  JKSqliteKit
//
//  Created by 王冲 on 2019/2/14.
//  Copyright © 2019年 JK科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
// 导入协议
#import "JKSqliteProtocol.h"
NS_ASSUME_NONNULL_BEGIN

@interface Student : NSObject<JKSqliteProtocol>


/** 学号 */
@property(nonatomic,assign)  int studentNumber;

/** 年龄 */
@property(nonatomic,assign) int studentAge;

/** 名字 */
@property(nonatomic,strong) NSString *studentName;

/** 分数 */
// @property(nonatomic,assign) float studentScore;

/** 身高 */
@property(nonatomic,strong) NSString *studentHeight;

/** 测试忽略的名字 */
@property(nonatomic,strong) NSString *testName;

@end

NS_ASSUME_NONNULL_END
