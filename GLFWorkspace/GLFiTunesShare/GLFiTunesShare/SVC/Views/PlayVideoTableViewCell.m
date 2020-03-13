//
//  PlayVideoTableViewCell.m
//  GLFiTunesShare
//
//  Created by guolongfei on 2020/3/14.
//  Copyright © 2020 GuoLongfei. All rights reserved.
//

#import "PlayVideoTableViewCell.h"
#import <AVFoundation/AVFoundation.h>

@interface PlayVideoTableViewCell ()
{
    AVPlayer *player;
    AVPlayerItem *playerItem;
    AVPlayerLayer *playerLayer;
}
@end

@implementation PlayVideoTableViewCell


#pragma mark - Life Cycle
- (void)awakeFromNib {
    [super awakeFromNib];
    self.contentView.backgroundColor = [UIColor blackColor];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playeEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];            
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

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
    player.volume = 0.0; // 控制音量
    // 4-添加AVPlayerLayer
    playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
    
    CGSize size = [GLFTools videoSizeWithPath:self.model.path];
    CGFloat width = 100.0 * size.width / size.height;
    playerLayer.frame = CGRectMake(10, 0, width, 100);
    [self.contentView.layer addSublayer:playerLayer];
}

- (void)setModel:(FileModel *)model {
    _model = model;
    if (playerLayer) {
        [playerLayer removeFromSuperlayer];
    }
    [self setupAVPlayer];
}

#pragma mark Events
// 视频播放暂停
- (void)playOrPauseVideo: (BOOL)isPlay  {
    if (isPlay) {
        [player play];
    } else {
        [player pause];
    }
}

// 播放完成
- (void)playeEnd:(NSNotification *)notification {
    CMTime dragedCMTime = CMTimeMake(0, 1);
    [player seekToTime:dragedCMTime];
}


@end
