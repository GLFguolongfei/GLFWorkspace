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
    GLFFileManager *fileManager;
}
@end

@implementation DetailViewController3


#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem *item1 = [[UIBarButtonItem alloc] initWithTitle:@"快进" style:UIBarButtonItemStylePlain target:self action:@selector(buttonAction1:)];
    UIBarButtonItem *item2 = [[UIBarButtonItem alloc] initWithTitle:@"快退" style:UIBarButtonItemStylePlain target:self action:@selector(buttonAction2:)];
    self.navigationItem.rightBarButtonItems = @[item1, item2];
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
    [pageVC setViewControllers:@[subVC] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    [self.view addSubview:pageVC.view];
}

- (void)buttonAction1:(id)sender {
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:@"avForward",@"key", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"avRadio" object:self userInfo:dic];
}

- (void)buttonAction2:(id)sender {
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:@"avBackward",@"key", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"avRadio" object:self userInfo:dic];
}

- (void)hiddenNaviBar:(NSNotification *)notification {
    NSDictionary *dict = notification.userInfo;
    NSString *str = dict[@"key"];
    if ([str isEqualToString:@"hidden"]) {
        self.navigationController.navigationBar.hidden = YES;
    } else if ([str isEqualToString:@"noHidden"]) {
        self.navigationController.navigationBar.hidden = NO;        
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
