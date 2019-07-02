//
//  RootViewController.m
//  GLFiTunesShare
//
//  Created by guolongfei on 2017/9/29.
//  Copyright © 2017年 GuoLongfei. All rights reserved.
//

#import "RootViewController.h"
#import "DetailViewController.h"
#import "DetailViewController2.h"
#import "DetailViewController3.h"
#import "SetupViewController.h"
#import "MoveViewController.h"
#import "FileInfoViewController.h"

@interface RootViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    UITableView *myTableView;
    NSMutableArray *myDataArray;
    
    GLFFileManager *fileManager;

    UIImageView *bgImageView;
    
    NSIndexPath *editIndexPath;
    NSMutableArray *editArray;
}
@end

@implementation RootViewController


#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    fileManager = [GLFFileManager sharedFileManager];
    myDataArray = [[NSMutableArray alloc] init];
    editArray = [[NSMutableArray alloc] init];

    [self prepareInterface];
}

- (void)viewWillAppear:(BOOL)animated {
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
    // 2.设置数据源
    [self prepareData];
}

- (void)viewDidAppear:(BOOL)animated {
    if (self.moveModel) {
        MoveViewController *editVC = [[MoveViewController alloc] init];
        editVC.modelArray = @[self.moveModel];
        [self presentViewController:editVC animated:YES completion:nil];
        self.moveModel = nil;
        return;
    }
}

- (void)prepareData {
    [myDataArray removeAllObjects];
    [editArray removeAllObjects];
    if (self.pathStr.length == 0) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        self.pathStr = [paths objectAtIndex:0];
    }
    fileManager.currentPath = self.pathStr;
    [self showHUD];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        NSMutableArray *cArray = [[NSMutableArray alloc] init];
        NSArray *array = [GLFFileManager searchSubFile:self.pathStr andIsDepth:NO];
        for (int i = 0; i < array.count; i++) {
            // 当其他程序让本程序打开文件时,会自动生成一个Inbox文件夹
            // 这个文件夹是系统权限,不能删除,只可以删除里面的文件,因此这里隐藏好了
            if ([array[i] isEqualToString:@"Inbox"]) {
                continue;
            }
            FileModel *model = [[FileModel alloc] init];
            model.name = array[i];
            model.path = [NSString stringWithFormat:@"%@/%@", self.pathStr,model.name];
            model.attributes = [GLFFileManager attributesOfItemAtPath:model.path];
            NSInteger fileType = [GLFFileManager fileExistsAtPath:model.path];
            if (fileType == 1) { // 文件
                model.isDir = NO;
                model.size = [GLFFileManager fileSize:model.path];
                NSArray *array = [model.name componentsSeparatedByString:@"."];
                NSString *lowerType = [array.lastObject lowercaseString];
                if ([CimgTypeArray containsObject:lowerType]) {
                    model.image = [UIImage imageWithContentsOfFile:model.path];
                } else if ([CvideoTypeArray containsObject:lowerType]) {
                    model.image = [GLFTools thumbnailImageRequest:9 andVideoPath:model.path];
                }
            } else if (fileType == 2) { // 文件夹
                model.isDir = YES;
                model.size = [GLFFileManager fileSizeForDir:model.path];
                model.count = [model.attributes[@"NSFileReferenceCount"] integerValue];
            }
            [cArray addObject:model];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideAllHUD];
            [myDataArray removeAllObjects];
            [myDataArray addObjectsFromArray:cArray];
            [myTableView reloadData];
        });
    });
}

- (void)prepareInterface {
    // 导航栏UINavigationBar
    if (self.titleStr.length > 0) {
        self.title = self.titleStr;
    } else {
        self.title = @"NSDocumentDirectory";
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"设置" style:UIBarButtonItemStylePlain target:self action:@selector(buttonAction1:)];
        self.navigationItem.leftBarButtonItem = item;
    }
    if (self.navigationController.viewControllers.count > 3) {
        UIBarButtonItem *item1 = [[UIBarButtonItem alloc] initWithTitle:@"选择" style:UIBarButtonItemStylePlain target:self action:@selector(buttonAction3:)];
        UIBarButtonItem *item2 = [[UIBarButtonItem alloc] initWithTitle:@"返回首页" style:UIBarButtonItemStylePlain target:self action:@selector(buttonAction2:)];
        self.navigationItem.rightBarButtonItems = @[item1, item2];
    } else {
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"选择" style:UIBarButtonItemStylePlain target:self action:@selector(buttonAction3:)];
        self.navigationItem.rightBarButtonItem = item;
    }
    
    // 工具栏UIToolbar
    self.navigationController.toolbarHidden = YES;
    UIBarButtonItem *item1 = [[UIBarButtonItem alloc] initWithTitle:@"新文件夹" style:UIBarButtonItemStylePlain target:self action:@selector(createAction:)];
    UIBarButtonItem *item2 = [[UIBarButtonItem alloc] initWithTitle:@"移动" style:UIBarButtonItemStylePlain target:self action:@selector(moveAction:)];
    item2.enabled = NO;
    UIBarButtonItem *item3 = [[UIBarButtonItem alloc] initWithTitle:@"删除" style:UIBarButtonItemStylePlain target:self action:@selector(deleteAction:)];
    item3.enabled = NO;
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil]; // 特殊的一个,用来自动计算宽度
    self.toolbarItems = @[item1, space, item2, space, item3];
    
    // 数据列表
    CGRect rect = CGRectMake(0, 64, kScreenWidth, kScreenHeight-64);
    myTableView = [[UITableView alloc] initWithFrame:rect style:UITableViewStylePlain];
    myTableView.delegate = self;
    myTableView.dataSource = self;
    myTableView.separatorInset = UIEdgeInsetsMake(0, -20, 0, 0);
    myTableView.allowsMultipleSelectionDuringEditing = YES;
    [self.view addSubview:myTableView];
    myTableView.tableFooterView = [[UIView alloc] init];

    // 设置背景图片
    bgImageView = [[UIImageView alloc] initWithFrame:myTableView.frame];
    bgImageView.contentMode = UIViewContentModeScaleAspectFill;
    myTableView.backgroundView = bgImageView;
}

#pragma mark Events
// 设置
- (void)buttonAction1:(id)sender {
    SetupViewController *setupVC = [[SetupViewController alloc] init];
    [self.navigationController pushViewController:setupVC animated:YES];
}

// 返回首页
- (void)buttonAction2:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

// 选择
- (void)buttonAction3:(id)sender {
    UIBarButtonItem *item = sender;
    if ([item.title isEqualToString:@"选择"]) {
        [self viewEditing:NO];
    } else {
        [self viewEditing:YES];
    }
}

// 新文件夹
- (void)createAction:(id)sender {
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"新文件夹" message:@"请为此文件夹输入新名称。" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [self viewEditing:YES];
    }];
    [alertVC addAction:cancelAction];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"创建" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (alertVC.textFields.count > 0) {
            UITextField *textField = alertVC.textFields.firstObject;
            NSLog(@"新建文件夹名称: %@", textField.text);
            
            NSString *path = [NSString stringWithFormat:@"%@/%@", fileManager.currentPath, textField.text];
            BOOL success = [GLFFileManager createFolder:path];
            if (success && editArray.count!=0) { // 如果有选中,则移动到新建文件夹中
                dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
                dispatch_async(queue, ^{
                    for (int i = 0; i < editArray.count; i++) {
                        FileModel *model = editArray[i];
                        NSString *toPath = [NSString stringWithFormat:@"%@/%@", path, model.name];
                        BOOL success = [GLFFileManager fileMove:model.path toPath:toPath];
                        if (!success) {
                            NSLog(@"%@ 移动失败", editArray[i]);
                        }
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self prepareData];
                        [self viewEditing:YES];
                    });
                });
            } else {
                [self prepareData];
                [self viewEditing:YES];
            }
            [GLFFileManager updateDocumentPaths];
        }
    }];
    [alertVC addAction:okAction];
    [alertVC addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"文件夹名称";
    }];
    [self presentViewController:alertVC animated:YES completion:nil];
}

// 移动
- (void)moveAction:(id)sender {
    MoveViewController *editVC = [[MoveViewController alloc] init];
    editVC.modelArray = editArray;
    [self presentViewController:editVC animated:YES completion:nil];
}

// 删除
- (void)deleteAction:(id)sender {
    NSString *str = [NSString stringWithFormat:@"%ld 个项目将从您的设备存储中删除。此操作不能撤销。",editArray.count];
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"" message:str preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [self viewEditing:YES];
    }];
    [alertVC addAction:cancelAction];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"从设备删除" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(queue, ^{
            for (int i = 0; i < editArray.count; i++) {
                FileModel *model = editArray[i];
                BOOL success = [GLFFileManager fileDelete:model.path];
                if (!success) {
                    NSLog(@"%@ 删除失败", editArray[i]);
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self prepareData];
                [self viewEditing:YES];
                [GLFFileManager updateDocumentPaths];
            });
        });
    }];
    [alertVC addAction:okAction];
    [self presentViewController:alertVC animated:YES completion:nil];
}

// editing: 是否恢复如初
- (void)viewEditing:(BOOL)editing {
    UIBarButtonItem *item = self.navigationItem.rightBarButtonItems[0];
    if (editing) {
        item.title = @"选择";
        self.navigationController.toolbarHidden = YES;
        [myTableView setEditing:NO animated:YES];
        
        UIBarButtonItem *item1 = self.toolbarItems[2]; // 移动
        UIBarButtonItem *item2 = self.toolbarItems[4]; // 删除
        item1.enabled = NO;
        item2.enabled = NO;
    } else {
        item.title = @"取消";
        self.navigationController.toolbarHidden = NO;
        [myTableView setEditing:YES animated:YES];
    }
    [editArray removeAllObjects];
}

#pragma mark UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return myDataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"UITableViewCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    // 背景色
    UIView *view = [[UIView alloc] initWithFrame:cell.frame];
    view.backgroundColor = [UIColor clearColor];
    cell.selectedBackgroundView = view;
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
    // 样式
    cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.numberOfLines = 3; // 写的是X,但其实最多显示X-1行,原因未知
    cell.detailTextLabel.textColor = [UIColor colorWithWhite:1 alpha:0.7];
    // 内容
    FileModel *model = myDataArray[indexPath.row];
    cell.textLabel.text = model.name;
    if (model.isDir) { // 文件夹
        NSString *sizeStr = [GLFFileManager returenSizeStr:model.size];
        cell.imageView.image = [UIImage imageNamed:@"wenjianjia"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld 项  %@", model.count, sizeStr];
    } else { // 文件
        NSArray *array = [model.name componentsSeparatedByString:@"."];
        NSString *lowerType = [array.lastObject lowercaseString];
        if ([CimgTypeArray containsObject:lowerType] && model.image.size.width > 0) { // 图片
            if (model.image.size.width > 0) { // 有时image会解析出错
                cell.imageView.image = model.image;
            } else {
                cell.imageView.image = [UIImage imageNamed:@"图片"];
            }
        } else if ([CvideoTypeArray containsObject:lowerType]) { // 视频
            if (model.image.size.width > 0) { // 有时image会解析出错
                cell.imageView.image = model.image;
            } else {
                cell.imageView.image = [UIImage imageNamed:@"video"];
            }
        } else { // 其它文件类型
            cell.imageView.image = [UIImage imageNamed:@"wenjian"];
        }
        cell.accessoryType = UITableViewCellAccessoryDetailButton;
        cell.detailTextLabel.text = @"";
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    FileModel *model = myDataArray[indexPath.row];
    if (myTableView.editing == YES) {
        [editArray addObject:model];
        UIBarButtonItem *item1 = self.toolbarItems[2]; // 移动
        UIBarButtonItem *item2 = self.toolbarItems[4]; // 删除
        item1.enabled = YES;
        item2.enabled = YES;
        return;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSInteger fileType = [GLFFileManager fileExistsAtPath:model.path];
    if (fileType == 1) { // 文件
        // 获取所有类型文件
        NSMutableArray *imageArray = [[NSMutableArray alloc] init];
        NSMutableArray *videoArray = [[NSMutableArray alloc] init];
        NSMutableArray *fileArray = [[NSMutableArray alloc] init];
        for (NSInteger i = 0; i < myDataArray.count; i++) {
            FileModel *md = myDataArray[i];
            NSInteger indexType = [GLFFileManager fileExistsAtPath:md.path];
            NSArray *array = [md.name componentsSeparatedByString:@"."];
            NSString *lowerType = [array.lastObject lowercaseString];
            if (indexType == 1) {
                if ([CimgTypeArray containsObject:lowerType]) {
                    [imageArray addObject:md];
                } else if ([CvideoTypeArray containsObject:lowerType]) {
                    [videoArray addObject:md];
                } else {
                    [fileArray addObject:md];
                }
            }
        }
        // 进入详情页面
        NSArray *array = [model.name componentsSeparatedByString:@"."];
        NSString *lowerType = [array.lastObject lowercaseString];
        if ([CimgTypeArray containsObject:lowerType]) { // 图片
            DetailViewController2 *detailVC = [[DetailViewController2 alloc] init];
            detailVC.selectIndex = [self returnIndex:imageArray with:model];
            detailVC.fileArray = imageArray;
            [self.navigationController pushViewController:detailVC animated:YES];
        } else if ([CvideoTypeArray containsObject:lowerType]) { // 视频
            DetailViewController3 *detailVC = [[DetailViewController3 alloc] init];
            detailVC.selectIndex = [self returnIndex:videoArray with:model];
            detailVC.fileArray = videoArray;
            [self.navigationController pushViewController:detailVC animated:YES];
        } else { // 其它文件类型
            DetailViewController *detailVC = [[DetailViewController alloc] init];
            detailVC.selectIndex = [self returnIndex:fileArray with:model];
            detailVC.fileArray = fileArray;
            [self.navigationController pushViewController:detailVC animated:YES];
        }
    } else if (fileType == 2) { // 文件夹
        RootViewController *vc = [[RootViewController alloc] init];
        vc.titleStr = model.name;
        vc.pathStr = model.path;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    FileModel *model = myDataArray[indexPath.row];
    if (myTableView.editing == YES) {
        [editArray removeObject:model];
        if (editArray.count == 0) {
            UIBarButtonItem *item1 = self.toolbarItems[2]; // 移动
            UIBarButtonItem *item2 = self.toolbarItems[4]; // 删除
            item1.enabled = NO;
            item2.enabled = NO;
        }
    }
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    FileInfoViewController *vc = [[FileInfoViewController alloc] init];
    vc.model = myDataArray[indexPath.row];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark 编辑
- (nullable NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    editIndexPath = indexPath;
    UITableViewRowAction *delete = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"删除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        NSLog(@"删除 %@ %@", action, indexPath);
        [self deleteAction];
    }];
    UITableViewRowAction *more = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"更多" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        NSLog(@"更多 %@ %@", action, indexPath);
        [self moreAction];
    }];
    NSArray *array = @[delete, more];
    return array;
}

- (void)deleteAction {
    FileModel *model = myDataArray[editIndexPath.row];
    NSString *str = [NSString stringWithFormat:@"[%@] 将从您的设备存储中删除。此操作不能撤销。", model.name];
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"" message:str preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [self viewEditing:YES];
    }];
    [alertVC addAction:cancelAction];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"从设备删除" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        BOOL success = [GLFFileManager fileDelete:model.path];
        if (success) {
            [self prepareData];
            [GLFFileManager updateDocumentPaths];
        }
    }];
    [alertVC addAction:okAction];
    [self presentViewController:alertVC animated:YES completion:nil];
}

- (void)moreAction {
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [self viewEditing:YES];
    }];
    [alertVC addAction:cancelAction];
    UIAlertAction *okAction1 = [UIAlertAction actionWithTitle:@"重新命名..." style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self renameAction];
    }];
    [alertVC addAction:okAction1];
    UIAlertAction *okAction2 = [UIAlertAction actionWithTitle:@"移动..." style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self moveAction];
    }];
    [alertVC addAction:okAction2];
    UIAlertAction *okAction3 = [UIAlertAction actionWithTitle:@"共享..." style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self shareAction];
    }];
    [alertVC addAction:okAction3];
    [self presentViewController:alertVC animated:YES completion:nil];
}

- (void)renameAction {
    FileModel *model = myDataArray[editIndexPath.row];
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"给项目重新命名" message:@"为该项目输入新名称" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [self viewEditing:YES];
    }];
    [alertVC addAction:cancelAction];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"完成" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (alertVC.textFields.count > 0) {
            UITextField *textField = alertVC.textFields.firstObject;
            NSLog(@"重命名文件夹名称: %@", textField.text);
            NSString *toPath = [NSString stringWithFormat:@"%@/%@", fileManager.currentPath, textField.text];
            BOOL success = [GLFFileManager fileMove:model.path toPath:toPath];
            if (success) {
                [self prepareData];
                [GLFFileManager updateDocumentPaths];
            }
        }
    }];
    [alertVC addAction:okAction];
    [alertVC addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"请输入新名称";
        textField.text = model.name;
    }];
    [self presentViewController:alertVC animated:YES completion:nil];
}

- (void)moveAction {
    FileModel *model = myDataArray[editIndexPath.row];
    MoveViewController *editVC = [[MoveViewController alloc] init];
    editVC.modelArray = @[model];
    [self presentViewController:editVC animated:YES completion:nil];
}

- (void)shareAction {
    FileModel *model = myDataArray[editIndexPath.row];
    NSURL *url = [NSURL fileURLWithPath:model.path];
    NSArray *objectsToShare = @[url];
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
    [self presentViewController:activityVC animated:YES completion:nil];
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
