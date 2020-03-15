//
//  DYNextViewController.m
//  GLFiTunesShare
//
//  Created by guolongfei on 2020/3/15.
//  Copyright © 2020 GuoLongfei. All rights reserved.
//

#import "DYNextViewController.h"
#import "DYNextSubViewController.h"

@interface DYNextViewController ()<UIPageViewControllerDataSource, UIPageViewControllerDelegate>
{
    UIPageViewController *pageVC; // 专门用来作电子书效果的,它用来管理其它的视图控制器
    DYNextSubViewController *currentVC; // 当前显示的VC
    BOOL isPlaying;
    
    NSInteger selectIndex;
    NSMutableArray *_dataArray;
    FileModel *currentModel;
    
    DocumentManager *manager;

    NSMutableArray *favoriteArray;
    UIButton *favoriteButton;
    
    UIView *gestureView;
    BOOL isSuccess;
    
    UILabel *label;
}
@end

@implementation DYNextViewController


#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    if (self.pageType == 1) {
        self.title = @"抖音短视频";
    } else {
        self.title = @"垃圾篓视频";
    }
    
    isPlaying = NO;
    
    UIBarButtonItem *item1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRewind target:self action:@selector(playerRewind)];
    UIBarButtonItem *item2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(playOrPauseVideo)];
    UIBarButtonItem *item3 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFastForward target:self action:@selector(playerForward)];
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil]; // 特殊的一个,用来自动计算宽度
    
    self.toolbarItems = @[space, item1, space, item2, space, item3, space];
    
    if (self.pageType == 1) {
        favoriteArray = [[NSUserDefaults standardUserDefaults] objectForKey:kFavorite];
    } else {
        favoriteArray = [[NSUserDefaults standardUserDefaults] objectForKey:kRemove];
    }
    favoriteArray = [favoriteArray mutableCopy];
    
    manager = [DocumentManager sharedDocumentManager];
    if (manager.allVideosArray.count > 0) {
        _dataArray = [[NSMutableArray alloc] init];
        for (NSInteger i = 0; i < manager.allVideosArray.count; i++) {
            FileModel *model = manager.allVideosArray[i];
            if ([favoriteArray containsObject: model.name]) {
                [_dataArray addObject:model];
            }
        }
        selectIndex = arc4random() % _dataArray.count;
        currentModel = _dataArray[selectIndex];
        [self prepareView];
        NSString *str = [NSString stringWithFormat:@"所有视频(%lu)", (unsigned long)_dataArray.count];
        [self showStringHUD:str second:1.5];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // 导航栏bg
    gestureView = [[UIView alloc] initWithFrame:CGRectMake((kScreenWidth - 150) / 2, -20, 150, 64)];
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(favoriteAction) name:@"favoriteClick" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playeEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [gestureView removeFromSuperview];
}

// 更改状态栏
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)prepareView {
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ UIPageViewController
    pageVC = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationVertical options:nil];
    pageVC.view.frame = self.view.bounds;
    pageVC.delegate = self;
    pageVC.dataSource = self;
        
    DYNextSubViewController *subVC = [[DYNextSubViewController alloc] init];
    subVC.currentIndex = selectIndex;
    subVC.model = _dataArray[selectIndex];
    [pageVC setViewControllers:@[subVC] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    [self.view addSubview:pageVC.view];
    
    currentVC = subVC;
    currentModel = subVC.model;

    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ UIButton
    CGRect rect = CGRectMake(kScreenWidth - 120, kScreenHeight - 120, 120, 120);
    UIView *view = [[UIView alloc] initWithFrame:rect];
    view.backgroundColor = [UIColor clearColor];
    [self.view addSubview:view];
    CGRect buttonRect = CGRectMake(20, 20, 80, 80);
    favoriteButton = [[UIButton alloc] initWithFrame:buttonRect];
    if (self.pageType == 1) {
        if ([favoriteArray containsObject:currentModel.name]) {
            [favoriteButton setImage:[UIImage imageNamed:@"favoriteBig"] forState:UIControlStateNormal];
        } else {
            [favoriteButton setImage:[UIImage imageNamed:@"nofavoriteBig"] forState:UIControlStateNormal];
        }
    } else {
        if ([favoriteArray containsObject:currentModel.name]) {
            [favoriteButton setImage:[UIImage imageNamed:@"deleteBig"] forState:UIControlStateNormal];
        } else {
            [favoriteButton setImage:[UIImage imageNamed:@"nodeleteBig"] forState:UIControlStateNormal];
        }
    }
    [favoriteButton addTarget:self action:@selector(favoriteAction) forControlEvents:UIControlEventTouchUpInside];
    favoriteButton.backgroundColor = [UIColor colorWithWhite:1 alpha:0.7];
    favoriteButton.layer.cornerRadius = 40;
    favoriteButton.layer.masksToBounds = YES;
    [view addSubview:favoriteButton];
    
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ title
    label = [[UILabel alloc] init];
    label.numberOfLines = 0;
    label.textColor = [UIColor whiteColor];
    [self.view addSubview:label];
    
    [self setLabelTitle];
    
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Other
    [self playOrPauseVideo];
}

#pragma mark Events
- (void)playOrPauseVideo {
    isPlaying = !isPlaying;
    [currentVC playOrPauseVideo:isPlaying];
    [self setButtonState];
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
    [self setButtonState];
}

- (void)setButtonState {
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

- (void)setLabelTitle {
    NSArray *array = [currentModel.name componentsSeparatedByString:@"/"];
    self.title = array.lastObject;
    
    NSDictionary *attrbute = @{NSFontAttributeName:[UIFont systemFontOfSize:17]};
    CGRect calculateRect = [self.title boundingRectWithSize:CGSizeMake(kScreenWidth - 130, MAXFLOAT)
       options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
    attributes:attrbute
       context:nil];
    
    CGFloat move = 10;
    if (calculateRect.size.height < 25) {
        move = 55;
    } else if (calculateRect.size.height < 50) {
        move = 40;
    } else if (calculateRect.size.height < 70) {
        move = 30;
    } else if (calculateRect.size.height < 70) {
        move = 20;
    } else {
        move = 15;
    }
    
    CGRect labelReact = CGRectMake(15, kScreenHeight - move - calculateRect.size.height, kScreenWidth - 130, calculateRect.size.height);
    label.text = self.title;
    label.frame = labelReact;
}

- (void)favoriteAction {
    if (self.pageType == 1) {
        if ([favoriteArray containsObject:currentModel.name]) {
            [favoriteArray removeObject:currentModel.name];
            [manager removeFavoriteModel:currentModel];
            [favoriteButton setImage:[UIImage imageNamed:@"nofavoriteBig"] forState:UIControlStateNormal];
        } else {
            [favoriteArray addObject:currentModel.name];
            [manager addFavoriteModel:currentModel];
            [favoriteButton setImage:[UIImage imageNamed:@"favoriteBig"] forState:UIControlStateNormal];
        }
    } else {
        if ([favoriteArray containsObject:currentModel.name]) {
            [favoriteArray removeObject:currentModel.name];
            [manager removeRemoveModel:currentModel];
            [favoriteButton setImage:[UIImage imageNamed:@"nodeleteBig"] forState:UIControlStateNormal];
        } else {
            [favoriteArray addObject:currentModel.name];
            [manager addRemoveModel:currentModel];
            [favoriteButton setImage:[UIImage imageNamed:@"deleteBig"] forState:UIControlStateNormal];
        }
    }
}

- (void)resetData {
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"隐藏功能" message:@"惊不惊喜！意不意外！！！" preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alertVC addAction:cancelAction];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"随机播放" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // 暂停当前播放
        isPlaying = NO;
        [currentVC playOrPauseVideo:isPlaying];
        [self setButtonState];
        // 切换视频
        selectIndex = arc4random() % _dataArray.count;
        [self prepareView];
        [self showStringHUD:@"随机播放" second:1.5];
    }];
    [alertVC addAction:okAction];
    
    [self presentViewController:alertVC animated:YES completion:nil];
}


#pragma mark UIPageViewControllerDataSource
// 上一页
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    selectIndex = ((DYNextSubViewController *) viewController).currentIndex;
    if (selectIndex==0 || selectIndex==NSNotFound) {
        selectIndex = _dataArray.count;
    }
    
    selectIndex--; // 注意: 直接使用VC的顺序index,不要再单独标记了,否则出大问题
    
    DYNextSubViewController *subVC = [[DYNextSubViewController alloc] init];
    subVC.currentIndex = selectIndex;
    subVC.model = _dataArray[selectIndex];
    return subVC;
}

// 下一页
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    selectIndex = ((DYNextSubViewController *) viewController).currentIndex;
    if (selectIndex==_dataArray.count-1 || selectIndex==NSNotFound) {
        selectIndex = -1;
    }
    
    selectIndex++;
    
    DYNextSubViewController *subVC = [[DYNextSubViewController alloc] init];
    subVC.currentIndex = selectIndex;
    subVC.model = _dataArray[selectIndex];
    return subVC;
}

#pragma mark UIPageViewControllerDelegate
// 开始滚动或翻页的时候触发
- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray<UIViewController *> *)pendingViewControllers {
    // 获取当前控制器
    currentVC = (DYNextSubViewController *)pendingViewControllers[0];
    // 获取当前控制器标题
    NSInteger currentIndex = currentVC.currentIndex;
    currentModel = _dataArray[currentIndex];
    [self setLabelTitle];
}

// 结束滚动或翻页的时候触发
- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed {
    if (previousViewControllers.count > 0 && completed) {
        // 获取之前控制器
        DYNextSubViewController *playVC = (DYNextSubViewController *)previousViewControllers[0];
        // 停止播放
        [playVC playOrPauseVideo:NO];
        // ToolBar设为暂停状态
        isPlaying = NO;
        [self setButtonState];
        [self playOrPauseVideo];
        
        if (self.pageType == 1) {
            if ([favoriteArray containsObject:currentModel.name]) {
                [favoriteButton setImage:[UIImage imageNamed:@"favoriteBig"] forState:UIControlStateNormal];
            } else {
                [favoriteButton setImage:[UIImage imageNamed:@"nofavoriteBig"] forState:UIControlStateNormal];
            }
        } else {
            if ([favoriteArray containsObject:currentModel.name]) {
                [favoriteButton setImage:[UIImage imageNamed:@"deleteBig"] forState:UIControlStateNormal];
            } else {
                [favoriteButton setImage:[UIImage imageNamed:@"nodeleteBig"] forState:UIControlStateNormal];
            }
        }
    }
}


@end
