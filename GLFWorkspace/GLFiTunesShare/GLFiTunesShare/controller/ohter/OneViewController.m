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
    self.title = @"UIKit动力学";

    // 1-动画者
    animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    // 2-重力仿真行为
    gravityBeahvior = [[UIGravityBehavior alloc] init];
    // 3-添加重力仿真行为
    [animator addBehavior:gravityBeahvior];
    

}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self showImage];
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
    imageView = [[UIImageView alloc] initWithImage:image];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.frame = CGRectMake(0, 0, kScreenWidth, 200);
    imageView.center = CGPointMake(kScreenWidth / 2.0, (kScreenHeight-64) / 2.0 + 64);
    [self.view addSubview:imageView];
}


@end
