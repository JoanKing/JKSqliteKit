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
#import "JKSqliteModelTool.h"

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

#pragma mark 保存模型的测试
-(void)testSavaModel{
    
    Student *student = [[Student alloc]init];
    student.studentNumber = 2;
    student.studentAge = 29;
    student.studentName = @"马冶";
    student.studentHeight = 172;
    student.TT = @"MY";
    student.studentlikes = @[@"射箭",@"拳击"];
    student.studentFriends = @[@"浩伟",@"爽姐"];
    // student.studentPropleInfo = @{@"father":@"爸爸",@"mother":@"妈妈"};
    
    BOOL result = [JKSqliteModelTool saveOrUpdateModel:student uid:@"1"];
    
    XCTAssertTrue(result);
    
}

#pragma mark 查询模型的测试
-(void)testQueryModel{
    
    NSArray *resultArray = [JKSqliteModelTool queryAllDataModel:NSClassFromString(@"Student") uid:@"1"];
    
    NSLog(@"resultArray=%@",resultArray);
    for (Student *student in resultArray) {
        
        NSLog(@"studentNumber=%d",student.studentNumber);
        NSLog(@"studentName=%@",student.studentName);
        NSLog(@"studentAge=%d",student.studentAge);
        NSLog(@"studentHeight=%lf",student.studentHeight);
        NSLog(@"studentlikes=%@",student.studentlikes);
        // NSLog(@"studentPropleInfo=%@",student.studentPropleInfo);
    }
    
}

#pragma mark 删除模型测试
-(void)testDeleteModel{
    
    Student *student = [[Student alloc]init];
    student.studentNumber = 1;
    
    BOOL result = [JKSqliteModelTool deleteModel:student uid:@"1"];
    XCTAssertTrue(result);
}

#pragma mark 删除模型中符合条件的数据测试
-(void)testDeleteRelationModel{
    
    BOOL result = [JKSqliteModelTool deleteModel:NSClassFromString(@"Student") columnName:@"studentHeight" relation:ColumnNameToValueRelationLess value:@175 uid:@"1"];
    XCTAssertTrue(result);
    
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
