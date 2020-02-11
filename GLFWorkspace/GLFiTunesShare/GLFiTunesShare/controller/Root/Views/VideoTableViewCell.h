//
//  VideoTableViewCell.h
//  GLFiTunesShare
//
//  Created by guolongfei on 2020/2/11.
//  Copyright © 2020 GuoLongfei. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface VideoTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *vImageView;
@property (weak, nonatomic) IBOutlet UILabel *vTextLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageViewWidthConstraint;

@end

NS_ASSUME_NONNULL_END
