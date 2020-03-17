//
//  WebSetupViewController.m
//  GLFiTunesShare
//
//  Created by guolongfei on 2017/11/4.
//  Copyright © 2017年 GuoLongfei. All rights reserved.
//

#import "WebSetupViewController.h"

@interface WebSetupViewController ()
{
    UIView *gestureView;
    BOOL isSuccess;
    BOOL isSu;
}
@end

@implementation WebSetupViewController


#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"设置内容显示";

    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *xuanfu = [userDefaults objectForKey:kWebContentXuanFu];
    NSString *img = [userDefaults objectForKey:kWebContentImg];
    NSString *font = [userDefaults objectForKey:kWebContentFont];
    NSString *border = [userDefaults objectForKey:kWebContentBorder];
    NSString *mute = [userDefaults objectForKey:kVoiceMute];
    NSString *min = [userDefaults objectForKey:kVoiceMin];
    NSString *hidden = [userDefaults objectForKey:kContentHidden];
    NSString *record = [userDefaults objectForKey:kRecord];
    [self.switch1 setOn:xuanfu.integerValue animated:YES];
    [self.switch2 setOn:img.integerValue animated:YES];
    [self.switch3 setOn:font.integerValue animated:YES];
    [self.switch4 setOn:border.integerValue animated:YES];
    [self.switch5 setOn:mute.integerValue animated:YES];
    [self.switch6 setOn:min.integerValue animated:YES];
    [self.switch7 setOn:hidden.integerValue animated:YES];
    [self.switch8 setOn:record.integerValue animated:YES];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] init];
    tapGesture.numberOfTapsRequired = 3;
    tapGesture.numberOfTouchesRequired = 3;
    [tapGesture addTarget:self action:@selector(tapGesture:)];
    [self.view addGestureRecognizer:tapGesture];
}

- (void)viewWillAppear:(BOOL)animated {
    isSu = false;
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

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [gestureView removeFromSuperview];
}

- (void)setState {
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"隐藏功能" message:@"惊不惊喜！意不意外！！！" preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alertVC addAction:cancelAction];
    
    NSString *title = @"其它控制";
    if (isSu) {
        title = @"Other Control";
    }
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.switch5.hidden = !self.switch6.hidden;
        self.label5.hidden = !self.label6.hidden;
        if (isSu) {
            self.switch6.hidden = !self.switch6.hidden;
            self.label6.hidden = !self.label6.hidden;
            self.switch7.hidden = !self.switch7.hidden;
            self.label7.hidden = !self.label7.hidden;
            self.switch8.hidden = !self.switch8.hidden;
            self.label8.hidden = !self.label8.hidden;
        }
    }];
    [alertVC addAction:okAction];
    
    [self presentViewController:alertVC animated:YES completion:nil];
}

- (void)tapGesture:(UITapGestureRecognizer *)gesture {
    isSu = YES;
}

- (IBAction)switchAction1:(id)sender {
    UISwitch *sw = (UISwitch *)sender;
    if (sw.on) {
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:kWebContentXuanFu];
    } else {
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:kWebContentXuanFu];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (IBAction)switchAction2:(id)sender {
    UISwitch *sw = (UISwitch *)sender;
    if (sw.on) {
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:kWebContentImg];
    } else {
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:kWebContentImg];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (IBAction)switchAction3:(id)sender {
    UISwitch *sw = (UISwitch *)sender;
    if (sw.on) {
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:kWebContentFont];
    } else {
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:kWebContentFont];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (IBAction)switchAction4:(id)sender {
    UISwitch *sw = (UISwitch *)sender;
    if (sw.on) {
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:kWebContentBorder];
    } else {
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:kWebContentBorder];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (IBAction)switchAction5:(id)sender {
    UISwitch *sw = (UISwitch *)sender;
    if (sw.on) {
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:kVoiceMute];
        if (self.switch6.on) {
            self.switch6.on = NO;
            [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:kVoiceMin];
        }
    } else {
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:kVoiceMute];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (IBAction)switchAction6:(id)sender {
    UISwitch *sw = (UISwitch *)sender;
    if (sw.on) {
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:kVoiceMin];
        if (self.switch5.on) {
            self.switch5.on = NO;
            [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:kVoiceMute];
        }
    } else {
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:kVoiceMin];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (IBAction)switchAction7:(id)sender {
    UISwitch *sw = (UISwitch *)sender;
    if (sw.on) {
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:kContentHidden];
    } else {
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:kContentHidden];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (IBAction)switchAction8:(id)sender {
    DocumentManager *manager = [DocumentManager sharedDocumentManager];
    UISwitch *sw = (UISwitch *)sender;
    if (sw.on) {
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:kRecord];
        [self showStringHUD:@"慎重打开, 很浪费空间的！！！" second:1.5];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [manager startRecording];
        });
    } else {
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:kRecord];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [manager stopRecording];
        });
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}


@end
