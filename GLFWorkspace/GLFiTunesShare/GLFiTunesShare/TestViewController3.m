//
//  TestViewController3.m
//  GLFiTunesShare
//
//  Created by guolongfei on 2021/4/11.
//  Copyright © 2021 GuoLongfei. All rights reserved.
//

#import "TestViewController3.h"
#import <AVFoundation/AVFoundation.h>

@interface TestViewController3 ()
{
    AVPlayer *player;
    BOOL isPlaying;
}
@end

@implementation TestViewController3


#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];

    [self setupAVPlayer];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (isPlaying) {
        [player pause];
    } else {
        [player play];
    }
    isPlaying = !isPlaying;
}

- (void)setupAVPlayer {
    // 1-获取URL(远程/本地)
//    NSURL *url = [[NSBundle mainBundle] URLForResource:@"暗恋.mp4" withExtension:nil];
    NSURL *url = [NSURL URLWithString:@"http://txmov2.a.yximgs.com/upic/2019/10/05/19/BMjAxOTEwMDUxOTQ2MjdfMTA2MTkxMTc3NV8xODIzNjc3NjA2N18xXzM=_b_Bd586faaf328ffe141a4e5abfe5bcd6a0.mp4"];
    // 2-创建AVPlayerItem
    AVPlayerItem *item = [AVPlayerItem playerItemWithURL:url];
    // 3-创建AVPlayer
    player = [AVPlayer playerWithPlayerItem:item];
    // 4-添加AVPlayerLayer
    AVPlayerLayer *layer = [AVPlayerLayer playerLayerWithPlayer:player];
    layer.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
    [self.view.layer addSublayer:layer];
}


@end
