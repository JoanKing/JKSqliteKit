//
//  Person.h
//  JKSqliteKit
//
//  Created by 王冲 on 2019/2/15.
//  Copyright © 2019年 JK科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
// 导入协议
#import "JKSqliteProtocol.h"
NS_ASSUME_NONNULL_BEGIN

@interface Person : NSObject

/** 人的ID */
@property(nonatomic,assign) int personID;

/** 人的名字 */
// @property(nonatomic,strong) NSString *personName;
//
@property(nonatomic,strong) NSString *name;

/** 人的年龄 */
@property(nonatomic,assign) int personAge;

/** 人的身高 */
@property(nonatomic,assign) float personHeight;

/** 人的爱好 */
@property(nonatomic,strong) NSArray *personLikes;


@end

NS_ASSUME_NONNULL_END
