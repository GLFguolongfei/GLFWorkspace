//
//  TestViewController.m
//  GLFiTunesShare
//
//  Created by guolongfei on 2020/1/31.
//  Copyright © 2020 GuoLongfei. All rights reserved.
//

#import "TestViewController.h"

@interface TestViewController ()
{
    UIDynamicAnimator *animator;          // 动画者
    UIGravityBehavior *gravityBeahvior;   // 仿真行为_重力
}
@end

@implementation TestViewController


#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"测试功能";

    // 1-动画者
    animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    // 2-重力仿真行为
    gravityBeahvior = [[UIGravityBehavior alloc] init];
    // 3-添加重力仿真行为
    [animator addBehavior:gravityBeahvior];
    
    // 点击手势
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
    [self.view addGestureRecognizer:tapGesture];
}

- (void)tapped:(UITapGestureRecognizer *)gesture {
    NSInteger mmm = arc4random() % 3;
    NSString *name = @"bgview1";
    if (mmm == 0) {
        NSInteger nnn = arc4random() % 9;
        name = [NSString stringWithFormat:@"bgview%ld", nnn];
    } else if (mmm == 1) {
        NSInteger nnn = arc4random() % 13;
        name = [NSString stringWithFormat:@"mv%ld", nnn];
    } else if (mmm == 2) {
        NSInteger nnn = arc4random() % 32;
        name = [NSString stringWithFormat:@"nv%ld", nnn];
    }
    UIImage *image = [UIImage imageNamed:name];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.frame = CGRectMake(0, 0, kScreenWidth, 200);
    imageView.center = [gesture locationInView:gesture.view];
    imageView.center = CGPointMake(kScreenWidth / 2.0, kScreenHeight / 2.0);
    [self.view addSubview:imageView];
    // 3秒后回到主线程执行Block中的代码
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 为重力仿真行为添加动力学元素
        [gravityBeahvior addItem:imageView];
    });
}

// 运动开始时执行
- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    // 这里只处理摇晃事件
    if (motion == UIEventSubtypeMotionShake) {
        NSLog(@"motion begin: %ld %@", motion, event);
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


@end
