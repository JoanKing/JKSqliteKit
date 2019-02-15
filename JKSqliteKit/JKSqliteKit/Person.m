//
//  Person.m
//  JKSqliteKit
//
//  Created by 王冲 on 2019/2/15.
//  Copyright © 2019年 JK科技有限公司. All rights reserved.
//

#import "Person.h"

@implementation Person


+(NSString *)primaryKey{
    
    return @"personID";
}

+(NSDictionary *)updateFieldNewNameReplaceOldName{

    return @{@"name":@"personName"};
}

@end
