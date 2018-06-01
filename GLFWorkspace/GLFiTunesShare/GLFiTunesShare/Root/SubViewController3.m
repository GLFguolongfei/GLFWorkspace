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
    AVPlayerItem *item;
    AVPlayer *player;
    BOOL isPlaying;
    UILabel *label;
    UIButton *button;
    UIProgressView *avProgress;
    NSTimer *timer;
}
@end

@implementation SubViewController3


#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidPlayToEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    
    [self setupAVPlayer];
    [self setupAVInfo];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    isPlaying = YES;
    [self videoAction];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    isPlaying = YES;
    [self videoAction];
    [timer invalidate];
}

- (void)setupAVPlayer {
    // 1-获取URL(远程/本地)
    NSURL *url = [NSURL fileURLWithPath:self.model.path];
    // 2-创建AVPlayerItem
    item = [AVPlayerItem playerItemWithURL:url];
    // 3-创建AVPlayer
    player = [AVPlayer playerWithPlayerItem:item];
    // 4-添加AVPlayerLayer
    AVPlayerLayer *layer = [AVPlayerLayer playerLayerWithPlayer:player];
    layer.frame = CGRectMake(0, 65, kScreenWidth, kScreenHeight-65);
    [self.view.layer addSublayer:layer];
    
    // 播放按钮
    button = [[UIButton alloc] initWithFrame:layer.frame];
    [button setImage:[UIImage imageNamed:@"播放"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(videoAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

- (void)setupAVInfo {
    // 进度条
    CGRect progressRect = CGRectMake(0, 64, kScreenWidth, 20);
    avProgress = [[UIProgressView alloc] initWithFrame:progressRect];
    avProgress.progressViewStyle = UIProgressViewStyleDefault;
    avProgress.progressTintColor = [UIColor blueColor]; // 前景色
    avProgress.trackTintColor = [UIColor lightGrayColor]; // 背景色
    avProgress.progress = 0; // 进度默认为0 - 1
    avProgress.backgroundColor = [UIColor cyanColor];
    [self.view addSubview:avProgress];
    
    // 时间
    label = [[UILabel alloc] initWithFrame:CGRectMake(80, 64, kScreenWidth-100, 40)];
    label.textAlignment = NSTextAlignmentRight;
    label.textColor = [UIColor blueColor];
    label.font = KFontSize(16);
    label.text = @"00/00";
    [self.view addSubview:label];

    // 定时器
    timer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(show) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self videoAction];
}

- (void)videoAction  {
    if (isPlaying) {
        [button setImage:[UIImage imageNamed:@"播放"] forState:UIControlStateNormal];
        button.hidden = NO;
        isPlaying = NO;
        [player pause];
    } else {
        [button setImage:[UIImage imageNamed:@"暂停"] forState:UIControlStateNormal];
        button.hidden = YES;
        isPlaying = YES;
        [player play];
    }
}

- (void)show {
    NSInteger currentTime = (NSInteger)CMTimeGetSeconds(item.currentTime);
    NSInteger duration = (NSInteger)CMTimeGetSeconds(item.duration);
    label.text = [NSString stringWithFormat:@"%ld/%ld", currentTime, duration];
    CGFloat index = CMTimeGetSeconds(item.currentTime) / CMTimeGetSeconds(item.duration);
    [avProgress setProgress:index animated:NO];
}

- (void)playerItemDidPlayToEnd:(NSNotification *)notification{
    isPlaying = YES;
    [self videoAction];
    // 重新播放
    CMTime dragedCMTime = CMTimeMake(0, 1);
    [player seekToTime:dragedCMTime];
}


@end
