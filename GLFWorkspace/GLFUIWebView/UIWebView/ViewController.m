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

@interface ViewController ()<UITextViewDelegate>

@end

@implementation ViewController


#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"HTML5";
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithTitle:@"说明" style:UIBarButtonItemStylePlain target:self action:@selector(declareAction)];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"扫码" style:UIBarButtonItemStylePlain target:self action:@selector(scanQrCode)];
    self.navigationItem.leftBarButtonItem = leftItem;
    self.navigationItem.rightBarButtonItem = rightItem;
    
    CGRect textViewRect = CGRectMake(15, 80, kScreenWidth-30, 60);
    self.ipTextView = [[UITextView alloc] initWithFrame:textViewRect];
    self.ipTextView.text = [NSString stringWithFormat:@"http://%@:8080/", [GLFTools getIPAddress:YES]];
    self.ipTextView.delegate = self;
    [self.view addSubview:self.ipTextView];
    
    for (NSInteger i = 0; i < 2; i++) {
        CGFloat width = (kScreenWidth - 60) / 2;
        CGRect frame = CGRectMake(20 * (i % 2 + 1) + width * (i % 2), 180 + 80 * ceil(i / 2), width, 60);
        UIButton *button = [[UIButton alloc] initWithFrame:frame];
        if (i == 0) {
            [button setTitle:@"选择地址" forState:UIControlStateNormal];
        } else if (i == 1)  {
            [button setTitle:@"清除缓存" forState:UIControlStateNormal];
        } else {
            [button setTitle:@"测试" forState:UIControlStateNormal];
        }
        [button setBackgroundColor:[UIColor clearColor]];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(buttonAction1:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = i + 10;
        button.layer.cornerRadius = 5;
        button.layer.masksToBounds = YES;
        [self.view addSubview:button];
    }
    
    for (NSInteger i = 0; i < 3; i++) {
        CGFloat width = (kScreenWidth - 60) / 2;
        CGRect frame = CGRectMake(20 * (i % 2 + 1) + width * (i % 2), 100 + 80 * ceil(i / 2), width, 60);
        UIButton *button = [[UIButton alloc] initWithFrame:frame];
        if (i == 0) {
            [button setTitle:@"Test1" forState:UIControlStateNormal];
        } else if (i == 1)  {
            [button setTitle:@"Test2" forState:UIControlStateNormal];
        } else {
            [button setTitle:@"测试" forState:UIControlStateNormal];
        }
        [button setBackgroundColor:[UIColor clearColor]];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(buttonAction2:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = i + 100;
        button.layer.cornerRadius = 5;
        button.layer.masksToBounds = YES;
        [self.view addSubview:button];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

#pragma mark Events
- (void)declareAction {
    DeclareViewController *vc = [[DeclareViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)scanQrCode {
    
}

- (void)buttonAction1:(UIButton *)button {
    [self.view endEditing:YES];
    if (button.tag == 100) {
        SelectIPView *ipView = [[SelectIPView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth/4*3, kScreenHeight/4*3)];
        ipView.parentVC = self;
        [self lew_presentPopupView:ipView animation:[LewPopupViewAnimationSpring new] dismissed:^{
            NSLog(@"动画结束");
        }];
    } else if (button.tag == 101) {
        [self showStringHUD:@"清除Webview缓存" second:2];
    }
}

- (void)buttonAction2:(UIButton *)button {
    [self.view endEditing:YES];
    WebViewController *vc = [[WebViewController alloc] init];
    if (button.tag == 100) {
        vc.urlStr = @"http://112.20.237.76:8087/HealthClientStatic/HTML/tabbar/home.html";
    } else if (button.tag == 101) {
        vc.urlStr = @"http://112.20.237.76:8087/docClient/login";
    }
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    // 如果为回车则将键盘收起
    if ([text isEqualToString:@"\n"]) {
        [self.view endEditing:YES];
        if (self.ipTextView.text.length == 0) {
            return NO;
        }
        WebViewController *vc = [[WebViewController alloc] init];
        vc.urlStr = self.ipTextView.text;
        [self.navigationController pushViewController:vc animated:YES];
        return NO;
    }
    return YES;
}


@end
