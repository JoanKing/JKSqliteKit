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
@property(nonatomic,assign) float studentHeight;

/** 测试忽略的名字 */
@property(nonatomic,strong) NSString *testName;

@property(nonatomic,strong) NSString *TT;

/** 用户的爱好 */
@property(nonatomic,strong) NSArray *studentlikes;

/** 用户家人的名字信息 */
// @property(nonatomic,strong) NSDictionary *studentPropleInfo;

/** 朋友的名字 */
@property(nonatomic,strong) NSArray *studentFriends;



@end

NS_ASSUME_NONNULL_END
