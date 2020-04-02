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
    self.canHiddenNaviBar = NO;
    self.canHiddenToolBar = NO;
}

// 运动开始时执行
- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    // 这里只处理摇晃事件
    if (motion == UIEventSubtypeMotionShake) {
        NSLog(@"motion begin: %ld %@", motion, event);
        if (self.navigationController.navigationBar.hidden == YES) {
            if (self.canHiddenNaviBar) {
                [self.navigationController setNavigationBarHidden:NO animated:YES];
                NSDictionary *dict = @{@"isHidden": @"0"};
                [[NSNotificationCenter defaultCenter] postNotificationName:@"NaviBarChange" object:self userInfo:dict];
            }
            if (self.canHiddenToolBar) {
                [self.navigationController setToolbarHidden:NO animated:YES];
                NSDictionary *dict = @{@"isHidden": @"0"};
                [[NSNotificationCenter defaultCenter] postNotificationName:@"ToolBarChange" object:self userInfo:dict];
            }
        } else {
            if (self.canHiddenNaviBar) {
                [self.navigationController setNavigationBarHidden:YES animated:YES];
                NSDictionary *dict = @{@"isHidden": @"1"};
                [[NSNotificationCenter defaultCenter] postNotificationName:@"NaviBarChange" object:self userInfo:dict];
            }
            if (self.canHiddenToolBar) {
                [self.navigationController setToolbarHidden:YES animated:YES];
                NSDictionary *dict = @{@"isHidden": @"1"};
                [[NSNotificationCenter defaultCenter] postNotificationName:@"ToolBarChange" object:self userInfo:dict];
            }
        }
    }
}

// 运动结束后执行
- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    NSLog(@"motion end: %ld %@", motion, event);
}

// 运动被意外取消时执行
- (void)motionCancelled:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    NSLog(@"motion cancel: %ld %@", motion, event);
}


#pragma mark hud
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
