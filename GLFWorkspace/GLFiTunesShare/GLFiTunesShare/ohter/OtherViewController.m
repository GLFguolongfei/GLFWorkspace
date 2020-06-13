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

@end

@implementation OtherViewController


#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"测试功能" style:UIBarButtonItemStylePlain target:self action:@selector(button)];
    self.navigationItem.rightBarButtonItem = item;
    [self setVCTitle:@"有趣功能"];

    for (NSInteger i = 0; i < 7; i++) {
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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.toolbar.hidden = YES;
    self.navigationController.navigationBar.hidden = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self removeEmitter];
}

- (void)button {
    TestViewController *testVC = [[TestViewController alloc] init];
    [self.navigationController pushViewController:testVC animated:YES];
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
        [DocumentManager iskytripLogin];
        [self showStringHUD:@"打卡成功" second:1.5];
    }
}


@end
