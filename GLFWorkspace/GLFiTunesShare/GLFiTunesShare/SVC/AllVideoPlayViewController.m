//
//  AllVideoPlayViewController.m
//  GLFiTunesShare
//
//  Created by guolongfei on 2020/3/14.
//  Copyright © 2020 GuoLongfei. All rights reserved.
//

#import "AllVideoPlayViewController.h"
#import "DetailViewController3.h"
#import "FileInfoViewController.h"
#import "PlayVideoTableViewCell.h"

static NSString *cellID = @"PlayVideoTableViewCell";

@interface AllVideoPlayViewController ()<UITableViewDataSource, UITableViewDelegate, UIDocumentInteractionControllerDelegate, UIViewControllerPreviewingDelegate>
{
    UITableView *_tableView;
    NSMutableArray *_dataArray;
    
    UIImageView *bgImageView;
    
    UIView *gestureView;
    BOOL isShowDefault;
    
    UIBarButtonItem *item1;
    UIBarButtonItem *item2;
    Boolean isBig;
    
    NSIndexPath *firstIndexPath;
}
@end

@implementation AllVideoPlayViewController


#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    item1 = [[UIBarButtonItem alloc] initWithTitle:@"标准" style:UIBarButtonItemStylePlain target:self action:@selector(buttonAction1)];
    item2 = [[UIBarButtonItem alloc] initWithTitle:@"全屏" style:UIBarButtonItemStylePlain target:self action:@selector(buttonAction2)];
    self.navigationItem.rightBarButtonItems = @[item1, item2];
    [self setVCTitle:@"所有视频"];
    self.canHiddenNaviBar = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(naviBarChange:) name:@"NaviBarChange" object:nil];
    
    isBig = false;
        
    [self showHUD:@"加载中, 不要着急!"];
    [DocumentManager getAllVideosArray:^(NSArray * array) {
        [self hideAllHUD];
        _dataArray = [array mutableCopy];
        NSString *titleStr = [NSString stringWithFormat:@"视频(%ld)", _dataArray.count];
        [self setVCTitle:titleStr];
        [self prepareView];
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSString *type = [[NSUserDefaults standardUserDefaults] objectForKey:@"RootShowType"];
    if ([type isEqualToString:@"1"]) {
        isShowDefault = YES;
    } else {
        isShowDefault = NO;
    }
    self.navigationController.toolbar.hidden = YES;
    
    // 导航栏bg
    gestureView = [[UIView alloc] initWithFrame:CGRectMake((kScreenWidth - 150) / 2, -20, 150, 64)];
    gestureView.backgroundColor = [UIColor clearColor];
    [self.navigationController.navigationBar addSubview:gestureView];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] init];
    tapGesture.numberOfTapsRequired = 2;
    tapGesture.numberOfTouchesRequired = 1;
    [tapGesture addTarget:self action:@selector(setState)];
    [gestureView addGestureRecognizer:tapGesture];
    
    // 放在最上面,否则点击事件没法触发
    [self.navigationController.navigationBar bringSubviewToFront:gestureView];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [gestureView removeFromSuperview];
}

- (void)prepareView {
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, kScreenWidth, kScreenHeight-64) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    _tableView.tableFooterView = [UIView new];
    
    [_tableView registerClass:[PlayVideoTableViewCell class] forCellReuseIdentifier:cellID];
    
    // 设置背景图片
    bgImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    bgImageView.contentMode = UIViewContentModeScaleAspectFill;
    bgImageView.image = [DocumentManager getBackgroundImage];
    _tableView.backgroundView = bgImageView;
    UIVisualEffectView *visualEfView2 = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
    visualEfView2.frame = kScreen;
    visualEfView2.alpha = 0.5;
    [bgImageView addSubview:visualEfView2];
}

- (void)naviBarChange:(NSNotification *)notify {
    NSDictionary *dict = notify.userInfo;
    if ([dict[@"isHidden"] isEqualToString: @"1"]) {
        _tableView.frame = kScreen;
    } else {
        _tableView.frame = CGRectMake(0, 64, kScreenWidth, kScreenHeight-64);
    }
}

- (void)setState {
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"隐藏功能" message:@"惊不惊喜！意不意外！！！" preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alertVC addAction:cancelAction];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"切换预览方式" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        isShowDefault = !isShowDefault;
        if (isShowDefault) {
            [[NSUserDefaults standardUserDefaults] setValue:@"1" forKey:@"RootShowType"];
        } else {
            [[NSUserDefaults standardUserDefaults] setValue:@"0" forKey:@"RootShowType"];
        }
        [[NSUserDefaults standardUserDefaults] synchronize];
    }];
    [alertVC addAction:okAction];
    
    DocumentManager *manager = [DocumentManager sharedDocumentManager];
    if (manager.isRecording) {
        UIAlertAction *okAction2 = [UIAlertAction actionWithTitle:@"切换方向" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [manager switchCamera];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self reSetVCTitle];
            });
        }];
        [alertVC addAction:okAction2];
    }
    
    [self presentViewController:alertVC animated:YES completion:nil];
}

- (void)buttonAction1 {
    if (isBig == true) {
        isBig = false;
        item1.enabled = NO;
        item2.enabled = YES;
        [_tableView reloadData];
        [_tableView scrollToRowAtIndexPath:firstIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}

- (void)buttonAction2 {
    if (isBig == false) {
        isBig = true;
        item1.enabled = YES;
        item2.enabled = NO;
        [_tableView reloadData];
        [_tableView scrollToRowAtIndexPath:firstIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}

#pragma mark UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (isBig) {
        FileModel *model = _dataArray[indexPath.row];
        CGSize size = model.videoSize;
        CGFloat cellHeight = kScreenWidth * size.height / size.width;
        return cellHeight;
    }
    return 90;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {    
    PlayVideoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];

    FileModel *model = _dataArray[indexPath.row];
    cell.model = model;

    // 3D Touch 可用!
    if (self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable) {
        // 给Cell注册3DTouch的peek和pop功能
        [self registerForPreviewingWithDelegate:self sourceView:cell];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    FileModel *model = _dataArray[indexPath.row];
    NSString *mute = [[NSUserDefaults standardUserDefaults] valueForKey:kVoiceMute];
    NSString *min = [[NSUserDefaults standardUserDefaults] valueForKey:kVoiceMin];
    if (isShowDefault && !mute.integerValue && !min.integerValue) {
        NSURL *url = [NSURL fileURLWithPath:model.path];
        UIDocumentInteractionController *documentController = [UIDocumentInteractionController interactionControllerWithURL:url];
        documentController.delegate = self;
        // 显示预览
        BOOL canOpen = [documentController presentPreviewAnimated:YES];
        if (!canOpen) {
            [self showStringHUD:@"沒有程序可以打开要分享的文件" second:1.5];
        }
    } else {
        // 进入详情页面
        DetailViewController3 *detailVC = [[DetailViewController3 alloc] init];
        detailVC.selectIndex = [self returnIndex:_dataArray with:model];
        detailVC.fileArray = _dataArray;
        [self.navigationController pushViewController:detailVC animated:YES];
    }
}

#pragma mark UIDocumentInteractionControllerDelegate(预览分享)
- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller {
    return self;
}
- (UIView *)documentInteractionControllerViewForPreview:(UIDocumentInteractionController *)controller {
    return self.view;
}

- (CGRect)documentInteractionControllerRectForPreview:(UIDocumentInteractionController *)controller {
    return self.view.frame;
}

#pragma mark UIViewControllerPreviewingDelegate
// peek(预览)
- (nullable UIViewController *)previewingContext:(id <UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location
{
    // 获取按压的Cell所在行,[previewingContext sourceView]就是按压的那个视图
    NSIndexPath *indexPath = [_tableView indexPathForCell:(UITableViewCell* )[previewingContext sourceView]];
    FileModel *model = _dataArray[indexPath.row];
    // 调整不被虚化的范围，按压的那个cell不被虚化（轻轻按压时周边会被虚化，再少用力展示预览，再加力跳页至设定界面）
    CGFloat cellHeight = 90;
    if (isBig) {
        FileModel *model = _dataArray[indexPath.row];
        CGSize size = model.videoSize;
        cellHeight = kScreenWidth * size.height / size.width;
    }
    CGRect rect = CGRectMake(0, 0, self.view.frame.size.width, cellHeight);
    previewingContext.sourceRect = rect;
    // 设定预览的界面
    DetailViewController3 *detailVC = [[DetailViewController3 alloc] init];
    detailVC.selectIndex = [self returnIndex:_dataArray with:model];
    detailVC.fileArray = _dataArray;
    detailVC.isPlay = YES;
    detailVC.preferredContentSize = CGSizeMake(kScreenWidth, kScreenHeight * 0.8);
    return detailVC;
}

// pop(按用点力进入）
- (void)previewingContext:(id <UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit
{
    [self showViewController:viewControllerToCommit sender:self];
}

#pragma mark Private Method
// 获取元素在数组中的下标
- (NSInteger)returnIndex:(NSArray *)array with:(FileModel *)model {
    NSInteger index = 0;
    for (NSInteger i = 0; i < array.count; i++) {
        FileModel *md = array[i];
        if ([model.name isEqualToString:md.name]) {
            index = i;
        }
    }
    return index;
}

#pragma mark UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    // 停止类型1、停止类型2
    BOOL scrollToScrollStop = !scrollView.tracking && !scrollView.dragging && !scrollView.decelerating;
    if (scrollToScrollStop) {
        [self scrollViewDidEndScroll];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        // 停止类型3
        BOOL dragToDragStop = scrollView.tracking && !scrollView.dragging && !scrollView.decelerating;
        if (dragToDragStop) {
            [self scrollViewDidEndScroll];
        }
    }
}

- (void)scrollViewDidEndScroll {
    NSLog(@"停止滚动了！！！");
    NSInteger count = 0;
    NSArray *array = [_tableView indexPathsForVisibleRows];
    for (NSInteger i = 0; i < _dataArray.count; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        PlayVideoTableViewCell *cell = [_tableView cellForRowAtIndexPath:indexPath];
        if ([array containsObject:indexPath]) {
            if (count == 0) {
                firstIndexPath = indexPath;
            }
            count++;
            [cell playOrPauseVideo:YES];
        } else {
            [cell playOrPauseVideo:NO];
        }
    }
}


@end
