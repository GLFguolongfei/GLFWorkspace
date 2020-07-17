//
//  OtherViewController.m
//  GLFiTunesShare
//
//  Created by guolongfei on 2020/2/3.
//  Copyright © 2020 GuoLongfei. All rights reserved.
//

#import "OtherViewController.h"
#import "TestViewController.h"
#import "OneViewController.h"
#import "TwoViewController.h"
#import "ThreeViewController.h"
#import "FourViewController.h"
#import "FiveViewController.h"
#import "SixViewController.h"

@interface OtherViewController ()
{
    UIImageView *bgImageView;
    UIView *gestureView;
}
@end

@implementation OtherViewController


#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
//    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"测试功能" style:UIBarButtonItemStylePlain target:self action:@selector(button)];
//    self.navigationItem.rightBarButtonItem = item;
    [self setVCTitle:@"有趣功能"];
    
    // 设置背景图片
    bgImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    bgImageView.contentMode = UIViewContentModeScaleAspectFill;
    bgImageView.image = [DocumentManager getBackgroundImage];
    [self.view addSubview:bgImageView];
    UIVisualEffectView *visualEfView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
    visualEfView.frame = kScreen;
    visualEfView.alpha = 0.5;
    [bgImageView addSubview:visualEfView];

    for (NSInteger i = 0; i < 6; i++) {
        CGFloat width = (kScreenWidth - 60) / 2;
        CGRect frame = CGRectMake(20 * (i % 2 + 1) + width * (i % 2), 100 + 80 * ceil(i / 2), width, 60);
        UIButton *button = [[UIButton alloc] initWithFrame:frame];
        if (i == 0) {
            [button setTitle:@"UIKit动力学" forState:UIControlStateNormal];
        } else if (i == 1)  {
            [button setTitle:@"UIKit动力学" forState:UIControlStateNormal];
        } else if (i == 2)  {
            [button setTitle:@"自定义拍照" forState:UIControlStateNormal];
        } else if (i == 3)  {
            [button setTitle:@"自定义录像" forState:UIControlStateNormal];
        } else if (i == 4)  {
            [button setTitle:@"日常小工具" forState:UIControlStateNormal];
        } else if (i == 5)  {
            [button setTitle:@"日常小玩意" forState:UIControlStateNormal];
        } else if (i == 6) {
            [button setTitle:@"iskytrip 打卡" forState:UIControlStateNormal];
        }
        [button setBackgroundColor:[UIColor clearColor]];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = i + 100;
        button.layer.cornerRadius = 5;
        button.layer.masksToBounds = YES;
        [self.view addSubview:button];
    }
    
    [self setupEmitter2];
}

// 更改状态栏
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.toolbar.hidden = YES;
    self.navigationController.navigationBar.hidden = NO;
    
    // 设置背景图片
    bgImageView.image = [DocumentManager getBackgroundImage];
    
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
    
//    // 导航栏标题颜色
//    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName: KNavgationBarColor}];
//    // 设置导航栏背景图片为一个空的image,这样就透明了
//    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
//    // 去掉透明后导航栏下边的黑边
//    [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self removeEmitter];
    
//    // 导航栏标题颜色
//    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor blackColor]}];
//    // 如果不想让其他页面的导航栏变为透明,需要重置
//    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
//    [self.navigationController.navigationBar setShadowImage:nil];
}

- (void)button {

}

- (void)buttonAction:(UIButton *)button {
    if (button.tag == 100) {
        OneViewController *vc = [[OneViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    } else if (button.tag == 101) {
        TwoViewController *vc = [[TwoViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    } else if (button.tag == 102) {
        ThreeViewController *vc = [[ThreeViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    } else if (button.tag == 103) {
        FourViewController *vc = [[FourViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    } else if (button.tag == 104) {
        FiveViewController *vc = [[FiveViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    } else if (button.tag == 105) {
        SixViewController *vc = [[SixViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    } else if (button.tag == 106) {
        [ProjectManager iskytripLogin];
        [self showStringHUD:@"打卡成功" second:1.5];
    }
}

- (void)setState {
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"隐藏功能" message:@"惊不惊喜！意不意外！！！" preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alertVC addAction:cancelAction];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"测试页" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        TestViewController *testVC = [[TestViewController alloc] init];
        [self.navigationController pushViewController:testVC animated:YES];
    }];
    [alertVC addAction:okAction];

    DocumentManager *manager = [DocumentManager sharedDocumentManager];
    if (manager.isRecording) {
        UIAlertAction *okAction2 = [UIAlertAction actionWithTitle:@"切换方向" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [manager switchCamera];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self reSetVCTitle];
            });
        }];
        [alertVC addAction:okAction2];
    }
    
    [self presentViewController:alertVC animated:YES completion:nil];
}


@end
