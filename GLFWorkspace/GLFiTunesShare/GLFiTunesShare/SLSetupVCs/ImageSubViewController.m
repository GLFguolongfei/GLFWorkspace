//
//  ImageSubViewController.m
//  GLFiTunesShare
//
//  Created by guolongfei on 2017/11/8.
//  Copyright © 2017年 GuoLongfei. All rights reserved.
//

#import "ImageSubViewController.h"

@interface ImageSubViewController ()<UIScrollViewDelegate>
{
    UIScrollView *_scrollView;
    UIImageView *_imageVew;
}
@end

@implementation ImageSubViewController


#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"选择" style:UIBarButtonItemStylePlain target:self action:@selector(buttonAction:)];
    self.navigationItem.rightBarButtonItem = item;
    
    _scrollView = [[UIScrollView alloc] init];
    if (self.imageName.length != 0) {
        _scrollView.frame = CGRectMake(0, 64, kScreenWidth, kScreenHeight-64);
    } else {
        _scrollView.frame = self.view.bounds;
    }
    _scrollView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_scrollView];
    
    _imageVew = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight-64)];
    if (self.imageName.length != 0) {
        _imageVew.image = [UIImage imageNamed:self.imageName];
    } else {
        _imageVew.image = self.image;
    }
    _imageVew.contentMode = UIViewContentModeScaleAspectFit;
    [_scrollView addSubview:_imageVew];
    
    _scrollView.delegate = self;
    float max = 3;
    if (self.image.size.width/self.view.frame.size.width > max) {
        max = self.image.size.width/self.view.frame.size.width * 2;
    }
    if (self.image.size.height/self.view.frame.size.height > max) {
        max = self.image.size.height/self.view.frame.size.height * 2;
    }
    _scrollView.maximumZoomScale = max;              // 最大缩放倍率
    _scrollView.minimumZoomScale = 1;                // 最小缩放倍率
    _scrollView.contentSize = self.view.bounds.size; // 内容
}

- (void)buttonAction:(id)sender {
    // 将图片copy在沙盒的documents文件夹中,并保存为image.png
    NSData *data;
    if (UIImagePNGRepresentation(self.image) == nil) {
        data = UIImageJPEGRepresentation(self.image, 1.0);
    } else {
        data = UIImagePNGRepresentation(self.image);
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
// 设置放大缩小的视图,要是UIScrollView的Subview
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView; {
    return _imageVew;
}


@end
