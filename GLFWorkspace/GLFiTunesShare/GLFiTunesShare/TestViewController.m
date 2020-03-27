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

@end

@implementation TestViewController


#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self setVCTitle:@"测试功能"];
    
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self selectMedia];
//    [self presentDocumentPicker];
}

#pragma mark Events
- (void)webView {
    WKWebViewController *vc = [[WKWebViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)selectMedia {
    MPMediaPickerController *mediaPicker = [[MPMediaPickerController alloc] initWithMediaTypes:MPMediaTypeAny];
    mediaPicker.allowsPickingMultipleItems = YES;  // 是否允许一次选择多个
    mediaPicker.prompt = @"请选择要播放的音乐";       // 提示文字
    mediaPicker.delegate = self;                   // 设置选择器代理
    [self presentViewController:mediaPicker animated:YES completion:nil];
}

- (void)presentDocumentPicker {
    NSArray *documentTypes = @[@"public.content", @"public.text", @"public.source-code ", @"public.image", @"public.audiovisual-content", @"com.adobe.pdf", @"com.apple.keynote.key", @"com.microsoft.word.doc", @"com.microsoft.excel.xls", @"com.microsoft.powerpoint.ppt"];
    UIDocumentPickerViewController *documentPickerViewController = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:documentTypes inMode:UIDocumentPickerModeOpen];
    documentPickerViewController.delegate = self;
    [self presentViewController:documentPickerViewController animated:YES completion:nil];
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
