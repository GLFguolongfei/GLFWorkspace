//
//  DYFavoriteViewController.m
//  GLFiTunesShare
//
//  Created by guolongfei on 2020/2/18.
//  Copyright © 2020 GuoLongfei. All rights reserved.
//

#import "DYFavoriteViewController.h"
#import "DYFavoriteSubViewController.h"

@interface DYFavoriteViewController ()<UIPageViewControllerDataSource, UIPageViewControllerDelegate>
{
    UIPageViewController *pageVC; // 专门用来作电子书效果的,它用来管理其它的视图控制器
    DYFavoriteSubViewController *currentVC; // 当前显示的VC
    BOOL isPlaying;
    
    NSInteger selectIndex;
    NSMutableArray *_dataArray;
    FileModel *currentModel;
    
    NSMutableArray *favoriteArray;
    DocumentManager *manager;
    UIButton *favoriteButton;
    
    NSTimer *timer; // 定时器
}
@end

@implementation DYFavoriteViewController


#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    self.title = @"抖音短视频";
    
    isPlaying = NO;
    
    UIBarButtonItem *item1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRewind target:self action:@selector(playerRewind)];
    UIBarButtonItem *item2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(playOrPauseVideo)];
    UIBarButtonItem *item3 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFastForward target:self action:@selector(playerForward)];
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil]; // 特殊的一个,用来自动计算宽度
    
    self.toolbarItems = @[space, item1, space, item2, space, item3, space];
    
    favoriteArray = [[NSUserDefaults standardUserDefaults] objectForKey:kFavorite];
    favoriteArray = [favoriteArray mutableCopy];
    
    manager = [DocumentManager sharedDocumentManager];
    if (manager.allDYVideosArray.count > 0) {
        _dataArray = [[NSMutableArray alloc] init];
        for (NSInteger i = 0; i < manager.allDYVideosArray.count; i++) {
            FileModel *model = manager.allDYVideosArray[i];
            if ([favoriteArray containsObject: model.name]) {
                [_dataArray addObject:model];
            }
        }
        selectIndex = arc4random() % _dataArray.count;
        currentModel = _dataArray[selectIndex];
        [self prepareView];
        NSString *str = [NSString stringWithFormat:@"所有视频(%lu)", (unsigned long)_dataArray.count];
        [self showStringHUD:str second:2];
    } else {
        [self showHUD];
        timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(prepareData) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hiddenNaviBar) name:@"isHiddenNaviBar" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(favoriteAction) name:@"favoriteClick" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playeEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
}

// 更改状态栏
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)prepareData {
    if (manager.allDYVideosArray.count > 0) {
        [self hideAllHUD];
        [timer invalidate];
        timer = nil;
        _dataArray = [[NSMutableArray alloc] init];
        for (NSInteger i = 0; i < manager.allDYVideosArray.count; i++) {
            FileModel *model = manager.allDYVideosArray[i];
            if ([favoriteArray containsObject: model.name]) {
                [_dataArray addObject:model];
            }
        }
        selectIndex = arc4random() % _dataArray.count;
        currentModel = _dataArray[selectIndex];
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
        
    DYFavoriteSubViewController *subVC = [[DYFavoriteSubViewController alloc] init];
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
    
    [self playOrPauseVideo];
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

#pragma mark UIPageViewControllerDataSource
// 上一页
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    selectIndex = ((DYFavoriteSubViewController *) viewController).currentIndex;
    if (selectIndex==0 || selectIndex==NSNotFound) {
        selectIndex = _dataArray.count;
    }
    
    selectIndex--; // 注意: 直接使用VC的顺序index,不要再单独标记了,否则出大问题
    
    DYFavoriteSubViewController *subVC = [[DYFavoriteSubViewController alloc] init];
    subVC.currentIndex = selectIndex;
    subVC.model = _dataArray[selectIndex];
    return subVC;
}

// 下一页
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    selectIndex = ((DYFavoriteSubViewController *) viewController).currentIndex;
    if (selectIndex==_dataArray.count-1 || selectIndex==NSNotFound) {
        selectIndex = -1;
    }
    
    selectIndex++;
    
    DYFavoriteSubViewController *subVC = [[DYFavoriteSubViewController alloc] init];
    subVC.currentIndex = selectIndex;
    subVC.model = _dataArray[selectIndex];
    return subVC;
}

#pragma mark UIPageViewControllerDelegate
// 开始滚动或翻页的时候触发
- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray<UIViewController *> *)pendingViewControllers {
    // 获取当前控制器
    currentVC = (DYFavoriteSubViewController *)pendingViewControllers[0];
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
        DYFavoriteSubViewController *playVC = (DYFavoriteSubViewController *)previousViewControllers[0];
        // 停止播放
        [playVC playOrPauseVideo:NO];
        // ToolBar设为暂停状态
        isPlaying = NO;
        [self setButtonPlayState];
        [self playOrPauseVideo];
        
        if ([favoriteArray containsObject:currentModel.name]) {
            [favoriteButton setImage:[UIImage imageNamed:@"favoriteBig"] forState:UIControlStateNormal];
        } else {
            [favoriteButton setImage:[UIImage imageNamed:@"nofavoriteBig"] forState:UIControlStateNormal];
        }
    }
}


@end
