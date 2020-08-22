//
//  DetailViewController3.h
//  GLFiTunesShare
//
//  Created by guolongfei on 2018/5/30.
//  Copyright © 2018年 GuoLongfei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SubViewController3.h"

// --- 内容页(视频)
@interface DetailViewController3 : BaseViewController

@property (nonatomic, assign) NSInteger selectIndex;
@property (nonatomic, strong) NSArray *fileArray;

@property (nonatomic, assign) BOOL isPlay;

@property (nonatomic, assign) SubViewController3 *currentVC; // 当前显示的VC

- (void)playTime:(NSInteger)time;
- (void)playRate:(CGFloat)rate;

@end
