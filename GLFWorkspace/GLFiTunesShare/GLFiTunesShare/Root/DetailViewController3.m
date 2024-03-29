//
//  DetailViewController3.m
//  GLFiTunesShare
//
//  Created by guolongfei on 2018/5/30.
//  Copyright © 2018年 GuoLongfei. All rights reserved.
//

#import "DetailViewController3.h"
#import "VideoToolView.h"
#import "GLFLewPopupViewAnimationSlide.h"

@interface DetailViewController3 ()<UIPageViewControllerDataSource, UIPageViewControllerDelegate>
{
    UIPageViewController *pageVC; // 专门用来作电子书效果的,它用来管理其它的视图控制器
    FileModel *currentModel;

    BOOL isPlaying;
    
    NSMutableArray *favoriteArray;
    NSMutableArray *removeArray;
    
    UIView *gestureView;
}
@end

@implementation DetailViewController3


#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"scale_big"] style:UIBarButtonItemStylePlain target:self action:@selector(playViewLandscape)];
    self.navigationItem.rightBarButtonItems = @[item];
    self.view.backgroundColor = [UIColor blackColor];
    self.canHiddenNaviBar = YES;
    self.canHiddenToolBar = YES;
    
    isPlaying = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hiddenNaviBar) name:@"isHiddenNaviBar" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playeEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    
    pageVC = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    pageVC.view.frame = self.view.bounds;
    pageVC.delegate = self;
    pageVC.dataSource = self;
        
    SubViewController3 *subVC = [[SubViewController3 alloc] init];
    subVC.currentIndex = self.selectIndex;
    subVC.model = self.fileArray[self.selectIndex];
    NSArray *array = [subVC.model.name componentsSeparatedByString:@"/"];
    [self setVCTitle:array.lastObject];
    
    self.currentVC = subVC;
    currentModel = subVC.model;

    [pageVC setViewControllers:@[subVC] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    [self.view addSubview:pageVC.view];
    
    if (self.isPlay) {
        [self playOrPauseVideo];
    }
    
    self.navigationController.toolbarHidden = NO;
    
    UIBarButtonItem *item1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRewind target:self action:@selector(playerRewind)];
    UIBarButtonItem *item2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(playOrPauseVideo)];
    UIBarButtonItem *item3 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFastForward target:self action:@selector(playerForward)];
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil]; // 特殊的一个,用来自动计算宽度
    
    self.toolbarItems = @[space, item1, space, item2, space, item3, space];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.toolbar.hidden = NO;
    
    // 导航栏bg
    gestureView = [[UIView alloc] initWithFrame:CGRectMake((kScreenWidth - 150) / 2, -20, 150, 64)];
    gestureView.backgroundColor = [UIColor clearColor];
    [self.navigationController.navigationBar addSubview:gestureView];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] init];
    tapGesture.numberOfTapsRequired = 2;
    tapGesture.numberOfTouchesRequired = 1;
    [tapGesture addTarget:self action:@selector(naviAction)];
    [gestureView addGestureRecognizer:tapGesture];
    
    // 放在最上面,否则点击事件没法触发
    [self.navigationController.navigationBar bringSubviewToFront:gestureView];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [gestureView removeFromSuperview];
    // 停止播放
    [self.currentVC playOrPauseVideo:NO];
}

// 更改状态栏
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark 预览
- (NSArray<id<UIPreviewActionItem>> *)previewActionItems {
    FileModel *model = [self returnModel];
    NSArray *favoriteArray = [[NSUserDefaults standardUserDefaults] objectForKey:kFavorite];
    NSArray *removeArray = [[NSUserDefaults standardUserDefaults] objectForKey:kRemove];
    NSString *favorite = @"收藏";
    NSString *remove = @"删除";
    if ([favoriteArray containsObject:model.name]) {
        favorite = @"取消收藏";
    }
    if ([removeArray containsObject:model.name]) {
        remove = @"取消删除";
    }
    
    UIPreviewAction *action1 = [UIPreviewAction actionWithTitle:favorite style:UIPreviewActionStyleDefault handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
        [DocumentManager favoriteModel:model];
        if ([favoriteArray containsObject:model.name]) {
            [self showStringHUD:@"取消收藏" second:1.5];
        } else {
            [self showStringHUD:@"已收藏" second:1.5];
        }
    }];
    UIPreviewAction *action2 = [UIPreviewAction actionWithTitle:remove style:UIPreviewActionStyleDefault handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
        [DocumentManager removeModel:model];
        if ([removeArray containsObject:model.name]) {
            [self showStringHUD:@"取消删除" second:1.5];
        } else {
            [self showStringHUD:@"已删除" second:1.5];
        }
    }];
    NSArray *actions = @[action1, action2];
    return actions;
}

#pragma mark Events
- (void)playOrPauseVideo {
    isPlaying = !isPlaying;
    [self.currentVC playOrPauseVideo:isPlaying];
    [self setButtonPlayState];
}

- (void)playerForward {
    [self.currentVC playerForwardOrRewind:YES];
}

- (void)playerRewind {
    [self.currentVC playerForwardOrRewind:NO];
}

- (void)playViewLandscape {
    [self.currentVC playViewLandscape];
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
    isPlaying = false;
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

- (void)naviAction {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"isHiddenNaviBar" object:self userInfo:nil];
    VideoToolView *toolView = [[VideoToolView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 200)];
    toolView.parentVC = self;
    toolView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    GLFLewPopupViewAnimationSlide *animation = [[GLFLewPopupViewAnimationSlide alloc]init];
    animation.type = LewPopupViewAnimationSlideTypeBottomBottom;
    [self lew_presentPopupView:toolView animation:animation dismissed:^{
        NSLog(@"动画结束");
        [[NSNotificationCenter defaultCenter] postNotificationName:@"isHiddenNaviBar" object:self userInfo:nil];
    }];
}

- (void)playTime:(NSInteger)time {
    [self.currentVC playTime:time];
}

- (void)playRate:(CGFloat)rate {
    [self.currentVC playRate:rate];
    isPlaying = YES;
    [self setButtonPlayState];
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
    // 获取要跳转的VC
    self.currentVC = (SubViewController3 *)pendingViewControllers[0];
    // 获取要跳转的Model
    currentModel = self.fileArray[self.currentVC.currentIndex];
    NSLog(@"%@", currentModel.name);
}

// 结束滚动或翻页的时候触发
- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed {
    // VC1跳转VC2
    // 无论跳转是否成功,结果都是: pendingViewControllers为VC2 previousViewControllers为VC1
    // 区别在于: 跳转成功,当前为VC2 跳转失败,当前为VC1
    if (previousViewControllers.count > 0) {
        // 获取以前的控VC
        SubViewController3 *vc = (SubViewController3 *)previousViewControllers[0];
        if (completed) { // 跳转成功
            // 停止播放
            [vc playOrPauseVideo:NO];
            // ToolBar设为暂停状态
            isPlaying = NO;
            [self setButtonPlayState];
            // 显示导航栏
            if (self.navigationController.navigationBar.hidden == YES) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"isHiddenNaviBar" object:self userInfo:nil];
            }
            // 设置标题
            NSArray *array = [currentModel.name componentsSeparatedByString:@"/"];
            [self setVCTitle:array.lastObject];
        } else { // 跳转失败
            // 获取当前控制器
            self.currentVC = vc;
            // 获取当前Model
            currentModel = self.fileArray[self.currentVC.currentIndex];
            NSLog(@"%@", currentModel.name);
        }
    }
}

#pragma mark Tools
- (FileModel *)returnModel {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    FileModel *model = currentModel;
    model.name = [model.path substringFromIndex:path.length + 1];
    return model;
}


@end
