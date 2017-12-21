//
//  RootViewController.m
//  GLFiTunesShare
//
//  Created by guolongfei on 2017/9/29.
//  Copyright © 2017年 GuoLongfei. All rights reserved.
//

#import "RootViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "SetupViewController.h"
#import "DetailViewController.h"
#import "EditViewController.h"
#import "FileInfoViewController.h"
#import "FileModel.h"

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
    if (self.titleStr.length == 0) {
        self.title = @"NSDocumentDirectory";
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"设置" style:UIBarButtonItemStylePlain target:self action:@selector(buttonAction1:)];
        self.navigationItem.leftBarButtonItem = item;
    } else {
        self.title = self.titleStr;
    }
    if (self.navigationController.viewControllers.count > 3) {
        UIBarButtonItem *item1 = [[UIBarButtonItem alloc] initWithTitle:@"选择" style:UIBarButtonItemStylePlain target:self action:@selector(buttonAction3:)];
        UIBarButtonItem *item2 = [[UIBarButtonItem alloc] initWithTitle:@"返回首页" style:UIBarButtonItemStylePlain target:self action:@selector(buttonAction2:)];
        self.navigationItem.rightBarButtonItems = @[item1, item2];
    } else {
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"选择" style:UIBarButtonItemStylePlain target:self action:@selector(buttonAction3:)];
        self.navigationItem.rightBarButtonItem = item;
    }

    [self prepareData];
    [self prepareInterface];
}

- (void)viewWillAppear:(BOOL)animated {
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
    fileManager.currentPath = self.path;
}

- (void)viewDidAppear:(BOOL)animated {
    if (self.moveModel) {
        EditViewController *editVC = [[EditViewController alloc] init];
        editVC.modelArray = @[self.moveModel];
        [self presentViewController:editVC animated:YES completion:nil];
        
        self.moveModel = nil;
        return;
    }
    [self viewEditing:YES];
    [self prepareData];
}

- (void)prepareData {
    fileManager = [GLFFileManager sharedFileManager];
    if (self.path.length == 0) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        self.path = [paths objectAtIndex:0];
        fileManager.currentPath = self.path;
    }
    
    myDataArray = [[NSMutableArray alloc] init];
    editArray = [[NSMutableArray alloc] init];
    NSArray *array = [GLFFileManager searchSubFile:self.path andISDepth:NO];
    for (int i = 0; i < array.count; i++) {
        FileModel *model = [[FileModel alloc] init];
        model.name = array[i];
        model.path = [NSString stringWithFormat:@"%@/%@", self.path,model.name];
        model.attributes = [GLFFileManager attributesOfItemAtPath:model.path];
        NSInteger fileType = [GLFFileManager fileExistsAtPath:model.path];
        if (fileType == 1) {
            model.isDir = NO;
            model.size = [GLFFileManager fileSize:model.path];
        } else if (fileType == 2) {
            model.isDir = YES;
            model.size = [GLFFileManager fileSizeForDir:model.path];
            model.count = [model.attributes[@"NSFileReferenceCount"] integerValue];
        }
        // 当其他程序让本程序打开文件时,会自动生成一个Inbox文件夹
        // 这个文件夹是系统权限,不能删除,只可以删除里面的文件,因此这里隐藏好了
        if (![model.name isEqualToString:@"Inbox"]) {
            [myDataArray addObject:model];
        }
    }
    [myTableView reloadData];
}

- (void)prepareInterface {
    myTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, kScreenWidth, kScreenHeight-64) style:UITableViewStylePlain];
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
    
    // 工具栏UIToolbar
    self.navigationController.toolbarHidden = YES;
    UIBarButtonItem *item1 = [[UIBarButtonItem alloc] initWithTitle:@"新文件夹" style:UIBarButtonItemStylePlain target:self action:@selector(createAction:)];
    UIBarButtonItem *item2 = [[UIBarButtonItem alloc] initWithTitle:@"移动" style:UIBarButtonItemStylePlain target:self action:@selector(moveAction:)];
    item2.enabled = NO;
    UIBarButtonItem *item3 = [[UIBarButtonItem alloc] initWithTitle:@"删除" style:UIBarButtonItemStylePlain target:self action:@selector(deleteAction:)];
    item3.enabled = NO;
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil]; // 特殊的一个,用来自动计算宽度
    self.toolbarItems = @[item1, space, item2, space, item3];
}

#pragma mark Events
- (void)buttonAction1:(id)sender {
    SetupViewController *setupVC = [[SetupViewController alloc] init];
    [self.navigationController pushViewController:setupVC animated:YES];
}

- (void)buttonAction2:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)buttonAction3:(id)sender {
    UIBarButtonItem *item = sender;
    if ([item.title isEqualToString:@"选择"]) {
        [self viewEditing:NO];
    } else {
        [self viewEditing:YES];
    }
}

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

- (void)moveAction:(id)sender {
    EditViewController *editVC = [[EditViewController alloc] init];
    editVC.modelArray = editArray;
    [self presentViewController:editVC animated:YES completion:nil];
}

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

// 是否恢复如初
- (void)viewEditing:(BOOL)editing {
    UIBarButtonItem *item = self.navigationItem.rightBarButtonItems[0];
    if (editing) {
        item.title = @"选择";
        self.navigationController.toolbarHidden = YES;
        [myTableView setEditing:NO animated:YES];
        
        UIBarButtonItem *item1 = self.toolbarItems[2];
        UIBarButtonItem *item2 = self.toolbarItems[4];
        item1.enabled = NO;
        item2.enabled = NO;
    } else {
        item.title = @"取消";
        self.navigationController.toolbarHidden = NO;
        [myTableView setEditing:YES animated:YES];
    }
    [editArray removeAllObjects];
}

#pragma mark UITableViewDataSource
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
    // 内容样式
    cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
    cell.textLabel.textColor = [UIColor whiteColor];
#if FirstTarget
    cell.textLabel.numberOfLines = 3; // 写的是X,但其实最多显示X-1行,原因未知
#elif SecondTarget
    cell.textLabel.numberOfLines = 3; // 写的是X,但其实最多显示X-1行,原因未知
#else
    cell.textLabel.numberOfLines = 0;
#endif
    cell.detailTextLabel.textColor = [UIColor colorWithWhite:1 alpha:0.7];

    FileModel *model = myDataArray[indexPath.row];
    if (model.isDir) {
        NSString *sizeStr = [GLFFileManager returenSizeStr:model.size];
        cell.imageView.image = [UIImage imageNamed:@"wenjianjia"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld 项  %@", model.count, sizeStr];
    } else {
        NSArray *imgTypeArray = @[@"png", @"jpeg", @"jpg", @"gif"];
        NSArray *array = [model.name componentsSeparatedByString:@"."];
        NSString *lowerType = [array.lastObject lowercaseString];
        if ([imgTypeArray containsObject:lowerType]) {
            cell.imageView.image = [UIImage imageWithContentsOfFile:model.path];
        } else {
            cell.imageView.image = [UIImage imageNamed:@"wenjian"];
        }
        cell.accessoryType = UITableViewCellAccessoryDetailButton;
        cell.detailTextLabel.text = @"";
    }
    cell.textLabel.text = model.name;

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    FileModel *model = myDataArray[indexPath.row];
    if (myTableView.editing == YES) {
        [editArray addObject:model];
        UIBarButtonItem *item1 = self.toolbarItems[2];
        UIBarButtonItem *item2 = self.toolbarItems[4];
        item1.enabled = YES;
        item2.enabled = YES;
        return;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSInteger fileType = [GLFFileManager fileExistsAtPath:model.path];
    if (fileType == 1) {
        // 判断是否为视频文件
        NSArray *array = [model.name componentsSeparatedByString:@"."];
        NSString *lowerType = [array.lastObject lowercaseString];
        if ([lowerType isEqualToString:@"mp4"]) {
            NSURL *url = [NSURL fileURLWithPath:model.path];
            MPMoviePlayerViewController *playVc = [[MPMoviePlayerViewController alloc] initWithContentURL:url];
            [self presentViewController:playVc animated:YES completion:nil];
            return;
        }
        // 所有文件类型数组
        NSMutableArray *fileArray = [[NSMutableArray alloc] init];
        for (NSInteger i = 0; i < myDataArray.count; i++) {
            FileModel *md = myDataArray[i];
            NSInteger indexType = [GLFFileManager fileExistsAtPath:md.path];
            if (indexType == 1) {
                [fileArray addObject:md];
            }
        }
        // 当前选中文件下标
        NSInteger index = 0;
        for (NSInteger i = 0; i < fileArray.count; i++) {
            FileModel *md = fileArray[i];
            if ([model.name isEqualToString:md.name]) {
                index = i;
            }
        }
        DetailViewController *detailVC = [[DetailViewController alloc] init];
        detailVC.selectIndex = index;
        detailVC.fileArray = fileArray;
        [self.navigationController pushViewController:detailVC animated:YES];
    } else if (fileType == 2) {
        RootViewController *vc = [[RootViewController alloc] init];
        vc.titleStr = model.name;
        vc.path = model.path;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    FileModel *model = myDataArray[indexPath.row];
    if (myTableView.editing == YES) {
        [editArray removeObject:model];
        if (editArray.count == 0) {
            UIBarButtonItem *item1 = self.toolbarItems[2];
            UIBarButtonItem *item2 = self.toolbarItems[4];
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
    EditViewController *editVC = [[EditViewController alloc] init];
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


@end
