//
//  OneViewController.m
//  GLFiTunesShare
//
//  Created by guolongfei on 2020/2/3.
//  Copyright © 2020 GuoLongfei. All rights reserved.
//

#import "OneViewController.h"

@interface OneViewController ()
{
    UIDynamicAnimator *animator;          // 动画者
    UIGravityBehavior *gravityBeahvior;   // 仿真行为_重力
    UIImageView *imageView;
}
@end

@implementation OneViewController


#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"ImageModel" style:UIBarButtonItemStylePlain target:self action:@selector(buttonAction)];
    self.navigationItem.rightBarButtonItem = item;
    [self setVCTitle:@"UIKit动力学"];

    // 1-动画者
    animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    // 2-重力仿真行为
    gravityBeahvior = [[UIGravityBehavior alloc] init];
    // 3-添加重力仿真行为
    [animator addBehavior:gravityBeahvior];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self showImage];
}

// 运动开始时执行
- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    // 这里只处理摇晃事件
    if (motion == UIEventSubtypeMotionShake) {
        NSLog(@"motion begin: %ld %@", motion, event);
        [self showImage];
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

- (void)buttonAction {
    if (imageView.contentMode == UIViewContentModeScaleAspectFill) {
        imageView.contentMode = UIViewContentModeScaleAspectFit;
    } else {
        imageView.contentMode = UIViewContentModeScaleAspectFill;
    }
}

- (void)showImage {
    if (imageView) {
        // 为重力仿真行为添加动力学元素
        [gravityBeahvior addItem:imageView];
    }
    NSInteger mmm = arc4random() % 3;
    NSString *name = @"bgview1";
    if (mmm == 0) {
        NSInteger nnn = arc4random() % 9;
        name = [NSString stringWithFormat:@"bgview%ld", nnn];
    } else if (mmm == 1) {
        NSInteger nnn = arc4random() % 13;
        name = [NSString stringWithFormat:@"mv%ld", nnn];
    }
    UIImage *image = [UIImage imageNamed:name];
    DocumentManager *manager = [DocumentManager sharedDocumentManager];
    if (manager.allImagesArray.count > 0) {
        NSInteger mmm = arc4random() % manager.allImagesArray.count;
        FileModel *model = manager.allImagesArray[mmm];
        image = [UIImage imageWithContentsOfFile:model.path];
    }
    imageView = [[UIImageView alloc] initWithImage:image];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.frame = CGRectMake(0, 0, 0, 0);
    imageView.center = CGPointMake(kScreenWidth / 2.0, (kScreenHeight-64) / 2.0 + 64);
    imageView.alpha = 0;
    [self.view addSubview:imageView];
    [UIView animateWithDuration:1 animations:^{
        imageView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
        imageView.alpha = 1;
    }];
}


@end
