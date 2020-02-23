//
//  MathViewController.m
//  GLFiTunesShare
//
//  Created by guolongfei on 2020/2/22.
//  Copyright © 2020 GuoLongfei. All rights reserved.
//

#import "MathViewController.h"
#import "ZHFigureDrawingView.h"

@interface MathViewController ()<UIGestureRecognizerDelegate>

@property (nonatomic, strong) ZHFigureDrawingView *drawingView;

@end

@implementation MathViewController


#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"数学绘图";
    [self canRecord:NO];
    
    _drawingView = [[ZHFigureDrawingView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:_drawingView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // 禁用右滑返回
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
        self.navigationController.interactivePopGestureRecognizer.delegate = self;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    // 恢复右滑返回
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
        self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    }
}

#pragma mark UIGestureRecognizerDelegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return NO;
}


@end
