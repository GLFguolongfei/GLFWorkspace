//
//  PlayVideoTableViewCell.h
//  GLFiTunesShare
//
//  Created by guolongfei on 2020/3/14.
//  Copyright © 2020 GuoLongfei. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PlayVideoTableViewCell : UITableViewCell

@property (nonatomic, assign) FileModel *model;
@property (nonatomic, assign) NSIndexPath *indexPath;

- (void)playOrPauseVideo: (BOOL)isPlay;

@end

NS_ASSUME_NONNULL_END
