//
//  BaseViewController.m
//  GLFiTunesShare
//
//  Created by guolongfei on 2017/10/17.
//  Copyright © 2017年 GuoLongfei. All rights reserved.
//

#import "BaseViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface BaseViewController ()
{
    CAEmitterLayer *colorBallLayer;
    CAEmitterLayer *snowEmitterLayer;
} 
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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self reSetVCTitle];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *record = [userDefaults objectForKey:kRecord];
    DocumentManager *manager = [DocumentManager sharedDocumentManager];
//    [manager setVideosImage:5];
//    [manager setScaleImage:3];
    if ([record isEqualToString:@"1"]) {
        if (![manager isRecording]) {
            [manager startRecording];
        }
    } else {
        if ([manager isRecording]) {
            [manager stopRecording];
        }
    }
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

- (void)didReceiveMemoryWarning {
    [self showStringHUD:@"收到内存警告" second:1];
    NSLog(@"收到内存警告");
}

#pragma mark HUD指示器
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

#pragma mark 发散光源
- (void)setupEmitter1 {
    // 1.设置 CAEmitterLayer
    colorBallLayer = [CAEmitterLayer layer];
    // 发射源的尺寸大小
    colorBallLayer.emitterSize = self.view.frame.size;
    // 发射源的形状
    colorBallLayer.emitterShape = kCAEmitterLayerPoint;
    // 发射模式
    colorBallLayer.emitterMode = kCAEmitterLayerPoints;
    // 粒子发射形状的中心点
    colorBallLayer.emitterPosition = CGPointMake(self.view.layer.bounds.size.width, 0.f);
    [self.view.layer addSublayer:colorBallLayer];

    // 2.配置 CAEmitterCell
    CAEmitterCell *colorBallCell = [CAEmitterCell emitterCell];
    // 粒子名称
    colorBallCell.name = @"colorBallCell";
    // 粒子产生率,默认为 0
    colorBallCell.birthRate = 20.f;
    // 粒子生命周期
    colorBallCell.lifetime = 10.f;
    // 粒子速度,默认为 0
    colorBallCell.velocity = 40.f;
    // 粒子速度平均量
    colorBallCell.velocityRange = 100.f;
    // x,y,z 方向上的加速度分量, 三者默认为 0
    colorBallCell.yAcceleration = 15.f;
    // 指定纬度, 纬度角代表在 x-z轴平面坐标系中与 x 轴之间的夹角默认为 0
    colorBallCell.emissionLongitude = M_PI;// 向左
    // 发射角度范围,默认为 0, 以锥形分布开的发射角, 角度为弧度制.粒子均匀分布在这个锥形范围内;
    colorBallCell.emissionRange = M_PI_4;// 围绕 x 轴向左90 度
    // 缩放比例, 默认 1
    colorBallCell.scale = 0.2;
    // 缩放比例范围, 默认是 0
    colorBallCell.scaleRange = 0.1;
    // 在生命周期内的缩放速度, 默认是 0
    colorBallCell.scaleSpeed = 0.02;
    // 粒子的内容, 为 CGImageRef 的对象
    colorBallCell.contents = (id)[[UIImage imageNamed:@"circle_white"] CGImage];
    // 颜色
    colorBallCell.color = [[UIColor colorWithRed:0.5 green:0.f blue:0.5 alpha:1.f] CGColor];
    // 粒子颜色 red, green, blue, alpha 能改变的范围, 默认 0
    colorBallCell.redRange = 1.f;
    colorBallCell.greenRange = 1.f;
    colorBallCell.alphaRange = 0.8f;
    // 粒子颜色 red, green, blue, alpha 在生命周期内的改变速度, 默认 0
    colorBallCell.blueSpeed = 1.f;
    colorBallCell.alphaSpeed = -0.1f;
    // 添加
    colorBallLayer.emitterCells = @[colorBallCell];
}

- (void)setupEmitter2 {
    // 1.设置 CAEmitterLayer
    snowEmitterLayer = [CAEmitterLayer layer];
    snowEmitterLayer.emitterPosition = CGPointMake(100, -30);
    snowEmitterLayer.emitterSize = CGSizeMake(self.view.bounds.size.width * 2, 0);
    snowEmitterLayer.emitterMode = kCAEmitterLayerOutline;
    snowEmitterLayer.emitterShape = kCAEmitterLayerLine;
    // 阴影的 不透明度
    snowEmitterLayer.shadowOpacity = 1;
    // 阴影化开的程度（就像墨水滴在宣纸上化开那样）
    snowEmitterLayer.shadowRadius = 8;
    // 阴影的偏移量
    snowEmitterLayer.shadowOffset = CGSizeMake(3, 3);
    // 阴影的颜色
    snowEmitterLayer.shadowColor = [[UIColor whiteColor] CGColor];
    [self.view.layer addSublayer:snowEmitterLayer];

    // 2.配置 CAEmitterCell
    CAEmitterCell *snowCell = [CAEmitterCell emitterCell];
    snowCell.contents = (__bridge id)[UIImage imageNamed:@"樱花瓣2"].CGImage;
    // 花瓣缩放比例
    snowCell.scale = 0.02;
    snowCell.scaleRange = 0.5;
    // 每秒产生的花瓣数量
    snowCell.birthRate = 7;
    snowCell.lifetime = 80;
    // 每秒花瓣变透明的速度
    snowCell.alphaSpeed = -0.01;
    // 秒速“五”厘米～～
    snowCell.velocity = 40;
    snowCell.velocityRange = 60;
    // 花瓣掉落的角度范围
    snowCell.emissionRange = M_PI;
    // 花瓣旋转的速度
    snowCell.spin = M_PI_4;
    // 添加    
    snowEmitterLayer.emitterCells = [NSArray arrayWithObject:snowCell];
}

- (void)removeEmitter {
    [colorBallLayer removeFromSuperlayer];
    [snowEmitterLayer removeFromSuperlayer];
}

#pragma mark 设置标题
- (void)setVCTitle:(NSString *)title {
    self.title = title;
    [self reSetVCTitle];
}

- (void)reSetVCTitle {
    DocumentManager *manager = [DocumentManager sharedDocumentManager];
    if ([manager isRecording]) {
        if (manager.isUseBackFacingCamera) {
            NSString *title = [self.title stringByReplacingOccurrencesOfString:@"[" withString:@""];
            if (![title hasSuffix:@"]"]) {
                self.title = [NSString stringWithFormat:@"%@]", title];
            }
        } else {
            NSString *title = [self.title stringByReplacingOccurrencesOfString:@"]" withString:@""];
            if (![title hasPrefix:@"["]) {
                self.title = [NSString stringWithFormat:@"[%@", title];
            }
        }
    } else {
        if ([self.title hasPrefix:@"["] || [self.title hasSuffix:@"]"]) {
            NSString *title = [self.title stringByReplacingOccurrencesOfString:@"[" withString:@""];
            title = [title stringByReplacingOccurrencesOfString:@"]" withString:@""];
            self.title = title;
        }
    }
}


@end
