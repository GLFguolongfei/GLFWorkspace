//
//  SubViewController2.m
//  GLFiTunesShare
//
//  Created by guolongfei on 2018/5/30.
//  Copyright © 2018年 GuoLongfei. All rights reserved.
//

#import "SubViewController2.h"

@interface SubViewController2 ()<UIScrollViewDelegate>
{
    UIScrollView *contentScrollView;
    CGFloat currentScale;
    CGFloat maxScale;
    CGFloat minScale;
}
@end

@implementation SubViewController2


#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    
    maxScale = 20;
    minScale = 0.1;
    
    CGRect rect1 = CGRectMake(0, 64, kScreenWidth, kScreenHeight-64);
    contentScrollView = [[UIScrollView alloc] initWithFrame:rect1];
    contentScrollView.showsHorizontalScrollIndicator = NO; // 隐藏滚动条(横向的)
    contentScrollView.showsVerticalScrollIndicator = NO;   // 隐藏滚动条(纵向的)
    contentScrollView.maximumZoomScale = maxScale;         // 最大缩放倍率,默认为1.0
    contentScrollView.minimumZoomScale = minScale;         // 最小缩放倍率
    contentScrollView.delegate = self;
    [self.view addSubview:contentScrollView];
    
    CGRect rect2 = CGRectMake(0, 0, kScreenWidth, kScreenHeight-64);
    UIImageView *contentImageView = [[UIImageView alloc] initWithFrame:rect2];
    contentImageView.contentMode = UIViewContentModeScaleAspectFit;
    contentImageView.image = [UIImage imageWithContentsOfFile:self.model.path];
    contentImageView.userInteractionEnabled = YES;
    contentImageView.tag = 22;
    [contentScrollView addSubview:contentImageView];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapImage:)];
    tapGesture.numberOfTapsRequired = 2;    // 设置点按次数,默认为1,注意在iOS中很少用双击操作
    tapGesture.numberOfTouchesRequired = 1; // 点按的手指数
    [contentScrollView addGestureRecognizer:tapGesture];
}

- (void)tapImage:(UITapGestureRecognizer *)gesture {
    // 如果当前为正常大小,双击则放大至三倍大小
    // 如果当前为放大或缩小,双击则变回正常尺寸
    if (currentScale == 1) {
        currentScale = 3;
        [contentScrollView setZoomScale:currentScale animated:YES];
        return;
    } else {
        currentScale = 1;
        [contentScrollView setZoomScale:currentScale animated:YES];
        return;
    }
}

#pragma mark UIScrollViewDelegate
// 设置放大缩小的视图
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView; {
    UIView *subView = [scrollView viewWithTag:22];
    return subView;
}

// 完成放大缩小时调用
- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale; {
    if (scale>=minScale && scale<=maxScale) {
        currentScale = scale;
    }
}


@end
