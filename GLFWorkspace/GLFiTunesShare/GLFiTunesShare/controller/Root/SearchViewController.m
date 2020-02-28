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
    NSMutableArray *allDataArray;
    
    UIBarButtonItem *item;
    
    UIImageView *bgImageView;
    BOOL isSuccess;
    BOOL isDir;
    
    UIView *view;
    UILabel *label1;
    UILabel *label2;
    UILabel *label3;
    UILabel *label4;
}
@end

@implementation SearchViewController


#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    item = [[UIBarButtonItem alloc] initWithTitle:@"文件夹" style:UIBarButtonItemStylePlain target:self action:@selector(buttonAction)];
    self.navigationItem.rightBarButtonItem = item;
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"搜索";
    
    myDataArray = [[NSMutableArray alloc] init];
    allDataArray = [[NSMutableArray alloc] init];
    
    DocumentManager *manager = [DocumentManager sharedDocumentManager];
    if (manager.allArray.count > 0) {
        allDataArray = manager.allArray;
    } else {
        [self prepareData];
    }
    [self prepareView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setToolbarHidden:YES animated:YES];
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
}

- (void)prepareData {
    [self showHUD];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *hidden = [userDefaults objectForKey:kContentHidden];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        NSMutableArray *cArray = [[NSMutableArray alloc] init];
        NSMutableArray *bArray = [[NSMutableArray alloc] init];
        NSArray *array = [GLFFileManager searchSubFile:path andIsDepth:YES];
        for (int i = 0; i < array.count; i++) {
            if ([array[i] isEqualToString:@"Inbox"]) {
                continue;
            }
            if ([hidden isEqualToString:@"0"] && [array[i] isEqualToString:@"郭龙飞"]) {
                continue;
            }
            FileModel *model = [[FileModel alloc] init];
            model.name = array[i];
            model.path = [NSString stringWithFormat:@"%@/%@", path, model.name];
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
//                    #if FirstTarget
//                        model.image = [GLFTools thumbnailImageRequest:9 andVideoPath:model.path];
//                    #else
//                        model.image = [GLFTools thumbnailImageRequest:90 andVideoPath:model.path];
//                    #endif
                    model.image = nil;
                } else if ([lowerType isEqualToString:@"ds_store"]) {
                    continue;
                }
                [bArray addObject:model];
            } else if (fileType == 2) { // 文件夹
                model.isDir = YES;
                model.size = [GLFFileManager fileSizeForDir:model.path];
                model.count = [model.attributes[@"NSFileReferenceCount"] integerValue];
                [cArray addObject:model];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideAllHUD];
            // 显示文件夹排在前面
            [allDataArray addObjectsFromArray:cArray];
            [allDataArray addObjectsFromArray:bArray];
            NSLog(@"总共文件(夹)数量: %ld", allDataArray.count);
        });
    });
}

- (void)prepareView {
    // UISearchBar的frame只有高度有效
    searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 64, kScreenWidth, 60)];
    searchBar.delegate = self;
    searchBar.placeholder = @"要搜啥, 就搜啥";
    searchBar.barStyle = UIBarStyleDefault;
    searchBar.searchBarStyle = UISearchBarStyleDefault;
    searchBar.backgroundColor = [UIColor clearColor];
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
    myTableView.backgroundView = bgImageView;
    UIVisualEffectView *visualEfView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
    visualEfView.frame = kScreen;
    visualEfView.alpha = 0.5;
    [bgImageView addSubview:visualEfView];
    
    // info
    [self prepareInfoView];
}

- (void)prepareInfoView {
    DocumentManager *manager = [DocumentManager sharedDocumentManager];
    if (manager.allArray.count == 0) {
        return;
    }
    
    CGFloat allFilesArraySize = 0;
    CGFloat allImagesArraySize = 0;
    CGFloat allVideosArraySize = 0;
    for (NSInteger i = 0; i < manager.allFilesArray.count; i++) {
        FileModel *model = manager.allFilesArray[i];
        allFilesArraySize += model.size;
    }
    for (NSInteger i = 0; i < manager.allImagesArray.count; i++) {
        FileModel *model = manager.allImagesArray[i];
        allImagesArraySize += model.size;
    }
    for (NSInteger i = 0; i < manager.allVideosArray.count; i++) {
        FileModel *model = manager.allVideosArray[i];
        allVideosArraySize += model.size;
    }
    
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
            label.text = [NSString stringWithFormat:@"总共: %ld    大小: %@", manager.allFilesArray.count, sizeStr];
        } else if (i == 1) {
            label2 = label;
            NSString *sizeStr = [GLFFileManager returenSizeStr:allImagesArraySize];
            label.text = [NSString stringWithFormat:@"图片: %ld    大小: %@", manager.allImagesArray.count, sizeStr];
        } else if (i == 2) {
            label3 = label;
            NSString *sizeStr = [GLFFileManager returenSizeStr:allVideosArraySize];
            label.text = [NSString stringWithFormat:@"视频: %ld    大小: %@", manager.allVideosArray.count, sizeStr];
        } else if (i == 3) {
            label4 = label;
            NSInteger count = manager.allFilesArray.count - manager.allImagesArray.count - manager.allVideosArray.count;
            CGFloat size = allFilesArraySize - allImagesArraySize - allVideosArraySize;
            NSString *sizeStr = [GLFFileManager returenSizeStr:size];
            label.text = [NSString stringWithFormat:@"其它: %ld    大小: %@", count, sizeStr];
        }
        [self.view addSubview:label];
    }
}

- (void)buttonAction {
    isDir = !isDir;
    if (isDir) {
        item.title = @"文夹";
    } else {
        item.title = @"文件夹";
    }
    [self search];
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
    for (NSInteger i = 0; i < allDataArray.count; i++) {
        if (myDataArray.count > 300) {
            break;
        }
        FileModel *model = allDataArray[i];
        if ([model.name containsString:searchBar.text]) {
            if (isDir) {
                if (model.isDir) {
                    [myDataArray addObject:model];
                }
            } else {
                if (!model.isDir) {
                    [myDataArray addObject:model];
                }
            }
        }
    }
    [myTableView reloadData];
    if (myDataArray.count == 0) {
        [self showStringHUD:@"未搜到任何内容" second:2];
    } else if (myDataArray.count > 300) {
        [self showStringHUD:@"搜到的内容过多, 只展示前300条" second:2];
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
    
    // 3D Touch 可用!
    if (self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable) {
        // 给Cell注册3DTouch的peek和pop功能
        [self registerForPreviewingWithDelegate:self sourceView:cell];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    FileModel *model = myDataArray[indexPath.row];
    NSInteger fileType = [GLFFileManager fileExistsAtPath:model.path];
    if (fileType == 1) { // 文件
        // 预览
        NSString *mute = [[NSUserDefaults standardUserDefaults] valueForKey:kVoiceMute];
        NSString *min = [[NSUserDefaults standardUserDefaults] valueForKey:kVoiceMin];
        NSArray *array = [model.name componentsSeparatedByString:@"."];
        NSString *lowerType = [array.lastObject lowercaseString];
        if (isSuccess && (![CvideoTypeArray containsObject:lowerType] || ([CvideoTypeArray containsObject:lowerType] && !mute.integerValue && !min.integerValue))) {
            NSURL *url = [NSURL fileURLWithPath:model.path];
            UIDocumentInteractionController *documentController = [UIDocumentInteractionController interactionControllerWithURL:url];
            documentController.delegate = self;
            // 显示预览
            BOOL canOpen = [documentController presentPreviewAnimated:YES];
            if (!canOpen) {
                [self showStringHUD:@"沒有程序可以打开要分享的文件" second:2];
            }
        } else {
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
    // 设定预览的界面
    FileInfoViewController *vc = [[FileInfoViewController alloc] init];
    vc.preferredContentSize = CGSizeMake(0.0f, 400.0f);
    vc.model = myDataArray[indexPath.row];
    // 调整不被虚化的范围，按压的那个cell不被虚化（轻轻按压时周边会被虚化，再少用力展示预览，再加力跳页至设定界面）
    CGRect rect = CGRectMake(0, 0, self.view.frame.size.width, 40);
    previewingContext.sourceRect = rect;
    // 返回预览界面
    return vc;
}

// pop(按用点力进入）
- (void)previewingContext:(id <UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit
{
    [self showViewController:viewControllerToCommit sender:self];
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
