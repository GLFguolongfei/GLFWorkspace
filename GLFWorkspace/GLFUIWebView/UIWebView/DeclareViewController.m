//
//  DeclareViewController.m
//  UIWebView
//
//  Created by guolongfei on 2018/1/31.
//  Copyright © 2018年 GuoLongfei. All rights reserved.
//

#import "DeclareViewController.h"

@interface DeclareViewController ()

@end

@implementation DeclareViewController


#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"说明";

    NSMutableString *str = [[NSMutableString alloc] init];
    [str appendString:@"家庭医生与健康小驿用的是同一个医生端和后台 \n"];
    [str appendString:@"http://192.168.1.59:8083/            上海测试服 \n"];
    [str appendString:@"http://61.177.174.10:8082/           芜湖测试服 \n"];
    [str appendString:@"http://www.z-health.cn:8088/         芜湖正式服 \n"];
    [str appendString:@" \n"];
    [str appendString:@"家庭医生居民端 \n"];
    [str appendString:@"http://localhost:8080/whserver/yhwApp/home-page!homeWelcome.action      判断页 \n"];
    [str appendString:@"http://localhost:8080/whserver/yhwApp/home-page!showHomeIndex.action    首页 \n"];
    [str appendString:@"家庭医生医生端 \n"];
    [str appendString:@"http://localhost:8080/whserver/appDoc/doc-login!loginIndex.action \n"];
    [str appendString:@" \n"];
    [str appendString:@"健康小驿 \n"];
    [str appendString:@"http://localhost:8080/whserver/healthy-home-v2!myarchives.action \n"];
    [str appendString:@"健康大本营（现已不用，现在使用由健康大本营改版来的健康小驿） \n"];
    [str appendString:@"http://localhost:8080/whserver/healthy-home-v2!home.action \n"];
    [str appendString:@" \n"];
    [str appendString:@"后台 \n"];
    [str appendString:@"http://localhost:8080/whserver/login.action \n"];
    [str appendString:@" \n"];
    [str appendString:@"邮电视频问诊（Http/Https） \n"];
    [str appendString:@"http://ydky.z-health.cn:8084/RemoteInquiry/user/Login \n"];
    [str appendString:@"https://ydky.z-health.cn:5081/RemoteInquiry/user/Login \n"];
    [str appendString:@" \n"];
    [str appendString:@" \n"];
    [str appendString:@" \n"];
    [str appendString:@" \n"];

    CGRect rect = CGRectMake(15, 10, kScreenWidth - 30, kScreenHeight - 15);
    UITextView *textView = [[UITextView alloc] initWithFrame:rect];
    textView.text = str;
    textView.editable = NO;
    textView.font = [UIFont systemFontOfSize:14];
    [self.view addSubview:textView];
}


@end
