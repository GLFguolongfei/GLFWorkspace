//
//  DetailViewController2.m
//  GLFiTunesShare
//
//  Created by guolongfei on 2018/5/30.
//  Copyright © 2018年 GuoLongfei. All rights reserved.
//

#import "DetailViewController2.h"
#import "SubViewController2.h"

@interface DetailViewController2 ()<UIPageViewControllerDataSource, UIPageViewControllerDelegate>
{
    UIPageViewController *pageVC; // 专门用来作电子书效果的,它用来管理其它的视图控制器
    GLFFileManager *fileManager;
}
@end

@implementation DetailViewController2


#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"设为背景" style:UIBarButtonItemStylePlain target:self action:@selector(buttonAction:)];
    self.navigationItem.rightBarButtonItem = item;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hiddenNaviBar) name:@"isHiddenNaviBar" object:nil];
    
    fileManager = [GLFFileManager sharedFileManager];

    pageVC = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    pageVC.view.frame = self.view.bounds;
    pageVC.delegate = self;
    pageVC.dataSource = self;
    
    SubViewController2 *subVC = [[SubViewController2 alloc] init];
    subVC.currentIndex = self.selectIndex;
    subVC.model = self.fileArray[self.selectIndex];
    [self setVCTitle:subVC.model.name];
    [pageVC setViewControllers:@[subVC] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    [self.view addSubview:pageVC.view];
}

// 更改状态栏
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)hiddenNaviBar {
    if (self.navigationController.navigationBar.hidden == YES) {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    } else {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    }
}

- (void)buttonAction:(id)sender {
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"" message:@"确定将此图片设为背景图？" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"再想想" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {

    }];
    [alertVC addAction:cancelAction];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"我确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        SubViewController2 *subVC = (SubViewController2 *)pageVC.viewControllers[0];
        [subVC setBgImage];
    }];
    [alertVC addAction:okAction];
    [self presentViewController:alertVC animated:YES completion:nil];
}

#pragma mark UIPageViewControllerDataSource
// 上一页
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    self.selectIndex = ((SubViewController2 *) viewController).currentIndex;
    if (self.selectIndex==0 || self.selectIndex==NSNotFound) {
        return nil;
    }
    
    self.selectIndex--; // 注意: 直接使用VC的顺序index,不要再单独标记了,否则出大问题
    
    SubViewController2 *subVC = [[SubViewController2 alloc] init];
    subVC.currentIndex = self.selectIndex;
    subVC.model = self.fileArray[self.selectIndex];
    return subVC;
}

// 下一页
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    self.selectIndex = ((SubViewController2 *) viewController).currentIndex;
    if (self.selectIndex==self.fileArray.count-1 || self.selectIndex==NSNotFound) {
        return nil;
    }
    
    self.selectIndex++;
    
    SubViewController2 *subVC = [[SubViewController2 alloc] init];
    subVC.currentIndex = self.selectIndex;
    subVC.model = self.fileArray[self.selectIndex];
    return subVC;
}

#pragma mark UIPageViewControllerDelegate
// 开始滚动或翻页的时候触发
- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray<UIViewController *> *)pendingViewControllers {
    NSInteger currentIndex = ((SubViewController2 *) pendingViewControllers[0]).currentIndex;
    FileModel *currentModel = self.fileArray[currentIndex];
    [self setVCTitle:currentModel.name];
}

// 结束滚动或翻页的时候触发
- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed {
    
}


@end
