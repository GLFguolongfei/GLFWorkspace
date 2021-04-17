//
//  TestViewController.m
//  GLFiTunesShare
//
//  Created by guolongfei on 2020/1/31.
//  Copyright © 2020 GuoLongfei. All rights reserved.
//

#import "TestViewController.h"
#import "WKWebViewController.h"
#import <MediaPlayer/MediaPlayer.h>

@interface TestViewController ()<MPMediaPickerControllerDelegate>

@end

@implementation TestViewController


#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self setVCTitle:@"测试功能"];
    
    for (NSInteger i = 0; i < 4; i++) {
        CGRect frame = CGRectMake(100, 100 + 80 * i, kScreenWidth - 200, 60);
        UIButton *button = [[UIButton alloc] initWithFrame:frame];
        if (i == 0) {
            [button setTitle:@"网络爬虫-测试" forState:UIControlStateNormal];
        } else if (i == 1) {
            [button setTitle:@"网络爬虫-获取" forState:UIControlStateNormal];
        } else if (i == 2) {
            [button setTitle:@"网络爬虫-补救" forState:UIControlStateNormal];
        } else {
            [button setTitle:@"其它测试" forState:UIControlStateNormal];
        }
        [button setBackgroundColor:[UIColor lightGrayColor]];
        button.tag = 100 + i;
        [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        button.layer.cornerRadius = 5;
        button.layer.masksToBounds = YES;
        [self.view addSubview:button];
    }
}

- (void)buttonAction:(UIButton *)button {
    if (button.tag == 100) {
        ProjectManager *manager = [ProjectManager sharedProjectManager];
        [manager getNetworkDataTest:@"https://www.1cbf673a5837e7b0.com/shipin/106890.html"];
    } else if (button.tag == 101) {
        ProjectManager *manager = [ProjectManager sharedProjectManager];
        [manager getNetworkData:2];
    } else if (button.tag == 102) {
        ProjectManager *manager = [ProjectManager sharedProjectManager];
        [manager getNetworkDataRepeat];
    } else {
        //    [self testWebView];
            [self testMediaPicker];
        //    [self testArchiverData];

        //    WKWebViewController *vc = [[WKWebViewController alloc] init];
        //    [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark Events
- (void)testWebView {
    WKWebViewController *vc = [[WKWebViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)testMediaPicker {
    MPMediaPickerController *mediaPicker = [[MPMediaPickerController alloc] initWithMediaTypes:MPMediaTypeAny];
    mediaPicker.allowsPickingMultipleItems = YES;  // 是否允许一次选择多个
    mediaPicker.prompt = @"请选择要播放的音乐";       // 提示文字
    mediaPicker.delegate = self;                   // 设置选择器代理
    [self presentViewController:mediaPicker animated:YES completion:nil];
}

- (void)testArchiverData {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    NSString *archiverPath = [path stringByAppendingPathComponent:@"course.plist"];

    NSMutableArray *mutableArray = [[NSMutableArray alloc] init];
    FileModel *model = [[FileModel alloc] init];
    model.name = @"郭龙飞";
    model.path = @"/path/fjls";
    model.attributes = @{@"key": @"value"};
    model.type = 2;
    model.size = 300;
    model.videoSize = CGSizeMake(100, 200);
    model.count = 10;
    [mutableArray addObject:model];
    
    if ([NSKeyedArchiver archiveRootObject:mutableArray toFile:archiverPath]) {
        NSLog(@"archiver success");
        NSArray *arr = [NSKeyedUnarchiver unarchiveObjectWithFile:archiverPath];
        NSLog(@"%@", arr);
    } else {
        NSLog(@"archiver error");
    }
}

#pragma mark MPMediaPickerControllerDelegate
// 选择完成
- (void)mediaPicker:(MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection {
    MPMediaItem *mediaItem = [mediaItemCollection.items firstObject];
    NSLog(@"标题: %@, 表演者: %@, 专辑: %@", mediaItem.title, mediaItem.artist, mediaItem.albumTitle);
}

// 取消选择
- (void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker {
    [mediaPicker dismissViewControllerAnimated:YES completion:nil];
}


@end
