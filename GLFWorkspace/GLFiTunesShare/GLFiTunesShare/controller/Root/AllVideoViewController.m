//
//  AllVideoViewController.m
//  GLFiTunesShare
//
//  Created by guolongfei on 2020/1/31.
//  Copyright © 2020 GuoLongfei. All rights reserved.
//

#import "AllVideoViewController.h"
#import "DetailViewController3.h"
#import "FileInfoViewController.h"
#import "VideoTableViewCell.h"

static NSString *cellID = @"ShowTableViewCell";

@interface AllVideoViewController ()<UITableViewDataSource, UITableViewDelegate, UIDocumentInteractionControllerDelegate, UIViewControllerPreviewingDelegate>
{
    UITableView *_tableView;
    NSMutableArray *_dataArray;
    
    UIView *gestureView;
    BOOL isSuccess;
    
    BOOL isShowImage;
    BOOL isStop;
}
@end

@implementation AllVideoViewController


#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    UIBarButtonItem *item1 = [[UIBarButtonItem alloc] initWithTitle:@"图文" style:UIBarButtonItemStylePlain target:self action:@selector(buttonAction1)];
    UIBarButtonItem *item2 = [[UIBarButtonItem alloc] initWithTitle:@"文字" style:UIBarButtonItemStylePlain target:self action:@selector(buttonAction2)];
    self.navigationItem.rightBarButtonItems = @[item1, item2];
    self.title = @"所有视频";
    
    isShowImage = NO;
    
    [self prepareData];
    [self prepareView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSString *type = [[NSUserDefaults standardUserDefaults] objectForKey:@"RootShowType"];
    if ([type isEqualToString:@"1"]) {
        isSuccess = YES;
    } else {
        isSuccess = NO;
    }
    self.navigationController.toolbar.hidden = YES;
    // 放在最上面,否则点击事件没法触发
    [self.navigationController.navigationBar bringSubviewToFront:gestureView];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    isStop = YES;
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
                if ([CvideoTypeArray containsObject:lowerType]) {
                    // 内存警告崩溃
                    if (i % 30 == 1) {
                        model.image = [GLFTools thumbnailImageRequest:9 andVideoPath:model.path];
                    }
                    model.image = nil;
                    [resultArray addObject:model];
                }
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideAllHUD];
            _dataArray = resultArray;
            self.title = [NSString stringWithFormat:@"所有视频(%lu)", (unsigned long)resultArray.count];
            [_tableView reloadData];
        });
    });
}

- (void)prepareView {
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, kScreenWidth, kScreenHeight-64) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    _tableView.tableFooterView = [UIView new];
    
    [_tableView registerNib:[UINib nibWithNibName:@"VideoTableViewCell" bundle:nil] forCellReuseIdentifier:cellID];
        
    gestureView = [[UIView alloc] initWithFrame:CGRectMake(100, -20, kScreenWidth-200, 64)];
    gestureView.backgroundColor = [UIColor clearColor];
    [self.navigationController.navigationBar addSubview:gestureView];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] init];
    tapGesture.numberOfTapsRequired = 2;
    tapGesture.numberOfTouchesRequired = 1;
    [tapGesture addTarget:self action:@selector(setState)];
    [gestureView addGestureRecognizer:tapGesture];
}

- (void)setState {
    isSuccess = !isSuccess;
    if (isSuccess) {
        [[NSUserDefaults standardUserDefaults] setValue:@"1" forKey:@"RootShowType"];
    } else {
        [[NSUserDefaults standardUserDefaults] setValue:@"0" forKey:@"RootShowType"];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)buttonAction1 {
    isShowImage = YES;
    __block NSInteger count = 0;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        for (NSInteger i = 0; i < _dataArray.count; i++) {
            if (count > 15) {
                break;
            }
            FileModel *model = _dataArray[i];
            if (model.image == nil) {
                count++;
                model.image = [GLFTools thumbnailImageRequest:90 andVideoPath:model.path];
                [_dataArray replaceObjectAtIndex:i withObject:model];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [_tableView reloadData];
        });
    });
}

- (void)buttonAction2 {
    isShowImage = NO;
    [_tableView reloadData];
}

#pragma mark UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    FileModel *model = _dataArray[indexPath.row];
    NSArray *array = [model.name componentsSeparatedByString:@"/"];
    NSString *name = [array lastObject];
    if (isShowImage && model.image != nil && model.image.size.width > 0) {
        CGFloat width = 90 * model.image.size.width / model.image.size.height;
        if (width > kScreenWidth / 2) {
            width = kScreenWidth / 2;
        }
        NSDictionary *attrbute = @{NSFontAttributeName:[UIFont systemFontOfSize:17]};
        CGRect rect = [name boundingRectWithSize:CGSizeMake(kScreenWidth - 30 - width, MAXFLOAT)
                                        options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                     attributes:attrbute
                                        context:nil];
        if (rect.size.height + 20 > 80) {
            return rect.size.height + 20;
        } else {
            return 80;
        }
    } else {
        NSDictionary *attrbute = @{NSFontAttributeName:[UIFont systemFontOfSize:17]};
        CGRect rect = [name boundingRectWithSize:CGSizeMake(kScreenWidth - 30, MAXFLOAT)
                                        options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                     attributes:attrbute
                                        context:nil];
        return rect.size.height + 30;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FileModel *model = _dataArray[indexPath.row];
    VideoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSArray *array = [model.name componentsSeparatedByString:@"/"];
    cell.vTextLabel.text = array.lastObject;
    cell.vTextLabel.numberOfLines = 0;
    
    if (isShowImage && model.image != nil && model.image.size.width > 0) {
        cell.vImageView.image = model.image;
        CGFloat width = 90 * model.image.size.width / model.image.size.height;
        if (width > kScreenWidth / 2) {
            width = kScreenWidth / 2;
        }
        cell.imageViewWidthConstraint.constant = width;
    } else {
        cell.vImageView.image = nil;
        cell.imageViewWidthConstraint.constant = 0;
    }
    

    // 3D Touch 可用!
    if (self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable) {
        // 给Cell注册3DTouch的peek和pop功能
        [self registerForPreviewingWithDelegate:self sourceView:cell];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    FileModel *model = _dataArray[indexPath.row];
    NSString *mute = [[NSUserDefaults standardUserDefaults] valueForKey:kVoiceMute];
    NSString *min = [[NSUserDefaults standardUserDefaults] valueForKey:kVoiceMin];
    if (isSuccess && !mute.integerValue && !min.integerValue) {
        NSURL *url = [NSURL fileURLWithPath:model.path];
        UIDocumentInteractionController *documentController = [UIDocumentInteractionController interactionControllerWithURL:url];
        documentController.delegate = self;
        // 显示预览
        BOOL canOpen = [documentController presentPreviewAnimated:YES];
        if (!canOpen) {
            [self showStringHUD:@"沒有程序可以打开要分享的文件" second:2];
        }
    } else {
        // 进入详情页面
        DetailViewController3 *detailVC = [[DetailViewController3 alloc] init];
        detailVC.selectIndex = [self returnIndex:_dataArray with:model];
        detailVC.fileArray = _dataArray;
        [self.navigationController pushViewController:detailVC animated:YES];
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

#pragma mark UIViewControllerPreviewingDelegate
// peek(预览)
- (nullable UIViewController *)previewingContext:(id <UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location
{
    // 获取按压的Cell所在行,[previewingContext sourceView]就是按压的那个视图
    NSIndexPath *indexPath = [_tableView indexPathForCell:(UITableViewCell* )[previewingContext sourceView]];
    // 设定预览的界面
    FileInfoViewController *vc = [[FileInfoViewController alloc] init];
    vc.preferredContentSize = CGSizeMake(0.0f, 400.0f);
    vc.model = _dataArray[indexPath.row];
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
