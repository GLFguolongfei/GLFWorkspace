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
    AVPlayerItem *playerItem;

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
    self.view.backgroundColor = [UIColor blackColor];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemPlay:) name:@"avRadio" object:nil];
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

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self videoAction];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark Setup
- (void)setupAVPlayer {
    // 1-获取URL(远程/本地)
    NSURL *url = [NSURL fileURLWithPath:self.model.path];
    // 2-创建AVPlayerItem
    playerItem = [AVPlayerItem playerItemWithURL:url];
    // 3-创建AVPlayer
    player = [AVPlayer playerWithPlayerItem:playerItem];
    NSString *VoiceMute = [[NSUserDefaults standardUserDefaults] valueForKey:kVoiceMute];
    if (VoiceMute.integerValue) {
        player.volume = 0.0; // 控制音量
    }
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
    timer = [NSTimer timerWithTimeInterval:0.1 target:self selector:@selector(show) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

#pragma mark Events
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
    NSInteger currentTime = (NSInteger)CMTimeGetSeconds(playerItem.currentTime);
    NSInteger duration = (NSInteger)CMTimeGetSeconds(playerItem.duration);
    label.text = [NSString stringWithFormat:@"%ld/%ld", currentTime, duration];
    CGFloat index = CMTimeGetSeconds(playerItem.currentTime) / CMTimeGetSeconds(playerItem.duration);
    [avProgress setProgress:index animated:YES];
}

- (void)playerItemDidPlayToEnd:(NSNotification *)notification{
    isPlaying = YES;
    [self videoAction];
    // 重新播放
    CMTime dragedCMTime = CMTimeMake(0, 1);
    [player seekToTime:dragedCMTime];
}

- (void)playerItemPlay:(NSNotification *)notification {
    NSInteger currentTime = (NSInteger)CMTimeGetSeconds(playerItem.currentTime);
    NSInteger duration = (NSInteger)CMTimeGetSeconds(playerItem.duration);
    NSInteger interval = duration / 30;
    // 根据总时长,设置每次快进和后退的时间间隔
    if (interval < 10) {
        interval = 10;
    } else if (interval > 180) {
        interval = 180;
    }
    
    NSDictionary *dict = notification.userInfo;
    NSString *str = dict[@"key"];
    if ([str isEqualToString:@"avForward"]) {
        CMTime dragedCMTime = CMTimeMake(currentTime + interval, 1);
        [player seekToTime:dragedCMTime];
    } else if ([str isEqualToString:@"avBackward"]) {
        CMTime dragedCMTime = CMTimeMake(currentTime - interval, 1);
        [player seekToTime:dragedCMTime];
    }
}


@end
