//
//  MathViewController.m
//  GLFiTunesShare
//
//  Created by guolongfei on 2020/2/22.
//  Copyright © 2020 GuoLongfei. All rights reserved.
//

#import "MathViewController.h"
#import "ZHFigureDrawingView.h"

@interface MathViewController ()

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


@end
