//
//  ImageViewController.m
//  GLFiTunesShare
//
//  Created by guolongfei on 2017/10/24.
//  Copyright © 2017年 GuoLongfei. All rights reserved.
//

#import "ImageViewController.h"
#import "ImageSubViewController.h"

@interface ImageViewController ()<UIPageViewControllerDataSource, UIPageViewControllerDelegate>
{
    UIPageViewController *pageVC; 
}
@end

@implementation ImageViewController


#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = [NSString stringWithFormat:@"%ld",self.selectIndex];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"选择" style:UIBarButtonItemStylePlain target:self action:@selector(buttonAction:)];
    self.navigationItem.rightBarButtonItem = item;
    [self canRecord:NO];

    pageVC = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    pageVC.view.frame = self.view.bounds;
    pageVC.delegate = self;
    pageVC.dataSource = self;
    
    ImageSubViewController *subVC = [[ImageSubViewController alloc] init];
    subVC.currentIndex = self.selectIndex;
    subVC.imageName = self.nameArray[self.selectIndex];
    [pageVC setViewControllers:@[subVC] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    [self.view addSubview:pageVC.view];
}

- (void)buttonAction:(id)sender {
    ImageSubViewController *subVC = (ImageSubViewController *)pageVC.viewControllers[0];
    NSString *imageName = self.nameArray[subVC.currentIndex];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:@"0" forKey:IsUseBackImagePath];
    [userDefaults setObject:imageName forKey:BackImageName];
    [userDefaults synchronize];
    UIViewController *vc = self.navigationController.viewControllers[self.navigationController.viewControllers.count-3];
    [self.navigationController popToViewController:vc animated:YES];
}

#pragma mark UIPageViewControllerDataSource
// 上一页
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    self.selectIndex = ((ImageSubViewController *) viewController).currentIndex;
    if (self.selectIndex==0 || self.selectIndex==NSNotFound) {
        return nil;
    }
    
    self.selectIndex--; // 注意: 直接使用VC的顺序index,不要再单独标记了,否则出大问题
    
    ImageSubViewController *subVC = [[ImageSubViewController alloc] init];
    subVC.currentIndex = self.selectIndex;
    subVC.imageName = self.nameArray[self.selectIndex];
    return subVC;
}

// 下一页
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    self.selectIndex = ((ImageSubViewController *) viewController).currentIndex;
    if (self.selectIndex==self.nameArray.count-1 || self.selectIndex==NSNotFound) {
        return nil;
    }
    
    self.selectIndex++;
    
    ImageSubViewController *subVC = [[ImageSubViewController alloc] init];
    subVC.currentIndex = self.selectIndex;
    subVC.imageName = self.nameArray[self.selectIndex];
    return subVC;
}

#pragma mark UIPageViewControllerDelegate
// 开始滚动或翻页的时候触发
- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray<UIViewController *> *)pendingViewControllers
{
    NSInteger currentIndex = ((ImageSubViewController *) pendingViewControllers[0]).currentIndex;
    self.title = [NSString stringWithFormat:@"%ld", currentIndex];
}

// 结束滚动或翻页的时候触发
- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed
{
    
}


@end
