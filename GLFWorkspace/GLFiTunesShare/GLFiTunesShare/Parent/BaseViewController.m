//
//  BaseViewController.m
//  GLFiTunesShare
//
//  Created by guolongfei on 2017/10/17.
//  Copyright © 2017年 GuoLongfei. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController ()

@end

@implementation BaseViewController


#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // 不需要添加额外的滚动区域
    self.automaticallyAdjustsScrollViewInsets = NO;
    
}

#pragma mark HUD透明指示器
// 功能:显示hud
- (void)showHUD {
    [self hideAllHUD];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.yOffset = 64;
}

- (void)showHUDsecond:(int)aSecond {
    [self hideAllHUD];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.yOffset = 64;
    [self performSelector:@selector(hideHUD) withObject:nil afterDelay:aSecond];
}

// 功能:显示字符串hud
- (void)showHUD:(NSString *)aMessage {
    [self hideAllHUD];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = aMessage;
    hud.yOffset = 64;
}

- (void)showHUD:(NSString *)aMessage animated:(BOOL)animated {
    [self hideAllHUD];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:animated];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = aMessage;
    hud.yOffset = 64;
}

- (void)showStringHUD:(NSString *)aMessage second:(int)aSecond {
    [self hideAllHUD];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.labelText = aMessage;
    hud.yOffset = 64;
    [self performSelector:@selector(hideHUD) withObject:nil afterDelay:aSecond];
}

// 功能:隐藏hud
- (void)hideHUD {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

- (void)hideHUD:(BOOL)animated {
    [MBProgressHUD hideHUDForView:self.view animated:animated];
}

- (void)hideAllHUD {
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}


@end
