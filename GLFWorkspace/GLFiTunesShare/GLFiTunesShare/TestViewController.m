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

@interface TestViewController ()<MPMediaPickerControllerDelegate, UIDocumentPickerDelegate>
{
    UITextField *textField1;
    UITextField *textField2;
}
@end

@implementation TestViewController


#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self setVCTitle:@"测试功能"];
    
    textField1 = [[UITextField alloc] initWithFrame:CGRectMake(30, 100, kScreenWidth - 60, 50)];
    textField1.backgroundColor = [UIColor lightGrayColor];
    textField1.keyboardType = UIKeyboardTypePhonePad;
    textField1.placeholder = @"StartIndex";
    textField1.borderStyle = UITextBorderStyleRoundedRect;
    [self.view addSubview:textField1];
    
    textField2 = [[UITextField alloc] initWithFrame:CGRectMake(30, 160, kScreenWidth - 60, 50)];
    textField2.backgroundColor = [UIColor lightGrayColor];
    textField2.keyboardType = UIKeyboardTypePhonePad;
    textField2.placeholder = @"EndIndex";
    textField2.borderStyle = UITextBorderStyleRoundedRect;
    [self.view addSubview:textField2];
    
    for (NSInteger i = 0; i < 2; i++) {
        CGRect frame = CGRectMake(100, 220 + 60 * i, kScreenWidth - 200, 50);
        UIButton *button = [[UIButton alloc] initWithFrame:frame];
        if (i == 0) {
            [button setTitle:@"网络爬虫-测试" forState:UIControlStateNormal];
        } else if (i == 1) {
            [button setTitle:@"网络爬虫-获取" forState:UIControlStateNormal];
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
        [ProjectManager getNetworkDataTest];
    } else if (button.tag == 101) {
        if (textField1.text.length == 0) {
            [self showStringHUD:@"请输入开始Index" second:2];
            return;
        }
        if (textField2.text.length == 0) {
            [self showStringHUD:@"请输入结束Index" second:2];
            return;
        }
        NSLog(@"%@ %@", textField1.text, textField2.text);
        
//        [ProjectManager getNetworkData1:textField1.text.integerValue andEnd:textField2.text.integerValue];
        [ProjectManager getNetworkData2:textField1.text.integerValue andEnd:textField2.text.integerValue];
    }
    
//    [self testWebView];
//    [self testMediaPicker];
//    [self testDocumentPicker];
//    [self testArchiverData];

//    WKWebViewController *vc = [[WKWebViewController alloc] init];
//    [self.navigationController pushViewController:vc animated:YES];
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

- (void)testDocumentPicker {
    NSArray *documentTypes = @[@"public.content", @"public.text", @"public.source-code ", @"public.image", @"public.audiovisual-content", @"com.adobe.pdf", @"com.apple.keynote.key", @"com.microsoft.word.doc", @"com.microsoft.excel.xls", @"com.microsoft.powerpoint.ppt"];
    UIDocumentPickerViewController *documentPickerViewController = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:documentTypes inMode:UIDocumentPickerModeOpen];
    documentPickerViewController.delegate = self;
    [self presentViewController:documentPickerViewController animated:YES completion:nil];
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

#pragma mark UIDocumentPickerDelegate
- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray <NSURL *>*)urls {
    NSLog(@"%@", urls);
}

- (void)documentPickerWasCancelled:(UIDocumentPickerViewController *)controller {
    NSLog(@"111%@", controller);
}

- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentAtURL:(NSURL *)url {
    NSLog(@"222%@", url);
}


@end
