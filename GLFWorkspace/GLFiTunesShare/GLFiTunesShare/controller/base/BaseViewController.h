//
//  BaseViewController.h
//  GLFiTunesShare
//
//  Created by guolongfei on 2017/10/17.
//  Copyright © 2017年 GuoLongfei. All rights reserved.
//

#import <UIKit/UIKit.h>

// --- 父视图控制器
@interface BaseViewController : UIViewController

#pragma mark HUD透明指示器
// 功能:显示hud
- (void)showHUD;
- (void)showHUDsecond:(int)aSecond;
// 功能:显示字符串hud
- (void)showHUD:(NSString *)aMessage;
- (void)showHUD:(NSString *)aMessage animated:(BOOL)animated;
- (void)showStringHUD:(NSString *)aMessage second:(int)aSecond;
// 功能:隐藏hud
- (void)hideHUD;
- (void)hideHUD:(BOOL)animated;
- (void)hideAllHUD;
#pragma mark 是否可以记录
- (void)canRecord:(BOOL)isYes;

- (void)setupEmitter;

@end
