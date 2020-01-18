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
    BOOL isPlaying;
    BOOL isRotate;
    UILabel *label;
    UIButton *button;
    UIProgressView *avProgress;
    NSTimer *timer;
    UIView *controlBg;
}
@end

@implementation SubViewController3


#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playControl) name:@"avRadio" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidPlayToEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
            
    [self setupAVPlayer];
    [self setupAVInfo];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    isPlaying = YES;
    [self videoAction:true];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    isPlaying = YES;
    [self videoAction:true];
    [timer invalidate];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self videoAction:false];
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
    playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
    playerLayer.frame = kScreen;
    [self.view.layer addSublayer:playerLayer];
    
    // 播放按钮
    CGRect rect = CGRectMake((kScreenWidth-60)/2, (kScreenHeight-60)/2, 60, 60);
    button = [[UIButton alloc] initWithFrame:rect];
    [button setImage:[UIImage imageNamed:@"播放"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(videoAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

- (void)setupAVInfo {
    // 进度条
    CGRect progressRect = CGRectMake(0, 0, kScreenWidth, 20);
    avProgress = [[UIProgressView alloc] initWithFrame:progressRect];
    avProgress.progressViewStyle = UIProgressViewStyleDefault;
    avProgress.progressTintColor = [UIColor blueColor]; // 前景色
    avProgress.trackTintColor = [UIColor lightGrayColor]; // 背景色
    avProgress.progress = 0; // 进度默认为0 - 1
    avProgress.backgroundColor = [UIColor cyanColor];
    [self.view addSubview:avProgress];
    
    // 时间
    label = [[UILabel alloc] initWithFrame:CGRectMake(90, 20, kScreenWidth-100, 20)];
    label.textAlignment = NSTextAlignmentRight;
    label.textColor = [UIColor blueColor];
    label.font = KFontSize(16);
    label.text = @"00/00";
    [self.view addSubview:label];

    // 定时器
    timer = [NSTimer timerWithTimeInterval:0.1 target:self selector:@selector(show) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    
    controlBg = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenHeight-100, kScreenWidth, 120)];
    [self.view addSubview:controlBg];
    [self playControl];
    for (NSInteger i = 0; i < 3; i++) {
        CGRect rect = CGRectMake(0 + kScreenWidth / 3 * i, 0, kScreenWidth / 3, 120);
        UIButton *button = [[UIButton alloc] initWithFrame:rect];
        button.tag = i;
        if (i == 0) {
            [button setTitle:@"横屏" forState:UIControlStateNormal];
        } else if (i == 1) {
            [button setTitle:@"快退" forState:UIControlStateNormal];
        } else {
            [button setTitle:@"快进" forState:UIControlStateNormal];
        }
        [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [button setTitleEdgeInsets:UIEdgeInsetsMake(20, 0, 0, 0)];
        [button setBackgroundColor:[UIColor clearColor]];
        [button addTarget:self action:@selector(playerItemPlay:) forControlEvents:UIControlEventTouchUpInside];
        [controlBg addSubview:button];
    }
}

#pragma mark Events
- (void)videoAction: (BOOL)isNotNotification  {
    if (isPlaying) {
        [button setImage:[UIImage imageNamed:@"播放"] forState:UIControlStateNormal];
        button.hidden = NO;
        isPlaying = NO;
        [player pause];
        if (!isNotNotification) {
            NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:@"noHidden",@"key", nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"isHiddenNaviBar" object:self userInfo:dic];
        }
    } else {
        [button setImage:[UIImage imageNamed:@"暂停"] forState:UIControlStateNormal];
        button.hidden = YES;
        isPlaying = YES;
        [player play];
        if (!isNotNotification) {
            NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:@"hidden",@"key", nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"isHiddenNaviBar" object:self userInfo:dic];
        }
    }
}

- (void)show {
    NSInteger currentTime = (NSInteger)CMTimeGetSeconds(playerItem.currentTime);
    NSInteger duration = (NSInteger)CMTimeGetSeconds(playerItem.duration);
    NSString *currentTimeStr = [self timeFormatted:currentTime];
    NSString *durationStr = [self timeFormatted:duration];
    label.text = [NSString stringWithFormat:@"%@ / %@", currentTimeStr, durationStr];
    CGFloat index = CMTimeGetSeconds(playerItem.currentTime) / CMTimeGetSeconds(playerItem.duration);
    [avProgress setProgress:index animated:YES];
}

- (void)playerItemPlay:(UIButton *)button {
    if (button.tag == 0) { // 视频横竖屏
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
    } else { // 快进快退
        NSInteger currentTime = (NSInteger)CMTimeGetSeconds(playerItem.currentTime);
        NSInteger duration = (NSInteger)CMTimeGetSeconds(playerItem.duration);
        NSInteger interval = 10;
        // 根据总时长,设置每次快进和后退的时间间隔
        if (duration < 60) {
            interval = duration / 20;
        } else if (duration < 300) {
            interval = duration / 30;
        }  else if (interval > 600) {
            interval = duration / 60;
        }
        if (interval < 3) {
            interval = 3;
        } else if (interval > 300) {
            interval = 300;
        }
        NSInteger time = 0;
        if (button.tag == 1) {
            time = currentTime - interval;
        } else if (button.tag == 2) {
            time = currentTime + interval;
        }
        if (time > duration) {
            time = duration;
        } else if (time < 0) {
            time = 0;
        }
        CMTime dragedCMTime = CMTimeMake(time, 1);
        [player seekToTime:dragedCMTime];
    }
}

- (void)playerItemDidPlayToEnd:(NSNotification *)notification{
    isPlaying = YES;
    [self videoAction:false];
    // 重新播放
    CMTime dragedCMTime = CMTimeMake(0, 1);
    [player seekToTime:dragedCMTime];
}

- (void)playControl {
    NSString *isHidden = [[NSUserDefaults standardUserDefaults] objectForKey:@"controlBar"];
    if ([isHidden isEqualToString:@"1"]) {
        controlBg.hidden = YES;
    } else {
        controlBg.hidden = NO;
    }
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
