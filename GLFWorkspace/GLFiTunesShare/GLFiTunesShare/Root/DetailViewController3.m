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
    BOOL isPlaying;
    
    UIBarButtonItem *barItem1;
    UIBarButtonItem *barItem2;
    
    NSMutableArray *favoriteArray;
    NSMutableArray *removeArray;
}
@end

@implementation DetailViewController3


#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"scale_big"] style:UIBarButtonItemStylePlain target:self action:@selector(playViewLandscape)];
    barItem1 = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"dyFavorite"] style:UIBarButtonItemStylePlain target:self action:@selector(favoriteAction)];
    barItem2 = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"dyDelete"] style:UIBarButtonItemStylePlain target:self action:@selector(removeAction)];
    self.navigationItem.rightBarButtonItems = @[item, barItem1, barItem2];
    self.view.backgroundColor = [UIColor blackColor];
    self.canHiddenNaviBar = YES;
    self.canHiddenToolBar = YES;
    
    isPlaying = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hiddenNaviBar) name:@"isHiddenNaviBar" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playeEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    
    fileManager = [GLFFileManager sharedFileManager];

    pageVC = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    pageVC.view.frame = self.view.bounds;
    pageVC.delegate = self;
    pageVC.dataSource = self;
        
    SubViewController3 *subVC = [[SubViewController3 alloc] init];
    subVC.currentIndex = self.selectIndex;
    subVC.model = self.fileArray[self.selectIndex];
    NSArray *array = [subVC.model.name componentsSeparatedByString:@"/"];
    [self setVCTitle:array.lastObject];
    currentVC = subVC;
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
    
    FileModel *model = [self returnModel];
    
    favoriteArray = [[NSUserDefaults standardUserDefaults] objectForKey:kFavorite];
    favoriteArray = [favoriteArray mutableCopy];
    if (!favoriteArray) {
        favoriteArray = [[NSMutableArray alloc] init];
    }
    if ([favoriteArray containsObject:model.name]) {
        [barItem1 setImage:[UIImage imageNamed:@"dyFavorite"]];
    } else {
        [barItem1 setImage:[UIImage imageNamed:@"dyNofavorite"]];
    }

    removeArray = [[NSUserDefaults standardUserDefaults] objectForKey:kRemove];
    removeArray = [removeArray mutableCopy];
    if (!removeArray) {
        removeArray = [[NSMutableArray alloc] init];
    }
    if ([removeArray containsObject:model.name]) {
        [barItem2 setImage:[UIImage imageNamed:@"dyDelete"]];
    } else {
        [barItem2 setImage:[UIImage imageNamed:@"dyNodelete"]];
    }
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
    }];
    UIPreviewAction *action2 = [UIPreviewAction actionWithTitle:remove style:UIPreviewActionStyleDefault handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
        [DocumentManager removeModel:model];
    }];
    NSArray *actions = @[action1, action2];
    return actions;
}

#pragma mark Events
- (void)favoriteAction {
    FileModel *model = [self returnModel];
    if ([favoriteArray containsObject:model.name]) {
        [favoriteArray removeObject:model.name];
        [barItem1 setImage:[UIImage imageNamed:@"dyNofavorite"]];
    } else {
        [favoriteArray addObject:model.name];
        [barItem1 setImage:[UIImage imageNamed:@"dyFavorite"]];
    }
    [DocumentManager favoriteModel:model];
}

- (void)removeAction {
    FileModel *model = [self returnModel];
    if ([removeArray containsObject:model.name]) {
        [removeArray removeObject:model.name];
        [barItem2 setImage:[UIImage imageNamed:@"dyNodelete"]];
    } else {
        [removeArray addObject:model.name];
        [barItem2 setImage:[UIImage imageNamed:@"dyDelete"]];
    }
    [DocumentManager removeModel:model];
}

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
    // 获取当前控制器
    currentVC = (SubViewController3 *)pendingViewControllers[0];
    // 获取当前控制器标题
    NSInteger currentIndex = currentVC.currentIndex;
    FileModel *currentModel = self.fileArray[currentIndex];
    NSArray *array = [currentModel.name componentsSeparatedByString:@"/"];
    [self setVCTitle:array.lastObject];
}

// 结束滚动或翻页的时候触发
- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed {
    if (previousViewControllers.count > 0 && completed) {
        // 获取之前控制器
        SubViewController3 *playVC = (SubViewController3 *)previousViewControllers[0];
        // 停止播放
        [playVC playOrPauseVideo:NO];
        // ToolBar设为暂停状态
        isPlaying = NO;
        [self setButtonPlayState];
        // 显示导航栏
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        [self.navigationController setToolbarHidden:NO animated:YES];
        [currentVC showBar];
    }
}

#pragma mark Tools
- (FileModel *)returnModel {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    FileModel *model = self.fileArray[self.selectIndex];
    model.name = [model.path substringFromIndex:path.length + 1];
    return model;
}


@end
