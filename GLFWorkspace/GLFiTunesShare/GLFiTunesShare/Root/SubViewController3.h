//
//  SubViewController3.h
//  GLFiTunesShare
//
//  Created by guolongfei on 2018/5/30.
//  Copyright © 2018年 GuoLongfei. All rights reserved.
//

#import <UIKit/UIKit.h>

// --- 内容子页(视频)
@interface SubViewController3 : BaseViewController

@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, strong) FileModel *model;

@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerItem *playerItem;

- (void)playOrPauseVideo:(BOOL)isPlay;
- (void)playerForwardOrRewind:(BOOL)isForward;
- (void)playViewLandscape;
- (void)showBar;

- (void)playTime:(NSInteger)time;
- (void)playRate:(CGFloat)rate;

@end
