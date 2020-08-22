//
//  VideoToolView.m
//  GLFiTunesShare
//
//  Created by guolongfei on 2020/8/22.
//  Copyright © 2020 GuoLongfei. All rights reserved.
//

#import "VideoToolView.h"
#import "DetailViewController3.h"
#import "SubViewController3.h"

@interface VideoToolView ()
{
    UISlider *slider1;
    NSTimer *timer;
    DetailViewController3 *vc;
    SubViewController3 *subVC;
    BOOL isSlidering;
}
@end

@implementation VideoToolView


#pragma mark - Life Cycle
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    self.backgroundColor = [UIColor clearColor];
    self.layer.cornerRadius = 10;
    self.layer.masksToBounds = YES;
    
    vc = (DetailViewController3 *)self.parentVC;
    subVC = (SubViewController3 *)vc.currentVC;
    NSInteger currentTime = (NSInteger)CMTimeGetSeconds(subVC.playerItem.currentTime);
    NSInteger duration = (NSInteger)CMTimeGetSeconds(subVC.playerItem.duration);
    
    CGRect labelFrame1 = CGRectMake(15, 30, self.frame.size.width - 30, 20);
    UILabel *label1 = [[UILabel alloc] initWithFrame:labelFrame1];
    label1.text = @"播放进度";
    label1.textColor = [UIColor whiteColor];
    [self addSubview:label1];

    CGRect sliderFrame1 = CGRectMake(15, 70, self.frame.size.width - 30, 20);
    slider1 = [[UISlider alloc] initWithFrame:sliderFrame1];
    slider1.minimumValue = 0;
    slider1.maximumValue = duration;
    slider1.value = currentTime;
    [self addSubview:slider1];
    [slider1 addTarget:self action:@selector(sliderChange1:) forControlEvents:UIControlEventValueChanged];

    CGRect labelFrame2 = CGRectMake(15, 120, self.frame.size.width - 30, 20);
    UILabel *label2 = [[UILabel alloc] initWithFrame:labelFrame2];
    label2.text = @"播放倍率";
    label2.textColor = [UIColor whiteColor];
    [self addSubview:label2];

    CGRect sliderFrame2 = CGRectMake(15, 160, self.frame.size.width - 30, 20);
    UISlider *slider2 = [[UISlider alloc] initWithFrame:sliderFrame2];
    slider2.value = 1;
    slider2.minimumValue = 0.2;
    slider2.maximumValue = 2.5;
    [self addSubview:slider2];
    slider2.continuous = NO; // 连续滑动是否触发方法,默认值为YES
    [slider2 addTarget:self action:@selector(sliderChange2:) forControlEvents:UIControlEventValueChanged];
    
    timer = [NSTimer timerWithTimeInterval:0.1 target:self selector:@selector(showTimer) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

#pragma mark Events
- (void)showTimer {
    NSInteger currentTime = (NSInteger)CMTimeGetSeconds(subVC.playerItem.currentTime);
    if (!isSlidering) {
        [slider1 setValue:currentTime animated:YES];
    }
}

- (void)stopSlider {
    isSlidering = NO;
}

- (void)sliderChange1:(id)sender {
    UISlider *slider = (UISlider *)sender;
    NSLog(@"%f", slider.value);
    [vc playTime:slider.value];
    isSlidering = YES;
    [NSTimer timerWithTimeInterval:0.5 target:self selector:@selector(stopSlider) userInfo:nil repeats:NO];
}

- (void)sliderChange2:(id)sender {
    UISlider *slider = (UISlider *)sender;
    NSLog(@"%f", slider.value);
    [vc playRate:slider.value];
}


@end
