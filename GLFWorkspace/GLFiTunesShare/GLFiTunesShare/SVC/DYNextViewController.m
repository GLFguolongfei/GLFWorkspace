//
//  DYNextViewController.m
//  GLFiTunesShare
//
//  Created by guolongfei on 2020/3/15.
//  Copyright © 2020 GuoLongfei. All rights reserved.
//

#import "DYNextViewController.h"
#import "DYNextSubViewController.h"
#import "SelectItemView.h"

@interface DYNextViewController ()<UIPageViewControllerDataSource, UIPageViewControllerDelegate>
{
    UIPageViewController *pageVC; // 专门用来作电子书效果的,它用来管理其它的视图控制器
    DYNextSubViewController *currentVC; // 当前显示的VC
    BOOL isPlaying;
    
    NSInteger selectIndex;
    NSMutableArray *_dataArray;
    FileModel *currentModel;
    
    NSMutableArray *editArray;
    UIButton *editButton;
    
    UIView *gestureView;
    
    UILabel *label;
}
@end

@implementation DYNextViewController


#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    if (self.pageType == 1) {
        [self setVCTitle:@"抖音短视频"];
    } else {
        [self setVCTitle:@"垃圾篓视频"];
        UIBarButtonItem *barItem = [[UIBarButtonItem alloc] initWithTitle:@"清空" style:UIBarButtonItemStylePlain target:self action:@selector(clearArray)];
        self.navigationItem.rightBarButtonItem = barItem;
    }
    
    isPlaying = NO;
    
    UIBarButtonItem *item1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRewind target:self action:@selector(playerRewind)];
    UIBarButtonItem *item2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(playOrPauseVideo)];
    UIBarButtonItem *item3 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFastForward target:self action:@selector(playerForward)];
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil]; // 特殊的一个,用来自动计算宽度
    
    self.toolbarItems = @[space, item1, space, item2, space, item3, space];
    
    if (self.pageType == 1) {
        editArray = [[NSUserDefaults standardUserDefaults] objectForKey:kFavorite];
    } else {
        editArray = [[NSUserDefaults standardUserDefaults] objectForKey:kRemove];
    }
    editArray = [editArray mutableCopy];
    
    [DocumentManager getAllVideosArray:^(NSArray * array) {
        _dataArray = [[NSMutableArray alloc] init];
        for (NSInteger i = 0; i < array.count; i++) {
            FileModel *model = array[i];
            if ([editArray containsObject: model.name]) {
                [_dataArray addObject:model];
            }
        }
        if (_dataArray.count > 0) {
            selectIndex = arc4random() % _dataArray.count;
            currentModel = _dataArray[selectIndex];
            [self prepareView];
        }
    }];
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
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hiddenNaviBar) name:@"isHiddenNaviBar" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(favoriteAction) name:@"favoriteClick" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playeEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    isPlaying = YES;
    [currentVC playOrPauseVideo:isPlaying];
    [self setButtonState];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [gestureView removeFromSuperview];
    isPlaying = NO;
    [currentVC playOrPauseVideo:isPlaying];
    [self setButtonState];
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
    editButton = [[UIButton alloc] initWithFrame:buttonRect];
    if (self.pageType == 1) {
        if ([editArray containsObject:currentModel.name]) {
            [editButton setImage:[UIImage imageNamed:@"dyFavoriteBig"] forState:UIControlStateNormal];
        } else {
            [editButton setImage:[UIImage imageNamed:@"dyNofavoriteBig"] forState:UIControlStateNormal];
        }
    } else {
        if ([editArray containsObject:currentModel.name]) {
            [editButton setImage:[UIImage imageNamed:@"dyDeleteBig"] forState:UIControlStateNormal];
        } else {
            [editButton setImage:[UIImage imageNamed:@"dyNodeleteBig"] forState:UIControlStateNormal];
        }
    }
    [editButton addTarget:self action:@selector(favoriteAction) forControlEvents:UIControlEventTouchUpInside];
    editButton.backgroundColor = [UIColor colorWithWhite:1 alpha:0.7];
    editButton.layer.cornerRadius = 40;
    editButton.layer.masksToBounds = YES;
    [view addSubview:editButton];
    
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
    NSString *title = [NSString stringWithFormat:@"%ld / %ld", currentVC.currentIndex + 1, _dataArray.count];
    [self setVCTitle:title];
    
    NSArray *array = [currentModel.name componentsSeparatedByString:@"/"];
    NSString *name = array.lastObject;

    NSDictionary *attrbute = @{NSFontAttributeName:[UIFont systemFontOfSize:17]};
    CGRect calculateRect = [name boundingRectWithSize:CGSizeMake(kScreenWidth - 130, MAXFLOAT)
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
    label.text = name;
    label.frame = labelReact;
}

- (void)favoriteAction {
    if (self.pageType == 1) {
        if ([editArray containsObject:currentModel.name]) {
            [editArray removeObject:currentModel.name];
            [editButton setImage:[UIImage imageNamed:@"dyNofavoriteBig"] forState:UIControlStateNormal];
        } else {
            [editArray addObject:currentModel.name];
            [editButton setImage:[UIImage imageNamed:@"dyFavoriteBig"] forState:UIControlStateNormal];
        }
        [DocumentManager favoriteModel:currentModel];
    } else {
        if ([editArray containsObject:currentModel.name]) {
            [editArray removeObject:currentModel.name];
            [editButton setImage:[UIImage imageNamed:@"dyNodeleteBig"] forState:UIControlStateNormal];
        } else {
            [editArray addObject:currentModel.name];
            [editButton setImage:[UIImage imageNamed:@"dyDeleteBig"] forState:UIControlStateNormal];
        }
        [DocumentManager removeModel:currentModel];
    }
}

- (void)resetData {
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"隐藏功能" message:@"惊不惊喜！意不意外！！！" preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alertVC addAction:cancelAction];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"选择播放" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        SelectItemView *selectView = [[SelectItemView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth/4*3, kScreenHeight/4*3)];
        selectView.parentVC = self;
        selectView.pageType = 2;
        selectView.dataArray = _dataArray;
        selectView.currentModel = currentModel;
        selectView.backgroundColor = [UIColor whiteColor];
        [self lew_presentPopupView:selectView animation:[LewPopupViewAnimationSpring new] dismissed:^{
            NSLog(@"动画结束");
        }];
        [self hiddenNaviBar];
    }];
    [alertVC addAction:okAction];
    
    DocumentManager *manager = [DocumentManager sharedDocumentManager];
    if (manager.isRecording) {
        UIAlertAction *okAction2 = [UIAlertAction actionWithTitle:@"切换主题" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [manager switchCamera];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self reSetVCTitle];
            });
        }];
        [alertVC addAction:okAction2];
    }
    
    [self presentViewController:alertVC animated:YES completion:nil];
}

- (void)playRandom:(NSInteger)index {
    // 暂停当前播放
    isPlaying = NO;
    [currentVC playOrPauseVideo:isPlaying];
    [self setButtonState];
    // 切换视频
    selectIndex = index;
    [self prepareView];
    [self showStringHUD:@"切换成功" second:1.5];
}

- (void)clearArray {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    for (NSInteger i = 0; i < editArray.count; i++) {
        NSString *filePath = [NSString stringWithFormat:@"%@/%@", path, editArray[i]];
        [GLFFileManager fileDelete:filePath];
    }
    [DocumentManager eachAllFiles];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:[[NSMutableArray alloc] init] forKey:kRemove];
    [userDefaults synchronize];

    [self showHUD:@"清理中, 不要着急!"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self showStringHUD:@"清空完成" second:2];
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.navigationController popViewControllerAnimated:YES];
    });
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
    // 获取要跳转的VC
    currentVC = (DYNextSubViewController *)pendingViewControllers[0];
    // 获取要跳转的Model
    currentModel = _dataArray[currentVC.currentIndex];
}

// 结束滚动或翻页的时候触发
- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed {
    if (previousViewControllers.count > 0) {
        // 获取以前的控VC
        DYNextSubViewController *vc = (DYNextSubViewController *)previousViewControllers[0];
        if (completed) {
            // 停止播放
            [vc playOrPauseVideo:NO];
            // ToolBar设为暂停状态
            isPlaying = NO;
            [self setButtonState];
            [self playOrPauseVideo];
            
            if (self.pageType == 1) {
                if ([editArray containsObject:currentModel.name]) {
                    [editButton setImage:[UIImage imageNamed:@"dyFavoriteBig"] forState:UIControlStateNormal];
                } else {
                    [editButton setImage:[UIImage imageNamed:@"dyNofavoriteBig"] forState:UIControlStateNormal];
                }
            } else {
                if ([editArray containsObject:currentModel.name]) {
                    [editButton setImage:[UIImage imageNamed:@"dyDeleteBig"] forState:UIControlStateNormal];
                } else {
                    [editButton setImage:[UIImage imageNamed:@"dyNodeleteBig"] forState:UIControlStateNormal];
                }
            }
            
            [self setLabelTitle];
        } else {
            // 获取当前控制器
            currentVC = vc;
            // 获取当前Model
            currentModel = _dataArray[vc.currentIndex];
            NSLog(@"%@", currentModel.name);
        }
    }
}


@end
