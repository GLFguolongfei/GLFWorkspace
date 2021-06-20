//
//  DYNextViewController.h
//  GLFiTunesShare
//
//  Created by guolongfei on 2020/3/15.
//  Copyright © 2020 GuoLongfei. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DYNextViewController : BaseViewController

@property (nonatomic, assign) NSInteger pageType; // 1-收藏夹(喜欢) 2-垃圾篓(待删除)

- (void)playRandom:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END
