//
//  DetailViewController.m
//  GLFiTunesShare
//
//  Created by guolongfei on 2017/9/29.
//  Copyright © 2017年 GuoLongfei. All rights reserved.
//

#import "DetailViewController.h"
#import "SubViewController.h"

@interface DetailViewController ()<UIPageViewControllerDataSource, UIPageViewControllerDelegate>
{
    UIPageViewController *pageVC; // 专门用来作电子书效果的,它用来管理其它的视图控制器
    GLFFileManager *fileManager;
}
@end

@implementation DetailViewController


#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    UIBarButtonItem *item1 = [[UIBarButtonItem alloc] initWithTitle:@"W前进" style:UIBarButtonItemStylePlain target:self action:@selector(buttonAction1:)];
    UIBarButtonItem *item2 = [[UIBarButtonItem alloc] initWithTitle:@"W回退" style:UIBarButtonItemStylePlain target:self action:@selector(buttonAction2:)];
    item1.enabled = NO;
    item2.enabled = NO;
    self.navigationItem.rightBarButtonItems = @[item1, item2];
    
    fileManager = [GLFFileManager sharedFileManager];

    pageVC = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    pageVC.view.frame = self.view.bounds;
    pageVC.delegate = self;
    pageVC.dataSource = self;
    
    SubViewController *subVC = [[SubViewController alloc] init];
    subVC.currentIndex = self.selectIndex;
    subVC.model = self.fileArray[self.selectIndex];
    self.title = subVC.model.name;
    subVC.backBlock = ^() {
        [self.navigationController popViewControllerAnimated:YES];
    };
    subVC.backEnableBlock = ^(BOOL enable) {
        UIBarButtonItem *item = self.navigationItem.rightBarButtonItems[1];
        item.enabled = enable;
    };
    subVC.forwardEnableBlock = ^(BOOL enable) {
        UIBarButtonItem *item = self.navigationItem.rightBarButtonItems[0];
        item.enabled = enable;
    };
    [pageVC setViewControllers:@[subVC] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    [self.view addSubview:pageVC.view];
}

- (void)buttonAction1:(id)sender {
    SubViewController *subVC = (SubViewController *)pageVC.viewControllers[0];
    if (subVC.myWebView.canGoForward) {
        [subVC.myWebView goForward];
    }
}

- (void)buttonAction2:(id)sender {
    SubViewController *subVC = (SubViewController *)pageVC.viewControllers[0];
    if (subVC.myWebView.canGoBack) {
        [subVC.myWebView goBack];
    }
}

#pragma mark UIPageViewControllerDataSource
// 上一页
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    self.selectIndex = ((SubViewController *) viewController).currentIndex;
    if (self.selectIndex==0 || self.selectIndex==NSNotFound) {
        return nil;
    }

    self.selectIndex--; // 注意: 直接使用VC的顺序index,不要再单独标记了,否则出大问题
    
    SubViewController *subVC = [[SubViewController alloc] init];
    subVC.currentIndex = self.selectIndex;
    subVC.model = self.fileArray[self.selectIndex];
    subVC.backBlock = ^() {
        [self.navigationController popViewControllerAnimated:YES];
    };
    subVC.backEnableBlock = ^(BOOL enable) {
        UIBarButtonItem *item = self.navigationItem.rightBarButtonItems[1];
        item.enabled = enable;
    };
    subVC.forwardEnableBlock = ^(BOOL enable) {
        UIBarButtonItem *item = self.navigationItem.rightBarButtonItems[0];
        item.enabled = enable;
    };
    subVC.backEnableBlock = ^(BOOL enable) {
        self.navigationItem.rightBarButtonItem.enabled = enable;
    };
    return subVC;
}

// 下一页
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    self.selectIndex = ((SubViewController *) viewController).currentIndex;
    if (self.selectIndex==self.fileArray.count-1 || self.selectIndex==NSNotFound) {
        return nil;
    }
    
    self.selectIndex++;
    
    SubViewController *subVC = [[SubViewController alloc] init];
    subVC.currentIndex = self.selectIndex;
    subVC.model = self.fileArray[self.selectIndex];
    subVC.backBlock = ^() {
        [self.navigationController popViewControllerAnimated:YES];
    };
    subVC.backEnableBlock = ^(BOOL enable) {
        UIBarButtonItem *item = self.navigationItem.rightBarButtonItems[1];
        item.enabled = enable;
    };
    subVC.forwardEnableBlock = ^(BOOL enable) {
        UIBarButtonItem *item = self.navigationItem.rightBarButtonItems[0];
        item.enabled = enable;
    };
    return subVC;
}

#pragma mark UIPageViewControllerDelegate
// 开始滚动或翻页的时候触发
- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray<UIViewController *> *)pendingViewControllers
{
    NSInteger currentIndex = ((SubViewController *) pendingViewControllers[0]).currentIndex;
    FileModel *currentModel = self.fileArray[currentIndex];
    self.title = currentModel.name;
}

// 结束滚动或翻页的时候触发
- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed
{

}


@end
