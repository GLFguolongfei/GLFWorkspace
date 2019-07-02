//
//  PhotoLibraryViewController.m
//  GLFiTunesShare
//
//  Created by guolongfei on 2017/10/24.
//  Copyright © 2017年 GuoLongfei. All rights reserved.
//

#import "PhotoLibraryViewController.h"
#import <LocalAuthentication/LocalAuthentication.h>
#import "Layout.h"
#import "Cell.h"
#import "PhotoStackView.h"
#import "GLFTools.h"
#import "ImageViewController.h"

static NSString *cellID = @"cellID";

@interface PhotoLibraryViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, PhotoStackViewDataSource, PhotoStackViewDelegate>
{
    UICollectionView *collectionView;
    NSMutableArray *collectionViewArray;
    
    NSMutableArray *nameArray;
    
    PhotoStackView *stackView;
    NSMutableArray *stackViewArray;
    
    UIImageView *background;
    UIImage *showImage;
    
    UIView *gestureView;
    BOOL isSuccess;
}
@end

@implementation PhotoLibraryViewController


#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"设置背景图像";
    self.view.backgroundColor = [UIColor whiteColor];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"选择" style:UIBarButtonItemStylePlain target:self action:@selector(buttonAction:)];
    self.navigationItem.rightBarButtonItem = item;
    self.navigationItem.rightBarButtonItem.enabled = NO;

    collectionViewArray = [[NSMutableArray alloc] init];
    stackViewArray = [[NSMutableArray alloc] init];
    nameArray = [[NSMutableArray alloc] init];

    [self prepareData];
    [self prepareCollectionView];
    [self prepareStackView];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [gestureView removeFromSuperview];
}

- (void)prepareData {
    isSuccess = !isSuccess;
    [collectionViewArray removeAllObjects];
    [nameArray removeAllObjects];
    if (isSuccess) {
        for (NSInteger i = 0; i < 9; i++) {
            NSString *name = [NSString stringWithFormat:@"bgview%ld", i];
            [nameArray addObject:name];
        }
        for (NSInteger i = 0; i < 13; i++) {
            NSString *name = [NSString stringWithFormat:@"mv%ld", i];
            [nameArray addObject:name];
        }
        for (int i = 0; i < nameArray.count; i++) {
            UIImage *image = [UIImage imageNamed:nameArray[i]];
            [collectionViewArray addObject:image];
        }
    } else {
        for (NSInteger i = 0; i < 32; i++) {
            NSString *name = [NSString stringWithFormat:@"nv%ld", i];
            [nameArray addObject:name];
        }
        for (int i = 0; i < nameArray.count; i++) {
            UIImage *image = [UIImage imageNamed:nameArray[i]];
            [collectionViewArray addObject:image];
        }
    }
    [collectionView reloadData];
}

- (void)prepareCollectionView {
    // 1-UICollectionViewLayout
    Layout *layout = [[Layout alloc] init];
    
    // 2-UICollectionView
    collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 64, kScreenWidth, kScreenHeight-64) collectionViewLayout:layout];
    collectionView.backgroundColor = [UIColor whiteColor];
    collectionView.delegate = self;
    collectionView.dataSource = self;
    [self.view addSubview:collectionView];
    
    [collectionView registerClass:[Cell class] forCellWithReuseIdentifier:cellID];
    
    gestureView = [[UIView alloc] initWithFrame:CGRectMake(100, -20, kScreenWidth-200, 64)];
    gestureView.backgroundColor = [UIColor clearColor];
    [self.navigationController.navigationBar addSubview:gestureView];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] init];
    tapGesture.numberOfTapsRequired = 3;
    tapGesture.numberOfTouchesRequired = 1;
    [tapGesture addTarget:self action:@selector(prepareData)];
    [gestureView addGestureRecognizer:tapGesture];
}

- (void)prepareStackView {
    // 1-背景
    background = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    background.backgroundColor = [UIColor clearColor];
    background.alpha = 0;
    background.userInteractionEnabled = YES;
    background.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:background];
    // 2-左右滑动按钮
    CGFloat space = kScreenWidth / 3.0;
    for (int i = 0; i < 3; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(i*space, kScreenHeight-90, space, 90);
        if (i == 0) {
            [button setTitle:@"左滑" forState:UIControlStateNormal];
        } else if (i == 1) {
            [button setTitle:@"取消" forState:UIControlStateNormal];
        } else {
            [button setTitle:@"右滑" forState:UIControlStateNormal];
        }
        [background addSubview:button];
        button.tag = 101 + i;
        [button addTarget:self action:@selector(tapAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    // 3-stackView(宽高比例3:4)
    stackView = [[PhotoStackView alloc] initWithFrame:CGRectMake(15, 80, kScreenWidth-30, 4*(kScreenWidth-30)/3.0)];
    stackView.dataSource = self;
    stackView.delegate = self;
    __weak PhotoLibraryViewController *weakSelf = self;
    stackView.operationBlock = ^{
        ImageViewController *detailVC = [[ImageViewController alloc] init];
        detailVC.selectIndex = weakSelf.title.integerValue;
        detailVC.nameArray = nameArray;
        [weakSelf.navigationController pushViewController:detailVC animated:YES];
    };
    [background addSubview:stackView];
}

#pragma mark Events
- (void)tapAction:(UIButton *)button {
    UIButton *leftButton = (UIButton *)[self.view viewWithTag:101];
    UIButton *rightButton = (UIButton *)[self.view viewWithTag:102];
    leftButton.userInteractionEnabled = NO;
    rightButton.userInteractionEnabled = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        leftButton.userInteractionEnabled = YES;
        rightButton.userInteractionEnabled = YES;
    });
    
    if (button.tag == 101) {
        [stackView leftMoveAnimation];
    } else if (button.tag == 102) {
        [UIView animateWithDuration:1 animations:^{
            background.alpha = 0;
        } completion:^(BOOL finished) {
            self.title = @"设置背景图像";
            self.navigationItem.rightBarButtonItem.enabled = NO;
        }];
    } else if (button.tag == 103) {
        [stackView rightMoveAnimation];
    }
}

- (void)setBackgroundImage:(UIImage *)sourceImage {
    showImage = sourceImage;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        UIImage *resultImage = [GLFTools blurryImage2:sourceImage withBlurLevel:30];
        dispatch_async(dispatch_get_main_queue(), ^{
            background.image = resultImage;
        });
    });
}

- (void)buttonAction:(id)sender {
    // 存储
    NSString *name = nameArray[self.title.integerValue];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:@"0" forKey:IsUseBackImagePath];
    [userDefaults setObject:name forKey:BackImageName];
    [userDefaults synchronize];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark UICollectionViewDelegate
- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    return collectionViewArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    Cell *cell = [cv dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
    cell.label.text = [NSString stringWithFormat:@"%ld", indexPath.item];
    cell.imageView.image = [collectionViewArray objectAtIndex:indexPath.row];
    
    // 注意: 如不重新设置可能会出问题(大小不对)
    if (indexPath.row == 0) {
        cell.imageView.frame = CGRectMake(0, 0, 2*kScreenWidth/3.0, 2*kScreenWidth/3.0*4/3.0);
    } else {
        CGRect rect = cell.imageView.frame;
        rect.size.width = kScreenWidth/3.0;
        rect.size.height = kScreenWidth/3.0*4/3.0;
        cell.imageView.frame = rect;
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    // 1-清空数组
    [stackViewArray removeAllObjects];
    // 2-添加数据
    for (NSInteger i = indexPath.row; i < collectionViewArray.count; i++) {
        id mmm = [collectionViewArray objectAtIndex:i];
        [stackViewArray addObject:mmm];
        
        if (i == indexPath.row) {
            [self setBackgroundImage:mmm];
        }
    }
    // 3-显示stackView
    self.navigationItem.rightBarButtonItem.enabled = YES;
    self.title = [NSString stringWithFormat:@"%ld", indexPath.row];
    [stackView reloadData];
    [UIView animateWithDuration:1 animations:^{
        background.alpha = 1;
    } completion:^(BOOL finished) {
        
    }];
}

#pragma mark PhotoStackViewDataSource
- (NSUInteger)numberOfPhotosInPhotoStackView:(PhotoStackView *)photoStackView {
    return stackViewArray.count;
}

- (UIImage *)photoStackView:(PhotoStackView *)photoStackView photoForIndex:(NSUInteger)index {
    return [stackViewArray objectAtIndex:index];
}

#pragma mark PhotoStackViewDelegate
- (void)photoStackView:(PhotoStackView *)photoStackView willStartMovingPhotoAtIndex:(NSUInteger)index {
//    NSLog(@"将要移动");
}

- (void)photoStackView:(PhotoStackView *)photoStackView didEndMovingPhotoAtIndex:(NSUInteger)index directionLeft:(BOOL)isLeft
{
//    NSLog(@"移动完成");
    NSInteger startIndex = collectionViewArray.count - stackViewArray.count;
    if (index+startIndex >= collectionViewArray.count-1) {
        [UIView animateWithDuration:1 animations:^{
            background.alpha = 0;
        } completion:^(BOOL finished) {
            self.title = @"设置背景图像";
            self.navigationItem.rightBarButtonItem.enabled = NO;
        }];
    } else {
        self.title = [NSString stringWithFormat:@"%ld", startIndex+index+1];
        UIImage *image = [stackViewArray objectAtIndex:index+1];
        [self setBackgroundImage:image];
    }
}


@end
