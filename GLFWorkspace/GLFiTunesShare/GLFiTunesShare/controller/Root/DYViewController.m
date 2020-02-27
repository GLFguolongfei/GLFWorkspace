//
//  DYViewController.m
//  GLFiTunesShare
//
//  Created by guolongfei on 2020/2/18.
//  Copyright © 2020 GuoLongfei. All rights reserved.
//

#import "DYViewController.h"
#import "DYSubViewController.h"
#import "DYFavoriteViewController.h"

@interface DYViewController ()<UIPageViewControllerDataSource, UIPageViewControllerDelegate>
{
    UIPageViewController *pageVC; // 专门用来作电子书效果的,它用来管理其它的视图控制器
    DYSubViewController *currentVC; // 当前显示的VC
    BOOL isPlaying;
    
    NSInteger selectIndex;
    NSMutableArray *_dataArray;
    FileModel *currentModel;
    
    NSMutableArray *favoriteArray;
    DocumentManager *manager;
    UIButton *favoriteButton;
    
    NSTimer *timer; // 定时器
    
    UIView *gestureView;
    BOOL isSuccess;
}
@end

@implementation DYViewController


#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"favorite"] style:UIBarButtonItemStylePlain target:self action:@selector(favoriteVideo)];
    self.navigationItem.rightBarButtonItem = item;
    self.view.backgroundColor = [UIColor blackColor];
    self.title = @"抖音短视频";
    
    isPlaying = NO;
    
    UIBarButtonItem *item1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRewind target:self action:@selector(playerRewind)];
    UIBarButtonItem *item2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(playOrPauseVideo)];
    UIBarButtonItem *item3 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFastForward target:self action:@selector(playerForward)];
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil]; // 特殊的一个,用来自动计算宽度
    
    self.toolbarItems = @[space, item1, space, item2, space, item3, space];
    
    NSString *indexStr = [[NSUserDefaults standardUserDefaults] objectForKey:@"selectIndex"];
    selectIndex = [indexStr integerValue];
        
    favoriteArray = [[NSUserDefaults standardUserDefaults] objectForKey:kFavorite];
    favoriteArray = [favoriteArray mutableCopy];
    if (!favoriteArray) {
        favoriteArray = [[NSMutableArray alloc] init];
    }
    if (favoriteArray.count > 0) {
        self.navigationItem.rightBarButtonItem = item;
    }
    
    manager = [DocumentManager sharedDocumentManager];
    if (manager.allDYVideosArray.count > 0) {
        _dataArray = manager.allDYVideosArray;
        currentModel = _dataArray.firstObject;
        [self prepareView];
        NSString *str = [NSString stringWithFormat:@"所有视频(%lu)", (unsigned long)_dataArray.count];
        [self showStringHUD:str second:2];
    } else {
        [self showHUD];
        timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(prepareData) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    }
}

// 更改状态栏
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // 导航栏bg
    gestureView = [[UIView alloc] initWithFrame:CGRectMake(100, -20, kScreenWidth-200, 64)];
    gestureView.backgroundColor = [UIColor clearColor];
    [self.navigationController.navigationBar addSubview:gestureView];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] init];
    tapGesture.numberOfTapsRequired = 2;
    tapGesture.numberOfTouchesRequired = 1;
    [tapGesture addTarget:self action:@selector(resetData)];
    [gestureView addGestureRecognizer:tapGesture];
    
    // 放在最上面,否则点击事件没法触发
    [self.navigationController.navigationBar bringSubviewToFront:gestureView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hiddenNaviBar) name:@"isHiddenNaviBar" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playeEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    isPlaying = YES;
    [currentVC playOrPauseVideo:isPlaying];
    [self setButtonPlayState];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    isPlaying = NO;
    [currentVC playOrPauseVideo:isPlaying];
    [self setButtonPlayState];
    [gestureView removeFromSuperview];
}

- (void)prepareData {
    if (manager.allDYVideosArray.count > 0) {
        [self hideAllHUD];
        [timer invalidate];
        timer = nil;
        _dataArray = manager.allDYVideosArray;
        currentModel = _dataArray.firstObject;
        [self prepareView];
        NSString *str = [NSString stringWithFormat:@"所有视频(%lu)", (unsigned long)_dataArray.count];
        [self showStringHUD:str second:2];
    }
}

- (void)prepareView {
    pageVC = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationVertical options:nil];
    pageVC.view.frame = self.view.bounds;
    pageVC.delegate = self;
    pageVC.dataSource = self;
        
    DYSubViewController *subVC = [[DYSubViewController alloc] init];
    subVC.currentIndex = selectIndex;
    subVC.model = _dataArray[selectIndex];
    [pageVC setViewControllers:@[subVC] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    [self.view addSubview:pageVC.view];
    
    NSArray *array = [subVC.model.name componentsSeparatedByString:@"/"];
    self.title = array.lastObject;
    
    currentVC = subVC;
    
    CGRect rect = CGRectMake(kScreenWidth - 120, kScreenHeight - 120, 120, 120);
    UIView *view = [[UIView alloc] initWithFrame:rect];
    view.backgroundColor = [UIColor clearColor];
    [self.view addSubview:view];
    CGRect buttonRect = CGRectMake(20, 20, 80, 80);
    favoriteButton = [[UIButton alloc] initWithFrame:buttonRect];
    if ([favoriteArray containsObject:currentModel.name]) {
        [favoriteButton setImage:[UIImage imageNamed:@"favoriteBig"] forState:UIControlStateNormal];
    } else {
        [favoriteButton setImage:[UIImage imageNamed:@"nofavoriteBig"] forState:UIControlStateNormal];
    }
    [favoriteButton addTarget:self action:@selector(favoriteAction) forControlEvents:UIControlEventTouchUpInside];
    favoriteButton.backgroundColor = [UIColor colorWithWhite:1 alpha:0.7];
    favoriteButton.layer.cornerRadius = 40;
    favoriteButton.layer.masksToBounds = YES;
    [view addSubview:favoriteButton];
    
    isPlaying = YES;
    [currentVC playOrPauseVideo:isPlaying];
    [self setButtonPlayState];

    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self.navigationController setToolbarHidden:YES animated:YES];
}

#pragma mark Events
- (void)playOrPauseVideo {
    isPlaying = !isPlaying;
    [currentVC playOrPauseVideo:isPlaying];
    [self setButtonPlayState];
}

- (void)playerForward {
    [currentVC playerForwardOrRewind:YES];
}

- (void)playerRewind {
    [currentVC playerForwardOrRewind:NO];
}

- (void)playViewLandscape {
    [currentVC playViewLandscape];
}

- (void)hiddenNaviBar {
    if (self.navigationController.navigationBar.hidden == YES) {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        [self.navigationController setToolbarHidden:NO animated:YES];
    } else {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        [self.navigationController setToolbarHidden:YES animated:YES];
    }
}

- (void)playeEnd:(NSNotification *)notification {
    isPlaying = YES;
    [currentVC playOrPauseVideo:YES];
    [self setButtonPlayState];
}

- (void)setButtonPlayState {
    if (isPlaying) {
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPause target:self action:@selector(playOrPauseVideo)];
        NSMutableArray *array = [self.toolbarItems mutableCopy];
        [array replaceObjectAtIndex:3 withObject:item];
        self.toolbarItems = array;
    } else {
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(playOrPauseVideo)];
        NSMutableArray *array = [self.toolbarItems mutableCopy];
        [array replaceObjectAtIndex:3 withObject:item];
        self.toolbarItems = array;
    }
}

- (void)favoriteVideo {
    if (manager.allDYVideosArray.count > 0) {
        DYFavoriteViewController *vc = [[DYFavoriteViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        [self showStringHUD:@"等待遍历完成" second:2];
    }
}

- (void)favoriteAction {
    if ([favoriteArray containsObject:currentModel.name]) {
        [favoriteArray removeObject:currentModel.name];
        [manager removeFavoriteModel:currentModel];
        [favoriteButton setImage:[UIImage imageNamed:@"nofavoriteBig"] forState:UIControlStateNormal];
    } else {
        [favoriteArray addObject:currentModel.name];
        [manager addFavoriteModel:currentModel];
        [favoriteButton setImage:[UIImage imageNamed:@"favoriteBig"] forState:UIControlStateNormal];
    }
}

- (void)resetData {
    selectIndex = arc4random() % _dataArray.count;
    currentVC.currentIndex = selectIndex;
    [self showStringHUD:@"随机播放" second:2];
}

#pragma mark UIPageViewControllerDataSource
// 上一页
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    selectIndex = ((DYSubViewController *) viewController).currentIndex;
    if (selectIndex==0 || selectIndex==NSNotFound) {
        selectIndex = _dataArray.count;
    }
    
    selectIndex--; // 注意: 直接使用VC的顺序index,不要再单独标记了,否则出大问题
    
    DYSubViewController *subVC = [[DYSubViewController alloc] init];
    subVC.currentIndex = selectIndex;
    subVC.model = _dataArray[selectIndex];
    return subVC;
}

// 下一页
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    selectIndex = ((DYSubViewController *) viewController).currentIndex;
    if (selectIndex==_dataArray.count-1 || selectIndex==NSNotFound) {
        selectIndex = -1;
    }
    
    selectIndex++;
    
    DYSubViewController *subVC = [[DYSubViewController alloc] init];
    subVC.currentIndex = selectIndex;
    subVC.model = _dataArray[selectIndex];
    return subVC;
}

#pragma mark UIPageViewControllerDelegate
// 开始滚动或翻页的时候触发
- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray<UIViewController *> *)pendingViewControllers {
    // 获取当前控制器
    currentVC = (DYSubViewController *)pendingViewControllers[0];
    // 获取当前控制器标题
    NSInteger currentIndex = currentVC.currentIndex;
    currentModel = _dataArray[currentIndex];
    NSArray *array = [currentModel.name componentsSeparatedByString:@"/"];
    self.title = array.lastObject;
}

// 结束滚动或翻页的时候触发
- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed {
    if (previousViewControllers.count > 0 && completed) {
        // 获取之前控制器
        DYSubViewController *playVC = (DYSubViewController *)previousViewControllers[0];
        // 停止播放
        [playVC playOrPauseVideo:NO];
        // ToolBar设为暂停状态
        isPlaying = NO;
        [self setButtonPlayState];
        [self playOrPauseVideo];
        NSString *indexStr = [NSString stringWithFormat:@"%ld", (long)selectIndex];
        [[NSUserDefaults standardUserDefaults] setObject:indexStr forKey:@"selectIndex"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        if ([favoriteArray containsObject:currentModel.name]) {
            [favoriteButton setImage:[UIImage imageNamed:@"favoriteBig"] forState:UIControlStateNormal];
        } else {
            [favoriteButton setImage:[UIImage imageNamed:@"nofavoriteBig"] forState:UIControlStateNormal];
        }
    }
}


@end
