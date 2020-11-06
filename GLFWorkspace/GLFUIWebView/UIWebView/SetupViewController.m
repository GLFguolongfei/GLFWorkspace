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
    NSString *tabbarHidden = [userDefaults objectForKey:kTabbarHidden];
    NSString *isHaveBridge = [userDefaults objectForKey:kHaveBridge];
    NSString *isNORecord = [userDefaults objectForKey:kNORecord];
    [self.switch1 setOn:tabbarHidden.integerValue animated:YES];
    [self.switch2 setOn:isHaveBridge.integerValue animated:YES];
    [self.switch3 setOn:isNORecord.integerValue animated:YES];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] init];
    tapGesture.numberOfTapsRequired = 3;
    tapGesture.numberOfTouchesRequired = 3;
    [tapGesture addTarget:self action:@selector(tapGesture:)];
    [self.view addGestureRecognizer:tapGesture];
    
    NSString *type = [userDefaults objectForKey:kWebViewType];
    if (type.integerValue == 1) {
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"UIWebView" style:UIBarButtonItemStylePlain target:self action:@selector(buttonAction)];
        self.navigationItem.rightBarButtonItem = item;
    } else if (type.integerValue == 2) {
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"WKWebView" style:UIBarButtonItemStylePlain target:self action:@selector(buttonAction)];
        self.navigationItem.rightBarButtonItem = item;
    } else if (type.integerValue == 3) {
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"SFSafariViewController" style:UIBarButtonItemStylePlain target:self action:@selector(buttonAction)];
        self.navigationItem.rightBarButtonItem = item;
    }
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
            self.switch3.hidden = !self.switch3.hidden;
            self.label3.hidden = !self.label3.hidden;
        }
    }];
    [alertVC addAction:okAction];
    
    [self presentViewController:alertVC animated:YES completion:nil];
}

- (void)tapGesture:(UITapGestureRecognizer *)gesture {
    isOC = YES;
}

- (void)buttonAction {
    [self.view endEditing:YES];

    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"百度展现方式" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alertVC addAction:cancelAction];
    
    UIAlertAction *okAction1 = [UIAlertAction actionWithTitle:@"UIWebView" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:kWebViewType];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }];
    [alertVC addAction:okAction1];
    
    UIAlertAction *okAction2 = [UIAlertAction actionWithTitle:@"WKWebView" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[NSUserDefaults standardUserDefaults] setObject:@"2" forKey:kWebViewType];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }];
    [alertVC addAction:okAction2];
    
    UIAlertAction *okAction3 = [UIAlertAction actionWithTitle:@"SFSafariViewController" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[NSUserDefaults standardUserDefaults] setObject:@"3" forKey:kWebViewType];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }];
    [alertVC addAction:okAction3];
    
    [self presentViewController:alertVC animated:YES completion:nil];
}

- (IBAction)switchAction1:(id)sender {
    UISwitch *sw = (UISwitch *)sender;
    if (sw.on) {
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:kTabbarHidden];
    } else {
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:kTabbarHidden];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (IBAction)switchAction2:(id)sender {
    UISwitch *sw = (UISwitch *)sender;
    if (sw.on) {
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:kHaveBridge];
    } else {
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:kHaveBridge];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (IBAction)switchAction3:(id)sender {
    UISwitch *sw = (UISwitch *)sender;
    if (sw.on) {
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:kNORecord];
    } else {
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:kNORecord];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}


@end
