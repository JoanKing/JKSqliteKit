//
//  ViewController.m
//  JKSqliteKit
//
//  Created by 王冲 on 2019/2/13.
//  Copyright © 2019年 JK科技有限公司. All rights reserved.
//

#import "ViewController.h"
#import "Person.h"
#import "JKSqliteKit.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
  
    
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    // 保存模型
    // [self saveModel];
    
    // 查询模型
    // [self queryModels];
    
    // 修改字段名字
    [self updateField];
}

// 保存模型
-(void)saveModel{
    
    Person *person = [[Person alloc]init];
    person.personID = 2;
    // person.personName = @"王小二";
    person.personAge = 29;
    person.personHeight = 178;
    person.personLikes = @[@"篮球",@"足球"];
    
    BOOL result = [JKSqliteModelTool saveOrUpdateModel:person uid:@"1"];
    if(result){
        // 保存成功
    }else{
        // 保存失败
    }
}

// 查询模型
-(void)queryModels{
    
    NSArray *resultArray = [JKSqliteModelTool queryAllDataModel:NSClassFromString(@"Person") uid:@"1"];
    
    NSLog(@"resultArray=%@",resultArray);
    for (Person *person in resultArray) {
        
        NSLog(@"personID =%d",person.personID);
        // NSLog(@"personName=%@",person.personName);
        NSLog(@"personAge=%d",person.personAge);
        NSLog(@"personHeight=%lf",person.personHeight);
        NSLog(@"personLikes=%@",person.personLikes);
        
    }
}

#pragma mark 修改字段名
-(void)updateField{
    
    BOOL result = [JKSqliteModelTool updateTable:[Person class] uid:@"1"];
    if(result){

        NSLog(@"修改成功");
    }else{

        NSLog(@"修改失败");
    }
}

#pragma mark 删除Person模型(也可以说是删除这个Person模型的表)
-(void)deleteModel{
    
    Person *person = [[Person alloc]init];
    [JKSqliteModelTool deleteModel:person uid:@"1"];
}

@end
