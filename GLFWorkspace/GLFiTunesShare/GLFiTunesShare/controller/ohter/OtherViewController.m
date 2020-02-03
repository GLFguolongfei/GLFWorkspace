//
//  OtherViewController.m
//  GLFiTunesShare
//
//  Created by guolongfei on 2020/2/3.
//  Copyright © 2020 GuoLongfei. All rights reserved.
//

#import "OtherViewController.h"
#import "TestViewController.h"

@interface OtherViewController ()

@end

@implementation OtherViewController


#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"测试" style:UIBarButtonItemStylePlain target:self action:@selector(button)];
    self.navigationItem.rightBarButtonItem = item;
    self.title = @"功能";

    for (NSInteger i = 0; i < 10; i++) {
        CGFloat width = (kScreenWidth - 80) / 3;
        CGRect frame = CGRectMake(20 * (i % 3 + 1) + width * (i % 3), 100 + 80 * ceil(i / 3), width, 60);
        UIButton *button = [[UIButton alloc] initWithFrame:frame];
        [button setTitle:@"测试" forState:UIControlStateNormal];
        [button setBackgroundColor:[UIColor lightGrayColor]];
        [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = i + 100;
        button.layer.cornerRadius = 5;
        button.layer.masksToBounds = YES;
        [self.view addSubview:button];
    }
}

- (void)button {
    TestViewController *testVC = [[TestViewController alloc] init];
    [self.navigationController pushViewController:testVC animated:YES];
}

- (void)buttonAction:(UIButton *)button {
    if (button.tag == 100) {
        
    } else if (button.tag == 101) {
        
    }
}


@end
