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
    UISlider *avSlider;
    NSTimer *timer;
}
@end

@implementation SubViewController3


#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    // 进度条和时间没有加上,因为它们有些小瑕疵
    // 但是可以用的
    
    [self setupAVPlayer];
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
    layer.frame = CGRectMake(10, 80, kScreenWidth-20, kScreenHeight-100);
    [self.view.layer addSublayer:layer];
    
    // 时间
//    label = [[UILabel alloc] initWithFrame:CGRectMake(0, 65, kScreenWidth, 30)];
//    label.textAlignment = NSTextAlignmentCenter;
//    [self.view addSubview:label];
    
    // 进度条
//    NSInteger duration = (NSInteger)CMTimeGetSeconds(item.duration);
//    avSlider = [[UISlider alloc] initWithFrame:CGRectMake(10, kScreenHeight-50, kScreenWidth-20, 50)];
//    avSlider.backgroundColor = [UIColor lightGrayColor];
//    avSlider.value = 0;
//    avSlider.minimumValue = 0;
//    avSlider.maximumValue = duration;
//    [self.view addSubview:avSlider];
//    avSlider.continuous = NO; // 连续滑动是否触发方法,默认值为YES
//    [avSlider addTarget:self action:@selector(avSliderAction:) forControlEvents:UIControlEventValueChanged];
    
    // 定时器
//    timer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(show) userInfo:nil repeats:YES];
//    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    
    // 播放按钮
    button = [[UIButton alloc] initWithFrame:layer.frame];
    [button setImage:[UIImage imageNamed:@"播放"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(videoAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    // 点按手势
    UIView *view = [[UIView alloc] initWithFrame:layer.frame];
    view.backgroundColor = [UIColor clearColor];
    [self.view addSubview:view];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] init];
    [tapGesture addTarget:self action:@selector(tapAction:)];
    [view addGestureRecognizer:tapGesture];
}

- (void)tapAction:(UITapGestureRecognizer *)gesture {
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

- (void)avSliderAction:(id)sender {
    UISlider *slider = (UISlider *)sender;
    // slider的value值为视频的时间
    float seconds = slider.value;
    // 让视频从指定的CMTime对象处播放
    CMTime startTime = CMTimeMakeWithSeconds(seconds, item.currentTime.timescale);
    // 让视频从指定处播放
    [player seekToTime:startTime completionHandler:^(BOOL finished) {
        if (finished) {
            isPlaying = NO;
            [self videoAction];
        }
    }];
}

- (void)show {
    NSInteger currentTime = (NSInteger)CMTimeGetSeconds(item.currentTime);
    NSInteger duration = (NSInteger)CMTimeGetSeconds(item.duration);
    label.text = [NSString stringWithFormat:@"%ld / %ld", currentTime, duration];
}


@end
