//
//  SetupViewController.m
//  UIWebView
//
//  Created by guolongfei on 2020/3/10.
//  Copyright © 2020 GuoLongfei. All rights reserved.
//

#import "SetupViewController.h"

@interface SetupViewController ()
{
    UIView *gestureView;
    BOOL isOC; // is Other Control
}
@end

@implementation SetupViewController


#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"设置";

    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *tabbarHidden = [userDefaults objectForKey:kNavigationBarHidden];
    NSString *isHaveBridge = [userDefaults objectForKey:kHaveBridge];
    NSString *isNORecord = [userDefaults objectForKey:kNORecord];
    [self.switch1 setOn:tabbarHidden.integerValue animated:YES];
    [self.switch2 setOn:isHaveBridge.integerValue animated:YES];
    [self.switch4 setOn:isNORecord.integerValue animated:YES];

    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] init];
    tapGesture.numberOfTapsRequired = 3;
    tapGesture.numberOfTouchesRequired = 3;
    [tapGesture addTarget:self action:@selector(tapGesture:)];
    [self.view addGestureRecognizer:tapGesture];
    
    NSString *type = [userDefaults objectForKey:kWebViewType];
    NSString *title = @"UIWebView";
    if (type.integerValue == 1) {
        title = @"UIWebView";
    } else if (type.integerValue == 2) {
        title = @"WKWebView";
    }
    [self.webviewButton setTitle:title forState:UIControlStateNormal];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    isOC = false;
    // 导航栏bg
    gestureView = [[UIView alloc] initWithFrame:CGRectMake((kScreenWidth - 150) / 2, -20, 150, 64)];
    gestureView.backgroundColor = [UIColor clearColor];
    [self.navigationController.navigationBar addSubview:gestureView];

    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] init];
    tapGesture.numberOfTapsRequired = 2;
    tapGesture.numberOfTouchesRequired = 1;
    [tapGesture addTarget:self action:@selector(setState)];
    [gestureView addGestureRecognizer:tapGesture];
    
    // 放在最上面,否则点击事件没法触发
    [self.navigationController.navigationBar bringSubviewToFront:gestureView];
}

- (void)setState {
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"隐藏功能" message:@"惊不惊喜！意不意外！！！" preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alertVC addAction:cancelAction];
    
    NSString *title = @"其它控制";
    if (isOC) {
        title = @"Other Control";
    }
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (isOC) {
            self.switch4.hidden = NO;
            self.label4.hidden = NO;
        }
    }];
    [alertVC addAction:okAction];
    
    [self presentViewController:alertVC animated:YES completion:nil];
}

- (void)tapGesture:(UITapGestureRecognizer *)gesture {
    isOC = YES;
}

// 隐藏导航栏
- (IBAction)switchAction1:(id)sender {
    UISwitch *sw = (UISwitch *)sender;
    if (sw.on) {
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:kNavigationBarHidden];
    } else {
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:kNavigationBarHidden];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

// 添加Bridge
- (IBAction)switchAction2:(id)sender {
    UISwitch *sw = (UISwitch *)sender;
    if (sw.on) {
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:kHaveBridge];
    } else {
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:kHaveBridge];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

// 无痕浏览
- (IBAction)switchAction4:(id)sender {
    UISwitch *sw = (UISwitch *)sender;
    if (sw.on) {
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:kNORecord];
    } else {
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:kNORecord];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (IBAction)webviewAction:(id)sender {
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"百度展现方式" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alertVC addAction:cancelAction];
    
    UIAlertAction *okAction1 = [UIAlertAction actionWithTitle:@"UIWebView" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:kWebViewType];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self.webviewButton setTitle:@"UIWebView" forState:UIControlStateNormal];
    }];
    [alertVC addAction:okAction1];
    
    UIAlertAction *okAction2 = [UIAlertAction actionWithTitle:@"WKWebView" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[NSUserDefaults standardUserDefaults] setObject:@"2" forKey:kWebViewType];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self.webviewButton setTitle:@"WKWebView" forState:UIControlStateNormal];
    }];
    [alertVC addAction:okAction2];
    
    [self presentViewController:alertVC animated:YES completion:nil];
}


@end
