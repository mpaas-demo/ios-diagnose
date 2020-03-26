//
//  MPDiagnoseTestCase.m
//  MPDiagnoseDemo
//
//  Created by yemingyu on 2019/2/18.
//  Copyright © 2019 alipay. All rights reserved.
//

#import "MPDiagnoseTestCase.h"
#import <MPDiagnosis/MPDiagnosis.h>
#import <MPDiagnosis/MPDiagnoseAdapter.h>
#import <MPMssAdapter/MPSyncInterface.h>
#import <APLog/APLog.h>

@interface APLogUser (MPTestCase)
- (NSString*)uploadLogUrl;
- (NSString*)uploadStatusUrl;
- (NSString*)currentUserId;
- (BOOL)isLogFormatAssertCheck;
- (BOOL)isCloseLogEncrypt;
@end

static NSString* currentUserId = @"MPTestCase";

@implementation MPDiagnoseTestCase

+ (void)runAllTestCase
{
    // TODO: meta.config 加到工程中才行
    [self testUrlAddressConfig];
    [self testDiagnoseSync];
//    [self testUserChange];
}

+ (void)testUrlAddressConfig
{
    // 读取 meta.config 然后和接口读出来的做对比
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"meta" ofType:@"config"];
    NSString *metaConfig = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    //    NSDictionary *metaConfig = [NSDictionary dictionaryWithContentsOfURL:[NSURL fileURLWithPath:filePath]];
    NSData *jsonData = [metaConfig dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    NSString *logGW = [dic objectForKey:@"logGW"];
    NSString *uploadLogUrl = nil;
    NSString *uploadStatusUrl = nil;
    NSString *currentUserId = nil;
    BOOL isLogFormatAssertCheck = NO;
    BOOL isCloseLogEncrypt = NO;
    APLogUser *instance = [APLogUser sharedInstance];
    if ([instance respondsToSelector:@selector(uploadLogUrl)]) {
        uploadLogUrl = [instance uploadLogUrl];
    }
    NSString *rightUploadLogUrl = [NSString stringWithFormat:@"%@/loggw/extLog.do", logGW];
    assert([uploadLogUrl isEqualToString:rightUploadLogUrl]);
    MPAdapterLog(@"MPAdapter", @"Diagnose", @"%@", @"uploadLogUrl 检测通过");
    
    if ([instance respondsToSelector:@selector(uploadStatusUrl)]) {
        uploadStatusUrl = [instance uploadStatusUrl];
    }
    NSString *rightUploadStatusUrl = [NSString stringWithFormat:@"%@/loggw/report_diangosis_upload_status.htm", logGW];
    assert([uploadStatusUrl isEqualToString:rightUploadStatusUrl]);
    MPAdapterLog(@"MPAdapter", @"Diagnose", @"%@", @"uploadStatusUrl 检测通过");
    
    if ([instance respondsToSelector:@selector(currentUserId)]) {
        currentUserId = [instance currentUserId];
    }
    MPAdapterLog(@"MPAdapter", @"Diagnose", @"%@", @"注意 currentUserId 至少 6 个字节");
    assert(currentUserId && currentUserId.length > 5);
    MPAdapterLog(@"MPAdapter", @"Diagnose", @"%@", @"currentUserId 检测通过");
    
    // 不配置情况为关闭 assert
    if ([instance respondsToSelector:@selector(isLogFormatAssertCheck)]) {
        isLogFormatAssertCheck = [instance isLogFormatAssertCheck];
    }
    assert(NO == isLogFormatAssertCheck);
    MPAdapterLog(@"MPAdapter", @"Diagnose", @"%@", @"isLogFormatAssertCheck 检测通过");
    
    // 不配置情况为开启加密
    if ([instance respondsToSelector:@selector(isCloseLogEncrypt)]) {
        isCloseLogEncrypt = [instance isCloseLogEncrypt];
    }
    assert(NO == isCloseLogEncrypt);
    MPAdapterLog(@"MPAdapter", @"Diagnose", @"%@", @"isCloseLogEncrypt 检测通过");
    
    APLogInfo(@"MPAdapter", @"%@", @"Diagnose 自定义日志");
}

+ (void)testDiagnoseSync
{
    [MPDiagnoseAdapter initDiagnose];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        MPSyncNetConnectType connectStatus = [MPSyncInterface connectStatus];
        assert(connectStatus == MPSyncNetConnectTypeConnected);
        MPAdapterLog(@"MPAdapter", @"Diagnose", @"%@", @"诊断 Sync初始化 连接成功 检测通过");
    });
}

+ (void)testUserChange
{
    currentUserId = @"MPTestCaseChange";
    [MPDiagnoseAdapter userChange];
    for (int i = 0; i < 200; i++) {
        APLogInfo(@"MPAdapter", @"%@", @"Diagnose UserChange 自定义日志");
    }
}

+ (NSString *)currentUserId
{
    return currentUserId;
}

#pragma mark - MPLog

static void MPAdapterLog(NSString *tag, NSString *componentTag, NSString *format, ...)
{
    if (format == nil) {
        return;
    }
    
    va_list args;
    va_start(args, format);
    NSString *logString = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    
    NSString *formatString = [[NSString alloc] initWithFormat:@"[%@][%@]: %@",
                              tag,
                              componentTag,
                              logString];
#if DEBUG
    NSLog(@"%@", formatString);
#endif
}

@end
