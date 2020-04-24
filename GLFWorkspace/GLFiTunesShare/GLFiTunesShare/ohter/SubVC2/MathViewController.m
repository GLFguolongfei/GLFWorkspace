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
    
    _drawingView = [[ZHFigureDrawingView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:_drawingView];
    
    CGRect viewFrame = CGRectMake(20, 20, 80, 80);
    UIView *bgview = [[UIView alloc] initWithFrame:viewFrame];
    bgview.backgroundColor = KNavgationBarColor;
    bgview.alpha = 0.5;
    bgview.layer.cornerRadius = 40;
    bgview.layer.masksToBounds = YES;
    [self.view addSubview:bgview];
    CGRect buttonFrame = CGRectMake(20, 20, 80, 80);
    UIButton *button = [[UIButton alloc] initWithFrame:buttonFrame];
    [button setTitle:@"返回" forState:UIControlStateNormal];
    [button setBackgroundColor:[UIColor clearColor]];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(buttonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

- (void)buttonAction {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
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
