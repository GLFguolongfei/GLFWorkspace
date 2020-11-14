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
    BOOL isPlaying;
    
    NSInteger selectIndex;
    NSMutableArray *_dataArray;
    FileModel *currentModel;
    
    NSMutableArray *favoriteArray;
    UIButton *favoriteButton;
    NSMutableArray *removeArray;
    UIButton *removeButton;
    
    BOOL isOtherVideos;
    
    UIView *gestureView;
    
    UILabel *label;
    
    UIBarButtonItem *barItem1;
    UIBarButtonItem *barItem2;
    
    UIView *editBgView1;
    UIView *editBgView2;
}
@end

@implementation DYViewController


#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    barItem1 = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"dyFavorite"] style:UIBarButtonItemStylePlain target:self action:@selector(favoriteVideo)];
    barItem2 = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"dyDelete"] style:UIBarButtonItemStylePlain target:self action:@selector(removeVideo)];
    self.navigationItem.rightBarButtonItems = @[barItem1, barItem2];
    self.view.backgroundColor = [UIColor blackColor];
    [self setVCTitle:@"抖音短视频"];
    
    isPlaying = NO;
    isOtherVideos = NO;
    
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
    if (pageVC) {
        return;
    }
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
    
    // 数据
    NSString *indexStr = [[NSUserDefaults standardUserDefaults] objectForKey:@"selectIndex"];
    selectIndex = [indexStr integerValue];
        
    favoriteArray = [[NSUserDefaults standardUserDefaults] objectForKey:kFavorite];
    favoriteArray = [favoriteArray mutableCopy];
    if (!favoriteArray) {
        favoriteArray = [[NSMutableArray alloc] init];
    }
    if (favoriteArray.count == 0) {
        barItem1.enabled = NO;
    }

    removeArray = [[NSUserDefaults standardUserDefaults] objectForKey:kRemove];
    removeArray = [removeArray mutableCopy];
    if (!removeArray) {
        removeArray = [[NSMutableArray alloc] init];
    }
    if (removeArray.count == 0) {
        barItem2.enabled = NO;
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

- (void)prepareData {
    isPlaying = NO;
    [currentVC playOrPauseVideo:isPlaying];
    [self setButtonState];
    if (isOtherVideos) {
        [DocumentManager getAllNoDYVideosArray:^(NSArray * array) {
            _dataArray = [array mutableCopy];
            if (selectIndex >= _dataArray.count) {
               selectIndex = arc4random() % _dataArray.count;
           }
           currentModel = _dataArray[selectIndex];
           [self prepareView];
           NSString *str = [NSString stringWithFormat:@"所有视频(%lu)", (unsigned long)_dataArray.count];
           [self showStringHUD:str second:2];
        }];
    } else {
        [DocumentManager getAllDYVideosArray:^(NSArray * array) {
            _dataArray = [array mutableCopy];
            if (selectIndex >= _dataArray.count) {
                selectIndex = arc4random() % _dataArray.count;
            }
            currentModel = _dataArray[selectIndex];
            [self prepareView];
            NSString *str = [NSString stringWithFormat:@"所有视频(%lu)", (unsigned long)_dataArray.count];
            [self showStringHUD:str second:2];
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
    subVC.currentIndex = selectIndex;
    subVC.model = _dataArray[selectIndex];
    [pageVC setViewControllers:@[subVC] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    [self.view addSubview:pageVC.view];
    
    currentVC = subVC;
    currentModel = subVC.model;
    
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ UIButton
    CGRect rect = CGRectMake(kScreenWidth - 120, kScreenHeight - 120, 120, 120);
    editBgView1 = [[UIView alloc] initWithFrame:rect];
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
    
    [self setLabelTitle];
    
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Other
    isPlaying = YES;
    [currentVC playOrPauseVideo:isPlaying];
    [self setButtonState];
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

- (void)favoriteVideo {
    DYNextViewController *vc = [[DYNextViewController alloc] init];
    vc.pageType = 1;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)removeVideo {
    DYNextViewController *vc = [[DYNextViewController alloc] init];
    vc.pageType = 2;
    [self.navigationController pushViewController:vc animated:YES];
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

    if (favoriteArray.count > 0) {
        barItem1.enabled = YES;
    } else {
        barItem1.enabled = NO;
    }
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
    if (removeArray.count > 0) {
        barItem2.enabled = YES;
    } else {
        barItem2.enabled = NO;
    }
}

- (void)resetData {
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"隐藏功能" message:@"惊不惊喜！意不意外！！！" preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alertVC addAction:cancelAction];
    
    UIAlertAction *okAction1 = [UIAlertAction actionWithTitle:@"显/隐 删除按钮" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        editBgView2.hidden = !editBgView2.hidden;
    }];
    [alertVC addAction:okAction1];
    
    UIAlertAction *okAction2 = [UIAlertAction actionWithTitle:@"选择播放" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        SelectItemView *selectView = [[SelectItemView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth/4*3, kScreenHeight/4*3)];
        selectView.parentVC = self;
        selectView.pageType = 1;
        selectView.dataArray = _dataArray;
        selectView.currentModel = currentModel;
        selectView.backgroundColor = [UIColor whiteColor];
        [self lew_presentPopupView:selectView animation:[LewPopupViewAnimationSpring new] dismissed:^{
            NSLog(@"动画结束");
        }];
        [self hiddenNaviBar];
    }];
    [alertVC addAction:okAction2];
    
    UIAlertAction *okAction3 = [UIAlertAction actionWithTitle:@"更多视频" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        isOtherVideos = !isOtherVideos;
        [self prepareData];
    }];
    [alertVC addAction:okAction3];
    
    DocumentManager *manager = [DocumentManager sharedDocumentManager];
    if (manager.isRecording) {
        UIAlertAction *okAction4 = [UIAlertAction actionWithTitle:@"切换方向" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [manager switchCamera];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self reSetVCTitle];
            });
        }];
        [alertVC addAction:okAction4];
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
    // 获取要跳转的VC
    currentVC = (DYSubViewController *)pendingViewControllers[0];
    // 获取要跳转的Model
    currentModel = _dataArray[currentVC.currentIndex];
}

// 结束滚动或翻页的时候触发
- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed {
    if (previousViewControllers.count > 0) {
        // 获取以前的控VC
        DYSubViewController *vc = (DYSubViewController *)previousViewControllers[0];
        if (completed) {
            // 停止播放
            [vc playOrPauseVideo:NO];
            // ToolBar设为暂停状态
            isPlaying = NO;
            [self setButtonState];
            [self playOrPauseVideo];
            if (!isOtherVideos) {
                NSString *indexStr = [NSString stringWithFormat:@"%ld", (long)selectIndex];
                [[NSUserDefaults standardUserDefaults] setObject:indexStr forKey:@"selectIndex"];
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
