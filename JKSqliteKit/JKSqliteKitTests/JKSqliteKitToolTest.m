//
//  JKSqliteKitToolTest.m
//  JKSqliteKitTests
//
//  Created by 王冲 on 2019/2/13.
//  Copyright © 2019年 JK科技有限公司. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "JKSqliteKit.h"
#import "Student.h"
#import "JKSqliteModelTool.h"
@interface JKSqliteKitToolTest : XCTestCase

@end

@implementation JKSqliteKitToolTest

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testExample {
    
    //NSString *sql = @"create table if not exists student(id integer primary key autoincrement,name text not null,age integer,score real)";
    //BOOL result = [JKSqliteKit deal:sql witUid:@""];
    //XCTAssertEqual(result, YES);
    
    
    Class cls = NSClassFromString(@"Student");
    BOOL result = [JKSqliteModelTool createTable:cls uid:@"1"];
    XCTAssertEqual(result, YES);
    
}

-(void)testQuary{
   
    NSString *sql = @"select * from student";
    NSMutableArray *result = [JKSqliteKit querySql:sql witUid:@"1"];
    
    NSLog(@"%@",result);
    
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
