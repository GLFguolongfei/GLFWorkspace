//
//  UIKitViewController.m
//  GLFiTunesShare
//
//  Created by guolongfei on 2020/1/31.
//  Copyright © 2020 GuoLongfei. All rights reserved.
//

#import "AllImageViewController.h"
#import "ShowTableViewCell.h"
#import "DetailViewController2.h"
#import "UINavigationController+FDFullscreenPopGesture.h"

static NSString *cellID1 = @"ShowTableViewCell1";
static NSString *cellID2 = @"ShowTableViewCell2";
static NSString *cellID3 = @"ShowTableViewCell3";

@interface AllImageViewController ()<UITableViewDataSource, UITableViewDelegate, UIDocumentInteractionControllerDelegate>
{
    UIDynamicAnimator *animator;          // 动画者
    UIGravityBehavior *gravityBeahvior;   // 仿真行为_重力
    
    UIImageView *bgImageView;
    
    UIImageView *imageView;
    UIBarButtonItem *item;
    UIVisualEffectView *visualEfView;
    BOOL isPlaying;
    
    UIView *gestureView;
    BOOL isSuccess;

    DocumentManager *manager;
    NSTimer *timer; // 定时器
    
    UITableView *_tableView1;
    UITableView *_tableView2;
    UITableView *_tableView3;
    NSMutableArray *_dataArray1;
    NSMutableArray *_dataArray2;
    NSMutableArray *_dataArray3;
}
@end

@implementation AllImageViewController


#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    item = [[UIBarButtonItem alloc] initWithTitle:@"自动播放" style:UIBarButtonItemStylePlain target:self action:@selector(buttonAction)];
    self.navigationItem.rightBarButtonItem = item;
    self.title = @"所有图片";
    
    _dataArray1 = [[NSMutableArray alloc] init];
    _dataArray2 = [[NSMutableArray alloc] init];
    _dataArray3 = [[NSMutableArray alloc] init];

    // 1-动画者
    animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    // 2-重力仿真行为
    gravityBeahvior = [[UIGravityBehavior alloc] init];
    gravityBeahvior.magnitude = 2.0;
    // 3-添加重力仿真行为
    [animator addBehavior:gravityBeahvior];
    
    manager = [DocumentManager sharedDocumentManager];
    if (manager.allImagesArray.count > 0) {
        DocumentManager *manager = [DocumentManager sharedDocumentManager];
        [manager setScaleImage:30];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self prepareData];
        });
    }  else {
        [self showHUD];
        timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(prepareData) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    }
    [self prepareView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSString *type = [[NSUserDefaults standardUserDefaults] objectForKey:@"RootShowType"];
    if ([type isEqualToString:@"1"]) {
        isSuccess = YES;
    } else {
        isSuccess = NO;
    }
    // 1.设置背景图片
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *isUseBackImagePath = [userDefaults objectForKey:IsUseBackImagePath];
    NSString *backName = [userDefaults objectForKey:BackImageName];
    NSArray *cachePaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachePath = [cachePaths objectAtIndex:0];
    NSString *filePath = [cachePath stringByAppendingString:@"/image.png"];
    UIImage *backImage;
    if (isUseBackImagePath.integerValue) {
        backImage = [UIImage imageWithContentsOfFile:filePath];
    } else {
        backImage = [UIImage imageNamed:backName];
    }
    if (backImage == nil) {
        backImage = [UIImage imageNamed:@"bgview"];
        [userDefaults setObject:@"bgview" forKey:BackImageName];
        [userDefaults synchronize];
    }
    bgImageView.image = backImage;
    
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

- (void)prepareData {
    if (manager.allVideosArray.count > 0) {
        [self hideAllHUD];
        CGFloat height1 = 0;
        CGFloat height2 = 0;
        CGFloat height3 = 0;
        CGFloat width = kScreenWidth/3;
        _dataArray1 = [[NSMutableArray alloc] init];
        _dataArray2 = [[NSMutableArray alloc] init];
        _dataArray3 = [[NSMutableArray alloc] init];
        for (NSInteger i = 0; i < manager.allImagesArray.count; i++) {
            FileModel *model = manager.allImagesArray[i];
            if (height1 <= height2 && height1 <= height3) {
                [_dataArray1 addObject:model];
                CGFloat height = width * model.image.size.height / model.image.size.width;
                height1 += height;
            } else if (height2 <= height1 && height2 <= height3) {
                [_dataArray2 addObject:model];
                CGFloat height = width * model.image.size.height / model.image.size.width;
                height2 += height;
            } else if (height3 <= height1 && height3 <= height2) {
                [_dataArray3 addObject:model];
                CGFloat height = width * model.image.size.height / model.image.size.width;
                height3 += height;
            }
        }
        [_tableView1 reloadData];
        [_tableView2 reloadData];
        [_tableView3 reloadData];
    }
}

- (void)prepareView {
    // 设置背景图片
    bgImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    bgImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:bgImageView];
    UIVisualEffectView *visualEfView2 = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
    visualEfView2.frame = kScreen;
    visualEfView2.alpha = 0.5;
    [bgImageView addSubview:visualEfView2];
    
    _tableView1 = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, kScreenWidth/3, kScreenHeight-64) style:UITableViewStylePlain];
    _tableView1.delegate = self;
    _tableView1.dataSource = self;
    [self.view addSubview:_tableView1];
    _tableView1.showsVerticalScrollIndicator = NO;
    _tableView1.tableFooterView = [UIView new];
    _tableView1.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView1.contentInset = UIEdgeInsetsMake(0, 0, 200, 0);

    _tableView2 = [[UITableView alloc] initWithFrame:CGRectMake(kScreenWidth/3, 64, kScreenWidth/3, kScreenHeight-64) style:UITableViewStylePlain];
    _tableView2.delegate = self;
    _tableView2.dataSource = self;
    [self.view addSubview:_tableView2];
    _tableView2.showsVerticalScrollIndicator = NO;
    _tableView2.tableFooterView = [UIView new];
    _tableView2.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView2.contentInset = UIEdgeInsetsMake(0, 0, 200, 0);

    _tableView3 = [[UITableView alloc] initWithFrame:CGRectMake(kScreenWidth/3*2, 64, kScreenWidth/3, kScreenHeight-64) style:UITableViewStylePlain];
    _tableView3.delegate = self;
    _tableView3.dataSource = self;
    [self.view addSubview:_tableView3];
    _tableView3.tableFooterView = [UIView new];
    _tableView3.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView3.contentInset = UIEdgeInsetsMake(0, 0, 200, 0);

    [_tableView1 registerNib:[UINib nibWithNibName:@"ShowTableViewCell" bundle:nil] forCellReuseIdentifier:cellID1];
    [_tableView2 registerNib:[UINib nibWithNibName:@"ShowTableViewCell" bundle:nil] forCellReuseIdentifier:cellID2];
    [_tableView3 registerNib:[UINib nibWithNibName:@"ShowTableViewCell" bundle:nil] forCellReuseIdentifier:cellID3];
    
    visualEfView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
    visualEfView.frame = kScreen;
    visualEfView.alpha = 0;
    [self.view addSubview:visualEfView];
}

- (void)buttonAction {
    isPlaying = !isPlaying;
    if (isPlaying) {
        item.title = @"停止播放";
        visualEfView.alpha = 0.7;
        if (imageView) {
            [gravityBeahvior addItem:imageView];
        }
    } else {
        item.title = @"自动播放";
        [UIView animateWithDuration:4 animations:^{
            visualEfView.alpha = 0;
        }];
    }
    [self playImage];
}

- (void)playImage {
    if (!isPlaying) {
        return;
    }
    NSInteger mmm = arc4random() % 3;
    NSString *name = @"bgview1";
    if (mmm == 0) {
        NSInteger nnn = arc4random() % 9;
        name = [NSString stringWithFormat:@"bgview%ld", nnn];
    } else if (mmm == 1) {
        NSInteger nnn = arc4random() % 13;
        name = [NSString stringWithFormat:@"mv%ld", nnn];
    } else if (mmm == 2) {
        NSInteger nnn = arc4random() % 32;
        name = [NSString stringWithFormat:@"nv%ld", nnn];
    }
    UIImage *image = [UIImage imageNamed:name];
    if (manager.allImagesArray.count > 0) {
        NSInteger mmm = arc4random() % manager.allImagesArray.count;
        FileModel *model = manager.allImagesArray[mmm];
        image = [UIImage imageWithContentsOfFile:model.path];
    }
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
    imageView.center = CGPointMake(kScreenWidth / 2.0, -kScreenHeight);
    [UIView animateWithDuration:1 animations:^{
        imageView.center = CGPointMake(kScreenWidth / 2.0, (kScreenHeight-64) / 2.0 + 64);
    }];
    [self.view addSubview:imageView];
    // 3秒后回到主线程执行Block中的代码
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 为重力仿真行为添加动力学元素
        [gravityBeahvior addItem:imageView];
        [self playImage];
    });
}

- (void)setState {
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"隐藏功能" message:@"惊不惊喜！意不意外！！！" preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alertVC addAction:cancelAction];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"切换预览方式" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        isSuccess = !isSuccess;
        if (isSuccess) {
            [[NSUserDefaults standardUserDefaults] setValue:@"1" forKey:@"RootShowType"];
        } else {
            [[NSUserDefaults standardUserDefaults] setValue:@"0" forKey:@"RootShowType"];
        }
        [[NSUserDefaults standardUserDefaults] synchronize];
    }];
    [alertVC addAction:okAction];
    
    [self presentViewController:alertVC animated:YES completion:nil];
}

#pragma mark UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat width = kScreenWidth/3;
    if (tableView == _tableView1) {
        FileModel *model = _dataArray1[indexPath.row];
        UIImage *image = model.image;
        CGFloat height = width * image.size.height / image.size.width;
        return height;
    } else if (tableView == _tableView2) {
        FileModel *model = _dataArray2[indexPath.row];
        UIImage *image = model.image;
        CGFloat height = width * image.size.height / image.size.width;
        return height;
    } else if (tableView == _tableView3) {
        FileModel *model = _dataArray3[indexPath.row];
        UIImage *image = model.image;
        CGFloat height = width * image.size.height / image.size.width;
        return height;
    } else {
        return 0;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == _tableView1) {
        return _dataArray1.count;
    } else if (tableView ==_tableView2) {
        return _dataArray2.count;
    } else if (tableView ==_tableView3) {
        return _dataArray3.count;
    } else{
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == _tableView1) {
        FileModel *model = _dataArray1[indexPath.row];
        ShowTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID1 forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if (model.scaleImage == nil) {
            cell.scaleImageView.image = [GLFTools scaleImage:model.image toScale:0.1];
        } else {
            cell.scaleImageView.image = model.scaleImage;
        }
        return cell;
    } else if (tableView == _tableView2) {
        FileModel *model = _dataArray2[indexPath.row];
        ShowTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID2 forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if (model.scaleImage == nil) {
            cell.scaleImageView.image = [GLFTools scaleImage:model.image toScale:0.1];
        } else {
            cell.scaleImageView.image = model.scaleImage;
        }
        return cell;
    } else if (tableView == _tableView3) {
        FileModel *model = _dataArray3[indexPath.row];
        ShowTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID3 forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if (model.scaleImage == nil) {
            cell.scaleImageView.image = [GLFTools scaleImage:model.image toScale:0.1];
        } else {
            cell.scaleImageView.image = model.scaleImage;
        }
        return cell;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    FileModel *model;
    if (tableView == _tableView1) {
        model = _dataArray1[indexPath.row];
    } else if (tableView == _tableView2) {
        model = _dataArray2[indexPath.row];
    } else if (tableView == _tableView3) {
        model = _dataArray3[indexPath.row];
    }
    
    if (isSuccess) {
        NSURL *url = [NSURL fileURLWithPath:model.path];
        UIDocumentInteractionController *documentController = [UIDocumentInteractionController interactionControllerWithURL:url];
        documentController.delegate = self;
        // 显示预览
        BOOL canOpen = [documentController presentPreviewAnimated:YES];
        if (!canOpen) {
            [self showStringHUD:@"沒有程序可以打开要分享的文件" second:1.5];
        }
    } else {
        DetailViewController2 *detailVC = [[DetailViewController2 alloc] init];
        detailVC.selectIndex = [self returnIndex:manager.allImagesArray with:model];
        detailVC.fileArray = manager.allImagesArray;
        [self.navigationController pushViewController:detailVC animated:YES];
    }
}

#pragma mark UIScrollViewDelegate
// 在滚动的时候调用
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // 如果1产生偏移 那么让2和3也产生偏移
    if (scrollView == _tableView1) { // 设置开始内容偏移量
        _tableView2.contentOffset = _tableView1.contentOffset;
        _tableView3.contentOffset = _tableView1.contentOffset;
    }
    if (scrollView == _tableView2) {
        _tableView1.contentOffset = _tableView2.contentOffset;
        _tableView3.contentOffset = _tableView2.contentOffset;
    }
    if (scrollView == _tableView3) {
        _tableView1.contentOffset = _tableView3.contentOffset;
        _tableView2.contentOffset = _tableView3.contentOffset;
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


@end
