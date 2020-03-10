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
    NSString *tabbarHidden = [userDefaults objectForKey:@"tabbarHidden"];
    [self.switch1 setOn:tabbarHidden.integerValue animated:YES];
}

- (IBAction)switchAction1:(id)sender {
    UISwitch *sw = (UISwitch *)sender;
    if (sw.on) {
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"tabbarHidden"];
    } else {
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"tabbarHidden"];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}


@end
