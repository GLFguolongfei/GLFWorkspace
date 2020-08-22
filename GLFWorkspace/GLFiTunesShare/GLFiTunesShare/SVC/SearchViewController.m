//
//  SearchViewController.m
//  GLFiTunesShare
//
//  Created by guolongfei on 2020/2/12.
//  Copyright © 2020 GuoLongfei. All rights reserved.
//

#import "SearchViewController.h"
#import "DetailViewController.h"
#import "DetailViewController2.h"
#import "DetailViewController3.h"
#import "SetupViewController.h"
#import "MoveViewController.h"
#import "FileInfoViewController.h"
#import "RootViewController.h"

@interface SearchViewController ()<UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource, UIDocumentInteractionControllerDelegate, UIViewControllerPreviewingDelegate>
{
    UISearchBar *searchBar;
    UITableView *myTableView;
    NSMutableArray *myDataArray;
    NSMutableArray *allArray;
        
    UIImageView *bgImageView;
    BOOL isShowDefault;
    
    NSIndexPath *editIndexPath;
    
    UIView *view;
    UILabel *label1;
    UILabel *label2;
    UILabel *label3;
    UILabel *label4;
    
    BOOL isVisable;
}
@end

@implementation SearchViewController


#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self setVCTitle:@"搜索"];
    
    myDataArray = [[NSMutableArray alloc] init];
    allArray = [[NSMutableArray alloc] init];
    
    [DocumentManager getAllArray:^(NSArray * array) {
        allArray = [array mutableCopy];
    }];
    [self prepareView];
    [self prepareInfoView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setToolbarHidden:YES animated:YES];
    NSString *type = [[NSUserDefaults standardUserDefaults] objectForKey:@"RootShowType"];
    if ([type isEqualToString:@"1"]) {
        isShowDefault = YES;
    } else {
        isShowDefault = NO;
    }
    // 设置背景图片
    bgImageView.image = [DocumentManager getBackgroundImage];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(keyboardDidShow) name:UIKeyboardDidShowNotification object:nil];
    [center addObserver:self selector:@selector(keyboardDidHide) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self resignFirstResponder];
    [searchBar resignFirstResponder];
}

- (void)keyboardDidShow {
    isVisable = YES;
}

- (void)keyboardDidHide {
    isVisable = NO;
}

- (void)prepareView {
    // UISearchBar的frame只有高度有效
    searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 64, kScreenWidth, 60)];
    searchBar.delegate = self;
    searchBar.placeholder = @"要搜啥, 就搜啥";
    searchBar.backgroundImage = [UIImage imageWithColor:[UIColor clearColor]];
    self.navigationItem.titleView = searchBar;
    
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
    bgImageView.image = [DocumentManager getBackgroundImage];
    myTableView.backgroundView = bgImageView;
    UIVisualEffectView *visualEfView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
    visualEfView.frame = kScreen;
    visualEfView.alpha = 0.5;
    [bgImageView addSubview:visualEfView];
}

- (void)prepareInfoView {
    NSInteger allCount = [[NSUserDefaults standardUserDefaults] integerForKey:@"AllCount"];
    NSInteger allImagesCount = [[NSUserDefaults standardUserDefaults] integerForKey:@"AllImagesCount"];
    NSInteger allVideosCount = [[NSUserDefaults standardUserDefaults] integerForKey:@"AllVideosCount"];
    NSNumber *allSize = [[NSUserDefaults standardUserDefaults] valueForKey:@"AllSize"];
    NSNumber *allImagesSize = [[NSUserDefaults standardUserDefaults] valueForKey:@"AllImagesSize"];
    NSNumber *allVideosSize = [[NSUserDefaults standardUserDefaults] valueForKey:@"AllVideosSize"];
    CGFloat allFilesArraySize = [allSize floatValue];
    CGFloat allImagesArraySize = [allImagesSize floatValue];
    CGFloat allVideosArraySize = [allVideosSize floatValue];
    
    CGRect frame = CGRectMake(60, (kScreenHeight-64-160)/2, kScreenWidth-120, 165);
    view = [[UIView alloc] initWithFrame:frame];
    view.backgroundColor = [UIColor whiteColor];
    view.layer.cornerRadius = 10;
    view.layer.masksToBounds = YES;
    view.alpha = 0.3;
    [self.view addSubview:view];
    for (NSInteger i = 0; i < 4; i ++) {
        CGRect rect = CGRectMake(75, (kScreenHeight-64-160)/2 + 10 + 35 * i, kScreenWidth-150, 40);
        UILabel *label = [[UILabel alloc] initWithFrame:rect];
        label.textColor = KColorThree;
        if (i == 0) {
            label1 = label;
            NSString *sizeStr = [GLFFileManager returenSizeStr:allFilesArraySize];
            label.text = [NSString stringWithFormat:@"总共: %ld    大小: %@", allCount, sizeStr];
        } else if (i == 1) {
            label2 = label;
            NSString *sizeStr = [GLFFileManager returenSizeStr:allImagesArraySize];
            label.text = [NSString stringWithFormat:@"图片: %ld    大小: %@", allImagesCount, sizeStr];
        } else if (i == 2) {
            label3 = label;
            NSString *sizeStr = [GLFFileManager returenSizeStr:allVideosArraySize];
            label.text = [NSString stringWithFormat:@"视频: %ld    大小: %@", allVideosCount, sizeStr];
        } else if (i == 3) {
            label4 = label;
            NSInteger count = allCount - allImagesCount - allVideosCount;
            CGFloat size = allFilesArraySize - allImagesArraySize - allVideosArraySize;
            NSString *sizeStr = [GLFFileManager returenSizeStr:size];
            label.text = [NSString stringWithFormat:@"其它: %ld    大小: %@", count, sizeStr];
        }
        [self.view addSubview:label];
    }
}

- (void)search {
    [searchBar resignFirstResponder];
    [myDataArray removeAllObjects];
    if (searchBar.text.length == 0) {
        [myTableView reloadData];
        view.hidden = NO;
        label1.hidden = NO;
        label2.hidden = NO;
        label3.hidden = NO;
        label4.hidden = NO;
        return;
    }
    for (NSInteger i = 0; i < allArray.count; i++) {
        if (myDataArray.count > 200) {
            break;
        }
        FileModel *model = allArray[i];
        if ([model.name containsString:searchBar.text]) {
            [myDataArray addObject:model];
        }
    }
    [myTableView reloadData];
    if (myDataArray.count > 200) {
        [self showStringHUD:@"搜到的内容过多, 只展示前200条" second:1.5];
    }
    if (myDataArray.count > 0) {
        view.hidden = YES;
        label1.hidden = YES;
        label2.hidden = YES;
        label3.hidden = YES;
        label4.hidden = YES;
    } else {
        view.hidden = NO;
        label1.hidden = NO;
        label2.hidden = NO;
        label3.hidden = NO;
        label4.hidden = NO;
    }
}

#pragma mark UISearchBarDelegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self search];
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
    
    // 3D Touch 可用!
    if (self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable) {
        // 给Cell注册3DTouch的peek和pop功能
        [self registerForPreviewingWithDelegate:self sourceView:cell];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if(isVisable) {
        [searchBar resignFirstResponder];
        return;
    }
    
    FileModel *model = myDataArray[indexPath.row];
    NSInteger fileType = [GLFFileManager fileExistsAtPath:model.path];
    if (fileType == 1) { // 文件
        // 预览
        NSString *mute = [[NSUserDefaults standardUserDefaults] valueForKey:kVoiceMute];
        NSString *min = [[NSUserDefaults standardUserDefaults] valueForKey:kVoiceMin];
        NSArray *array = [model.name componentsSeparatedByString:@"."];
        NSString *lowerType = [array.lastObject lowercaseString];
        if (isShowDefault && (![CvideoTypeArray containsObject:lowerType] || ([CvideoTypeArray containsObject:lowerType] && !mute.integerValue && !min.integerValue))) {
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
            if ([CimgTypeArray containsObject:lowerType]) { // 图片
                DetailViewController2 *detailVC = [[DetailViewController2 alloc] init];
                detailVC.selectIndex = [self returnTypeIndex:model];
                detailVC.fileArray = [self returnTypeArray:model];
                [self.navigationController pushViewController:detailVC animated:YES];
            } else if ([CvideoTypeArray containsObject:lowerType]) { // 视频
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
    } else if (fileType == 2) { // 文件夹
        RootViewController *vc = [[RootViewController alloc] init];
        vc.titleStr = model.name;
        vc.pathStr = model.path;
        [self.navigationController pushViewController:vc animated:YES];
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
    UITableViewRowAction *share = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"分享" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        NSLog(@"分享 %@ %@", action, indexPath);
        [self shareAction];
    }];
    NSArray *array = @[delete, share];
    return array;
}

- (void)deleteAction {
    FileModel *model = myDataArray[editIndexPath.row];
    if ([CHiddenPaths containsObject:model.name]) {
        NSString *msg = [NSString stringWithFormat:@"特殊文件夹【%@】不可以删除", model.name];
        [self showStringHUD:msg second:1.5];
        return;
    }
    NSString *str = [NSString stringWithFormat:@"[%@] 将从您的设备存储中删除。此操作不能撤销。", model.name];
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"" message:str preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [myTableView setEditing:NO animated:YES];
    }];
    [alertVC addAction:cancelAction];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"从设备删除" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        BOOL success = [GLFFileManager fileDelete:model.path];
        if (success) {
            [myTableView setEditing:NO animated:YES];
            [myDataArray removeObject:model];
            [myTableView reloadData];
            [DocumentManager eachAllFiles];
            [DocumentManager updateDocumentPaths];
        } else {
            [self showStringHUD:@"删除失败" second:1.5];
        }
    }];
    [alertVC addAction:okAction];
    [self presentViewController:alertVC animated:YES completion:nil];
}

- (void)shareAction {
    FileModel *model = myDataArray[editIndexPath.row];
    NSURL *url = [NSURL fileURLWithPath:model.path];
    NSArray *objectsToShare = @[url];
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
    [self presentViewController:activityVC animated:YES completion:nil];
    [myTableView setEditing:NO animated:YES];
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
    NSInteger fileType = [GLFFileManager fileExistsAtPath:model.path];
    if (fileType == 1) { // 文件
        NSArray *array = [model.name componentsSeparatedByString:@"."];
        NSString *lowerType = [array.lastObject lowercaseString];
        if ([CimgTypeArray containsObject:lowerType]) { // 图片
            DetailViewController2 *detailVC = [[DetailViewController2 alloc] init];
            detailVC.selectIndex = [self returnTypeIndex:model];
            detailVC.fileArray = [self returnTypeArray:model];
            return detailVC;
        } else if ([CvideoTypeArray containsObject:lowerType]) { // 视频
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
    } else if (fileType == 2) { // 文件夹
        RootViewController *vc = [[RootViewController alloc] init];
        vc.titleStr = model.name;
        vc.pathStr = model.path;
        return vc;
    }
    // 设定预览的界面
    FileInfoViewController *vc = [[FileInfoViewController alloc] init];
    vc.preferredContentSize = CGSizeMake(0.0f, 400.0f);
    vc.model = model;
    return vc;
}

// pop(按用点力进入）
- (void)previewingContext:(id <UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit
{
    [self showViewController:viewControllerToCommit sender:self];
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


@end
