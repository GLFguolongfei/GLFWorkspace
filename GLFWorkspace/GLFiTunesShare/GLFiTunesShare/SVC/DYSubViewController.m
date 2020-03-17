//
//  DYSubViewController.m
//  GLFiTunesShare
//
//  Created by guolongfei on 2020/2/18.
//  Copyright © 2020 GuoLongfei. All rights reserved.
//

#import "DYSubViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface DYSubViewController ()
{
    AVPlayer *player;
    AVPlayerItem *playerItem;
    AVPlayerLayer *playerLayer;
    BOOL isHiddenBar;
    BOOL isRotate;
    UILabel *label;
    UIProgressView *progressView;
    NSTimer *timer;
}
@end

@implementation DYSubViewController


#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playeEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
                
    [self setupAVPlayer];
    [self setupAVInfo];
    
    UITapGestureRecognizer *tapGesture1 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hiddenNaviBar)];
    tapGesture1.numberOfTapsRequired = 1;    // 设置点按次数,默认为1,注意在iOS中很少用双击操作
    tapGesture1.numberOfTouchesRequired = 1; // 点按的手指数
    [self.view addGestureRecognizer:tapGesture1];
    
    UITapGestureRecognizer *tapGesture2 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(favoriteAction)];
    tapGesture2.numberOfTapsRequired = 2;    // 设置点按次数,默认为1,注意在iOS中很少用双击操作
    tapGesture2.numberOfTouchesRequired = 1; // 点按的手指数
    [self.view addGestureRecognizer:tapGesture2];
    
    // 指定一个手势需要另一个手势执行失败才会执行
    [tapGesture1 requireGestureRecognizerToFail:tapGesture2];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [timer invalidate];
    [player pause];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)hiddenNaviBar {
    if (isHiddenBar) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"isHiddenNaviBar" object:self userInfo:nil];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"isHiddenNaviBar" object:self userInfo:nil];
    }
    isHiddenBar = !isHiddenBar;
}

- (void)favoriteAction {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"favoriteClick" object:self userInfo:nil];
}

#pragma mark Setup
- (void)setupAVPlayer {
    // 1-获取URL(远程/本地)
    NSURL *url = [NSURL fileURLWithPath:self.model.path];
    // 2-创建AVPlayerItem
    playerItem = [AVPlayerItem playerItemWithURL:url];
    // 3-创建AVPlayer
    player = [AVPlayer playerWithPlayerItem:playerItem];
    NSString *mute = [[NSUserDefaults standardUserDefaults] valueForKey:kVoiceMute];
    if (mute.integerValue) {
        player.volume = 0.0; // 控制音量
    } else {
        NSString *min = [[NSUserDefaults standardUserDefaults] valueForKey:kVoiceMin];
        if (min.integerValue) {
            player.volume = 0.01; // 控制音量
        }
    }
    // 4-添加AVPlayerLayer
    playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
    playerLayer.frame = kScreen;
    [self.view.layer addSublayer:playerLayer];
}

- (void)setupAVInfo {
    // 进度条
    CGRect progressRect = CGRectMake(0, 0, kScreenWidth, 20);
    progressView = [[UIProgressView alloc] initWithFrame:progressRect];
    progressView.progressViewStyle = UIProgressViewStyleDefault;
    progressView.progressTintColor = [UIColor colorWithHexString:@"2C84E8"]; // 前景色
    progressView.trackTintColor = [UIColor clearColor]; // 背景色
    progressView.progress = 0; // 进度默认为0 - 1
    [self.view addSubview:progressView];
    
    // 时间
    CGRect labelRect = CGRectMake(10, 20, kScreenWidth-20, 20);
    label = [[UILabel alloc] initWithFrame:labelRect];
    label.textAlignment = NSTextAlignmentRight;
    label.textColor = [UIColor colorWithHexString:@"2C84E8"];
    label.font = KFontSize(16);
    label.text = @"00 / 00";
    [self.view addSubview:label];
}

#pragma mark Events
// 视频播放暂停
- (void)playOrPauseVideo: (BOOL)isPlay  {
    if (isPlay) {
        [player play];
        // 定时器
        timer = [NSTimer timerWithTimeInterval:0.1 target:self selector:@selector(showTimer) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    } else {
        [player pause];
    }
}

// 视频快进快退
- (void)playerForwardOrRewind:(BOOL)isForward {
    NSInteger currentTime = (NSInteger)CMTimeGetSeconds(playerItem.currentTime);
    NSInteger duration = (NSInteger)CMTimeGetSeconds(playerItem.duration);
    NSInteger interval = 10;
    // 根据总时长,设置每次快进和后退的时间间隔
    if (duration < 60) {
        interval = duration / 20;
    } else if (duration < 300) {
        interval = duration / 30;
    } else {
        interval = duration / 60;
    }
    if (interval < 5) {
        interval = 5;
    } else if (interval > 300) {
        interval = 300;
    }
    NSInteger time = 0;
    if (isForward) {
        time = currentTime + interval;
    } else {
        time = currentTime - interval;
    }
    if (time > duration) {
        time = duration;
    } else if (time < 0) {
        time = 0;
    }
    CMTime dragedCMTime = CMTimeMake(time, 1);
    [player seekToTime:dragedCMTime];
}

// 视频横竖屏
- (void)playViewLandscape {
    if (isRotate) {
        [UIView animateWithDuration:0.25 animations:^{
            playerLayer.transform = CATransform3DIdentity;
            playerLayer.frame = kScreen;
        }];
    } else {
        CATransform3D transform = CATransform3DRotate(playerLayer.transform, -M_PI_2, 0.0f, 0.0f, 1.0f);
        [UIView animateWithDuration:0.25 animations:^{
            playerLayer.transform = transform;
            playerLayer.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
        }];
    }
    isRotate = !isRotate;
}

- (void)playeEnd:(NSNotification *)notification {
    CMTime dragedCMTime = CMTimeMake(0, 1);
    [player seekToTime:dragedCMTime];
}

- (void)showTimer {
    NSInteger currentTime = (NSInteger)CMTimeGetSeconds(playerItem.currentTime);
    NSInteger duration = (NSInteger)CMTimeGetSeconds(playerItem.duration);
    NSString *currentTimeStr = [GLFTools timeFormatted:currentTime];
    NSString *durationStr = [GLFTools timeFormatted:duration];
    label.text = [NSString stringWithFormat:@"%@ / %@", currentTimeStr, durationStr];
    CGFloat index = CMTimeGetSeconds(playerItem.currentTime) / CMTimeGetSeconds(playerItem.duration);
    [progressView setProgress:index animated:YES];
}


@end
