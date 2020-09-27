//
//  SetupViewController.m
//  UIWebView
//
//  Created by guolongfei on 2020/3/10.
//  Copyright © 2020 GuoLongfei. All rights reserved.
//

#import "SetupViewController.h"

@interface SetupViewController ()

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
    [self.switch1 setOn:tabbarHidden.integerValue animated:YES];
    [self.switch2 setOn:isHaveBridge.integerValue animated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
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

- (IBAction)switchAction4:(id)sender {
    UISwitch *sw = (UISwitch *)sender;
    if (sw.on) {
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:kContentHidden];
    } else {
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:kContentHidden];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}


@end
