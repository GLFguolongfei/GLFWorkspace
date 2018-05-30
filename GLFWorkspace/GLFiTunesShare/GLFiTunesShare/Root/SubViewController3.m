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
    UIButton *button;
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
    if (player) {
        [player play];
    } else {
        [self setupAVPlayer];
    }
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
    layer.frame = CGRectMake(10, 75, kScreenWidth-20, kScreenHeight-120);
    [self.view.layer addSublayer:layer];
    
    button = [[UIButton alloc] initWithFrame:layer.frame];
    [button setImage:[UIImage imageNamed:@"播放"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(videoAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
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
    [self videoAction];
}

- (void)videoAction {
    if (isPlaying) {
        [button setImage:[UIImage imageNamed:@"暂停"] forState:UIControlStateNormal];
        isPlaying = NO;
        [player pause];
        button.hidden = NO;
    } else {
        [button setImage:[UIImage imageNamed:@"播放"] forState:UIControlStateNormal];
        isPlaying = YES;
        [player play];
        button.hidden = YES;
    }
}


@end
