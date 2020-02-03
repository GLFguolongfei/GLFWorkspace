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

static NSString *cellID1 = @"ShowTableViewCell1";
static NSString *cellID2 = @"ShowTableViewCell2";
static NSString *cellID3 = @"ShowTableViewCell3";

@interface AllImageViewController ()<UITableViewDataSource, UITableViewDelegate>
{
    UIDynamicAnimator *animator;          // 动画者
    UIGravityBehavior *gravityBeahvior;   // 仿真行为_重力
    NSArray *imageArray;
    
    UIImageView *imageView;
    UIBarButtonItem *item;
    UIView *background;
    BOOL isPlaying;
    
    UIView *gestureView;
    BOOL isSuccess;
    
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
    
    [self prepareData];
    [self prepareView];
}

- (void)prepareData {
    [self showHUD];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        NSMutableArray *resultArray = [[NSMutableArray alloc] init];
        NSArray *array = [GLFFileManager searchSubFile:path andIsDepth:YES];
        for (int i = 0; i < array.count; i++) {
            // 当其他程序让本程序打开文件时,会自动生成一个Inbox文件夹
            // 这个文件夹是系统权限,不能删除,只可以删除里面的文件,因此这里隐藏好了
            if ([array[i] isEqualToString:@"Inbox"]) {
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
                if ([CimgTypeArray containsObject:lowerType]) {
                    model.size = [GLFFileManager fileSize:model.path];
                    model.image = [UIImage imageWithContentsOfFile:model.path];
                    if (model.size > 1000000) { // 大于1M
                        model.scaleImage = nil;
                    } else {
                        model.scaleImage = model.image;
                    }
                    [resultArray addObject:model];
                }
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideAllHUD];
            imageArray = resultArray;
            self.title = [NSString stringWithFormat:@"所有图片(%lu)", (unsigned long)resultArray.count];
            CGFloat height1 = 0;
            CGFloat height2 = 0;
            CGFloat height3 = 0;
            CGFloat width = kScreenWidth/3;
            for (NSInteger i = 0; i < resultArray.count; i++) {
                FileModel *model = resultArray[i];
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
        });
    });
}

- (void)prepareView {
    _tableView1 = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, kScreenWidth/3, kScreenHeight-64) style:UITableViewStylePlain];
    _tableView1.delegate = self;
    _tableView1.dataSource=self;
    [self.view addSubview:_tableView1];
    _tableView1.showsVerticalScrollIndicator = NO;
    _tableView1.tableFooterView = [UIView new];
    _tableView1.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView1.contentInset = UIEdgeInsetsMake(0, 0, 100, 0);

    _tableView2 = [[UITableView alloc] initWithFrame:CGRectMake(kScreenWidth/3, 64, kScreenWidth/3, kScreenHeight-64) style:UITableViewStylePlain];
    _tableView2.delegate = self;
    _tableView2.dataSource = self;
    [self.view addSubview:_tableView2];
    _tableView2.showsVerticalScrollIndicator = NO;
    _tableView2.tableFooterView = [UIView new];
    _tableView2.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView2.contentInset = UIEdgeInsetsMake(0, 0, 100, 0);

    _tableView3 = [[UITableView alloc] initWithFrame:CGRectMake(kScreenWidth/3*2, 64, kScreenWidth/3, kScreenHeight-64) style:UITableViewStylePlain];
    _tableView3.delegate = self;
    _tableView3.dataSource = self;
    [self.view addSubview:_tableView3];
    _tableView3.tableFooterView = [UIView new];
    _tableView3.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView3.contentInset = UIEdgeInsetsMake(0, 0, 100, 0);

    [_tableView1 registerNib:[UINib nibWithNibName:@"ShowTableViewCell" bundle:nil] forCellReuseIdentifier:cellID1];
    [_tableView2 registerNib:[UINib nibWithNibName:@"ShowTableViewCell" bundle:nil] forCellReuseIdentifier:cellID2];
    [_tableView3 registerNib:[UINib nibWithNibName:@"ShowTableViewCell" bundle:nil] forCellReuseIdentifier:cellID3];
    
    background = [[UIView alloc] initWithFrame:kScreen];
    background.backgroundColor = [UIColor lightGrayColor];
    background.alpha = 0;
    [self.view addSubview:background];
    
    gestureView = [[UIView alloc] initWithFrame:CGRectMake(100, -20, kScreenWidth-200, 64)];
    gestureView.backgroundColor = [UIColor clearColor];
    [self.navigationController.navigationBar addSubview:gestureView];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] init];
    tapGesture.numberOfTapsRequired = 2;
    tapGesture.numberOfTouchesRequired = 1;
    [tapGesture addTarget:self action:@selector(setState)];
    [gestureView addGestureRecognizer:tapGesture];
}

- (void)buttonAction {
    isPlaying = !isPlaying;
    if (isPlaying) {
        item.title = @"停止播放";
        background.alpha = 0.7;
        if (imageView) {
            [gravityBeahvior addItem:imageView];
        }
    } else {
        item.title = @"自动播放";
        [UIView animateWithDuration:4 animations:^{
            background.alpha = 0;
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
    if (imageArray.count > 0) {
        NSInteger mmm = arc4random() % imageArray.count;
        FileModel *model = imageArray[mmm];
        image = [UIImage imageWithContentsOfFile:model.path];
    }
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
    imageView.center = CGPointMake(kScreenWidth / 2.0, -kScreenHeight);
    [UIView animateWithDuration:1.2 animations:^{
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

- (void)hiddenImage {
    // 为重力仿真行为添加动力学元素
    [gravityBeahvior addItem:imageView];
    [UIView animateWithDuration:1 animations:^{
        background.alpha = 0;
    }];
}

- (void)setState {
    isSuccess = !isSuccess;
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
            UIImage *scaleImage = [self scaleImage:model.image toScale:0.1];
            cell.scaleImageView.image = scaleImage;
            model.scaleImage = scaleImage;
            [_dataArray1 replaceObjectAtIndex:indexPath.row withObject:model];
        } else {
            cell.scaleImageView.image = model.scaleImage;
        }
        return cell;
    } else if (tableView == _tableView2) {
        FileModel *model = _dataArray2[indexPath.row];
        ShowTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID2 forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if (model.scaleImage == nil) {
            UIImage *scaleImage = [self scaleImage:model.image toScale:0.1];
            cell.scaleImageView.image = scaleImage;
            model.scaleImage = scaleImage;
            [_dataArray2 replaceObjectAtIndex:indexPath.row withObject:model];
        } else {
            cell.scaleImageView.image = model.scaleImage;
        }
        return cell;
    } else if (tableView == _tableView3) {
        FileModel *model = _dataArray3[indexPath.row];
        ShowTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID3 forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if (model.scaleImage == nil) {
            UIImage *scaleImage = [self scaleImage:model.image toScale:0.1];
            cell.scaleImageView.image = scaleImage;
            model.scaleImage = scaleImage;
            [_dataArray3 replaceObjectAtIndex:indexPath.row withObject:model];
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
         DetailViewController2 *detailVC = [[DetailViewController2 alloc] init];
         detailVC.selectIndex = [self returnIndex:imageArray with:model];
         detailVC.fileArray = imageArray;
         [self.navigationController pushViewController:detailVC animated:YES];
    } else {
        background.alpha = 0.7;

        imageView = [[UIImageView alloc] initWithImage:model.image];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.frame = CGRectMake(0, 0, 10, 10);
        imageView.center = CGPointMake(kScreenWidth / 2.0, (kScreenHeight-64) / 2.0 + 64);
        imageView.alpha = 0;
        [UIView animateWithDuration:0.5 animations:^{
            imageView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
            imageView.center = CGPointMake(kScreenWidth / 2.0, (kScreenHeight-64) / 2.0 + 64);
            imageView.alpha = 1;
        }];
        imageView.userInteractionEnabled = YES;
        [self.view addSubview:imageView];

        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] init];
        [tapGesture addTarget:self action:@selector(hiddenImage)];
        [imageView addGestureRecognizer:tapGesture];
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

#pragma mark Private Method
// 压缩图片
- (UIImage *)scaleImage:(UIImage *)image toScale:(float)scaleSize {
    CGFloat imageW = image.size.width * scaleSize;
    CGFloat imageH = image.size.height * scaleSize;
    UIGraphicsBeginImageContext(CGSizeMake(imageW, imageH));
    [image drawInRect:CGRectMake(0, 0, imageW, imageH)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

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
