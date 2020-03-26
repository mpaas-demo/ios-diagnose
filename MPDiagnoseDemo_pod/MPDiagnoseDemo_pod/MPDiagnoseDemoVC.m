//
//  MPDiagnoseDemoVC.m
//  MPDiagnoseDemo
//
//  Created by shifei.wkp on 2018/12/18.
//  Copyright © 2018 alipay. All rights reserved.
//

#import "MPDiagnoseDemoVC.h"
#import "MPDiagnoseDemoDef.h"
#import "MPDiagnoseTestCase.h"
#import <MPDiagnosis/MPDiagnoseAdapter.h>

@implementation MPDiagnoseDemoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // 诊断日志
    [MPDiagnoseAdapter initDiagnose];

    
    CREATE_UI(
//              BUTTON_WITH_ACTION(@"测试用户切换", testUserChange)
              BUTTON_WITH_ACTION(@"执行用例检测", runAllTestCase)
              )
    
}

- (void)runAllTestCase
{
    [MPDiagnoseTestCase runAllTestCase];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        AUNoticeDialog *alert = [[AUNoticeDialog alloc] initWithTitle:@"执行结果" message:@"诊断 自动部分用例执行完毕，其余部分需要操作服务端推数据测试" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    });
}

- (void)testUserChange
{
    [MPDiagnoseTestCase testUserChange];
}

@end
