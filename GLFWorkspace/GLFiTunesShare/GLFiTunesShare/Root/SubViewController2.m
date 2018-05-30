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
    self.view.backgroundColor = [UIColor whiteColor];
    
    maxScale = 3;
    minScale = 1;
    
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
    // 当前倍数等于最大放大倍数: 双击默认为缩小到原图
    if (currentScale == maxScale) {
        currentScale = minScale;
        [contentScrollView setZoomScale:currentScale animated:YES];
        return;
    }
    // 当前等于最小放大倍数: 双击默认为放大到最大倍数
    if (currentScale == minScale) {
        currentScale = maxScale;
        [contentScrollView setZoomScale:currentScale animated:YES];
        return;
    }
    
    CGFloat aveScale = minScale + (maxScale-minScale)/2.0; // 中间倍数
    
    // 当前倍数大于平均倍数: 双击默认为放大最大倍数
    if (currentScale >= aveScale) {
        currentScale = maxScale;
        [contentScrollView setZoomScale:currentScale animated:YES];
        return;
    }
    // 当前倍数小于平均倍数: 双击默认为放大到最小倍数
    if (currentScale < aveScale) {
        currentScale = minScale;
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
