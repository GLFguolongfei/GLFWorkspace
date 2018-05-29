//
//  SubViewController2.m
//  GLFiTunesShare
//
//  Created by guolongfei on 2018/5/30.
//  Copyright © 2018年 GuoLongfei. All rights reserved.
//

#import "SubViewController2.h"
#import <AVFoundation/AVFoundation.h>

@interface SubViewController2 ()
{
    AVPlayer *player;
    BOOL isPlaying;
}
@end

@implementation SubViewController2


#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    if (self.titleBlock) {
        self.titleBlock(self.model.name);
    }
    [self setupAVPlayer];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (player) {
        isPlaying = YES;
        [player play];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
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
    layer.frame = CGRectMake(10, 80, kScreenWidth-20, 400);
    [self.view.layer addSublayer:layer];
    isPlaying = YES;
    [player play];
    
    // 点按手势
    UIView *view = [[UIView alloc] initWithFrame:layer.frame];
    view.backgroundColor = [UIColor redColor];
    view.alpha = 0.3;
    [self.view addSubview:view];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] init];
    [tapGesture addTarget:self action:@selector(tapAction:)];
    [view addGestureRecognizer:tapGesture];
}

- (void)tapAction:(UITapGestureRecognizer *)gesture {
    if (isPlaying) {
        [player pause];
    } else {
        [player play];
    }
    isPlaying = !isPlaying;
}


@end
