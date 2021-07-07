//
//  DYViewController.m
//  GLFiTunesShare
//
//  Created by guolongfei on 2020/2/18.
//  Copyright © 2020 GuoLongfei. All rights reserved.
//

#import "DYViewController.h"
#import "DYSubViewController.h"
#import "DYNextViewController.h"
#import "SelectItemView.h"

@interface DYViewController ()<UIPageViewControllerDataSource, UIPageViewControllerDelegate>
{
    UIPageViewController *pageVC; // 专门用来作电子书效果的,它用来管理其它的视图控制器
    DYSubViewController *currentVC; // 当前显示的VC
    
    NSMutableArray *dataArray;
    FileModel *currentModel;
    NSInteger currentIndex;

    BOOL isPlaying;
    BOOL isNODYVideos;
    BOOL isAutoPlay;
    
    UIView *gestureView; // 导航栏手势
    UILabel *label; // 视频名称
    
    NSMutableArray *favoriteArray; // 收藏
    NSMutableArray *removeArray; // 删除
    UIButton *favoriteButton;
    UIButton *removeButton;
    UIView *editBgView2; // 删除
}
@end

@implementation DYViewController


#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem *barItem1 = [[UIBarButtonItem alloc] initWithTitle:@"选择" style:UIBarButtonItemStylePlain target:self action:@selector(selectVideo)];
    UIBarButtonItem *barItem2 = [[UIBarButtonItem alloc] initWithTitle:@"更多" style:UIBarButtonItemStylePlain target:self action:@selector(moreVideo)];
    self.navigationItem.rightBarButtonItems = @[barItem1, barItem2];
    self.view.backgroundColor = [UIColor blackColor];
    [self setVCTitle:@"抖音短视频"];
    
    isPlaying = NO;
    isNODYVideos = NO;
    isAutoPlay = NO;
    
    UIBarButtonItem *item1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRewind target:self action:@selector(playerRewind)];
    UIBarButtonItem *item2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(playOrPauseVideo)];
    UIBarButtonItem *item3 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFastForward target:self action:@selector(playerForward)];
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil]; // 特殊的一个,用来自动计算宽度
    self.toolbarItems = @[space, item1, space, item2, space, item3, space];
}

// 更改状态栏
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self.navigationController setToolbarHidden:YES animated:YES];
    
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
    
    if (pageVC) {
        return;
    }
    
    // 数据
    favoriteArray = [[NSUserDefaults standardUserDefaults] objectForKey:kFavorite];
    favoriteArray = [favoriteArray mutableCopy];
    if (!favoriteArray) {
        favoriteArray = [[NSMutableArray alloc] init];
    }

    removeArray = [[NSUserDefaults standardUserDefaults] objectForKey:kRemove];
    removeArray = [removeArray mutableCopy];
    if (!removeArray) {
        removeArray = [[NSMutableArray alloc] init];
    }
    
    [self prepareData];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hiddenNaviBar) name:@"isHiddenNaviBar" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(favoriteAction) name:@"favoriteClick" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playeEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    isPlaying = YES;
    [self playOrPause];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [gestureView removeFromSuperview];
    isPlaying = NO;
    [self playOrPause];
}

- (void)prepareData {
    NSString *videoName = [[NSUserDefaults standardUserDefaults] objectForKey:@"VideoCurrent"];
    if (isNODYVideos) {
        [DocumentManager getAllNoDYVideosArray:^(NSArray * array) {
            dataArray = [array mutableCopy];
            for (NSInteger i = 0; i < array.count; i++) {
                FileModel *model = array[i];
                if ([model.name isEqualToString:videoName]) {
                    currentIndex = i;
                    currentModel = model;
                    break;
                }
            }
            if (currentIndex == 0 || currentIndex >= dataArray.count) {
                currentIndex = arc4random() % dataArray.count;
                currentModel = dataArray[currentIndex];
           }
           [self prepareView];
        }];
    } else {
        [DocumentManager getAllDYVideosArray:^(NSArray * array) {
            dataArray = [array mutableCopy];
            for (NSInteger i = 0; i < array.count; i++) {
                FileModel *model = array[i];
                if ([model.name isEqualToString:videoName]) {
                    currentIndex = i;
                    currentModel = model;
                    break;
                }
            }
            if (currentIndex == 0 || currentIndex >= dataArray.count) {
                currentIndex = arc4random() % dataArray.count;
                currentModel = dataArray[currentIndex];
           }
            [self prepareView];
        }];
    }
}

- (void)prepareView {
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ UIPageViewController
    pageVC = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationVertical options:nil];
    pageVC.view.frame = self.view.bounds;
    pageVC.delegate = self;
    pageVC.dataSource = self;
        
    DYSubViewController *subVC = [[DYSubViewController alloc] init];
    subVC.currentIndex = currentIndex;
    subVC.model = dataArray[currentIndex];
    [pageVC setViewControllers:@[subVC] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    [self.view addSubview:pageVC.view];
    
    currentVC = subVC;
    currentModel = subVC.model;
    
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ UIButton
    CGRect rect = CGRectMake(kScreenWidth - 120, kScreenHeight - 120, 120, 120);
    UIView *editBgView1 = [[UIView alloc] initWithFrame:rect];
    editBgView1.backgroundColor = [UIColor clearColor];
    [self.view addSubview:editBgView1];
    CGRect buttonRect = CGRectMake(20, 20, 80, 80);
    favoriteButton = [[UIButton alloc] initWithFrame:buttonRect];
    if ([favoriteArray containsObject:currentModel.name]) {
        [favoriteButton setImage:[UIImage imageNamed:@"dyFavoriteBig"] forState:UIControlStateNormal];
    } else {
        [favoriteButton setImage:[UIImage imageNamed:@"dyNofavoriteBig"] forState:UIControlStateNormal];
    }
    [favoriteButton addTarget:self action:@selector(favoriteAction) forControlEvents:UIControlEventTouchUpInside];
    favoriteButton.backgroundColor = [UIColor colorWithWhite:1 alpha:0.7];
    favoriteButton.layer.cornerRadius = 40;
    favoriteButton.layer.masksToBounds = YES;
    [editBgView1 addSubview:favoriteButton];
    
    CGRect rect2 = CGRectMake(kScreenWidth - 120, kScreenHeight - 210, 120, 120);
    editBgView2 = [[UIView alloc] initWithFrame:rect2];
    editBgView2.backgroundColor = [UIColor clearColor];
    editBgView2.hidden = YES;
    [self.view addSubview:editBgView2];
    CGRect buttonRect2 = CGRectMake(20, 20, 80, 80);
    removeButton = [[UIButton alloc] initWithFrame:buttonRect2];
    if ([removeArray containsObject:currentModel.name]) {
        [removeButton setImage:[UIImage imageNamed:@"dyDeleteBig"] forState:UIControlStateNormal];
    } else {
        [removeButton setImage:[UIImage imageNamed:@"dyNodeleteBig"] forState:UIControlStateNormal];
    }
    [removeButton addTarget:self action:@selector(removeAction) forControlEvents:UIControlEventTouchUpInside];
    removeButton.backgroundColor = [UIColor colorWithWhite:1 alpha:0.7];
    removeButton.layer.cornerRadius = 40;
    removeButton.layer.masksToBounds = YES;
    [editBgView2 addSubview:removeButton];
    
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ title
    label = [[UILabel alloc] init];
    label.numberOfLines = 0;
    label.textColor = [UIColor whiteColor];
    [self.view addSubview:label];
    
    [self setUIBtn];
    [self setLabelTitle];
    
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Other
    isPlaying = YES;
    [self playOrPause];
}

#pragma mark Events
- (void)playOrPauseVideo {
    isPlaying = !isPlaying;
    [self playOrPause];
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
    if (isAutoPlay) {
        [self playRandom:++currentIndex];
    } else {
        isPlaying = YES;
        [self playOrPause];
    }
}

- (void)selectVideo {
    SelectItemView *selectView = [[SelectItemView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth/4*3, kScreenHeight/4*3)];
    selectView.parentVC = self;
    selectView.pageType = 1;
    selectView.dataArray = dataArray;
    selectView.currentModel = currentModel;
    selectView.backgroundColor = [UIColor whiteColor];
    [self lew_presentPopupView:selectView animation:[LewPopupViewAnimationSpring new] dismissed:^{
        NSLog(@"动画结束");
    }];
    [self hiddenNaviBar];
}

- (void)moreVideo {
    isPlaying = NO;
    [self playOrPause];
    
    isNODYVideos = !isNODYVideos;
    [self prepareData];
}

- (void)favoriteAction {
    if ([favoriteArray containsObject:currentModel.name]) {
        [favoriteArray removeObject:currentModel.name];
        [favoriteButton setImage:[UIImage imageNamed:@"dyNofavoriteBig"] forState:UIControlStateNormal];
    } else {
        [favoriteArray addObject:currentModel.name];
        [favoriteButton setImage:[UIImage imageNamed:@"dyFavoriteBig"] forState:UIControlStateNormal];
    }
    [DocumentManager favoriteModel:currentModel];
}

- (void)removeAction {
    if ([removeArray containsObject:currentModel.name]) {
        [removeArray removeObject:currentModel.name];
        [removeButton setImage:[UIImage imageNamed:@"dyNodeleteBig"] forState:UIControlStateNormal];
    } else {
        [removeArray addObject:currentModel.name];
        [removeButton setImage:[UIImage imageNamed:@"dyDeleteBig"] forState:UIControlStateNormal];
    }
    [DocumentManager removeModel:currentModel];
}

- (void)resetData {
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"隐藏功能" message:@"惊不惊喜！意不意外！！！" preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alertVC addAction:cancelAction];
    
    NSString *str1 = @"隐藏删除";
    if (editBgView2.hidden) {
        str1 = @"显示删除";
    }
    UIAlertAction *okAction1 = [UIAlertAction actionWithTitle:str1 style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        editBgView2.hidden = !editBgView2.hidden;
    }];
    [alertVC addAction:okAction1];
    
    UIAlertAction *okAction2 = [UIAlertAction actionWithTitle:@"垃圾篓" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (removeArray.count == 0) {
            [self showStringHUD:@"垃圾篓暂无视频" second:2];
            return;
        }
        DYNextViewController *vc = [[DYNextViewController alloc] init];
        vc.pageType = 2;
        [self.navigationController pushViewController:vc animated:YES];
    }];
    [alertVC addAction:okAction2];
    
    UIAlertAction *okAction3 = [UIAlertAction actionWithTitle:@"收藏夹" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (favoriteArray.count == 0) {
            [self showStringHUD:@"收藏夹暂无视频" second:2];
            return;
        }
        DYNextViewController *vc = [[DYNextViewController alloc] init];
        vc.pageType = 1;
        [self.navigationController pushViewController:vc animated:YES];
    }];
    [alertVC addAction:okAction3];
    
    NSString *str2 = @"自动播放";
    if (isAutoPlay) {
        str2 = @"停止自动播放";
    }
    UIAlertAction *okAction4 = [UIAlertAction actionWithTitle:str2 style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        isAutoPlay = !isAutoPlay;
    }];
    [alertVC addAction:okAction4];
    
    DocumentManager *manager = [DocumentManager sharedDocumentManager];
    if (manager.isRecording) {
        UIAlertAction *okAction5 = [UIAlertAction actionWithTitle:@"切换主题" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [manager switchCamera];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self reSetVCTitle];
            });
        }];
        [alertVC addAction:okAction5];
    }
    
    [self presentViewController:alertVC animated:YES completion:nil];
}

// 用于选择视图回调
- (void)playRandom:(NSInteger)index {
    DYSubViewController *subVC = [[DYSubViewController alloc] init];
    subVC.currentIndex = index;
    subVC.model = dataArray[index];
    [pageVC setViewControllers:@[subVC] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];

    currentVC = subVC;
    currentIndex = index;
    currentModel = dataArray[currentIndex];
    
    [subVC playOrPauseVideo:YES];
    
    [self setUIBtn];
    [self setLabelTitle];
}

#pragma mark UIPageViewControllerDataSource
// 上一页
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    currentIndex = ((DYSubViewController *) viewController).currentIndex;
    if (currentIndex==0 || currentIndex==NSNotFound) {
        currentIndex = dataArray.count;
    }
    
    currentIndex--; // 注意: 直接使用VC的顺序index,不要再单独标记了,否则出大问题
    
    DYSubViewController *subVC = [[DYSubViewController alloc] init];
    subVC.currentIndex = currentIndex;
    subVC.model = dataArray[currentIndex];
    return subVC;
}

// 下一页
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    currentIndex = ((DYSubViewController *) viewController).currentIndex;
    if (currentIndex==dataArray.count-1 || currentIndex==NSNotFound) {
        currentIndex = -1;
    }
    
    currentIndex++;
    
    DYSubViewController *subVC = [[DYSubViewController alloc] init];
    subVC.currentIndex = currentIndex;
    subVC.model = dataArray[currentIndex];
    return subVC;
}

#pragma mark UIPageViewControllerDelegate
// 开始滚动或翻页的时候触发
- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray<UIViewController *> *)pendingViewControllers {
    // 获取要跳转的VC
    currentVC = (DYSubViewController *)pendingViewControllers[0];
    // 获取要跳转的Model
    currentModel = dataArray[currentVC.currentIndex];
}

// 结束滚动或翻页的时候触发
- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed {
    if (previousViewControllers.count > 0) {
        // 获取以前的控VC
        DYSubViewController *vc = (DYSubViewController *)previousViewControllers[0];
        if (completed) {
            // 停止播放
            isPlaying = YES;
            [self playOrPause];

            [self setUIBtn];
            [self setLabelTitle];
        } else {
            // 获取当前控制器
            currentVC = vc;
            // 获取当前Model
            currentModel = dataArray[vc.currentIndex];
            NSLog(@"%@", currentModel.name);
        }
    }
}

#pragma mark Tools
// 存储当前播放位置,设置收藏删除按钮
- (void)setUIBtn {
    if (!isNODYVideos) {
        [[NSUserDefaults standardUserDefaults] setObject:currentModel.name forKey:@"VideoCurrent"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    if ([favoriteArray containsObject:currentModel.name]) {
        [favoriteButton setImage:[UIImage imageNamed:@"dyFavoriteBig"] forState:UIControlStateNormal];
    } else {
        [favoriteButton setImage:[UIImage imageNamed:@"dyNofavoriteBig"] forState:UIControlStateNormal];
    }
    
    if ([removeArray containsObject:currentModel.name]) {
        [removeButton setImage:[UIImage imageNamed:@"dyDeleteBig"] forState:UIControlStateNormal];
    } else {
        [removeButton setImage:[UIImage imageNamed:@"dyNodeleteBig"] forState:UIControlStateNormal];
    }
}

// 设置标题和视频名称
- (void)setLabelTitle {
    // 设置标题
    NSString *title = [NSString stringWithFormat:@"%ld / %ld", currentVC.currentIndex + 1, dataArray.count];
    [self setVCTitle:title];
    
    // 设置视频名称
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

// 播放与暂停
- (void)playOrPause {
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
    [currentVC playOrPauseVideo:isPlaying];
}


@end
