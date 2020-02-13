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
    AVPlayerLayer *playerLayer;
    BOOL isHiddenBar;
    BOOL isRotate;
    UILabel *label;
    UIProgressView *progressView;
    NSTimer *timer;
}
@end

@implementation SubViewController3


#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    [self canRecord:NO];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playeEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
            
    [self setupAVPlayer];
    [self setupAVInfo];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [timer invalidate];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (isHiddenBar) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"isHiddenNaviBar" object:self userInfo:nil];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"isHiddenNaviBar" object:self userInfo:nil];
    }
    isHiddenBar = !isHiddenBar;
    if (isHiddenBar) {
        progressView.hidden = YES;
        if (!isRotate) {
            CGRect labelRect = CGRectMake(10, 20, kScreenWidth-20, 20);
            [UIView animateWithDuration:0.25 animations:^{
                label.frame = labelRect;
            }];
        }
    } else {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            progressView.hidden = NO;
        });
        if (!isRotate) {
            CGRect labelRect = CGRectMake(10, 74, kScreenWidth-20, 20);
            [UIView animateWithDuration:0.25 animations:^{
                label.frame = labelRect;
            }];
        }
    }
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
    CGRect progressRect = CGRectMake(0, 64, kScreenWidth, 20);
    progressView = [[UIProgressView alloc] initWithFrame:progressRect];
    progressView.progressViewStyle = UIProgressViewStyleDefault;
    progressView.progressTintColor = [UIColor colorWithHexString:@"2C84E8"]; // 前景色
    progressView.trackTintColor = [UIColor clearColor]; // 背景色
    progressView.progress = 0; // 进度默认为0 - 1
    [self.view addSubview:progressView];
    
    // 时间
    CGRect labelRect = CGRectMake(10, 74, kScreenWidth-20, 20);
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
//            progressView.transform = CGAffineTransformIdentity;
//            progressView.frame = CGRectMake(0, 64, 20, kScreenWidth);
            label.transform = CGAffineTransformIdentity;
            label.frame = CGRectMake(90, 74, kScreenWidth-100, 20);
        }];
    } else {
        CATransform3D transform = CATransform3DRotate(playerLayer.transform, -M_PI_2, 0.0f, 0.0f, 1.0f);
//        CGAffineTransform transform2 = CGAffineTransformRotate(progressView.transform, M_PI_2);
        CGAffineTransform transform3 = CGAffineTransformRotate(label.transform, -M_PI_2);
        [UIView animateWithDuration:0.25 animations:^{
            playerLayer.transform = transform;
            playerLayer.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
//            progressView.transform = transform2;
//            progressView.frame = CGRectMake(0, 0, 20, kScreenHeight);
            label.transform = transform3;
            label.frame = CGRectMake(10, 30, 20, kScreenHeight - 40);
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
    NSString *currentTimeStr = [self timeFormatted:currentTime];
    NSString *durationStr = [self timeFormatted:duration];
    label.text = [NSString stringWithFormat:@"%@ / %@", currentTimeStr, durationStr];
    CGFloat index = CMTimeGetSeconds(playerItem.currentTime) / CMTimeGetSeconds(playerItem.duration);
    [progressView setProgress:index animated:YES];
}

#pragma mark Private Method
// 转换成时分秒
- (NSString *)timeFormatted:(NSInteger)totalSeconds {
    NSInteger seconds = totalSeconds % 60;
    NSInteger minutes = (totalSeconds / 60) % 60;
    NSInteger hours = totalSeconds / 3600;
    if (totalSeconds >= 3600) {
        return [NSString stringWithFormat:@"%02ld:%02ld:%02ld", (long)hours, (long)minutes, (long)seconds];
    } else if (totalSeconds >= 60) {
        return [NSString stringWithFormat:@"%02ld:%02ld", (long)minutes, (long)seconds];
    } else {
        return [NSString stringWithFormat:@"%02ld", (long)seconds];
    }
}


@end
