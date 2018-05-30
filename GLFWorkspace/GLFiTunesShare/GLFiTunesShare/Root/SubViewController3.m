//
//  SubViewController3.m
//  GLFiTunesShare
//
//  Created by guolongfei on 2018/5/30.
//  Copyright © 2018年 GuoLongfei. All rights reserved.
//

#import "SubViewController3.h"
#import <AVFoundation/AVFoundation.h>

@interface SubViewController3 ()
{
    AVPlayer *player;
    BOOL isPlaying;
}
@end

@implementation SubViewController3


#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self setupAVPlayer];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    isPlaying = NO;
    [player pause];
}

- (void)setupAVPlayer {
    // 1-获取URL(远程/本地)
    NSURL *url = [NSURL fileURLWithPath:self.model.path];
    // 2-创建AVPlayerItem
    AVPlayerItem *item = [AVPlayerItem playerItemWithURL:url];
    // 3-创建AVPlayer
    player = [AVPlayer playerWithPlayerItem:item];
    // 4-添加AVPlayerLayer
    AVPlayerLayer *layer = [AVPlayerLayer playerLayerWithPlayer:player];
    layer.frame = CGRectMake(10, 80, kScreenWidth-20, kScreenHeight-100);
    [self.view.layer addSublayer:layer];
    isPlaying = YES;
    [player play];
    
    // 点按手势
    UIView *view = [[UIView alloc] initWithFrame:layer.frame];
    //    view.backgroundColor = [UIColor clearColor];
    view.backgroundColor = [UIColor redColor];
    view.alpha = 0.3;
    [self.view addSubview:view];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] init];
    [tapGesture addTarget:self action:@selector(tapAction:)];
    [view addGestureRecognizer:tapGesture];
}

- (void)tapAction:(UITapGestureRecognizer *)gesture {
    if (isPlaying) {
        isPlaying = NO;
        [player pause];
    } else {
        isPlaying = YES;
        [player play];
    }
}


@end
