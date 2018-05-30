//
//  WebSetupViewController.m
//  GLFiTunesShare
//
//  Created by guolongfei on 2017/11/4.
//  Copyright © 2017年 GuoLongfei. All rights reserved.
//

#import "WebSetupViewController.h"

@interface WebSetupViewController ()

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
    [self.switch1 setOn:xuanfu.integerValue animated:YES];
    [self.switch2 setOn:img.integerValue animated:YES];
    [self.switch3 setOn:font.integerValue animated:YES];
    [self.switch4 setOn:border.integerValue animated:YES];
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


@end
