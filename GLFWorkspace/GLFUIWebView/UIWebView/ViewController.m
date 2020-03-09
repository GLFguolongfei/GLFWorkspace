//
//  ViewController.m
//  UIWebView
//
//  Created by guolongfei on 2017/10/27.
//  Copyright © 2017年 GuoLongfei. All rights reserved.
//

#import "ViewController.h"
// VCs
#import "WebViewController.h"
#import "DeclareViewController.h"
// Views
#import "SelectIPView.h"
// Tools
#import "LewPopupViewController.h"

@interface ViewController () 

@end

@implementation ViewController


#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"HTML5";
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithTitle:@"说明" style:UIBarButtonItemStylePlain target:self action:@selector(declareAction)];
    self.navigationItem.leftBarButtonItem = leftItem;

    self.topButton1.layer.cornerRadius = 20;
    self.topButton1.layer.masksToBounds = YES;
    self.topButton2.layer.cornerRadius = 20;
    self.topButton2.layer.masksToBounds = YES;
    self.topButton3.layer.cornerRadius = 20;
    self.topButton3.layer.masksToBounds = YES;
    self.button1.layer.cornerRadius = 20;
    self.button1.layer.masksToBounds = YES;
    self.button2.layer.cornerRadius = 20;
    self.button2.layer.masksToBounds = YES;
    self.button3.layer.cornerRadius = 20;
    self.button3.layer.masksToBounds = YES;
    self.button4.layer.cornerRadius = 20;
    self.button4.layer.masksToBounds = YES;
    self.button5.layer.cornerRadius = 20;
    self.button5.layer.masksToBounds = YES;
    self.testButton.layer.cornerRadius = 20;
    self.testButton.layer.masksToBounds = YES;
    self.clearCache.layer.cornerRadius = 20;
    self.clearCache.layer.masksToBounds = YES;
    
    [self resetAction:nil];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

#pragma mark 说明
- (void)declareAction {
    DeclareViewController *vc = [[DeclareViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark 网址操作
- (IBAction)selectIPAction:(id)sender {
    [self.view endEditing:YES];
    SelectIPView *ipView = [[SelectIPView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth/4*3, kScreenHeight/4*3)];
    ipView.parentVC = self;
    [self lew_presentPopupView:ipView animation:[LewPopupViewAnimationSpring new] dismissed:^{
        NSLog(@"动画结束");
    }];
}

- (IBAction)goAction:(id)sender {
    [self.view endEditing:YES];
    if (self.ipTextView.text.length == 0) {
        return;
    }    
    WebViewController *vc = [[WebViewController alloc] init];
    vc.urlStr = self.ipTextView.text;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)resetAction:(id)sender {
    [self.view endEditing:YES];
    NSString *ipAdress = [GLFTools getIPAddress:YES];
    self.ipTextView.text = [NSString stringWithFormat:@"http://%@:8080/", ipAdress];
}

#pragma mark 各个项目
// 家庭医生居民版（沭阳家庭医生）
- (IBAction)buttonAction1:(id)sender {
    WebViewController *vc = [[WebViewController alloc] init];
    vc.urlStr = @"http://112.20.237.76:8087/HealthClientStatic/HTML/tabbar/home.html";
    [self.navigationController pushViewController:vc animated:YES];
}

// 家庭医生医生版（沭阳家庭医生）
- (IBAction)buttonAction2:(id)sender {
    WebViewController *vc = [[WebViewController alloc] init];
    vc.urlStr = @"http://112.20.237.76:8087/docClient/login";
    [self.navigationController pushViewController:vc animated:YES];
}

// 健康大本营（新）
- (IBAction)buttonAction3:(id)sender {
    WebViewController *vc = [[WebViewController alloc] init];
    vc.urlStr = @"http://61.177.174.10:8082/whserver/healthy-home-v2!myarchives.action";
    [self.navigationController pushViewController:vc animated:YES];
}

// 健康大本营（旧）
- (IBAction)buttonAction4:(id)sender {
    WebViewController *vc = [[WebViewController alloc] init];
    vc.urlStr = @"http://61.177.174.10:8082/whserver/healthy-home-v2!home.action";
    [self.navigationController pushViewController:vc animated:YES];
}

// 健康小驿
- (IBAction)buttonAction5:(id)sender {
    WebViewController *vc = [[WebViewController alloc] init];
    vc.urlStr = @"http://61.177.174.10:80/HealthHotel/HTML/tabbar/home.html";
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark 特殊
// 测试
- (IBAction)testAction:(id)sender {
    WebViewController *vc = [[WebViewController alloc] init];
    vc.urlStr = @"http://www.baidu.com";
    [self.navigationController pushViewController:vc animated:YES];
}

// 清除Webview缓存
- (IBAction)clearCache:(id)sender {
    
}


@end
