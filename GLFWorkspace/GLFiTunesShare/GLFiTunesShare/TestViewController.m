//
//  TestViewController.m
//  GLFiTunesShare
//
//  Created by guolongfei on 2020/1/31.
//  Copyright © 2020 GuoLongfei. All rights reserved.
//

#import "TestViewController.h"

@interface TestViewController ()

@end

@implementation TestViewController


#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"测试功能";

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
