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
    
    UILabel *label;
    UIView *bgView;
}
@end

@implementation PlayVideoTableViewCell


#pragma mark - Life Cycle
- (void)awakeFromNib {
    [super awakeFromNib];
    self.contentView.backgroundColor = [UIColor blackColor];

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

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
    CMTime dragedCMTime = CMTimeMake(0, 1);
    #if FirstTarget
        dragedCMTime = CMTimeMake(9, 1);
    #else
        dragedCMTime = CMTimeMake(90, 1);
    #endif
    [player seekToTime:dragedCMTime];
    // 4-添加AVPlayerLayer
    playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
    CGSize size = [GLFTools videoSizeWithPath:self.model.path];
    CGFloat width = self.bounds.size.height * size.width / size.height;
    if (width > kScreenWidth - 20) {
        width = kScreenWidth - 20;
    }
    playerLayer.frame = CGRectMake(10, 0, width, self.bounds.size.height);
    playerLayer.backgroundColor = KColorCCC.CGColor;
    [self.contentView.layer addSublayer:playerLayer];
    
    bgView = [[UIView alloc] init];
    bgView.backgroundColor = [UIColor whiteColor];
    bgView.alpha = 0.5;
    bgView.hidden = YES;
    [self.contentView addSubview:bgView];
    
    CGRect rect = CGRectMake(width + 20, 0, kScreenWidth - 30 - width, self.bounds.size.height);
    label = [[UILabel alloc] initWithFrame:rect];
    label.numberOfLines = 0;
    label.textColor = kSAColorWithStr(@"555555");
    [self.contentView addSubview:label];
    
    NSArray *array = [self.model.name componentsSeparatedByString:@"/"];
    label.text = array.lastObject;
    
    NSDictionary *attrbute = @{NSFontAttributeName:[UIFont systemFontOfSize:17]};
    CGRect calculateRect = [label.text boundingRectWithSize:CGSizeMake(kScreenWidth - 30 - width, MAXFLOAT)
       options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
    attributes:attrbute
       context:nil];
    if (width >= kScreenWidth - 20) {
        calculateRect = [label.text boundingRectWithSize:CGSizeMake(kScreenWidth - 30, MAXFLOAT)
           options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
        attributes:attrbute
           context:nil];
        label.frame = CGRectMake(15, self.bounds.size.height - 5 - calculateRect.size.height, kScreenWidth - 30, calculateRect.size.height);
        label.textColor = KColorThree;
        
        bgView.hidden = NO;
        bgView.frame = CGRectMake(10, self.bounds.size.height - 10 - calculateRect.size.height, kScreenWidth - 20, calculateRect.size.height + 10);
    }
}

- (void)setModel:(FileModel *)model {
    _model = model;
    if (playerLayer) {
        [playerLayer removeFromSuperlayer];
        [bgView removeFromSuperview];
        [label removeFromSuperview];
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


@end
