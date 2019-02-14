//
//  JKSqliteModelToolTest.m
//  JKSqliteKitTests
//
//  Created by 王冲 on 2019/2/14.
//  Copyright © 2019年 JK科技有限公司. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "JKSqliteModel.h"
#import "Student.h"

@interface JKSqliteModelToolTest : XCTestCase

@end

@implementation JKSqliteModelToolTest

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testIvar{
    
    NSString *dict = [JKSqliteModel columnNamesAndTypesStr:[Student class]];
    
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
