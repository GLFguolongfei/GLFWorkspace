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
    self.view.backgroundColor = [UIColor blackColor];
    self.title = @"测试功能";
    [self canRecord:NO];
    [self setupEmitter];
    
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    WKWebViewController *vc = [[WKWebViewController alloc] init];
//    [self.navigationController pushViewController:vc animated:YES];
    
    MPMediaPickerController *mediaPicker = [[MPMediaPickerController alloc] initWithMediaTypes:MPMediaTypeAny];
    mediaPicker.allowsPickingMultipleItems = YES;  // 是否允许一次选择多个
    mediaPicker.prompt = @"请选择要播放的音乐";       // 提示文字
    mediaPicker.delegate = self;                   // 设置选择器代理
    [self presentViewController:mediaPicker animated:YES completion:nil];
}

#pragma mark MPMediaPickerControllerDelegate
// 选择完成
- (void)mediaPicker:(MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection {
    MPMediaItem *mediaItem = [mediaItemCollection.items firstObject]; // 第一个播放音乐
    // 注意:
    // 很多音乐信息如标题、专辑、表演者、封面、时长等信息都可以通过MPMediaItem的valueForKey:方法得到,但是从iOS7开始都有对应的属性可以直接访问
    //    NSString *title = [mediaItem valueForKey:MPMediaItemPropertyAlbumTitle];
    //    NSString *artist = [mediaItem valueForKey:MPMediaItemPropertyAlbumArtist];
    //    MPMediaItemArtwork *artwork = [mediaItem valueForKey:MPMediaItemPropertyArtwork];
    //    UIImage *image = [artwork imageWithSize:CGSizeMake(100, 100)]; // 专辑图片
    NSLog(@"标题: %@, 表演者: %@, 专辑: %@", mediaItem.title, mediaItem.artist, mediaItem.albumTitle);
}

// 取消选择
- (void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker {
//    [mediaPicker dismissViewControllerAnimated:YES completion:nil];
}


@end
