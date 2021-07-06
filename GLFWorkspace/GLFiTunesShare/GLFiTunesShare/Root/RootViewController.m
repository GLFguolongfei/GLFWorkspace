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

@interface RootViewController ()<UITableViewDelegate, UITableViewDataSource, UIDocumentInteractionControllerDelegate, UIViewControllerPreviewingDelegate, UINavigationControllerDelegate, UIVideoEditorControllerDelegate>
{
    UITableView *myTableView;
    NSMutableArray *myDataArray;
    
    GLFFileManager *fileManager;

    UIImageView *bgImageView;
    
    NSIndexPath *editIndexPath;
    NSMutableArray *editArray;

    UIView *gestureView;
    BOOL isShowDefault;
}
@end

@implementation RootViewController


#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
//    DocumentManager *manager = [DocumentManager sharedDocumentManager];
//    [manager startPlay];
        
    fileManager = [GLFFileManager sharedFileManager];
    myDataArray = [[NSMutableArray alloc] init];
    editArray = [[NSMutableArray alloc] init];
    
    [self prepareInterface];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSString *type = [[NSUserDefaults standardUserDefaults] objectForKey:@"RootShowType"];
    if ([type isEqualToString:@"1"]) {
        isShowDefault = YES;
    } else {
        isShowDefault = NO;
    }
    self.navigationController.navigationBar.hidden = NO;
    self.navigationController.toolbarHidden = YES;
        
    // 设置背景图片
    bgImageView.image = [DocumentManager getBackgroundImage];
    
    // 2.设置数据源
    [self prepareData];
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

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.moveModel) {
        MoveViewController *editVC = [[MoveViewController alloc] init];
        editVC.modelArray = @[self.moveModel];
        [self presentViewController:editVC animated:YES completion:nil];
        self.moveModel = nil;
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [gestureView removeFromSuperview];
}

- (void)prepareData {
    [editArray removeAllObjects];
    [self viewEditing:YES];
    if (self.pathStr.length == 0) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        self.pathStr = [paths objectAtIndex:0];
    }
    NSLog(@"%@", self.pathStr);
    fileManager.currentPath = self.pathStr;
    if ([myTableView numberOfRowsInSection:0] == 0) {
        [self showHUD:@"加载中, 不要着急!"];
    }
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *hidden = [userDefaults objectForKey:kContentHidden];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        NSMutableArray *cArray = [[NSMutableArray alloc] init];
        NSMutableArray *bArray = [[NSMutableArray alloc] init];
        NSArray *array = [GLFFileManager searchSubFile:self.pathStr andIsDepth:NO];
        for (int i = 0; i < array.count; i++) {
            // 当其他程序让本程序打开文件时,会自动生成一个Inbox文件夹
            // 这个文件夹是系统权限,不能删除,只可以删除里面的文件,因此这里隐藏好了
            if ([@"Inbox" isEqualToString:array[i]]) {
                continue;
            }
            if ([hidden isEqualToString:@"0"] && [CHiddenPaths containsObject:array[i]]) {
                continue;
            }
            FileModel *model = [[FileModel alloc] init];
            model.name = array[i];
            model.path = [NSString stringWithFormat:@"%@/%@", self.pathStr,model.name];
            model.attributes = [GLFFileManager attributesOfItemAtPath:model.path];
            // 是否为隐藏目录(注意：Inbox目录不是隐藏目录)
            NSNumber *isHidden = (NSNumber *)model.attributes[@"NSFileExtensionHidden"];
            if (isHidden.integerValue == 1) {
                continue;
            }
            // 文件类型
            NSInteger fileType = [GLFFileManager fileExistsAtPath:model.path];
            if (fileType == 1) { // 文件
                model.size = [GLFFileManager fileSize:model.path];
                NSArray *array = [model.name componentsSeparatedByString:@"."];
                NSString *lowerType = [array.lastObject lowercaseString];
                if ([CimgTypeArray containsObject:lowerType]) {
                    model.type = 2;
                    model.image = [UIImage imageWithContentsOfFile:model.path];
                } else if ([CvideoTypeArray containsObject:lowerType]) {
                    model.type = 3;
                    #if FirstTarget
                        model.image = [GLFTools thumbnailImageRequest:9 andVideoPath:model.path];
                    #else
                        model.image = [GLFTools thumbnailImageRequest:90 andVideoPath:model.path];
                    #endif
                } else {
                    model.type = 4;
                }
                [bArray addObject:model];
            } else if (fileType == 2) { // 文件夹
                model.type = 1;
                model.size = [GLFFileManager fileSizeForDir:model.path];
                model.count = [model.attributes[@"NSFileReferenceCount"] integerValue];
                [cArray addObject:model];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideAllHUD];
            [myDataArray removeAllObjects];
            // 显示文件夹排在前面
            [myDataArray addObjectsFromArray:cArray];
            [myDataArray addObjectsFromArray:bArray];
            [myTableView reloadData];
        });
    });
}

- (void)prepareInterface {
    // 导航栏UINavigationBar
    if (self.titleStr.length > 0) {
        [self setVCTitle:self.titleStr];
    } else {
        [self setVCTitle:@"NSDocumentDirectory"];
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"设置" style:UIBarButtonItemStylePlain target:self action:@selector(buttonAction1:)];
        self.navigationItem.leftBarButtonItem = item;
    }
    if (self.navigationController.viewControllers.count > 3) {
        UIBarButtonItem *item1 = [[UIBarButtonItem alloc] initWithTitle:@"选择" style:UIBarButtonItemStylePlain target:self action:@selector(buttonAction3:)];
        UIBarButtonItem *item2 = [[UIBarButtonItem alloc] initWithTitle:@"首页" style:UIBarButtonItemStylePlain target:self action:@selector(buttonAction2:)];
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
    UIBarButtonItem *item4 = [[UIBarButtonItem alloc] initWithTitle:@"视频合并" style:UIBarButtonItemStylePlain target:self action:@selector(mergeAction:)];
    item4.enabled = NO;
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil]; // 特殊的一个,用来自动计算宽度
    self.toolbarItems = @[item1, space, item2, space, item3, space, item4];
    
    // 设置背景图片
    bgImageView = [[UIImageView alloc] initWithFrame:kScreen];
    bgImageView.contentMode = UIViewContentModeScaleAspectFill;
    bgImageView.image = [DocumentManager getBackgroundImage];
    [self.view addSubview:bgImageView];
    
    UIVisualEffectView *visualEfView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
    visualEfView.frame = kScreen;
    visualEfView.alpha = 0.5;
    [bgImageView addSubview:visualEfView];
    
    // 数据列表
    CGRect tableViewFrame = CGRectMake(0, 64, kScreenWidth, kScreenHeight-64);
    myTableView = [[UITableView alloc] initWithFrame:tableViewFrame style:UITableViewStylePlain];
    myTableView.backgroundColor = [UIColor clearColor];
    myTableView.delegate = self;
    myTableView.dataSource = self;
    myTableView.separatorInset = UIEdgeInsetsMake(0, -20, 0, 0);
    myTableView.allowsMultipleSelectionDuringEditing = YES;
    [self.view addSubview:myTableView];
    myTableView.tableFooterView = [[UIView alloc] init];
}

#pragma mark Events
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
        UIAlertAction *okAction2 = [UIAlertAction actionWithTitle:@"切换主题" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [manager switchCamera];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self reSetVCTitle];
            });
        }];
        [alertVC addAction:okAction2];
    }
    
    [self presentViewController:alertVC animated:YES completion:nil];
}

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
            [DocumentManager eachAllFiles];
            [DocumentManager updateDocumentPaths];
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
    for (NSInteger i = 0; i < editArray.count; i++) {
        FileModel *model = editArray[i];
        if ([CHiddenPaths containsObject:model.name]) {
            NSString *msg = [NSString stringWithFormat:@"特殊文件夹【%@】不可以移动", model.name];
            [self showStringHUD:msg second:1.5];
            [self viewEditing:YES];
            return;
        }
    }
    
    MoveViewController *editVC = [[MoveViewController alloc] init];
    editVC.modelArray = editArray;
    [self presentViewController:editVC animated:YES completion:nil];
}

// 删除
- (void)deleteAction:(id)sender {
    for (NSInteger i = 0; i < editArray.count; i++) {
        FileModel *model = editArray[i];
        if ([CHiddenPaths containsObject:model.name]) {
            NSString *msg = [NSString stringWithFormat:@"特殊文件夹【%@】不可以删除", model.name];
            [self showStringHUD:msg second:1.5];
            [self viewEditing:YES];
            return;
        }
    }
    
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
                [DocumentManager eachAllFiles];
                [DocumentManager updateDocumentPaths];
            });
        });
    }];
    [alertVC addAction:okAction];
    [self presentViewController:alertVC animated:YES completion:nil];
}

- (void)mergeAction:(id)sender {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    NSString *path = @"合并";
    for (NSInteger i = 0; i < editArray.count; i++) {
        FileModel *model = editArray[i];
        if (model.type == 3) { // 视频
            [array addObject:model.path];
            NSArray *subArray = [model.name componentsSeparatedByString:@"."];
            if (subArray.count > 1) {
                NSString *str2 = (NSString *)subArray.lastObject;
                NSString *str1 = [model.name substringToIndex:model.name.length - str2.length - 1];
                path = [NSString stringWithFormat:@"%@-%@", path, str1];
            }
        }
    }
    if (array.count > 1) {
        path = [NSString stringWithFormat:@"%@/%@.mp4", self.pathStr, path];
        NSLog(@"%@", path);
        NSLog(@"%@", array);
        [self showHUD:@"视频合并中..." animated:YES];
        [DocumentManager mergeVideos:array withOutPath:path andCallBack:^(NSArray *array) {
            [self prepareData];
            [self showStringHUD:@"视频合并成功" second:2];
        }];
    } else {
        [self showStringHUD:@"请至少选择两个视频文件" second:2];
    }
}

// editing: 是否恢复如初
- (void)viewEditing:(BOOL)editing {
    UIBarButtonItem *item = self.navigationItem.rightBarButtonItems[0];
    if (editing) {
        item.title = @"选择";
        [self.navigationController setToolbarHidden:YES animated:YES];
        [myTableView setEditing:NO animated:YES];
        
        UIBarButtonItem *item1 = self.toolbarItems[2]; // 移动
        UIBarButtonItem *item2 = self.toolbarItems[4]; // 删除
        UIBarButtonItem *item3 = self.toolbarItems[6]; // 视频合并
        item1.enabled = NO;
        item2.enabled = NO;
        item3.enabled = NO;
    } else {
        item.title = @"取消";
        [self.navigationController setToolbarHidden:NO animated:YES];
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
    if (model.type == 1) { // 文件夹
        NSString *sizeStr = [GLFFileManager returenSizeStr:model.size];
        cell.imageView.image = [UIImage imageNamed:@"wenjianjia"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld 项  %@", model.count, sizeStr];
    } else { // 文件
        if (model.type == 2) { // 图片
            if (model.image.size.width > 0) { // 有时image会解析出错
                cell.imageView.image = model.image;
            } else {
                cell.imageView.image = [UIImage imageNamed:@"图片"];
            }
        } else if (model.type == 3) { // 视频
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
    
    // 3D Touch 可用!
    if (self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable) {
        // 给Cell注册3DTouch的peek和pop功能
        [self registerForPreviewingWithDelegate:self sourceView:cell];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    FileModel *model = myDataArray[indexPath.row];
    if (myTableView.editing == YES) {
        [editArray addObject:model];
        UIBarButtonItem *item1 = self.toolbarItems[2]; // 移动
        UIBarButtonItem *item2 = self.toolbarItems[4]; // 删除
        UIBarButtonItem *item3 = self.toolbarItems[6]; // 视频合并
        item1.enabled = YES;
        item2.enabled = YES;
        item3.enabled = YES;
        return;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // 预览
    NSString *mute = [[NSUserDefaults standardUserDefaults] valueForKey:kVoiceMute];
    if (isShowDefault && (model.type != 3 || (model.type == 3 && !mute.integerValue))) {
        NSURL *url = [NSURL fileURLWithPath:model.path];
        UIDocumentInteractionController *documentController = [UIDocumentInteractionController interactionControllerWithURL:url];
        documentController.delegate = self;
        // 显示预览
        BOOL canOpen = [documentController presentPreviewAnimated:YES];
        if (!canOpen) {
            [self showStringHUD:@"沒有程序可以打开要分享的文件" second:1.5];
        }
    } else {
        if (model.type == 1) { // 文件夹
            RootViewController *vc = [[RootViewController alloc] init];
            vc.titleStr = model.name;
            vc.pathStr = model.path;
            [self.navigationController pushViewController:vc animated:YES];
        } else if (model.type == 2) { // 图片
            DetailViewController2 *detailVC = [[DetailViewController2 alloc] init];
            detailVC.selectIndex = [self returnTypeIndex:model];
            detailVC.fileArray = [self returnTypeArray:model];
            [self.navigationController pushViewController:detailVC animated:YES];
        } else if (model.type == 3) { // 视频
            NSString *MIMEType = [DocumentManager mimeTypeForFileAtPath2:model.path];
            BOOL isCanPlay = [AVURLAsset isPlayableExtendedMIMEType:MIMEType];
            NSLog(@"%d", isCanPlay);
            if (!isCanPlay) {
                [self showStringHUD:@"不支持该视频格式" second:1.5];
            }
            DetailViewController3 *detailVC = [[DetailViewController3 alloc] init];
            detailVC.selectIndex = [self returnTypeIndex:model];
            detailVC.fileArray = [self returnTypeArray:model];
            [self.navigationController pushViewController:detailVC animated:YES];
        } else { // 其它文件类型
            DetailViewController *detailVC = [[DetailViewController alloc] init];
            detailVC.selectIndex = [self returnTypeIndex:model];
            detailVC.fileArray = [self returnTypeArray:model];
            [self.navigationController pushViewController:detailVC animated:YES];
        }
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    FileModel *model = myDataArray[indexPath.row];
    if (myTableView.editing == YES) {
        [editArray removeObject:model];
        if (editArray.count == 0) {
            UIBarButtonItem *item1 = self.toolbarItems[2]; // 移动
            UIBarButtonItem *item2 = self.toolbarItems[4]; // 删除
            UIBarButtonItem *item3 = self.toolbarItems[6]; // 视频合并
            item1.enabled = NO;
            item2.enabled = NO;
            item3.enabled = NO;
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
    if ([CHiddenPaths containsObject:model.name]) {
        NSString *msg = [NSString stringWithFormat:@"特殊文件夹【%@】不可以删除", model.name];
        [self showStringHUD:msg second:1.5];
        [self viewEditing:YES];
        return;
    }
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
            [DocumentManager eachAllFiles];
            [DocumentManager updateDocumentPaths];
        } else {
            [self showStringHUD:@"删除失败" second:1.5];
        }
    }];
    [alertVC addAction:okAction];
    [self presentViewController:alertVC animated:YES completion:nil];
}

- (void)moreAction {
    FileModel *model = myDataArray[editIndexPath.row];
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
    if (model.type == 3) { // 视频
        UIAlertAction *okAction3 = [UIAlertAction actionWithTitle:@"编辑..." style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            UIVideoEditorController *editVC;
            // 检查这个视频资源能不能被修改
            if ([UIVideoEditorController canEditVideoAtPath:model.path]) {
                editVC = [[UIVideoEditorController alloc] init];
                editVC.videoPath = model.path;
                editVC.videoMaximumDuration = 0;
                editVC.videoQuality = UIImagePickerControllerQualityTypeHigh;
                editVC.delegate = self;
            } else {
                [self showStringHUD:@"不支持该种视频格式编辑" second:2];
            }
            [self presentViewController:editVC animated:YES completion:nil];
        }];
        [alertVC addAction:okAction3];
    }
    UIAlertAction *okAction4 = [UIAlertAction actionWithTitle:@"图片压缩..." style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (model.type == 1) { // 文件夹
            UIAlertController *modalVC = [UIAlertController alertControllerWithTitle:@"再次确定" message:@"是否压缩图片文件夹?" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancelAct = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                [myTableView setEditing:NO animated:YES];
            }];
            [modalVC addAction:cancelAct];
            UIAlertAction *okAct = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self showHUD:@"压缩中..."];
                [myTableView setEditing:NO animated:YES];
                [self compress:model];
            }];
            [modalVC addAction:okAct];
            [self presentViewController:modalVC animated:YES completion:nil];
        } else {
            [self showStringHUD:@"目前只压缩图片文件夹" second:2];
        }
    }];
    [alertVC addAction:okAction4];
    [self presentViewController:alertVC animated:YES completion:nil];
}

- (void)renameAction {
    FileModel *model = myDataArray[editIndexPath.row];
    if ([CHiddenPaths containsObject:model.name]) {
        NSString *msg = [NSString stringWithFormat:@"特殊文件夹【%@】不可以重命名", model.name];
        [self showStringHUD:msg second:1.5];
        [self viewEditing:YES];
        return;
    }
    NSArray *array = [model.name componentsSeparatedByString:@"."];
    NSString *str = @"";
    NSString *name = model.name;
    if (array.count > 1) {
        str = array.lastObject;
        name = [model.name substringToIndex:model.name.length - str.length - 1];
    }
    NSLog(@"%@", name);
    
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
            if (str.length > 0) {
                toPath = [NSString stringWithFormat:@"%@/%@.%@", fileManager.currentPath, textField.text, str];
            }
            BOOL success = [GLFFileManager fileMove:model.path toPath:toPath];
            if (success) {
                [self prepareData];
                [DocumentManager eachAllFiles];
                [DocumentManager updateDocumentPaths];
            } else {
                [self showStringHUD:@"重命名失败" second:1.5];
                [self viewEditing:YES];
            }
        }
    }];
    [alertVC addAction:okAction];
    [alertVC addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"请输入新名称";
        textField.text = name;
    }];
    [self presentViewController:alertVC animated:YES completion:nil];
}

- (void)moveAction {
    FileModel *model = myDataArray[editIndexPath.row];
    if ([CHiddenPaths containsObject:model.name]) {
        NSString *msg = [NSString stringWithFormat:@"特殊文件夹【%@】不可以移动", model.name];
        [self showStringHUD:msg second:1.5];
        [self viewEditing:YES];
        return;
    }
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
    NSIndexPath *indexPath = [myTableView indexPathForCell:(UITableViewCell* )[previewingContext sourceView]];
    FileModel *model = myDataArray[indexPath.row];
    // 调整不被虚化的范围，按压的那个cell不被虚化（轻轻按压时周边会被虚化，再少用力展示预览，再加力跳页至设定界面）
    CGRect rect = CGRectMake(0, 0, self.view.frame.size.width, 60);
    previewingContext.sourceRect = rect;
    // 设定预览的界面
    if (model.type == 1) { // 文件夹
        RootViewController *vc = [[RootViewController alloc] init];
        vc.titleStr = model.name;
        vc.pathStr = model.path;
        return vc;
    } else if (model.type == 2) { // 图片
        DetailViewController2 *detailVC = [[DetailViewController2 alloc] init];
        detailVC.selectIndex = [self returnTypeIndex:model];
        detailVC.fileArray = [self returnTypeArray:model];
        return detailVC;
    } else if (model.type == 3) { // 视频
        DetailViewController3 *detailVC = [[DetailViewController3 alloc] init];
        detailVC.selectIndex = [self returnTypeIndex:model];
        detailVC.fileArray = [self returnTypeArray:model];
        detailVC.isPlay = YES;
        detailVC.preferredContentSize = CGSizeMake(kScreenWidth, kScreenHeight * 0.8);
        return detailVC;
    } else { // 其它文件类型
        DetailViewController *detailVC = [[DetailViewController alloc] init];
        detailVC.selectIndex = [self returnTypeIndex:model];
        detailVC.fileArray = [self returnTypeArray:model];
        return detailVC;
    }
}

// pop(按用点力进入）
- (void)previewingContext:(id <UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit
{
    [self showViewController:viewControllerToCommit sender:self];
}

#pragma mark UIVideoEditorControllerDelegate(视频编辑)
// 编辑成功后的Video被保存在沙盒的临时目录中
- (void)videoEditorController:(UIVideoEditorController *)editor didSaveEditedVideoToPath:(NSString *)editedVideoPath {
    [editor dismissViewControllerAnimated:YES completion:nil];
    FileModel *model = myDataArray[editIndexPath.row];
    NSArray *array = [model.path componentsSeparatedByString:@"."];
    NSString *path = @"";
    if (array.count > 1) {
        NSString *str2 = (NSString *)array.lastObject;
        NSString *str1 = [model.path substringToIndex:model.path.length - str2.length - 1];
        path = [NSString stringWithFormat:@"%@的副本.%@", str1, str2];
    }
    BOOL success = [GLFFileManager fileCopy:editedVideoPath toPath:path];
    if (success) {
        [self prepareData];
        [self showStringHUD:@"编辑成功" second:2];
    } else {
        [self showStringHUD:@"编辑失败" second:2];
    }
}

// 编辑失败后调用的方法
- (void)videoEditorController:(UIVideoEditorController *)editor didFailWithError:(NSError *)error {
    [editor dismissViewControllerAnimated:YES completion:nil];
    [self showStringHUD:@"编辑失败" second:2];
}

// 编辑取消后调用的方法
- (void)videoEditorControllerDidCancel:(UIVideoEditorController *)editor {
    [editor dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark Private Method
// 获取元素在数组中的下标
- (NSInteger)returnTypeIndex:(FileModel *)model {
    NSArray *array = [self returnTypeArray:model];
    NSInteger index = 0;
    for (NSInteger i = 0; i < array.count; i++) {
        FileModel *md = array[i];
        if ([model.name isEqualToString:md.name]) {
            index = i;
        }
    }
    return index;
}

// 获取同类型的数组
- (NSArray *)returnTypeArray:(FileModel *)model {
    NSMutableArray *foldersArray = [[NSMutableArray alloc] init];
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
        } else {
            [foldersArray addObject:md];
        }
    }
    // type 1-文件夹 2-图片 3-视频 4-其它文件类型
    if (model.type == 1) {
        return foldersArray;
    } else if (model.type == 2) {
        return imageArray;
    } else if (model.type == 3) {
        return videoArray;
    } else {
        return fileArray;
    }
}

- (void)compress:(FileModel *)model {
    NSInteger oneM = 1024 * 1024;
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        NSArray *array = [GLFFileManager searchSubFile:model.path andIsDepth:YES];
        for (int i = 0; i < array.count; i++) {
            NSString *subPath = array[i];
            NSString *path = [NSString stringWithFormat:@"%@/%@", model.path, subPath];
            NSInteger fileType = [GLFFileManager fileExistsAtPath:path];
            if (fileType == 1) { // 文件
                NSArray *array = [subPath componentsSeparatedByString:@"."];
                NSString *lowerType = [array.lastObject lowercaseString];
                if ([CimgTypeArray containsObject:lowerType]) {
                    CGFloat size = [GLFFileManager fileSize:path];
                    // 小于2M的就不用压缩了
                    if (size < 2 * oneM) {
                        continue;
                    }
                    
                    // CGFloat realSize = image.size.width * image.size.height * [UIScreen mainScreen].scale;
                    // CGFloat press = size / realSize;
                    // NSData *datass = UIImageJPEGRepresentation(image, 1.0);
                    // NSLog(@"realSize: %f %f %f %ld", size, realSize, press, datass.length);
                    
                    UIImage *image = [UIImage imageWithContentsOfFile:path];
                    NSData *data = nil;
                    CGFloat press = 0.1;
                    if (size < 10 * oneM) {
                        press = 0.5;
                    } else if (size < 20 * oneM) {
                        press = 0.4;
                    } else if (size < 30 * oneM) {
                        press = 0.3;
                    } else if (size < 40 * oneM) {
                        press = 0.2;
                    }
                    data = UIImageJPEGRepresentation(image, press);
                    // 很神奇: 1.0 并不是原图大小,不知道为什么
                    // 压缩后的大小比原来还大,就不用了
                    if (data.length >= size / 2) {
                        press = press / 2;
                        data = UIImageJPEGRepresentation(image, press);
                    }
                    if (data.length >= size) {
                        continue;
                    }
                    
                    // 回到主线程
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [data writeToFile:path atomically:YES];
                    });
                }
            }
        }
        // 回到主线程
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideAllHUD];
            [self prepareData];
        });
    });
}


@end
