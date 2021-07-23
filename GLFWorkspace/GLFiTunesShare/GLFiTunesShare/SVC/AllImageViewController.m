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

static NSString *cellID = @"ShowTableViewCell";

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
    CGFloat height1;
    CGFloat height2;
    CGFloat height3;
    
    NSInteger colums; // 列数
    BOOL isloading;
    NSInteger insetHeight;
    NSInteger pageCount;
    NSInteger pageIndex;
}
@end

@implementation AllImageViewController


#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"选择页数" style:UIBarButtonItemStylePlain target:self action:@selector(selectPage)];
    self.navigationItem.rightBarButtonItem = item;
    [self setVCTitle:@"所有图片"];
    self.canHiddenNaviBar = YES;
        
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(naviBarChange:) name:@"NaviBarChange" object:nil];
    
    colums = 2;
    isloading = NO;
    insetHeight = 300;
    pageCount = 30;
    pageIndex = 0;

    // 1-动画者
    animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    // 2-重力仿真行为
    gravityBeahvior = [[UIGravityBehavior alloc] init];
    gravityBeahvior.magnitude = 2.0;
    // 3-添加重力仿真行为
    [animator addBehavior:gravityBeahvior];

    allImagesArray = [[NSMutableArray alloc] init];
    _dataArray1 = [[NSMutableArray alloc] init];
    _dataArray2 = [[NSMutableArray alloc] init];
    _dataArray3 = [[NSMutableArray alloc] init];
    
     height1 = 0;
     height2 = 0;
     height3 = 0;
    
    [self prepareView];
    
    [self showHUD:@"加载中, 不要着急!"];
    [DocumentManager getAllImagesArray:^(NSArray *array) {
        NSInteger end = pageCount;
        if (array.count < pageCount) {
            end = array.count;
        }
        NSInteger oneM = 1024 * 1024;
        for (NSInteger i = 0; i < end; i++) {
            FileModel *model = array[i];
            if (model.size > oneM) { // 大于1M
                CGFloat scale = [self returnScaleSize:model.size];
                UIImage *scaleImage = [GLFTools scaleImage:model.image toScale:scale];
                model.scaleImage = scaleImage;
            }
        }
        [self hideAllHUD];
        allImagesArray = [array mutableCopy];
        [self prepareData];
        NSString *title = [NSString stringWithFormat:@"所有图片(%ld)", array.count];
        [self setVCTitle:title];
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
    if (isloading) {
        return;
    }
    isloading = YES;
    CGFloat width = kScreenWidth/3;
    NSInteger oneM = 1024 * 1024;
    BOOL isInit = NO;
    if (_dataArray1.count == 0 && _dataArray2.count == 0 && _dataArray3.count == 0) {
        isInit = YES;
    }

    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        NSMutableArray *array1 = [[NSMutableArray alloc] init];
        NSMutableArray *array2 = [[NSMutableArray alloc] init];
        NSMutableArray *array3 = [[NSMutableArray alloc] init];
        NSInteger start = pageCount * pageIndex;
        for (NSInteger i = start; i < allImagesArray.count; i++) {
            // 分页
            if (i >= start + pageCount) {
                break;
            }
            // 压缩
            FileModel *model = allImagesArray[i];
            if (model.size > oneM) { // 大于1M
                CGFloat scale = [self returnScaleSize:model.size];
                UIImage *scaleImage = [GLFTools scaleImage:model.image toScale:scale];
                model.scaleImage = scaleImage;
            }
            // 加载
            NSInteger type = 1;
            if (colums == 1) {
                type = 1;
                [_dataArray1 addObject:model];
            } else if (colums == 2) {
                if (height1 <= height2) {
                    type = 1;
                    [_dataArray1 addObject:model];
                    CGFloat height = width * model.image.size.height / model.image.size.width;
                    height1 += height;
                } else {
                    type = 2;
                    [_dataArray2 addObject:model];
                    CGFloat height = width * model.image.size.height / model.image.size.width;
                    height2 += height;
                }
            } else {
                if (height1 <= height2 && height1 <= height3) {
                    type = 1;
                    [_dataArray1 addObject:model];
                    CGFloat height = width * model.image.size.height / model.image.size.width;
                    height1 += height;
                } else if (height2 <= height1 && height2 <= height3) {
                    type = 2;
                    [_dataArray2 addObject:model];
                    CGFloat height = width * model.image.size.height / model.image.size.width;
                    height2 += height;
                } else if (height3 <= height1 && height3 <= height2) {
                    type = 3;
                    [_dataArray3 addObject:model];
                    CGFloat height = width * model.image.size.height / model.image.size.width;
                    height3 += height;
                }
            }
            // NSIndexPath收集
            if (type == 1) {
                NSIndexPath *path = [NSIndexPath indexPathForRow:_dataArray1.count - 1 inSection:0];
                [array1 addObject:path];
            } else if (type == 2) {
                NSIndexPath *path = [NSIndexPath indexPathForRow:_dataArray2.count - 1 inSection:0];
                [array2 addObject:path];
            } else if (type == 3) {
                NSIndexPath *path = [NSIndexPath indexPathForRow:_dataArray3.count - 1 inSection:0];
                [array3 addObject:path];
            }
        }
    
        dispatch_async(dispatch_get_main_queue(), ^{
//            NSLog(@"=== array1 %@", array1);
//            NSLog(@"=== array2 %@", array2);
//            NSLog(@"=== array3 %@", array3);
            
            isloading = NO;
            [_tableView1 reloadData];
            [_tableView2 reloadData];
            [_tableView3 reloadData];
            
//            [_tableView1 beginUpdates];
//            [_tableView2 beginUpdates];
//            [_tableView3 beginUpdates];
//            [_tableView1 insertRowsAtIndexPaths:array1 withRowAnimation:UITableViewRowAnimationFade];
//            [_tableView2 insertRowsAtIndexPaths:array2 withRowAnimation:UITableViewRowAnimationFade];
//            [_tableView3 insertRowsAtIndexPaths:array3 withRowAnimation:UITableViewRowAnimationFade];
//            [_tableView1 endUpdates];
//            [_tableView2 endUpdates];
//            [_tableView3 endUpdates];
//
//            timer = [NSTimer timerWithTimeInterval:0.5 target:self selector:@selector(show) userInfo:nil repeats:NO];
//            [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
        });
    });
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
    _tableView1.contentInset = UIEdgeInsetsMake(0, 0, insetHeight, 0);

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
        _tableView2.contentInset = UIEdgeInsetsMake(0, 0, insetHeight, 0);
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
        _tableView3.contentInset = UIEdgeInsetsMake(0, 0, insetHeight, 0);
    }

    [_tableView1 registerNib:[UINib nibWithNibName:@"ShowTableViewCell" bundle:nil] forCellReuseIdentifier:cellID];
    [_tableView2 registerNib:[UINib nibWithNibName:@"ShowTableViewCell" bundle:nil] forCellReuseIdentifier:cellID];
    [_tableView3 registerNib:[UINib nibWithNibName:@"ShowTableViewCell" bundle:nil] forCellReuseIdentifier:cellID];
    
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
        _dataArray1 = [[NSMutableArray alloc] init];
        _dataArray2 = [[NSMutableArray alloc] init];
        _dataArray3 = [[NSMutableArray alloc] init];
        height1 = 0;
        height2 = 0;
        height3 = 0;
        pageIndex = 0;
        NSInteger col = colums;
        col++;
        if (col > 3) {
            colums = 1;
        } else {
            colums = col;
        }
        [self prepareView];
        [self prepareData];
        [_tableView1 scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
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

- (void)selectPage {
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alertVC addAction:cancelAction];
    
    NSInteger allPages = allImagesArray.count / pageCount;
    if (allImagesArray.count % pageCount != 0) {
        allPages++;
    }
    NSInteger pageInter = 1;
    if (allImagesArray.count > 100 && allImagesArray.count < 500) {
        pageInter = 2;
    } else if (allImagesArray.count < 1000) {
        pageInter = 4;
    } else if (allImagesArray.count < 2000) {
        pageInter = 6;
    } else {
        pageInter = 8;
    }
    for (NSInteger i = 0; i < allPages; i++) {
        if (i % pageInter != 0) {
            continue;
        }
        NSInteger startIndex = pageCount * i;
        NSInteger endIndex = pageCount * (i + 1);
        if (endIndex > allImagesArray.count) {
            endIndex = allImagesArray.count;
        }
        NSString *str = [NSString stringWithFormat:@"第 %ld 页（%ld ~ %ld）", i + 1, startIndex, endIndex];
        if (i == pageIndex) {
            str = [NSString stringWithFormat:@"-> 第 %ld 页（%ld ~ %ld）", i + 1, startIndex, endIndex];
        }
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:str style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            _dataArray1 = [[NSMutableArray alloc] init];
            _dataArray2 = [[NSMutableArray alloc] init];
            _dataArray3 = [[NSMutableArray alloc] init];
            [_tableView1 reloadData];
            [_tableView2 reloadData];
            [_tableView3 reloadData];
            height1 = 0;
            height2 = 0;
            height3 = 0;
            pageIndex = i;
            [self prepareData];
//            [_tableView1 scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        }];
        [alertVC addAction:okAction];
    }
    
    [self presentViewController:alertVC animated:YES completion:nil];
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
        ShowTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
        if (model.scaleImage != nil) {
            cell.scaleImageView.image = model.scaleImage;
        } else if (model.image != nil) {
            cell.scaleImageView.image = model.image;
        } else {
            cell.scaleImageView.image = [UIImage imageWithColor:[UIColor clearColor]];
        }
        return cell;
    } else if (tableView == _tableView2) {
        FileModel *model = _dataArray2[indexPath.row];
        ShowTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
        if (model.scaleImage != nil) {
            cell.scaleImageView.image = model.scaleImage;
        } else if (model.image != nil) {
            cell.scaleImageView.image = model.image;
        } else {
            cell.scaleImageView.image = [UIImage imageWithColor:[UIColor clearColor]];
        }
        return cell;
    } else if (tableView == _tableView3) {
        FileModel *model = _dataArray3[indexPath.row];
        ShowTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
        if (model.scaleImage != nil) {
            cell.scaleImageView.image = model.scaleImage;
        } else if (model.image != nil) {
            cell.scaleImageView.image = model.image;
        } else {
            cell.scaleImageView.image = [UIImage imageWithColor:[UIColor clearColor]];
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

    // 分页
    CGPoint point = scrollView.contentOffset;
    CGSize size = scrollView.contentSize;
//    NSLog(@"%@ %@", NSStringFromCGSize(size), NSStringFromCGPoint(point));
    if (point.y > size.height - insetHeight - 300) {
        if (pageIndex * pageCount < allImagesArray.count && !isloading) {
            pageIndex++;
            [self prepareData];
            NSLog(@"分页加载 %ld", pageIndex + 1);
        }
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
