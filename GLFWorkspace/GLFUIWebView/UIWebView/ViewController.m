//
//  ViewController.m
//  UIWebView
//
//  Created by guolongfei on 2017/10/27.
//  Copyright © 2017年 GuoLongfei. All rights reserved.
//

#import "ViewController.h"
#import "WebViewController.h"
#import "SelectIPView.h"
#import "LewPopupViewController.h"

@interface ViewController () 

@end

@implementation ViewController


#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"HTML5";
    
    // // 正式服地址（芜湖）
    // http://www.z-health.cn:8088
    // // 上海测试服地址
    // http://192.168.1.59:8090
    // http://localhost:8080/whserver/healthy-home-v2!home.action 健康大本营
    // http://localhost:8080/whserver/home-page!homeWelcome.action 城市令家庭医生 居民端(健康大本营下面"医生"点进去就是这个)
    // http://localhost:8080/whserver/doc-login!loginIndex.action 健康1+1家庭医生 医生端

    [self resetAction:nil];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (IBAction)selectIPAction:(id)sender {
    [self.view endEditing:YES];
    SelectIPView *ipView = [[SelectIPView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth/3*2, kScreenHeight/3*2)];
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
    vc.type = 0;
    vc.urlStr = self.ipTextView.text;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)resetAction:(id)sender {
    [self.view endEditing:YES];
    NSString *ipAdress = [GLFTools getIPAddress:YES];
    self.ipTextView.text = [NSString stringWithFormat:@"http://%@:8080/", ipAdress];
}

- (IBAction)buttonAction1:(id)sender {
    // 健康大本营
    WebViewController *vc = [[WebViewController alloc] init];
    vc.type = 1;
    vc.urlStr = @"http://www.z-health.cn:8088/whserver/healthy-home-v2!home.action";
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)buttonAction2:(id)sender {
    // 城市令家庭医生 居民端
    WebViewController *vc = [[WebViewController alloc] init];
    vc.type = 2;
    vc.urlStr = @"http://192.168.1.14:8080/whserver/home-page!homeWelcome.action"; 
//    vc.urlStr = @"http://www.z-health.cn:8088/whserver/home-page!homeWelcome.action";
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)buttonAction3:(id)sender {
    // 健康1+1家庭医生 医生端
    WebViewController *vc = [[WebViewController alloc] init];
    vc.type = 3;
    vc.urlStr = @"http://www.z-health.cn:8088/whserver/doc-login!loginIndex.action";
    [self.navigationController pushViewController:vc animated:YES];
}


@end
