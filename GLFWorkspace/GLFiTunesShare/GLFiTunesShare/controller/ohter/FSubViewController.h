//
//  FSubViewController.h
//  GLFiTunesShare
//
//  Created by guolongfei on 2020/2/14.
//  Copyright © 2020 GuoLongfei. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FSubViewController : BaseViewController

@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, strong) FileModel *model;

- (void)playOrPauseVideo:(BOOL)isPlay;
- (void)playerForwardOrRewind:(BOOL)isForward;
- (void)playViewLandscape;

- (void)hiddenBar;
- (void)resetInfo;

@end

NS_ASSUME_NONNULL_END
