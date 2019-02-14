//
//  Student.m
//  JKSqliteKit
//
//  Created by 王冲 on 2019/2/14.
//  Copyright © 2019年 JK科技有限公司. All rights reserved.
//

#import "Student.h"

@implementation Student

+(NSString *)primaryKey{
    
    return @"studentNumber";
}

+(NSArray *)ignoreColumnNames{
    
    return @[@"testName"];
}

@end
