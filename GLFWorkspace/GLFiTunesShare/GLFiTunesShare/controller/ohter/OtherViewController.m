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
#import "MMScanViewController.h"

@interface OtherViewController ()
{
    UIImageView *bgImageView;
}
@end

@implementation OtherViewController


#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"测试功能" style:UIBarButtonItemStylePlain target:self action:@selector(button)];
    self.navigationItem.rightBarButtonItem = item;
    self.title = @"有趣功能";
    [self canRecord:NO];

    // 设置背景图片
    bgImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    bgImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:bgImageView];

    for (NSInteger i = 0; i < 5; i++) {
        CGFloat width = (kScreenWidth - 60) / 2;
        CGRect frame = CGRectMake(20 * (i % 2 + 1) + width * (i % 2), 100 + 80 * ceil(i / 2), width, 60);
        UIButton *button = [[UIButton alloc] initWithFrame:frame];
        if (i == 0) {
            [button setTitle:@"UIKit动力学" forState:UIControlStateNormal];
        } else if (i == 1)  {
            [button setTitle:@"iOS字体" forState:UIControlStateNormal];
        } else if (i == 2)  {
            [button setTitle:@"自定义拍照" forState:UIControlStateNormal];
        } else if (i == 3)  {
            [button setTitle:@"自定义录像" forState:UIControlStateNormal];
        } else if (i == 4)  {
            [button setTitle:@"扫描二维码" forState:UIControlStateNormal];
        } else {
            [button setTitle:@"测试" forState:UIControlStateNormal];
        }
        [button setBackgroundColor:[UIColor clearColor]];
        [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = i + 100;
        button.layer.cornerRadius = 5;
        button.layer.masksToBounds = YES;
        [self.view addSubview:button];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.toolbar.hidden = YES;
    self.navigationController.navigationBar.hidden = NO;
    // 1.设置背景图片
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *isUseBackImagePath = [userDefaults objectForKey:IsUseBackImagePath];
    NSString *backName = [userDefaults objectForKey:BackImageName];
    NSArray *cachePaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachePath = [cachePaths objectAtIndex:0];
    NSString *filePath = [cachePath stringByAppendingString:@"/image.png"];
    UIImage *backImage;
    if (isUseBackImagePath.integerValue) {
        backImage = [UIImage imageWithContentsOfFile:filePath];
    } else {
        backImage = [UIImage imageNamed:backName];
    }
    if (backImage == nil) {
        backImage = [UIImage imageNamed:@"bgView2"];
        [userDefaults setObject:@"bgView2" forKey:BackImageName];
        [userDefaults synchronize];
    }
    bgImageView.image = backImage;
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
          MMScanViewController *scanVc = [[MMScanViewController alloc] initWithQrType:MMScanTypeAll onFinish:^(NSString *result, NSError *error) {
              if (error) {
                  NSLog(@"error: %@", error);
                  [self showStringHUD:error.localizedDescription second:2];
              } else {
                  NSLog(@"扫描结果：%@", result);
                  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"扫描结果" message:result delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                  [alert show];
              }
          }];
          [scanVc setHistoryCallBack:^(NSArray *result) {
              NSLog(@"%@", result);
          }];
          [self.navigationController pushViewController:scanVc animated:YES];
    }
}


@end
