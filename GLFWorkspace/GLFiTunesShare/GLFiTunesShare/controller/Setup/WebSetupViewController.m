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
    [self.switch1 setOn:xuanfu.integerValue animated:YES];
    [self.switch2 setOn:img.integerValue animated:YES];
    [self.switch3 setOn:font.integerValue animated:YES];
    [self.switch4 setOn:border.integerValue animated:YES];
    [self.switch5 setOn:mute.integerValue animated:YES];
    [self.switch6 setOn:min.integerValue animated:YES];
    
    gestureView = [[UIView alloc] initWithFrame:CGRectMake(100, -20, kScreenWidth-200, 64)];
    gestureView.backgroundColor = [UIColor clearColor];
    [self.navigationController.navigationBar addSubview:gestureView];

    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] init];
    tapGesture.numberOfTapsRequired = 2;
    tapGesture.numberOfTouchesRequired = 1;
    [tapGesture addTarget:self action:@selector(setState)];
    [gestureView addGestureRecognizer:tapGesture];
}

- (void)viewWillAppear:(BOOL)animated {
    // 放在最上面,否则点击事件没法触发
    [self.navigationController.navigationBar bringSubviewToFront:gestureView];
}

- (void)setState {
    self.switch6.hidden = !self.switch6.hidden;
    self.label6.hidden = !self.label6.hidden;
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
    } else {
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:kVoiceMute];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (IBAction)switchAction6:(id)sender {
    UISwitch *sw = (UISwitch *)sender;
    if (sw.on) {
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:kVoiceMin];
    } else {
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:kVoiceMin];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
