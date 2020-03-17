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
    UIImageView *contentImageView;
    CGFloat currentScale;
    CGFloat maxScale;
    CGFloat minScale;
    BOOL isHiddenBar;
}
@end

@implementation SubViewController2


#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];

    maxScale = 20;
    minScale = 1;
    
    CGRect rect1 = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
    contentScrollView = [[UIScrollView alloc] initWithFrame:rect1];
    contentScrollView.showsHorizontalScrollIndicator = NO; // 隐藏滚动条(横向的)
    contentScrollView.showsVerticalScrollIndicator = NO;   // 隐藏滚动条(纵向的)
    contentScrollView.maximumZoomScale = maxScale;         // 最大缩放倍率,默认为1.0
    contentScrollView.minimumZoomScale = minScale;         // 最小缩放倍率
    contentScrollView.delegate = self;
    [self.view addSubview:contentScrollView];
    
    CGRect rect2 = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
    contentImageView = [[UIImageView alloc] initWithFrame:rect2];
    contentImageView.contentMode = UIViewContentModeScaleAspectFit;
    contentImageView.image = [UIImage imageWithContentsOfFile:self.model.path];
    contentImageView.userInteractionEnabled = YES;
    contentImageView.tag = 22;
    [contentScrollView addSubview:contentImageView];
    
    UITapGestureRecognizer *tapGesture1 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hiddenNaviBar)];
    tapGesture1.numberOfTapsRequired = 1;    // 设置点按次数,默认为1,注意在iOS中很少用双击操作
    tapGesture1.numberOfTouchesRequired = 1; // 点按的手指数
    [contentScrollView addGestureRecognizer:tapGesture1];
    
    UITapGestureRecognizer *tapGesture2 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapImage:)];
    tapGesture2.numberOfTapsRequired = 2;    // 设置点按次数,默认为1,注意在iOS中很少用双击操作
    tapGesture2.numberOfTouchesRequired = 1; // 点按的手指数
    [contentScrollView addGestureRecognizer:tapGesture2];
    
    // 指定一个手势需要另一个手势执行失败才会执行
    [tapGesture1 requireGestureRecognizerToFail:tapGesture2];
}

- (void)hiddenNaviBar {
    if (isHiddenBar) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"isHiddenNaviBar" object:self userInfo:nil];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"isHiddenNaviBar" object:self userInfo:nil];
    }
    isHiddenBar = !isHiddenBar;
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

- (void)setBgImage {
    // 将图片copy在沙盒的documents文件夹中,并保存为image.png
    NSData *data;
    if (UIImagePNGRepresentation(contentImageView.image) == nil) {
        data = UIImageJPEGRepresentation(contentImageView.image, 1.0);
    } else {
        data = UIImagePNGRepresentation(contentImageView.image);
    }
    NSFileManager *fileManager = [NSFileManager defaultManager];
    // 获取Library目录下的Cache目录
    NSArray *cachePaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachePath = [cachePaths objectAtIndex:0];
    NSString *filePath = [cachePath stringByAppendingString:@"/image.png"];
    [fileManager createFileAtPath:filePath contents:data attributes:nil];
    NSLog(@"-------- 图片的路径为 ------------ %@", filePath);
    // 存储
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:@"1" forKey:IsUseBackImagePath];
    [userDefaults synchronize];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark UIScrollViewDelegate
// 设置放大缩小的视图
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView; {
    UIView *subView = [scrollView viewWithTag:22];
    return subView;
}

// 完成放大缩小时调用
- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale; {
    if (scale>=minScale && scale<=maxScale) {
        currentScale = scale;
    }
}


@end
