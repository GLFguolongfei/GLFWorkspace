//
//  FiveViewController.m
//  GLFiTunesShare
//
//  Created by guolongfei on 2020/2/14.
//  Copyright © 2020 GuoLongfei. All rights reserved.
//

#import "FiveViewController.h"
#import "SubViewController3.h"

@interface FiveViewController ()<UIPageViewControllerDataSource, UIPageViewControllerDelegate>
{
    UIPageViewController *pageVC; // 专门用来作电子书效果的,它用来管理其它的视图控制器
    SubViewController3 *currentVC; // 当前显示的VC
    BOOL isPlaying;
    
    NSInteger selectIndex;
    NSMutableArray *_dataArray;
}
@end

@implementation FiveViewController


#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"scale_big"] style:UIBarButtonItemStylePlain target:self action:@selector(playViewLandscape)];
    self.navigationItem.rightBarButtonItems = @[item];
    self.view.backgroundColor = [UIColor blackColor];
    self.title = @"抖音短视频";
    
    isPlaying = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hiddenNaviBar) name:@"isHiddenNaviBar" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playeEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    
    UIBarButtonItem *item1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRewind target:self action:@selector(playerRewind)];
    UIBarButtonItem *item2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(playOrPauseVideo)];
    UIBarButtonItem *item3 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFastForward target:self action:@selector(playerForward)];
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil]; // 特殊的一个,用来自动计算宽度
    
    self.toolbarItems = @[space, item1, space, item2, space, item3, space];
    
    [self prepareData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self hiddenNaviBar];
    NSString *indexStr = [[NSUserDefaults standardUserDefaults] objectForKey:@"selectIndex"];
    selectIndex = [indexStr integerValue];
}

- (void)prepareData {
    [self showHUD];
        
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *hidden = [userDefaults objectForKey:kContentHidden];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        NSMutableArray *resultArray = [[NSMutableArray alloc] init];
        NSArray *array = [GLFFileManager searchSubFile:path andIsDepth:YES];
        NSLog(@"%d", array.count);
        for (int i = 0; i < array.count; i++) {
            if ([array[i] isEqualToString:@"Inbox"]) {
                continue;
            }
            if ([hidden isEqualToString:@"0"] && [array[i] isEqualToString:@"郭龙飞"]) {
                continue;
            }
            FileModel *model = [[FileModel alloc] init];
            model.name = array[i];
            model.path = [NSString stringWithFormat:@"%@/%@", path,model.name];
            NSInteger fileType = [GLFFileManager fileExistsAtPath:model.path];
            if (fileType == 1) { // 文件
                model.isDir = NO;
                NSArray *array = [model.name componentsSeparatedByString:@"."];
                NSString *lowerType = [array.lastObject lowercaseString];
                if ([CvideoTypeArray containsObject:lowerType]) {
                    // 内存警告崩溃
//                    model.image = [GLFTools thumbnailImageRequest:9 andVideoPath:model.path];
                    model.image = nil;
                    CGSize size = [self returnVideoSize:model.path];
                    if (size.width / size.height < (kScreenWidth + 200) / kScreenHeight) {
                        [resultArray addObject:model];
                    }
                }
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideAllHUD];
            NSLog(@"%d", resultArray.count);
            _dataArray = resultArray;
            self.title = [NSString stringWithFormat:@"所有视频(%lu)", (unsigned long)resultArray.count];
            [self prepareView];
        });
    });
}

- (void)prepareView {
    pageVC = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationVertical options:nil];
    pageVC.view.frame = self.view.bounds;
    pageVC.delegate = self;
    pageVC.dataSource = self;
        
    SubViewController3 *subVC = [[SubViewController3 alloc] init];
    subVC.currentIndex = selectIndex;
    subVC.model = _dataArray[selectIndex];
    NSArray *array = [subVC.model.name componentsSeparatedByString:@"/"];
    self.title = array.lastObject;
    currentVC = subVC;
    [pageVC setViewControllers:@[subVC] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    [self.view addSubview:pageVC.view];
    
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

#pragma mark UIPageViewControllerDataSource
// 上一页
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    selectIndex = ((SubViewController3 *) viewController).currentIndex;
    if (selectIndex==0 || selectIndex==NSNotFound) {
        selectIndex = _dataArray.count;
    }
    
    selectIndex--; // 注意: 直接使用VC的顺序index,不要再单独标记了,否则出大问题
    
    SubViewController3 *subVC = [[SubViewController3 alloc] init];
    subVC.currentIndex = selectIndex;
    subVC.model = _dataArray[selectIndex];
    return subVC;
}

// 下一页
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    selectIndex = ((SubViewController3 *) viewController).currentIndex;
    if (selectIndex==_dataArray.count-1 || selectIndex==NSNotFound) {
        selectIndex = -1;
    }
    
    selectIndex++;
    
    SubViewController3 *subVC = [[SubViewController3 alloc] init];
    subVC.currentIndex = selectIndex;
    subVC.model = _dataArray[selectIndex];
    return subVC;
}

#pragma mark UIPageViewControllerDelegate
// 开始滚动或翻页的时候触发
- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray<UIViewController *> *)pendingViewControllers {
    // 获取当前控制器
    currentVC = (SubViewController3 *)pendingViewControllers[0];
    // 获取当前控制器标题
    NSInteger currentIndex = currentVC.currentIndex;
    FileModel *currentModel = _dataArray[currentIndex];
    NSArray *array = [currentModel.name componentsSeparatedByString:@"/"];
    self.title = array.lastObject;
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
        [self playOrPauseVideo];
        NSString *indexStr = [NSString stringWithFormat:@"%ld", (long)selectIndex];
        [[NSUserDefaults standardUserDefaults] setObject:indexStr forKey:@"selectIndex"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

#pragma mark Private Method
- (CGSize)returnVideoSize:(NSString *)path {
    NSURL *url = [NSURL fileURLWithPath:path];
    AVURLAsset *asset = [AVURLAsset assetWithURL:url];
    NSArray *array = asset.tracks;
    CGSize videoSize = CGSizeZero;
    for(AVAssetTrack  *track in array) {
        if([track.mediaType isEqualToString:AVMediaTypeVideo]) {
            videoSize = track.naturalSize;
        }
    }
//    NSLog(@"%f,%f", videoSize.width, videoSize.height);
    return videoSize;
}

@end
