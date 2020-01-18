//
//  DetailViewController3.m
//  GLFiTunesShare
//
//  Created by guolongfei on 2018/5/30.
//  Copyright © 2018年 GuoLongfei. All rights reserved.
//

#import "DetailViewController3.h"
#import "SubViewController3.h"

@interface DetailViewController3 ()<UIPageViewControllerDataSource, UIPageViewControllerDelegate>
{
    UIPageViewController *pageVC; // 专门用来作电子书效果的,它用来管理其它的视图控制器
    SubViewController3 *currentVC; // 当前显示的VC
    GLFFileManager *fileManager;
}
@end

@implementation DetailViewController3


#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"显示&隐藏控制栏" style:UIBarButtonItemStylePlain target:self action:@selector(buttonAction:)];
    self.navigationItem.rightBarButtonItems = @[item];
    self.view.backgroundColor = [UIColor blackColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hiddenNaviBar:) name:@"isHiddenNaviBar" object:nil];
    
    fileManager = [GLFFileManager sharedFileManager];

    pageVC = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    pageVC.view.frame = self.view.bounds;
    pageVC.delegate = self;
    pageVC.dataSource = self;
        
    SubViewController3 *subVC = [[SubViewController3 alloc] init];
    subVC.currentIndex = self.selectIndex;
    subVC.model = self.fileArray[self.selectIndex];
    self.title = subVC.model.name;
    currentVC = subVC;
    [pageVC setViewControllers:@[subVC] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    [self.view addSubview:pageVC.view];
}

- (void)buttonAction:(id)sender {
    NSString *isHidden = [[NSUserDefaults standardUserDefaults] objectForKey:@"controlBar"];
    NSString *saveStr;
    if ([isHidden isEqualToString:@"1"]) {
        saveStr = @"0";
    } else {
        saveStr = @"1";
    }
    [[NSUserDefaults standardUserDefaults] setObject:saveStr forKey:@"controlBar"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"avRadio" object:self userInfo:nil];
}

- (void)hiddenNaviBar:(NSNotification *)notification {
    NSDictionary *dict = notification.userInfo;
    NSString *str = dict[@"key"];
    if ([str isEqualToString:@"hidden"]) {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    } else if ([str isEqualToString:@"noHidden"]) {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
}

#pragma mark UIPageViewControllerDataSource
// 上一页
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    self.selectIndex = ((SubViewController3 *) viewController).currentIndex;
    if (self.selectIndex==0 || self.selectIndex==NSNotFound) {
        return nil;
    }
    
    self.selectIndex--; // 注意: 直接使用VC的顺序index,不要再单独标记了,否则出大问题
    
    SubViewController3 *subVC = [[SubViewController3 alloc] init];
    subVC.currentIndex = self.selectIndex;
    subVC.model = self.fileArray[self.selectIndex];
    currentVC = subVC;
    return subVC;
}

// 下一页
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    self.selectIndex = ((SubViewController3 *) viewController).currentIndex;
    if (self.selectIndex==self.fileArray.count-1 || self.selectIndex==NSNotFound) {
        return nil;
    }
    
    self.selectIndex++;
    
    SubViewController3 *subVC = [[SubViewController3 alloc] init];
    subVC.currentIndex = self.selectIndex;
    subVC.model = self.fileArray[self.selectIndex];
    currentVC = subVC;
    return subVC;
}

#pragma mark UIPageViewControllerDelegate
// 开始滚动或翻页的时候触发
- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray<UIViewController *> *)pendingViewControllers {
    NSInteger currentIndex = ((SubViewController3 *) pendingViewControllers[0]).currentIndex;
    FileModel *currentModel = self.fileArray[currentIndex];
    self.title = currentModel.name;
}

// 结束滚动或翻页的时候触发
- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed {
    
}


@end
