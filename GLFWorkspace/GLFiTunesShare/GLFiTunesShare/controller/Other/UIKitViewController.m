//
//  UIKitViewController.m
//  GLFiTunesShare
//
//  Created by guolongfei on 2020/1/31.
//  Copyright © 2020 GuoLongfei. All rights reserved.
//

#import "UIKitViewController.h"
#import "ShowTableViewCell.h"

static NSString *cellID1 = @"ShowTableViewCell1";
static NSString *cellID2 = @"ShowTableViewCell2";
static NSString *cellID3 = @"ShowTableViewCell3";

@interface UIKitViewController ()<UITableViewDataSource, UITableViewDelegate>
{
    UIDynamicAnimator *animator;          // 动画者
    UIGravityBehavior *gravityBeahvior;   // 仿真行为_重力
    NSArray *imageArray;
    
    UITableView *_tableView1;
    UITableView *_tableView2;
    UITableView *_tableView3;
    
    NSMutableArray *_dataArray1;
    NSMutableArray *_dataArray2;
    NSMutableArray *_dataArray3;
}
@end

@implementation UIKitViewController


#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"UIKit动力学";

    // 1-动画者
    animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    // 2-重力仿真行为
    gravityBeahvior = [[UIGravityBehavior alloc] init];
    // 3-添加重力仿真行为
    [animator addBehavior:gravityBeahvior];
    
    // 点击手势
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
    [self.view addGestureRecognizer:tapGesture];
    
    _dataArray1 = [[NSMutableArray alloc] init];
    _dataArray2 = [[NSMutableArray alloc] init];
    _dataArray3 = [[NSMutableArray alloc] init];
    
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
                    model.image = [UIImage imageWithContentsOfFile:model.path];
                    [resultArray addObject:model];
                }
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideAllHUD];
            imageArray = resultArray;
            for (NSInteger i = 0; i < resultArray.count; i++) {
                FileModel *model = resultArray[i];
                if (i % 3 == 0) {
                    [_dataArray1 addObject:model.image];
                } else if (i % 3 == 1) {
                    [_dataArray2 addObject:model.image];
                } else if (i % 3 == 2) {
                    [_dataArray3 addObject:model.image];
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
    
    _tableView2 = [[UITableView alloc] initWithFrame:CGRectMake(kScreenWidth/3, 64, kScreenWidth/3, kScreenHeight-64) style:UITableViewStylePlain];
    _tableView2.delegate = self;
    _tableView2.dataSource = self;
    [self.view addSubview:_tableView2];
    _tableView2.showsVerticalScrollIndicator = NO;
    _tableView2.tableFooterView = [UIView new];
    
    _tableView3 = [[UITableView alloc] initWithFrame:CGRectMake(kScreenWidth/3*2, 64, kScreenWidth/3, kScreenHeight-64) style:UITableViewStylePlain];
    _tableView3.delegate = self;
    _tableView3.dataSource = self;
    [self.view addSubview:_tableView3];
    _tableView3.tableFooterView = [UIView new];
    
    [_tableView1 registerNib:[UINib nibWithNibName:@"ShowTableViewCell" bundle:nil] forCellReuseIdentifier:cellID1];
    [_tableView2 registerNib:[UINib nibWithNibName:@"ShowTableViewCell" bundle:nil] forCellReuseIdentifier:cellID2];
    [_tableView3 registerNib:[UINib nibWithNibName:@"ShowTableViewCell" bundle:nil] forCellReuseIdentifier:cellID3];
}

- (void)tapped:(UITapGestureRecognizer *)gesture {
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
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.frame = CGRectMake(0, 0, kScreenWidth, 200);
    imageView.center = [gesture locationInView:gesture.view];
    imageView.center = CGPointMake(kScreenWidth / 2.0, kScreenHeight / 2.0);
    [self.view addSubview:imageView];
    // 3秒后回到主线程执行Block中的代码
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 为重力仿真行为添加动力学元素
        [gravityBeahvior addItem:imageView];
    });
}

#pragma mark UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat width = kScreenWidth/3;
    if (tableView == _tableView1) {
        UIImage *image = _dataArray1[indexPath.row];
        int height = width * image.size.height / image.size.width;
        return height;
    } else if (tableView == _tableView2) {
        UIImage *image = _dataArray2[indexPath.row];
        int height = width * image.size.height / image.size.width;
        return height;
    } else if (tableView == _tableView3) {
        UIImage *image = _dataArray3[indexPath.row];
        int height = width * image.size.height / image.size.width;
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
        ShowTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID1 forIndexPath:indexPath];
        cell.imageView.image = _dataArray1[indexPath.row];
        return cell;
    } else if (tableView == _tableView2) {
        ShowTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID2 forIndexPath:indexPath];
        cell.imageView.image = _dataArray2[indexPath.row];
        return cell;
    } else if (tableView == _tableView3) {
        ShowTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID3 forIndexPath:indexPath];
        cell.imageView.image = _dataArray3[indexPath.row];
        return cell;
    }
    return nil;
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

@end
