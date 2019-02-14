//
//  JKSqliteTableToolTest.m
//  JKSqliteKitTests
//
//  Created by 王冲 on 2019/2/14.
//  Copyright © 2019年 JK科技有限公司. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "JKSqliteTableTool.h"
#import "JKSqliteModelTool.h"
@interface JKSqliteTableToolTest : XCTestCase

@end

@implementation JKSqliteTableToolTest

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testExample {
    
   NSArray *array = [JKSqliteTableTool tableColumnNames:NSClassFromString(@"Student") uid:@"2"];
    
    NSLog(@"names=%@",array);
    
}

// 更新表
-(void)testUpdateTable{
    
    BOOL result = [JKSqliteModelTool isUpdateTable:NSClassFromString(@"Student") uid:@"1"];
    if (result) {
        // 表需要更新
        BOOL isResult = [JKSqliteModelTool updateTable:NSClassFromString(@"Student") uid:@"1"];
        XCTAssertEqual(isResult, YES);
    }
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
