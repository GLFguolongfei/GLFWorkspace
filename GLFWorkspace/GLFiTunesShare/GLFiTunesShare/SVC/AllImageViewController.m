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
    UIVisualEffectView *visualEfView;
    BOOL isPlaying;
    
    BOOL isHiddenNavi;
        
    UIView *gestureView;
    BOOL isShowDefault;
    
    FileModel *currentModel;
    
    NSMutableArray *allImagesArray;

    UITableView *_tableView1;
    UITableView *_tableView2;
    UITableView *_tableView3;
    NSMutableArray *_dataArray1;
    NSMutableArray *_dataArray2;
    NSMutableArray *_dataArray3;
    
    NSInteger colums; // 列数
}
@end

@implementation AllImageViewController


#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    if (!self.isPageShow) {
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"缩略图" style:UIBarButtonItemStylePlain target:self action:@selector(scaleImage)];
        self.navigationItem.rightBarButtonItem = item;
    }
    [self setVCTitle:@"所有图片"];
    self.canHiddenNaviBar = YES;
        
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(naviBarChange:) name:@"NaviBarChange" object:nil];
    
    colums = 2;

    // 1-动画者
    animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    // 2-重力仿真行为
    gravityBeahvior = [[UIGravityBehavior alloc] init];
    gravityBeahvior.magnitude = 2.0;
    // 3-添加重力仿真行为
    [animator addBehavior:gravityBeahvior];
    
    _dataArray1 = [[NSMutableArray alloc] init];
    _dataArray2 = [[NSMutableArray alloc] init];
    _dataArray3 = [[NSMutableArray alloc] init];
    
    [self prepareView];
    [self prepareData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSString *type = [[NSUserDefaults standardUserDefaults] objectForKey:@"RootShowType"];
    if ([type isEqualToString:@"1"]) {
        isShowDefault = YES;
    } else {
        isShowDefault = NO;
    }
    
    // 设置背景图片
    bgImageView.image = [DocumentManager getBackgroundImage];
    
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

- (void)didReceiveMemoryWarning {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)prepareData {
    [self showHUD:@"加载中, 不要着急!"];
    if (self.isPageShow) {
        NSInteger allImagesCount = [[NSUserDefaults standardUserDefaults] integerForKey:@"AllImagesCount"];
        [DocumentManager getAllImagesArray:^(NSArray * array) {
            [self hideAllHUD];
            [self rePrepareData:array];
            NSInteger endIndex = self.startIndex + self.pageCount;
            if (endIndex > allImagesCount) {
                endIndex = allImagesCount;
            }
            NSString *title = [NSString stringWithFormat:@"图片(%ld~%ld)", self.startIndex, endIndex];
            [self setVCTitle:title];
        } startIndex:self.startIndex lengthCount:self.pageCount];
    } else {
        [DocumentManager getAllImagesArray:^(NSArray * array) {
            [self hideAllHUD];
            [self rePrepareData:array];
            NSString *title = [NSString stringWithFormat:@"所有图片(%ld)", array.count];
            [self setVCTitle:title];
        }];
    }
}

- (void)rePrepareData:(NSArray *)array {
    if (self.isPageShow) {
        for (NSInteger i = 0; i < array.count; i++) {
            FileModel *model = array[i];
            if (model.size > 1000000) { // 大于1M
                CGFloat scale = [self returnScaleSize:model.size];
                UIImage *scaleImage = [GLFTools scaleImage:model.image toScale:scale];
                model.scaleImage = scaleImage;
            }
        }
    }
    allImagesArray = [array mutableCopy];
    _dataArray1 = [[NSMutableArray alloc] init];
    _dataArray2 = [[NSMutableArray alloc] init];
    _dataArray3 = [[NSMutableArray alloc] init];
    CGFloat height1 = 0;
    CGFloat height2 = 0;
    CGFloat height3 = 0;
    CGFloat width = kScreenWidth/3;
    for (NSInteger i = 0; i < allImagesArray.count; i++) {
        FileModel *model = allImagesArray[i];
        if (colums == 1) {
            [_dataArray1 addObject:model];
        } else if (colums == 2) {
            if (height1 <= height2) {
                [_dataArray1 addObject:model];
                CGFloat height = width * model.image.size.height / model.image.size.width;
                height1 += height;
            } else {
                [_dataArray2 addObject:model];
                CGFloat height = width * model.image.size.height / model.image.size.width;
                height2 += height;
            }
        } else {
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
    }
    [_tableView1 reloadData];
    [_tableView2 reloadData];
    [_tableView3 reloadData];
}

- (void)prepareView {
    // 设置背景图片
    bgImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    bgImageView.contentMode = UIViewContentModeScaleAspectFill;
    bgImageView.image = [DocumentManager getBackgroundImage];
    [self.view addSubview:bgImageView];
    UIVisualEffectView *visualEfView2 = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
    visualEfView2.frame = kScreen;
    visualEfView2.alpha = 0.5;
    [bgImageView addSubview:visualEfView2];
    
    CGRect frame1 = CGRectMake(0, 64, kScreenWidth, kScreenHeight-64);
    if (colums == 2) {
        frame1 = CGRectMake(0, 64, kScreenWidth/2, kScreenHeight-64);
    } else if (colums == 3) {
        frame1 = CGRectMake(0, 64, kScreenWidth/3, kScreenHeight-64);
    }
    _tableView1 = [[UITableView alloc] initWithFrame:frame1 style:UITableViewStylePlain];
    _tableView1.backgroundColor = [UIColor clearColor];
    _tableView1.delegate = self;
    _tableView1.dataSource = self;
    [self.view addSubview:_tableView1];
    _tableView1.showsVerticalScrollIndicator = NO;
    _tableView1.tableFooterView = [UIView new];
    _tableView1.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView1.contentInset = UIEdgeInsetsMake(0, 0, 300, 0);

    if (colums == 2 || colums == 3) {
        CGRect frame2 = CGRectMake(kScreenWidth/2, 64, kScreenWidth/2, kScreenHeight-64);
        if (colums == 3) {
            frame2 = CGRectMake(kScreenWidth/3, 64, kScreenWidth/3, kScreenHeight-64);
        }
        _tableView2 = [[UITableView alloc] initWithFrame:frame2 style:UITableViewStylePlain];
        _tableView2.backgroundColor = [UIColor clearColor];
        _tableView2.delegate = self;
        _tableView2.dataSource = self;
        [self.view addSubview:_tableView2];
        _tableView2.showsVerticalScrollIndicator = NO;
        _tableView2.tableFooterView = [UIView new];
        _tableView2.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView2.contentInset = UIEdgeInsetsMake(0, 0, 300, 0);
    }

    if (colums == 3) {
        CGRect frame3 = CGRectMake(kScreenWidth/3*2, 64, kScreenWidth/3, kScreenHeight-64);
        _tableView3 = [[UITableView alloc] initWithFrame:frame3 style:UITableViewStylePlain];
        _tableView3.backgroundColor = [UIColor clearColor];
        _tableView3.delegate = self;
        _tableView3.dataSource = self;
        [self.view addSubview:_tableView3];
        _tableView3.tableFooterView = [UIView new];
        _tableView3.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView3.contentInset = UIEdgeInsetsMake(0, 0, 300, 0);
    }

    [_tableView1 registerNib:[UINib nibWithNibName:@"ShowTableViewCell" bundle:nil] forCellReuseIdentifier:cellID1];
    [_tableView2 registerNib:[UINib nibWithNibName:@"ShowTableViewCell" bundle:nil] forCellReuseIdentifier:cellID2];
    [_tableView3 registerNib:[UINib nibWithNibName:@"ShowTableViewCell" bundle:nil] forCellReuseIdentifier:cellID3];
    
    visualEfView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
    visualEfView.frame = kScreen;
    visualEfView.alpha = 0;
    [self.view addSubview:visualEfView];
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
    if (allImagesArray.count > 0) {
        NSInteger mmm = arc4random() % allImagesArray.count;
        FileModel *model = allImagesArray[mmm];
        image = [UIImage imageWithContentsOfFile:model.path];
        currentModel = model;
    }
    imageView = [[UIImageView alloc] initWithImage:image];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.frame = CGRectMake(0, 0, 0, 0);
    imageView.center = self.view.center;
//    imageView.transform = CGAffineTransformMakeRotation(-135.0); // 转的人头晕,还是不要了
    [UIView animateWithDuration:1 animations:^{
//        imageView.transform = CGAffineTransformIdentity;
        if (isHiddenNavi) {
            imageView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
        } else {
            imageView.frame = CGRectMake(0, 64, kScreenWidth, kScreenHeight-64);
        }
    }];
    [self.view addSubview:imageView];
    // 3秒后回到主线程执行Block中的代码
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 为重力仿真行为添加动力学元素
        [gravityBeahvior addItem:imageView];
        [self playImage];
    });
    imageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] init];
    [tapGesture addTarget:self action:@selector(showImage)];
    [imageView addGestureRecognizer:tapGesture];
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
    
    UIAlertAction *okAction2 = [UIAlertAction actionWithTitle:@"列数切换" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSInteger col = colums;
        col++;
        if (col > 3) {
            colums = 1;
        } else {
            colums = col;
        }
        [self prepareView];
        [self rePrepareData:allImagesArray];
    }];
    [alertVC addAction:okAction2];
    
    NSString *str = @"";
    if (isPlaying) {
        str = @"停止播放";
    } else {
        str = @"自动播放";
    }
    UIAlertAction *okAction3 = [UIAlertAction actionWithTitle:str style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self autoPlay];
    }];
    [alertVC addAction:okAction3];
    
    DocumentManager *manager = [DocumentManager sharedDocumentManager];
    if (manager.isRecording) {
        UIAlertAction *okAction4 = [UIAlertAction actionWithTitle:@"切换主题" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [manager switchCamera];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self reSetVCTitle];
            });
        }];
        [alertVC addAction:okAction4];
    }
    
    [self presentViewController:alertVC animated:YES completion:nil];
}

- (void)autoPlay {
    isPlaying = !isPlaying;
    if (isPlaying) {
        // 隐藏导航栏
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        NSDictionary *dict = @{@"isHidden": @"1"};
        [[NSNotificationCenter defaultCenter] postNotificationName:@"NaviBarChange" object:self userInfo:dict];
        // 开始播放
        [UIView animateWithDuration:1 animations:^{
            visualEfView.alpha = 0.7;
        } completion:^(BOOL finished) {
            [self playImage];
        }];
    } else {
        [UIView animateWithDuration:1 animations:^{
            imageView.center = CGPointMake(kScreenWidth / 2.0, kScreenHeight * 2);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:1 animations:^{
                visualEfView.alpha = 0;
            }];
        }];
    }
}

- (void)scaleImage {
    [self showHUD:@"加载中, 不要着急!"];
    __block NSInteger count1 = 0;
    __block NSInteger count2 = 0;
    __block NSInteger count3 = 0;
    __block NSInteger loadPage1 = 5;
    __block NSInteger loadPage2 = 5;
    __block NSInteger loadPage3 = 5;
    if (colums == 1) {
        loadPage1 = 15;
    }
    if (colums == 2) {
        loadPage1 = 8;
        loadPage2 = 8;
    }
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        NSArray *array1 = [_tableView1 indexPathsForVisibleRows];
        NSArray *array2 = [_tableView2 indexPathsForVisibleRows];
        NSArray *array3 = [_tableView3 indexPathsForVisibleRows];

        NSInteger first1 = 0;
        if (array1.count > 0) {
            NSIndexPath *indexPath = array1.firstObject;
            first1 = indexPath.row;
        }
        NSInteger first2 = 0;
        if (array2.count > 0) {
            NSIndexPath *indexPath = array2.firstObject;
            first2 = indexPath.row;
        }
        NSInteger first3 = 0;
        if (array3.count > 0) {
            NSIndexPath *indexPath = array3.firstObject;
            first3 = indexPath.row;
        }
        for (NSInteger i = first1; i < _dataArray1.count; i++) {
            if (count1 >= loadPage1) {
                break;
            }
            FileModel *model = _dataArray1[i];
            if (model.size > 1000000) { // 大于1M
                count1++;
                CGFloat scale = [self returnScaleSize:model.size];
                UIImage *scaleImage = [GLFTools scaleImage:model.image toScale:scale];
                model.scaleImage = scaleImage;
                [_dataArray1 replaceObjectAtIndex:i withObject:model];
            }
        }
        for (NSInteger i = first2; i < _dataArray2.count; i++) {
            if (count2 >= loadPage2) {
                break;
            }
            FileModel *model = _dataArray2[i];
            if (model.size > 1000000) { // 大于1M
                count1++;
                CGFloat scale = [self returnScaleSize:model.size];
                UIImage *scaleImage = [GLFTools scaleImage:model.image toScale:scale];
                model.scaleImage = scaleImage;
                [_dataArray2 replaceObjectAtIndex:i withObject:model];
            }
        }
        for (NSInteger i = first3; i < _dataArray3.count; i++) {
            if (count3 >= loadPage3) {
                break;
            }
            FileModel *model = _dataArray3[i];
            if (model.size > 1000000) { // 大于1M
                count3++;
                CGFloat scale = [self returnScaleSize:model.size];
                UIImage *scaleImage = [GLFTools scaleImage:model.image toScale:scale];
                model.scaleImage = scaleImage;
                [_dataArray3 replaceObjectAtIndex:i withObject:model];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideAllHUD];
            [_tableView1 reloadData];
            [_tableView2 reloadData];
            [_tableView3 reloadData];
        });
    });
}

- (void)naviBarChange:(NSNotification *)notify {
    NSDictionary *dict = notify.userInfo;
    CGRect frame1 = _tableView1.frame;
    CGRect frame2 = _tableView2.frame;
    CGRect frame3 = _tableView3.frame;
    if ([dict[@"isHidden"] isEqualToString: @"1"]) {
        isHiddenNavi = YES;
        frame1.origin.y = 0;
        frame1.size.height = kScreenHeight;
        _tableView1.frame = frame1;
        frame2.origin.y = 0;
        frame2.size.height = kScreenHeight;
        _tableView2.frame = frame2;
        frame3.origin.y = 0;
        frame3.size.height = kScreenHeight;
        _tableView3.frame = frame3;
    } else {
        isHiddenNavi = NO;
        frame1.origin.y = 64;
        frame1.size.height = kScreenHeight-64;
        _tableView1.frame = frame1;
        frame2.origin.y = 64;
        frame2.size.height = kScreenHeight-64;
        _tableView2.frame = frame2;
        frame3.origin.y = 64;
        frame3.size.height = kScreenHeight-64;
        _tableView3.frame = frame3;
    }
}

- (void)showImage {
    if (currentModel) {
        if (isShowDefault) {
            NSURL *url = [NSURL fileURLWithPath:currentModel.path];
            UIDocumentInteractionController *documentController = [UIDocumentInteractionController interactionControllerWithURL:url];
            documentController.delegate = self;
            // 显示预览
            BOOL canOpen = [documentController presentPreviewAnimated:YES];
            if (!canOpen) {
                [self showStringHUD:@"沒有程序可以打开要分享的文件" second:1.5];
            }
        } else {
            DetailViewController2 *detailVC = [[DetailViewController2 alloc] init];
            detailVC.selectIndex = [self returnIndex:allImagesArray with:currentModel];
            detailVC.fileArray = allImagesArray;
            [self.navigationController pushViewController:detailVC animated:YES];
        }
    }
}

#pragma mark UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat width = kScreenWidth;
    if (colums == 2) {
        width = kScreenWidth/2;
    } else if (colums == 3) {
        width = kScreenWidth/3;
    }
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
        cell.backgroundColor = [UIColor clearColor];
        if (model.size > 1000000) { // 大于1M
            if (model.scaleImage != nil) {
                cell.scaleImageView.image = model.scaleImage;
            } else {
                cell.scaleImageView.image = [UIImage imageWithColor:[UIColor clearColor]];
            }
        } else {
            cell.scaleImageView.image = model.image;
        }
        return cell;
    } else if (tableView == _tableView2) {
        FileModel *model = _dataArray2[indexPath.row];
        ShowTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID2 forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
        if (model.size > 1000000) { // 大于1M
            if (model.scaleImage != nil) {
                cell.scaleImageView.image = model.scaleImage;
            } else {
                cell.scaleImageView.image = [UIImage imageWithColor:[UIColor clearColor]];
            }
        } else {
            cell.scaleImageView.image = model.image;
        }
        return cell;
    } else if (tableView == _tableView3) {
        FileModel *model = _dataArray3[indexPath.row];
        ShowTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID3 forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
        if (model.size > 1000000) { // 大于1M
            if (model.scaleImage != nil) {
                cell.scaleImageView.image = model.scaleImage;
            } else {
                cell.scaleImageView.image = [UIImage imageWithColor:[UIColor clearColor]];
            }
        } else {
            cell.scaleImageView.image = model.image;
        }
        return cell;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    FileModel *model;
    // 就这么写,否则,进入下一页会自动返回到顶部(2列或3列总有一个)
    if (colums == 1) {
        model = _dataArray1[indexPath.row];
    } else if (colums == 2) {
        if (tableView == _tableView1) {
            model = _dataArray1[indexPath.row];
        } else if (tableView == _tableView2) {
            model = _dataArray2[indexPath.row];
        } else if (tableView == _tableView3) {
            model = _dataArray3[indexPath.row];
        }
    } else {
        if (tableView == _tableView1) {
            model = _dataArray1[indexPath.row];
        } else if (tableView == _tableView2) {
            model = _dataArray2[indexPath.row];
        }
    }
    
    if (isShowDefault) {
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
        detailVC.selectIndex = [self returnIndex:allImagesArray with:model];
        detailVC.fileArray = allImagesArray;
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

// 返回压缩比例
- (CGFloat)returnScaleSize:(CGFloat)fileSize {
    CGFloat scale = 0.1;
    if (fileSize < 1000000) {
        scale = 1;
    } else if (fileSize < 5000000) {
        scale = 0.2;
    } else {
        scale = 0.1;
    }
    return scale;
}


@end
