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

// 是否可以隐藏导航栏、工具栏
@property (nonatomic, assign) BOOL canHiddenNaviBar;
@property (nonatomic, assign) BOOL canHiddenToolBar;

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
#pragma mark 雪花飞舞
- (void)setupEmitter1;
- (void)setupEmitter2;
- (void)removeEmitter;
#pragma mark 设置标题
- (void)setVCTitle:(NSString *)title;
- (void)reSetVCTitle;

@end
